#!/bin/bash

# Script de Build para Aplicação CCB
# Aplicação estática HTML/CSS/JavaScript

set -e

echo "🚀 Iniciando build da aplicação CCB..."

# Configurações
BUILD_DIR="dist"
SOURCE_DIR="."

# Função para exibir ajuda
show_help() {
    echo "Uso: ./build.sh [OPÇÃO]"
    echo ""
    echo "Opções:"
    echo "  -h, --help     Exibe esta ajuda"
    echo "  -c, --clean    Limpa o diretório de build antes de gerar"
    echo "  -p, --prod     Build para produção (minifica arquivos)"
    echo "  -d, --dev      Build para desenvolvimento (sem minificação)"
    echo "  -s, --serve    Inicia servidor local após o build"
    echo ""
    echo "Exemplos:"
    echo "  ./build.sh -c -p    # Limpa e faz build de produção"
    echo "  ./build.sh -d -s    # Build de desenvolvimento e serve"
}

# Função para limpar diretório de build
clean_build() {
    echo "🧹 Limpando diretório de build..."
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    mkdir -p "$BUILD_DIR"
}

# Função para copiar arquivos essenciais
copy_files() {
    echo "📁 Copiando arquivos..."
    
    # Copiar arquivo principal
    cp quiz.html "$BUILD_DIR/"
    cp README.md "$BUILD_DIR/"
    
    # Copiar todas as pastas e seus conteúdos
    for dir in cep ga iframes images pagar-pac pagar-pix-pac pagar-pix-sedex pagar-sedex sedex termos type-pac type-sedex up1 up2 up3 up4 up5; do
        if [ -d "$dir" ]; then
            echo "  📂 Copiando diretório: $dir"
            cp -r "$dir" "$BUILD_DIR/"
        fi
    done
}

# Função para otimizar arquivos para produção
optimize_prod() {
    echo "⚡ Otimizando para produção..."
    
    # Minificar HTML (removendo comentários e espaços desnecessários)
    find "$BUILD_DIR" -name "*.html" -type f -exec sh -c '
        for file do
            echo "  🔧 Minificando HTML: $file"
            # Remover comentários HTML
            sed -i "/<!--.*-->/d" "$file"
            # Remover linhas em branco
            sed -i "/^[[:space:]]*$/d" "$file"
        done
    ' sh {} +
    
    # Remover arquivos de desenvolvimento se existirem
    find "$BUILD_DIR" -name ".vscode" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$BUILD_DIR" -name "*.log" -type f -delete 2>/dev/null || true
    find "$BUILD_DIR" -name "*.tmp" -type f -delete 2>/dev/null || true
}

# Função para criar arquivo de configuração do servidor
create_server_config() {
    echo "🔧 Criando configurações do servidor..."
    
    # Criar .htaccess para Apache
    cat > "$BUILD_DIR/.htaccess" << 'EOF'
# Configurações de Cache
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/html "access plus 1 hour"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
    ExpiresByType font/woff2 "access plus 1 year"
</IfModule>

# Compressão GZIP
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>

# Redirecionar para HTTPS
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Index fallback
DirectoryIndex quiz.html index.html
EOF

    # Criar nginx.conf para Nginx
    cat > "$BUILD_DIR/nginx.conf" << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index quiz.html index.html;

    # Configurações de cache
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1M;
        add_header Cache-Control "public, immutable";
    }

    location ~* \.html$ {
        expires 1h;
        add_header Cache-Control "public";
    }

    # Compressão
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # Fallback para SPA
    try_files $uri $uri/ /quiz.html;
}
EOF
}

# Função para criar Dockerfile
create_dockerfile() {
    echo "🐳 Criando Dockerfile..."
    
    cat > "$BUILD_DIR/Dockerfile" << 'EOF'
# Multi-stage build para aplicação estática
FROM nginx:alpine

# Copiar arquivos da aplicação
COPY . /usr/share/nginx/html/

# Copiar configuração do nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expor porta
EXPOSE 80

# Comando padrão
CMD ["nginx", "-g", "daemon off;"]
EOF

    # Criar docker-compose.yml
    cat > "$BUILD_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  ccb-app:
    build: .
    ports:
      - "8080:80"
    restart: unless-stopped
    environment:
      - NGINX_HOST=localhost
      - NGINX_PORT=80
EOF
}

# Função para criar scripts de deploy
create_deploy_scripts() {
    echo "📋 Criando scripts de deploy..."
    
    # Script para deploy via rsync/SSH
    cat > "$BUILD_DIR/deploy-ssh.sh" << 'EOF'
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
EOF

    # Script para deploy via FTP
    cat > "$BUILD_DIR/deploy-ftp.sh" << 'EOF'
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
EOF

    # Tornar scripts executáveis
    chmod +x "$BUILD_DIR/deploy-ssh.sh"
    chmod +x "$BUILD_DIR/deploy-ftp.sh"
}

# Função para servir localmente
serve_local() {
    echo "🌐 Iniciando servidor local..."
    
    if command -v python3 &> /dev/null; then
        echo "📡 Servidor disponível em: http://localhost:8000"
        cd "$BUILD_DIR" && python3 -m http.server 8000
    elif command -v php &> /dev/null; then
        echo "📡 Servidor disponível em: http://localhost:8000"
        cd "$BUILD_DIR" && php -S localhost:8000
    elif command -v node &> /dev/null; then
        if command -v npx &> /dev/null; then
            echo "📡 Servidor disponível em: http://localhost:8000"
            cd "$BUILD_DIR" && npx http-server -p 8000
        fi
    else
        echo "❌ Nenhum servidor local disponível."
        echo "Instale Python3, PHP ou Node.js para servir a aplicação."
    fi
}

# Função para gerar relatório do build
generate_report() {
    echo "📊 Gerando relatório do build..."
    
    REPORT_FILE="$BUILD_DIR/build-report.txt"
    
    cat > "$REPORT_FILE" << EOF
CCB Application Build Report
===========================
Build Date: $(date)
Build Directory: $BUILD_DIR
Source Directory: $SOURCE_DIR

Files and Directories:
$(find "$BUILD_DIR" -type f | wc -l) arquivos
$(find "$BUILD_DIR" -type d | wc -l) diretórios

Total Size: $(du -sh "$BUILD_DIR" | cut -f1)

Main Components:
- Quiz Page: quiz.html
- Payment flows: pagar-*
- Upsell pages: up1-up5
- Type selection: type-*
- Iframes: iframes/
- Static assets: images/, css/, js/, fonts/

Deployment Options:
1. Static hosting (Netlify, Vercel, GitHub Pages)
2. Web server (Apache, Nginx)
3. Docker container
4. CDN deployment

Next Steps:
- Configure your server settings in deploy scripts
- Test the application in $BUILD_DIR
- Deploy using provided scripts
EOF

    echo "📋 Relatório salvo em: $REPORT_FILE"
}

# Processar argumentos da linha de comando
CLEAN=false
PRODUCTION=false
DEVELOPMENT=false
SERVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -p|--prod)
            PRODUCTION=true
            shift
            ;;
        -d|--dev)
            DEVELOPMENT=true
            shift
            ;;
        -s|--serve)
            SERVE=true
            shift
            ;;
        *)
            echo "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Executar build
echo "🏗️  Build da aplicação CCB"
echo "=========================="

# Limpar se solicitado
if [ "$CLEAN" = true ]; then
    clean_build
else
    mkdir -p "$BUILD_DIR"
fi

# Copiar arquivos
copy_files

# Aplicar otimizações se for produção
if [ "$PRODUCTION" = true ]; then
    optimize_prod
fi

# Criar configurações do servidor
create_server_config

# Criar Dockerfile
create_dockerfile

# Criar scripts de deploy
create_deploy_scripts

# Gerar relatório
generate_report

echo ""
echo "✅ Build concluído com sucesso!"
echo "📁 Arquivos de build em: $BUILD_DIR"
echo ""

if [ "$PRODUCTION" = true ]; then
    echo "🚀 Build de PRODUÇÃO criado"
    echo "   - Arquivos otimizados"
    echo "   - Configurações de servidor incluídas"
    echo "   - Scripts de deploy prontos"
elif [ "$DEVELOPMENT" = true ]; then
    echo "🔧 Build de DESENVOLVIMENTO criado"
    echo "   - Arquivos não minificados"
    echo "   - Configurações básicas"
fi

echo ""
echo "📋 Opções de deploy disponíveis:"
echo "   - Docker: docker-compose up -d (no diretório $BUILD_DIR)"
echo "   - SSH: ./deploy-ssh.sh (edite as configurações primeiro)"
echo "   - FTP: ./deploy-ftp.sh (edite as configurações primeiro)"
echo "   - Hosting estático: Faça upload do conteúdo de $BUILD_DIR"

# Servir localmente se solicitado
if [ "$SERVE" = true ]; then
    echo ""
    serve_local
fi

echo ""
echo "🎉 Build finalizado!"
