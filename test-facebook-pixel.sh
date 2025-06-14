#!/bin/bash

echo "🎯 Testando integração Facebook Pixel..."
echo ""

# Verificar se o arquivo do pixel existe
if [ -f "js/facebook-pixel.js" ]; then
    echo "✅ Arquivo facebook-pixel.js encontrado"
else
    echo "❌ Arquivo facebook-pixel.js não encontrado"
    exit 1
fi

echo ""
echo "📋 Verificando páginas com pixel integrado..."

# Lista de páginas para verificar
pages=(
    "quiz.html"
    "pagar-pix-sedex/index.html" 
    "pagar-pix-pac/index.html"
    "up2/pagar/index.html"
    "ga/index.html"
    "sedex/index.html"
    "type-sedex/index.html"
    "type-pac/index.html"
)

for page in "${pages[@]}"; do
    if [ -f "$page" ]; then
        if grep -q "facebook-pixel.js" "$page"; then
            echo "✅ $page - Pixel integrado"
        else
            echo "❌ $page - Pixel NÃO integrado"
        fi
    else
        echo "⚠️ $page - Arquivo não encontrado"
    fi
done

echo ""
echo "🔍 Verificando configurações do pixel..."

# Verificar ID do pixel
if grep -q "1249534570141968" "js/facebook-pixel.js"; then
    echo "✅ Pixel ID configurado: 1249534570141968"
else
    echo "❌ Pixel ID não encontrado"
fi

# Verificar eventos configurados
events=("PageView" "ViewContent" "InitiateCheckout" "AddPaymentInfo" "Purchase" "Lead")
for event in "${events[@]}"; do
    if grep -q "$event" "js/facebook-pixel.js"; then
        echo "✅ Evento $event configurado"
    else
        echo "❌ Evento $event não encontrado"
    fi
done

echo ""
echo "🌐 Para testar em produção:"
echo "1. Abra: https://ccb-web.onrender.com/quiz.html?utm_source=facebook&utm_medium=cpc"
echo "2. Abra o console (F12)"
echo "3. Procure por logs: '🎯 Facebook Pixel inicializado'"
echo "4. Verifique no Facebook Events Manager"

echo ""
echo "✅ Verificação concluída!"
