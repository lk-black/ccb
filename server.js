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
        console.log('Requisição recebida:', req.body);
        
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
        console.log('Resposta da API:', data);
        
        res.json(data);
    } catch (error) {
        console.error('Erro no proxy:', error);
        res.status(500).json({ 
            error: 'Erro interno do servidor', 
            message: error.message 
        });
    }
});

// Armazenamento em memória para conexões SSE ativas
const activeConnections = new Map();

// Endpoint para webhook da Duckfy
app.post('/webhook/duckfy', (req, res) => {
    try {
        console.log('Webhook recebido:', JSON.stringify(req.body, null, 2));
        
        const { event, transaction, client } = req.body;
        
        // Verificar se é um evento de pagamento aprovado
        if (event === 'transaction.paid' || transaction.status === 'PAID' || transaction.status === 'CONFIRMED') {
            console.log('Pagamento confirmado para transação:', transaction.id);
            
            // Notificar todas as conexões ativas sobre o pagamento
            const paymentData = {
                type: 'payment_confirmed',
                transactionId: transaction.id,
                identifier: transaction.identifier,
                status: transaction.status,
                amount: transaction.amount,
                payedAt: transaction.payedAt
            };
            
            // Enviar para todas as conexões SSE ativas
            activeConnections.forEach((connection, sessionId) => {
                try {
                    connection.write(`data: ${JSON.stringify(paymentData)}\n\n`);
                } catch (error) {
                    console.error('Erro ao enviar SSE:', error);
                    activeConnections.delete(sessionId);
                }
            });
            
            console.log(`Notificação enviada para ${activeConnections.size} conexões ativas`);
        }
        
        res.status(200).json({ received: true });
    } catch (error) {
        console.error('Erro no webhook:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

// Endpoint SSE para conexão em tempo real
app.get('/api/payment-status/:sessionId', (req, res) => {
    const sessionId = req.params.sessionId;
    
    // Configurar headers SSE
    res.writeHead(200, {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Cache-Control'
    });
    
    // Enviar heartbeat inicial
    res.write(`data: ${JSON.stringify({ type: 'connected', sessionId })}\n\n`);
    
    // Armazenar conexão
    activeConnections.set(sessionId, res);
    console.log(`Nova conexão SSE: ${sessionId}. Total: ${activeConnections.size}`);
    
    // Limpar conexão quando cliente desconectar
    req.on('close', () => {
        activeConnections.delete(sessionId);
        console.log(`Conexão SSE fechada: ${sessionId}. Total: ${activeConnections.size}`);
    });
    
    // Heartbeat a cada 30 segundos para manter conexão ativa
    const heartbeat = setInterval(() => {
        try {
            res.write(`data: ${JSON.stringify({ type: 'heartbeat', timestamp: Date.now() })}\n\n`);
        } catch (error) {
            clearInterval(heartbeat);
            activeConnections.delete(sessionId);
        }
    }, 30000);
    
    // Limpar heartbeat quando conexão for fechada
    req.on('close', () => {
        clearInterval(heartbeat);
    });
});

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
