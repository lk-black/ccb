# Makefile para aplicação CCB
# Aplicação estática HTML/CSS/JavaScript

.PHONY: help build build-prod build-dev clean serve deploy-docker deploy-ssh deploy-ftp validate compress start

# Variáveis
BUILD_DIR := dist
PORT := 8000
TIMESTAMP := $(shell date +%Y%m%d-%H%M%S)

# Comando padrão
help: ## Exibe esta ajuda
	@echo "🚀 CCB Application - Comandos disponíveis:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Instala dependências (se houver package.json)
	@if [ -f package.json ]; then \
		echo "📦 Instalando dependências do npm..."; \
		npm install; \
	else \
		echo "ℹ️  Nenhuma dependência npm para instalar"; \
	fi

validate: ## Valida a estrutura do projeto
	@echo "🔍 Validando estrutura do projeto..."
	@test -f quiz.html || (echo "❌ quiz.html não encontrado" && exit 1)
	@test -d cep || (echo "❌ Diretório cep não encontrado" && exit 1)
	@test -d images || (echo "❌ Diretório images não encontrado" && exit 1)
	@echo "✅ Estrutura do projeto validada"

clean: ## Limpa o diretório de build
	@echo "🧹 Limpando diretório de build..."
	@rm -rf $(BUILD_DIR)
	@echo "✅ Limpeza concluída"

build: ## Build básico da aplicação
	@chmod +x build.sh
	@./build.sh

build-dev: ## Build para desenvolvimento
	@chmod +x build.sh
	@./build.sh -c -d

build-prod: ## Build para produção (otimizado)
	@chmod +x build.sh
	@./build.sh -c -p

serve: build-dev ## Inicia servidor de desenvolvimento
	@chmod +x build.sh
	@./build.sh -d -s

start: ## Inicia servidor local simples
	@echo "🌐 Iniciando servidor na porta $(PORT)..."
	@if command -v python3 >/dev/null 2>&1; then \
		echo "📡 Servidor disponível em: http://localhost:$(PORT)"; \
		python3 -m http.server $(PORT); \
	elif command -v php >/dev/null 2>&1; then \
		echo "📡 Servidor disponível em: http://localhost:$(PORT)"; \
		php -S localhost:$(PORT); \
	elif command -v node >/dev/null 2>&1; then \
		echo "📡 Servidor disponível em: http://localhost:$(PORT)"; \
		npx http-server -p $(PORT); \
	else \
		echo "❌ Nenhum servidor disponível. Instale Python3, PHP ou Node.js"; \
	fi

# Deploy targets
deploy-docker: build-prod ## Deploy usando Docker
	@echo "🐳 Fazendo deploy com Docker..."
	@cd $(BUILD_DIR) && docker-compose up -d
	@echo "✅ Deploy Docker concluído"

deploy-ssh: build-prod ## Deploy via SSH (configure primeiro)
	@echo "📤 Deploy via SSH..."
	@cd $(BUILD_DIR) && chmod +x deploy-ssh.sh && ./deploy-ssh.sh

deploy-ftp: build-prod ## Deploy via FTP (configure primeiro)
	@echo "📤 Deploy via FTP..."
	@cd $(BUILD_DIR) && chmod +x deploy-ftp.sh && ./deploy-ftp.sh

# Utilitários
compress: build-prod ## Comprime o build em arquivo tar.gz
	@echo "📦 Comprimindo aplicação..."
	@cd $(BUILD_DIR) && tar -czf ../ccb-application-$(TIMESTAMP).tar.gz .
	@echo "✅ Arquivo criado: ccb-application-$(TIMESTAMP).tar.gz"

size: ## Mostra o tamanho dos arquivos
	@echo "📏 Tamanho dos arquivos:"
	@du -sh . --exclude=node_modules --exclude=$(BUILD_DIR) 2>/dev/null || du -sh .
	@if [ -d $(BUILD_DIR) ]; then \
		echo "📁 Build: $$(du -sh $(BUILD_DIR) | cut -f1)"; \
	fi

test: validate ## Executa testes básicos
	@echo "🧪 Executando testes..."
	@echo "  ✓ Validação da estrutura"
	@find . -name "*.html" -not -path "./$(BUILD_DIR)/*" -not -path "./node_modules/*" | head -5 | while read file; do \
		echo "  ✓ HTML encontrado: $$file"; \
	done
	@echo "✅ Testes básicos concluídos"

watch: ## Observa mudanças e reconstrói automaticamente (requer inotify-tools)
	@echo "👀 Observando mudanças nos arquivos..."
	@if command -v inotifywait >/dev/null 2>&1; then \
		while inotifywait -r -e modify,create,delete --exclude '$(BUILD_DIR)' .; do \
			echo "🔄 Mudança detectada, reconstruindo..."; \
			make build-dev; \
		done; \
	else \
		echo "❌ inotifywait não encontrado. Instale: sudo apt install inotify-tools"; \
	fi

info: ## Exibe informações do projeto
	@echo "📋 Informações do Projeto CCB"
	@echo "=============================="
	@echo "Tipo: Aplicação Web Estática"
	@echo "Tecnologias: HTML, CSS, JavaScript"
	@echo "Arquivo principal: quiz.html"
	@echo "Diretório de build: $(BUILD_DIR)"
	@echo "Porta padrão: $(PORT)"
	@echo ""
	@echo "🗂️  Estrutura principal:"
	@ls -la | grep '^d' | awk '{print "  📁 " $$9}' | grep -v '^\.\$$\|^\.\.\$$'
	@echo ""
	@echo "📄 Arquivos principais:"
	@ls -la *.html *.md 2>/dev/null | awk '{print "  📄 " $$9}' || echo "  (nenhum arquivo .html/.md na raiz)"

lint: ## Verifica problemas básicos nos arquivos
	@echo "🔍 Verificando arquivos..."
	@find . -name "*.html" -not -path "./$(BUILD_DIR)/*" -not -path "./node_modules/*" | while read file; do \
		if grep -q "console.log" "$$file"; then \
			echo "⚠️  Console.log encontrado em: $$file"; \
		fi; \
		if grep -q "alert(" "$$file"; then \
			echo "⚠️  Alert encontrado em: $$file"; \
		fi; \
	done
	@echo "✅ Verificação concluída"

# Atalhos
dev: build-dev ## Atalho para build-dev
prod: build-prod ## Atalho para build-prod
up: serve ## Atalho para serve

# Para desenvolvimento rápido
quick: clean build-dev start ## Build dev + start rápido
