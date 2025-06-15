#!/bin/bash

echo "🇧🇷 Verificação de Moeda BRL nos Eventos do Facebook Pixel"
echo "========================================================="

# Arquivos principais para verificar
pages=(
    "/home/lkdev/workspace/projects/offers/ccb/cep/index.html"
    "/home/lkdev/workspace/projects/offers/ccb/pagar-pac/index.html"
    "/home/lkdev/workspace/projects/offers/ccb/pagar-sedex/index.html"
    "/home/lkdev/workspace/projects/offers/ccb/up1/index.html"
    "/home/lkdev/workspace/projects/offers/ccb/up2/pagar/index.html"
    "/home/lkdev/workspace/projects/offers/ccb/up3/index.html"
    "/home/lkdev/workspace/projects/offers/ccb/up4/index.html"
    "/home/lkdev/workspace/projects/offers/ccb/up5/index.html"
)

echo ""
echo "📊 Verificando eventos ViewContent com currency: 'BRL':"

for page in "${pages[@]}"; do
    if [[ -f "$page" ]]; then
        pagename=$(basename $(dirname "$page"))/$(basename "$page")
        
        # Verificar se tem ViewContent
        if grep -q "fbq('track', 'ViewContent'" "$page"; then
            # Verificar se tem currency: 'BRL'
            if grep -A 10 "fbq('track', 'ViewContent'" "$page" | grep -q "currency: 'BRL'"; then
                echo "✅ $pagename - ViewContent com currency: BRL"
            else
                echo "❌ $pagename - ViewContent SEM currency: BRL"
            fi
        else
            echo "⚠️  $pagename - Não tem ViewContent"
        fi
    else
        echo "❌ Arquivo não encontrado: $page"
    fi
done

echo ""
echo "💳 Verificando eventos AddPaymentInfo com currency: 'BRL':"

for page in "${pages[@]}"; do
    if [[ -f "$page" ]]; then
        pagename=$(basename $(dirname "$page"))/$(basename "$page")
        
        # Verificar se tem AddPaymentInfo
        if grep -q "fbq('track', 'AddPaymentInfo'" "$page"; then
            # Verificar se tem currency: 'BRL'
            if grep -A 10 "fbq('track', 'AddPaymentInfo'" "$page" | grep -q "currency: 'BRL'"; then
                echo "✅ $pagename - AddPaymentInfo com currency: BRL"
            else
                echo "❌ $pagename - AddPaymentInfo SEM currency: BRL"
            fi
        else
            echo "⚪ $pagename - Não tem AddPaymentInfo"
        fi
    fi
done

echo ""
echo "💰 Verificando facebook-pixel.js para eventos Purchase:"

pixel_js="/home/lkdev/workspace/projects/offers/ccb/js/facebook-pixel.js"
if [[ -f "$pixel_js" ]]; then
    if grep -A 10 "trackPurchase" "$pixel_js" | grep -q "currency: 'BRL'"; then
        echo "✅ facebook-pixel.js - Purchase com currency: BRL"
    else
        echo "❌ facebook-pixel.js - Purchase SEM currency: BRL"
    fi
    
    if grep -A 10 "trackAddPaymentInfo" "$pixel_js" | grep -q "currency: 'BRL'"; then
        echo "✅ facebook-pixel.js - AddPaymentInfo com currency: BRL"
    else
        echo "❌ facebook-pixel.js - AddPaymentInfo SEM currency: BRL"
    fi
else
    echo "❌ Arquivo facebook-pixel.js não encontrado"
fi

echo ""
echo "📈 Resumo da verificação:"

# Contar total de eventos ViewContent com BRL
viewcontent_with_brl=0
viewcontent_total=0

for page in "${pages[@]}"; do
    if [[ -f "$page" ]]; then
        if grep -q "fbq('track', 'ViewContent'" "$page"; then
            viewcontent_total=$((viewcontent_total + 1))
            if grep -A 10 "fbq('track', 'ViewContent'" "$page" | grep -q "currency: 'BRL'"; then
                viewcontent_with_brl=$((viewcontent_with_brl + 1))
            fi
        fi
    fi
done

echo "🎯 ViewContent: $viewcontent_with_brl/$viewcontent_total páginas com currency: BRL"

# Contar total de eventos AddPaymentInfo com BRL
addpayment_with_brl=0
addpayment_total=0

for page in "${pages[@]}"; do
    if [[ -f "$page" ]]; then
        if grep -q "fbq('track', 'AddPaymentInfo'" "$page"; then
            addpayment_total=$((addpayment_total + 1))
            if grep -A 10 "fbq('track', 'AddPaymentInfo'" "$page" | grep -q "currency: 'BRL'"; then
                addpayment_with_brl=$((addpayment_with_brl + 1))
            fi
        fi
    fi
done

echo "💳 AddPaymentInfo: $addpayment_with_brl/$addpayment_total páginas com currency: BRL"

if [[ $viewcontent_with_brl -eq $viewcontent_total ]] && [[ $addpayment_with_brl -eq $addpayment_total ]]; then
    echo ""
    echo "🎉 SUCESSO! Todos os eventos estão configurados com currency: 'BRL'"
else
    echo ""
    echo "⚠️  ATENÇÃO! Alguns eventos ainda precisam de currency: 'BRL'"
fi

echo ""
echo "📝 Documentação do Facebook:"
echo "Currency deve ser especificado como código de 3 letras (ISO 4217)"
echo "Para o Brasil: currency: 'BRL'"
echo "Aplicável para: ViewContent, AddPaymentInfo, Purchase, InitiateCheckout"
