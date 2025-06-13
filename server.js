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
