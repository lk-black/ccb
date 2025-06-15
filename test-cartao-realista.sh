#!/bin/bash

echo "💳 Teste do Design Realista do Cartão - iframe"
echo "=============================================="

cartao_file="/home/lkdev/workspace/projects/offers/ccb/iframes/cartao/index.html"
images_dir="/home/lkdev/workspace/projects/offers/ccb/iframes/cartao/images"

echo ""
echo "📁 Verificando arquivos necessários:"

# Verificar se o arquivo principal existe
if [[ -f "$cartao_file" ]]; then
    echo "✅ Arquivo principal encontrado: index.html"
else
    echo "❌ Arquivo principal não encontrado: index.html"
    exit 1
fi

# Verificar imagens necessárias
required_images=(
    "casas-bahia.png"
    "logo.png"  
    "chip-1-logo-png-transparent.png"
    "aproximacao.png"
    "Visa-logo-white.png"
)

echo ""
echo "🖼️ Verificando imagens necessárias:"
for image in "${required_images[@]}"; do
    if [[ -f "$images_dir/$image" ]]; then
        echo "✅ $image"
    else
        echo "❌ $image (não encontrada)"
    fi
done

echo ""
echo "🔍 Verificando implementação do código:"

echo ""
echo "1. 📋 Elementos do cartão realista:"
if grep -q "logo-casas-bahia" "$cartao_file"; then
    echo "   ✅ Logo Casas Bahia implementada"
else
    echo "   ❌ Logo Casas Bahia não implementada"
fi

if grep -q "logo-bradescard" "$cartao_file"; then
    echo "   ✅ Logo Bradescard implementada"
else
    echo "   ❌ Logo Bradescard não implementada"
fi

if grep -q "imagem-chip" "$cartao_file"; then
    echo "   ✅ Imagem do chip implementada"
else
    echo "   ❌ Imagem do chip não implementada"
fi

if grep -q "contactless-icon" "$cartao_file"; then
    echo "   ✅ Ícone contactless implementado"
else
    echo "   ❌ Ícone contactless não implementado"
fi

if grep -q "visa-logo" "$cartao_file"; then
    echo "   ✅ Logo Visa implementada"
else
    echo "   ❌ Logo Visa não implementada"
fi

echo ""
echo "2. 💳 Dados simulados do cartão:"
if grep -q "gerarNumeroCartao" "$cartao_file"; then
    echo "   ✅ Geração de número do cartão implementada"
else
    echo "   ❌ Geração de número do cartão não implementada"
fi

if grep -q "gerarDataValidade" "$cartao_file"; then
    echo "   ✅ Geração de data de validade implementada"
else
    echo "   ❌ Geração de data de validade não implementada"
fi

if grep -q "formatarNomeCartao" "$cartao_file"; then
    echo "   ✅ Formatação do nome do titular implementada"
else
    echo "   ❌ Formatação do nome do titular não implementada"
fi

echo ""
echo "3. 💾 Integração com localStorage:"
if grep -q "localStorage.getItem.*userData" "$cartao_file"; then
    echo "   ✅ Leitura de dados do usuário do localStorage implementada"
else
    echo "   ❌ Leitura de dados do usuário não implementada"
fi

if grep -q "nomeTitular" "$cartao_file"; then
    echo "   ✅ Exibição do nome do titular implementada"
else
    echo "   ❌ Exibição do nome do titular não implementada"
fi

echo ""
echo "4. 🎨 Sistema de cores:"
cores_count=$(grep -c "data-gradient" "$cartao_file")
echo "   ✅ Opções de cores implementadas: $cores_count cores"

if grep -q "grid-template-columns.*repeat.*3.*1fr" "$cartao_file"; then
    echo "   ✅ Layout em grid para as cores implementado"
else
    echo "   ❌ Layout em grid não implementado"
fi

echo ""
echo "5. 📱 Design responsivo:"
if grep -q "font-family.*monospace" "$cartao_file"; then
    echo "   ✅ Fonte monospace para números do cartão implementada"
else
    echo "   ❌ Fonte monospace não implementada"
fi

if grep -q "drop-shadow" "$cartao_file"; then
    echo "   ✅ Efeitos de sombra implementados"
else
    echo "   ❌ Efeitos de sombra não implementados"
fi

echo ""
echo "📊 Verificando estrutura HTML:"
if grep -q "numeroCartao" "$cartao_file"; then
    echo "   ✅ Campo número do cartão presente"
else
    echo "   ❌ Campo número do cartão não encontrado"
fi

if grep -q "validadeCartao" "$cartao_file"; then
    echo "   ✅ Campo validade presente"
else
    echo "   ❌ Campo validade não encontrado"
fi

if grep -q "info-cartao" "$cartao_file"; then
    echo "   ✅ Área de informações do cartão presente"
else
    echo "   ❌ Área de informações não encontrada"
fi

echo ""
echo "🔒 Verificando segurança:"
if grep -q "user-select.*none" "$cartao_file"; then
    echo "   ✅ Proteção contra seleção de texto implementada"
else
    echo "   ❌ Proteção contra seleção não implementada"
fi

echo ""
echo "📋 Resumo:"
echo "================================"

# Contar implementações
implementations=0
total_checks=12

checks=(
    "logo-casas-bahia"
    "imagem-chip" 
    "visa-logo"
    "gerarNumeroCartao"
    "gerarDataValidade"
    "formatarNomeCartao"
    "localStorage.getItem.*userData"
    "nomeTitular"
    "data-gradient"
    "font-family.*monospace"
    "numeroCartao"
    "validadeCartao"
)

for check in "${checks[@]}"; do
    if grep -q "$check" "$cartao_file"; then
        implementations=$((implementations + 1))
    fi
done

percentage=$((implementations * 100 / total_checks))

echo "✅ Funcionalidades implementadas: $implementations/$total_checks ($percentage%)"

if [[ $implementations -eq $total_checks ]]; then
    echo "🎉 PERFEITO! Cartão realista completamente implementado."
elif [[ $implementations -ge 10 ]]; then
    echo "✅ EXCELENTE! Implementação quase completa."
elif [[ $implementations -ge 8 ]]; then
    echo "✅ BOM! A maioria das funcionalidades está implementada."
else
    echo "⚠️  ATENÇÃO! Várias funcionalidades importantes estão faltando."
fi

echo ""
echo "📝 Para testar:"
echo "1. Abra o iframe do cartão no navegador"
echo "2. Verifique se as imagens estão carregando"
echo "3. Confirme se o nome do usuário aparece (se houver no localStorage)"
echo "4. Teste as opções de cores"
echo "5. Verifique se número e validade são gerados automaticamente"
