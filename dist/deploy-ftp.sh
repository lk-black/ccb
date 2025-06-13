#!/bin/bash

# Configurações - EDITE CONFORME SUA NECESSIDADE
FTP_HOST="ftp.seuservidor.com"
FTP_USER="usuario"
FTP_PASS="senha"
FTP_PATH="/public_html"

echo "🚀 Fazendo deploy via FTP..."

# Verificar se lftp está instalado
if ! command -v lftp &> /dev/null; then
    echo "❌ lftp não está instalado. Instale com: sudo apt install lftp"
    exit 1
fi

# Upload via lftp
lftp -c "
set ftp:ssl-allow no;
open -u $FTP_USER,$FTP_PASS $FTP_HOST;
cd $FTP_PATH;
mirror -R --delete --verbose ./ ./;
bye
"

echo "✅ Deploy via FTP concluído!"
