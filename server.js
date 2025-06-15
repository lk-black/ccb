const express = require('express');
const cors = require('cors');
const path = require('path');
const fetch = require('node-fetch');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('.'));

// Proxy endpoint para a API Duckfy
app.post('/api/pix', async (req, res) => {
    try {
        console.log('=== REQUISIÇÃO PIX RECEBIDA ===');
        console.log('Dados completos:', JSON.stringify(req.body, null, 2));
        
        // Log específico para trackProps se presente
        if (req.body.trackProps) {
            console.log('TrackProps (UTM) detectados:', req.body.trackProps);
        }
        
        const response = await fetch('https://app.duckfyoficial.com/api/v1/gateway/pix/receive', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-public-key': 'lucasoliveiratnb0_7ssiugdms9s99nuy',
                'x-secret-key': 'b8359edl75psep1mo65ti6p93ytw4a0ih838a12gs7hbz4sxijg6hpwliwl8np1z'
            },
            body: JSON.stringify(req.body)
        });

        console.log('Status da resposta da API:', response.status);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Erro da API Duckfy:', errorText);
            return res.status(response.status).json({ 
                error: 'Erro na API', 
                details: errorText 
            });
        }

        const data = await response.json();
        console.log('=== RESPOSTA DA API DUCKFY ===');
        console.log('Dados completos:', JSON.stringify(data, null, 2));
        
        res.json(data);
    } catch (error) {
        console.error('Erro no proxy:', error);
        res.status(500).json({ 
            error: 'Erro interno do servidor', 
            message: error.message 
        });
    }
});

// Armazenamento em memória para transações e conexões
const transactionStatus = new Map(); // transactionId -> status info
const activeConnections = new Map(); // sessionId -> connection info

// Webhook endpoint da Duckfy
app.post('/webhook/duckfy', (req, res) => {
    try {
        console.log('=== WEBHOOK DUCKFY RECEBIDO ===');
        console.log('Headers:', JSON.stringify(req.headers, null, 2));
        console.log('Body completo:', JSON.stringify(req.body, null, 2));
        
        const { event: webhookEvent, transaction: webhookTransaction, trackProps } = req.body;
        
        // Log específico para trackProps
        if (trackProps) {
            console.log('🎯 TRACKPROPS RECEBIDOS NO WEBHOOK:');
            console.log(JSON.stringify(trackProps, null, 2));
        } else {
            console.log('⚠️ Nenhum trackProps encontrado no webhook');
        }
        
        if (!webhookTransaction || !webhookTransaction.id) {
            console.error('Webhook sem dados de transação válidos');
            return res.status(400).json({ error: 'Dados de transação inválidos' });
        }
        
        // Verificar se é um evento de pagamento aprovado
        const isPaid = webhookEvent === 'transaction.paid' || 
                      webhookEvent === 'TRANSACTION_PAID' ||
                      webhookTransaction.status === 'PAID' || 
                      webhookTransaction.status === 'CONFIRMED' ||
                      webhookTransaction.status === 'COMPLETED';
        
        if (isPaid) {
            console.log(`🎉 PAGAMENTO CONFIRMADO! Transação: ${webhookTransaction.id}`);
            
            // Salvar status da transação
            const paymentData = {
                transactionId: webhookTransaction.id,
                identifier: webhookTransaction.identifier,
                status: webhookTransaction.status,
                amount: webhookTransaction.amount,
                payedAt: webhookTransaction.payedAt || new Date().toISOString(),
                confirmedAt: new Date().toISOString(),
                trackProps: trackProps || null
            };
            
            transactionStatus.set(webhookTransaction.id, paymentData);
            
            // Notificar via SSE se houver conexões ativas
            let notificationsSent = 0;
            let connectionsRemoved = 0;
            
            activeConnections.forEach((connectionInfo, sessionId) => {
                try {
                    if (connectionInfo.response && !connectionInfo.response.destroyed) {
                        const sseData = {
                            type: 'payment_confirmed',
                            ...paymentData
                        };
                        connectionInfo.response.write(`data: ${JSON.stringify(sseData)}\n\n`);
                        notificationsSent++;
                        console.log(`✅ Notificação enviada para sessão: ${sessionId}`);
                    } else {
                        console.log(`🔌 Removendo conexão inativa: ${sessionId}`);
                        activeConnections.delete(sessionId);
                        connectionsRemoved++;
                    }
                } catch (error) {
                    if (error.code === 'ECONNRESET' || error.code === 'EPIPE') {
                        console.log(`🔌 Cliente ${sessionId} já desconectado (Normal)`);
                    } else {
                        console.error(`❌ Erro ao enviar notificação para ${sessionId}:`, error.message);
                    }
                    activeConnections.delete(sessionId);
                    connectionsRemoved++;
                }
            });
            
            console.log(`📡 Resumo: ${notificationsSent} notificações enviadas, ${connectionsRemoved} conexões removidas`);
            console.log(`🔌 Conexões ativas restantes: ${activeConnections.size}`);
        } else {
            console.log(`ℹ️ Status da transação ${webhookTransaction.id}: ${webhookTransaction.status}`);
            
            // Salvar status mesmo que não seja pago para tracking
            transactionStatus.set(webhookTransaction.id, {
                transactionId: webhookTransaction.id,
                status: webhookTransaction.status,
                updatedAt: new Date().toISOString(),
                trackProps: trackProps || null
            });
        }
        
        res.status(200).json({ 
            received: true, 
            processed: isPaid,
            transactionId: webhookTransaction.id,
            trackPropsReceived: !!trackProps
        });
        
    } catch (error) {
        console.error('❌ Erro no webhook:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

// Endpoint para verificar status via polling (fallback)
app.get('/api/payment-check/:transactionId', (req, res) => {
    try {
        const { transactionId } = req.params;
        const status = transactionStatus.get(transactionId);
        
        if (status) {
            console.log(`🔍 Verificação de status para ${transactionId}:`, status.status);
            res.json({
                found: true,
                ...status
            });
        } else {
            res.json({
                found: false,
                transactionId
            });
        }
    } catch (error) {
        console.error('Erro na verificação de status:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// Endpoint SSE melhorado
app.get('/api/payment-status/:sessionId', (req, res) => {
    const sessionId = req.params.sessionId;
    
    try {
        // Configurar headers SSE
        res.writeHead(200, {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Cache-Control'
        });
        
        // Enviar heartbeat inicial
        res.write(`data: ${JSON.stringify({ 
            type: 'connected', 
            sessionId,
            timestamp: Date.now()
        })}\n\n`);
        
        // Armazenar conexão com informações adicionais
        activeConnections.set(sessionId, {
            response: res,
            connectedAt: new Date().toISOString(),
            lastHeartbeat: Date.now()
        });
        
        console.log(`🔌 Nova conexão SSE: ${sessionId} (Total: ${activeConnections.size})`);
        
        // Heartbeat a cada 15 segundos
        const heartbeatInterval = setInterval(() => {
            try {
                if (res.destroyed || !activeConnections.has(sessionId)) {
                    clearInterval(heartbeatInterval);
                    activeConnections.delete(sessionId);
                    return;
                }
                
                res.write(`data: ${JSON.stringify({ 
                    type: 'heartbeat', 
                    timestamp: Date.now() 
                })}\n\n`);
                
                // Atualizar último heartbeat
                const connectionInfo = activeConnections.get(sessionId);
                if (connectionInfo) {
                    connectionInfo.lastHeartbeat = Date.now();
                }
                
            } catch (error) {
                // Erro normal quando cliente desconecta
                if (error.code === 'ECONNRESET' || error.code === 'EPIPE') {
                    console.log(`🔌 Cliente desconectou durante heartbeat: ${sessionId}`);
                } else {
                    console.error(`❌ Erro no heartbeat ${sessionId}:`, error.message);
                }
                clearInterval(heartbeatInterval);
                activeConnections.delete(sessionId);
            }
        }, 15000);
        
        // Limpeza quando cliente desconectar
        req.on('close', () => {
            clearInterval(heartbeatInterval);
            activeConnections.delete(sessionId);
            console.log(`🔌 Conexão SSE fechada normalmente: ${sessionId} (Total: ${activeConnections.size})`);
        });
        
        req.on('error', (error) => {
            // Tratamento específico para tipos de erro comuns
            if (error.code === 'ECONNRESET') {
                console.log(`🔌 Cliente fechou conexão abruptamente: ${sessionId} (Normal)`);
            } else if (error.code === 'EPIPE') {
                console.log(`🔌 Pipe quebrado para cliente: ${sessionId} (Normal)`);
            } else {
                console.error(`❌ Erro inesperado na conexão SSE ${sessionId}:`, error.message);
            }
            clearInterval(heartbeatInterval);
            activeConnections.delete(sessionId);
        });
        
    } catch (error) {
        console.error(`❌ Erro ao criar SSE ${sessionId}:`, error);
        res.status(500).json({ error: 'Erro ao criar conexão SSE' });
    }
});

// Limpeza periódica de conexões antigas (a cada 5 minutos)
setInterval(() => {
    const now = Date.now();
    const timeout = 5 * 60 * 1000; // 5 minutos
    
    activeConnections.forEach((connectionInfo, sessionId) => {
        if (now - connectionInfo.lastHeartbeat > timeout) {
            console.log(`🧹 Removendo conexão antiga: ${sessionId}`);
            try {
                if (!connectionInfo.response.destroyed) {
                    connectionInfo.response.end();
                }
            } catch (error) {
                console.error('Erro ao fechar conexão antiga:', error);
            }
            activeConnections.delete(sessionId);
        }
    });
}, 5 * 60 * 1000);

// Servir arquivos estáticos e rotas
app.get('/quiz', (req, res) => {
    res.sendFile(path.join(__dirname, 'quiz.html'));
});

app.get('/pagar-pix-pac', (req, res) => {
    res.sendFile(path.join(__dirname, 'pagar-pix-pac', 'index.html'));
});

app.get('/pagar-pix-sedex', (req, res) => {
    res.sendFile(path.join(__dirname, 'pagar-pix-sedex', 'index.html'));
});

// Outras rotas
const routes = [
    'pagar-pac', 'pagar-sedex', 'cep', 'ga', 'termos', 
    'type-pac', 'type-sedex', 'sedex', 'up1', 'up2', 'up3', 'up4', 'up5'
];

routes.forEach(route => {
    app.get(`/${route}`, (req, res) => {
        res.sendFile(path.join(__dirname, route, 'index.html'));
    });
});

// Rota padrão
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'quiz.html'));
});

app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

// Endpoint para Facebook Conversions API (server-side tracking)
// TEMPORARIAMENTE DESABILITADO PARA TESTE COM PLATAFORMA EXTERNA
app.post('/api/facebook-conversion', async (req, res) => {
    try {
        console.log('📊 [DESABILITADO] Evento de conversão Facebook recebido mas não processado:', req.body);
        
        // Retornar sucesso sem enviar para Facebook
        res.json({
            success: true,
            message: 'Endpoint temporariamente desabilitado para testes',
            received_data: req.body,
            timestamp: new Date().toISOString()
        });
        
        return; // Sair da função sem processar
        
        const { 
            event_name, 
            event_time, 
            user_data = {}, 
            custom_data = {}, 
            event_source_url = '',
            action_source = 'website'
        } = req.body;

        // Validar dados obrigatórios
        if (!event_name) {
            return res.status(400).json({ error: 'event_name é obrigatório' });
        }

        // Preparar dados para a Facebook Conversions API
        const conversionData = {
            data: [{
                event_name: event_name,
                event_time: event_time || Math.floor(Date.now() / 1000),
                action_source: action_source,
                event_source_url: event_source_url,
                user_data: {
                    client_ip_address: req.ip || req.connection.remoteAddress,
                    client_user_agent: req.headers['user-agent'],
                    fbc: user_data.fbc || '',
                    fbp: user_data.fbp || '',
                    em: user_data.em || '', // email hasheado
                    ph: user_data.ph || '', // telefone hasheado
                },
                custom_data: {
                    currency: custom_data.currency || 'BRL',
                    value: custom_data.value || 0,
                    content_name: custom_data.content_name || '',
                    content_category: custom_data.content_category || 'frete',
                    transaction_id: custom_data.transaction_id || '',
                    utm_source: custom_data.utm_source || '',
                    utm_medium: custom_data.utm_medium || '',
                    utm_campaign: custom_data.utm_campaign || '',
                    utm_content: custom_data.utm_content || '',
                    utm_term: custom_data.utm_term || ''
                }
            }],
            access_token: 'EAARfjYp6gD4BOZBnSxVPIcZCeF3ZCvXe1NnrgWO6lfHidEaHvJf9trVPGZA0lZA1V1w6fa1YSMyMdrbqs6WQuYPzghSk3SljrrKp77FqaE7G4oqVMsUKMMv0sagpJBh4waxtNZBmK0YtdzZA4qyEwSJInMI0QuDout9wOvsccDdGdFM4DiRZACMIs2fRnvwuTxkEPAZDZD'
        };

        // Enviar para Facebook Conversions API
        const facebookResponse = await fetch('https://graph.facebook.com/v21.0/1249534570141968/events', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(conversionData)
        });

        const responseData = await facebookResponse.json();
        
        if (facebookResponse.ok) {
            console.log('✅ Conversão enviada para Facebook:', responseData);
            res.json({ 
                success: true, 
                facebook_response: responseData,
                event_name: event_name,
                pixel_id: '1249534570141968'
            });
        } else {
            console.error('❌ Erro ao enviar conversão para Facebook:', responseData);
            res.status(400).json({ 
                success: false, 
                error: responseData,
                event_name: event_name
            });
        }
        
    } catch (error) {
        console.error('❌ Erro no endpoint Facebook:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Erro interno do servidor',
            message: error.message 
        });
    }
});
