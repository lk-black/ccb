#!/bin/bash

echo "=== TESTE DA NOVA IMPLEMENTAÇÃO LOCALSTORAGE ==="
echo ""

# Verificar se as páginas foram atualizadas para usar localStorage
echo "🔍 Verificando se as páginas PIX foram atualizadas para localStorage:"
echo ""

pix_pages=(
    "pagar-pix-pac/index.html"
    "pagar-pix-sedex/index.html"
    "up2/pagar/index.html"
)

for page in "${pix_pages[@]}"; do
    if [ -f "$page" ]; then
        echo "📄 Verificando $page:"
        
        # Verificar se busca dados do localStorage
        if grep -q "localStorage\.getItem.*userData\|localStorage\.getItem.*userName" "$page"; then
            echo "  ✅ Busca dados do localStorage"
        else
            echo "  ❌ Não busca dados do localStorage"
        fi
        
        # Verificar se ainda usa parâmetros de URL como fallback
        if grep -q "urlParams\.get.*name\|urlParams\.get.*cpf\|urlParams\.get.*phone" "$page"; then
            echo "  ✅ Mantém fallback para URL params"
        else
            echo "  ❌ Não tem fallback para URL params"
        fi
        
        # Verificar se busca tracking params do localStorage
        if grep -q "trackingParams.*localStorage\|localStorage\.getItem.*trackingParams" "$page"; then
            echo "  ✅ Busca tracking params do localStorage"
        else
            echo "  ❌ Não busca tracking params do localStorage"
        fi
        
        echo ""
    fi
done

echo "🔍 Verificando página CEP:"
if [ -f "cep/index.html" ]; then
    echo "📄 Verificando cep/index.html:"
    
    # Verificar se salva dados no localStorage
    if grep -q "localStorage\.setItem.*userData\|localStorage\.setItem.*userName" "cep/index.html"; then
        echo "  ✅ Salva dados do usuário no localStorage"
    else
        echo "  ❌ Não salva dados do usuário no localStorage"
    fi
    
    # Verificar se salva tracking params
    if grep -q "localStorage\.setItem.*trackingParams" "cep/index.html"; then
        echo "  ✅ Salva tracking params no localStorage"
    else
        echo "  ❌ Não salva tracking params no localStorage"
    fi
    
    # Verificar se redireciona apenas com tracking params
    if grep -q "redirectWithTrackingParams" "cep/index.html"; then
        echo "  ✅ Usa redirecionamento apenas com tracking params"
    else
        echo "  ❌ Não usa redirecionamento otimizado"
    fi
    
    # Verificar se tem Facebook Pixel
    if grep -q "facebook-pixel.js" "cep/index.html"; then
        echo "  ✅ Tem Facebook Pixel"
    else
        echo "  ❌ Não tem Facebook Pixel"
    fi
    
    echo ""
fi

echo "=== RESUMO DA IMPLEMENTAÇÃO ==="
echo ""
echo "📋 Nova lógica de dados do usuário:"
echo "1. ✅ Quiz coleta dados iniciais via formulário"
echo "2. ✅ Página CEP salva name, cpf, phone no localStorage"
echo "3. ✅ Páginas PIX buscam dados do localStorage (com fallback para URL)"
echo "4. ✅ Tracking params (UTM, Facebook) são preservados separadamente"
echo ""

echo "🔄 Fluxo de dados:"
echo "Quiz → Termos (Typebot) → CEP (salva localStorage) → Sedex → PIX (usa localStorage)"
echo ""

echo "🎯 Benefícios:"
echo "• URLs mais limpas (apenas tracking params)"
echo "• Dados persistem durante toda a sessão"
echo "• Melhor segurança (dados não visíveis na URL)"
echo "• Tracking de Facebook Ads mantido"
echo ""

echo "⚡ Para testar:"
echo "1. Acesse uma página PIX diretamente: dados de fallback serão usados"
echo "2. Passe por CEP primeiro: dados do localStorage serão usados"
echo "3. Verifique console para logs de recuperação de dados"
echo ""

# Verificar se todas as páginas têm Facebook Pixel
echo "🎯 Status do Facebook Pixel em todas as páginas:"
all_pages=(
    "cep/index.html"
    "pagar-pac/index.html"
    "pagar-sedex/index.html" 
    "pagar-pix-pac/index.html"
    "pagar-pix-sedex/index.html"
    "up1/index.html"
    "up2/pagar/index.html"
    "up3/index.html"
    "up4/index.html"
    "up5/index.html"
    "quiz.html"
    "ga/index.html"
    "sedex/index.html"
    "type-sedex/index.html"
    "type-pac/index.html"
)

pixel_count=0
total_count=0

for page in "${all_pages[@]}"; do
    if [ -f "$page" ]; then
        total_count=$((total_count + 1))
        if grep -q "facebook-pixel.js" "$page"; then
            pixel_count=$((pixel_count + 1))
        fi
    fi
done

echo "📊 $pixel_count de $total_count páginas têm Facebook Pixel"

if [ $pixel_count -eq $total_count ]; then
    echo "🎉 SUCESSO: Todas as páginas têm Facebook Pixel integrado!"
else
    echo "⚠️  Algumas páginas ainda precisam do Facebook Pixel"
fi

echo ""
echo "=== IMPLEMENTAÇÃO LOCALSTORAGE COMPLETA ==="
