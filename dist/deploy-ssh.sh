#!/bin/bash

# Configurações - EDITE CONFORME SUA NECESSIDADE
SERVER_HOST="seu-servidor.com"
SERVER_USER="usuario"
SERVER_PATH="/var/www/html"
SSH_KEY_PATH="$HOME/.ssh/id_rsa"

echo "🚀 Fazendo deploy via SSH..."

# Verificar se a chave SSH existe
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "❌ Chave SSH não encontrada em: $SSH_KEY_PATH"
    exit 1
fi

# Fazer backup do servidor (opcional)
echo "📦 Criando backup no servidor..."
ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_HOST" "tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz -C $SERVER_PATH ."

# Enviar arquivos
echo "📤 Enviando arquivos..."
rsync -avz --delete -e "ssh -i $SSH_KEY_PATH" ./ "$SERVER_USER@$SERVER_HOST:$SERVER_PATH/"

echo "✅ Deploy concluído!"
