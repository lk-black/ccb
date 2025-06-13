# CCB - Aplicação de Cartão de Crédito

Aplicação web estática para funil de vendas de cartões de crédito da Casas Bahia, desenvolvida em HTML, CSS e JavaScript puro.

## 🚀 Deploy e Build

### Métodos de Build

#### 1. Usando o Script de Build (Recomendado)
```bash
# Build básico
./build.sh

# Build de produção (otimizado)
./build.sh -c -p

# Build de desenvolvimento
./build.sh -c -d

# Build e servir localmente
./build.sh -d -s
```

#### 2. Usando NPM Scripts
```bash
# Instalar dependências (opcional)
npm install

# Build de produção
npm run build:prod

# Build de desenvolvimento
npm run build:dev

# Servir localmente
npm run serve

# Deploy com Docker
npm run deploy:docker
```

#### 3. Usando Makefile
```bash
# Ver todos os comandos disponíveis
make help

# Build de produção
make build-prod

# Build de desenvolvimento e servir
make serve

# Deploy com Docker
make deploy-docker

# Informações do projeto
make info
```

## 📁 Estrutura do Projeto

```
ccb/
├── quiz.html              # Página principal do quiz
├── build.sh               # Script de build
├── package.json           # Configuração NPM
├── Makefile              # Comandos make
├── README.md             # Este arquivo
├── cep/                  # Coleta de CEP
├── ga/                   # Google Analytics
├── iframes/              # Componentes iframe
│   ├── cartao/
│   ├── gerente/
│   ├── identidade/
│   └── processamento/
├── images/               # Imagens globais
├── pagar-pac/           # Pagamento PAC
├── pagar-pix-pac/       # Pagamento PIX PAC
├── pagar-pix-sedex/     # Pagamento PIX SEDEX
├── pagar-sedex/         # Pagamento SEDEX
├── sedex/               # Seleção SEDEX
├── termos/              # Termos de uso
├── type-pac/            # Tipo PAC
├── type-sedex/          # Tipo SEDEX
├── up1/                 # Upsell 1
├── up2/                 # Upsell 2
├── up3/                 # Upsell 3
├── up4/                 # Upsell 4
└── up5/                 # Upsell 5
```

## 🌐 Opções de Deploy

### 1. Hospedagem Estática (Recomendado)

#### Netlify
1. Faça build: `make build-prod`
2. Faça upload da pasta `dist/` no Netlify
3. Configure redirects se necessário

#### Vercel
1. Conecte o repositório
2. Configure build command: `npm run build:prod`
3. Configure output directory: `dist`

#### GitHub Pages
1. Faça build: `make build-prod`
2. Copie conteúdo de `dist/` para branch `gh-pages`
3. Configure GitHub Pages

### 2. Servidor Web

#### Apache
1. Faça build: `make build-prod`
2. Copie conteúdo de `dist/` para `/var/www/html/`
3. Use o arquivo `.htaccess` incluído

#### Nginx
1. Faça build: `make build-prod`
2. Copie conteúdo de `dist/` para diretório web
3. Use configuração `nginx.conf` incluída

### 3. Docker

#### Build e Run Local
```bash
make deploy-docker
# ou
cd dist && docker-compose up -d
```

#### Deploy em Servidor
```bash
# Build da imagem
docker build -t ccb-app ./dist/

# Executar container
docker run -d -p 80:80 ccb-app
```

### 4. Deploy via SSH/FTP

#### SSH (rsync)
1. Edite configurações em `dist/deploy-ssh.sh`
2. Execute: `make deploy-ssh`

#### FTP
1. Edite configurações em `dist/deploy-ftp.sh`
2. Execute: `make deploy-ftp`

## 🛠️ Desenvolvimento

### Servidor Local
```bash
# Método 1: Com build automático
make serve

# Método 2: Servidor simples
make start

# Método 3: NPM
npm start
```

### Observar Mudanças
```bash
# Requer inotify-tools
make watch
```

### Validação
```bash
# Validar estrutura
make validate

# Testes básicos
make test

# Verificar problemas
make lint
```

## 📦 Arquivos Gerados no Build

Após executar o build, a pasta `dist/` conterá:

- **Aplicação completa**: Todos os arquivos HTML, CSS, JS
- **Configurações de servidor**: `.htaccess`, `nginx.conf`
- **Docker**: `Dockerfile`, `docker-compose.yml`
- **Scripts de deploy**: `deploy-ssh.sh`, `deploy-ftp.sh`
- **Relatório**: `build-report.txt`

## ⚡ Otimizações de Produção

O build de produção inclui:

- ✅ Minificação de HTML
- ✅ Remoção de comentários
- ✅ Configurações de cache
- ✅ Compressão GZIP
- ✅ Headers de segurança
- ✅ Configurações otimizadas

## 🔧 Configurações Avançadas

### Variáveis de Ambiente
```bash
export BUILD_DIR="custom-dist"
export SERVER_PORT="3000"
```

### Customização do Build
Edite o arquivo `build.sh` para:
- Adicionar mais otimizações
- Modificar estrutura de saída
- Adicionar validações customizadas

## 📋 Comandos Úteis

```bash
# Informações do projeto
make info

# Tamanho dos arquivos
make size

# Comprimir build
make compress

# Limpeza completa
make clean

# Build rápido para desenvolvimento
make quick
```

## 🆘 Troubleshooting

### Erro: "Permission denied"
```bash
chmod +x build.sh
chmod +x Makefile
```

### Servidor não inicia
Verifique se tem Python3, PHP ou Node.js instalado:
```bash
python3 --version
php --version
node --version
```

### Build falha
1. Verifique se todos os arquivos estão presentes
2. Execute: `make validate`
3. Verifique permissões de escrita na pasta

## 📝 Notas Importantes

- Esta é uma aplicação **estática** - não requer backend
- Todos os dados são processados no frontend
- APIs externas são chamadas via JavaScript
- Otimizada para SEO e performance
- Compatível com todos os navegadores modernos

## 🚀 Deploy Rápido

Para deploy rápido em qualquer servidor:

```bash
# 1. Build de produção
make build-prod

# 2. Comprimir
make compress

# 3. Enviar arquivo .tar.gz para servidor

# 4. No servidor, extrair:
tar -xzf ccb-application-*.tar.gz -C /var/www/html/
```

## 📞 Suporte

Para dúvidas sobre o deploy ou configuração, consulte:
- Arquivo `build-report.txt` gerado após o build
- Logs de build no terminal
- Configurações específicas em cada pasta `dist/`
