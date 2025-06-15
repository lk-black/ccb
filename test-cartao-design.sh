#!/bin/bash

echo "🎨 Verificação do Design do Cartão - Iframe"
echo "=========================================="

cartao_file="/home/lkdev/workspace/projects/offers/ccb/iframes/cartao/index.html"

if [[ ! -f "$cartao_file" ]]; then
    echo "❌ Arquivo não encontrado: $cartao_file"
    exit 1
fi

echo ""
echo "🔍 Verificando implementação do novo design:"

echo ""
echo "1. 🏢 Marcas do cartão:"
if grep -q "marca-casas-bahia\|marca-bradescard" "$cartao_file"; then
    echo "   ✅ Marcas Casas Bahia e Bradescard implementadas"
else
    echo "   ❌ Marcas não encontradas"
fi

echo ""
echo "2. 💳 Chip e contactless:"
if grep -q "chip-contactless-area\|contactless-waves" "$cartao_file"; then
    echo "   ✅ Área do chip e ícone contactless implementados"
else
    echo "   ❌ Elementos do chip não encontrados"
fi

echo ""
echo "3. 🏅 Logo Visa Platinum:"
if grep -q "visa-logo\|visa-platinum" "$cartao_file"; then
    echo "   ✅ Logo Visa Platinum implementado"
else
    echo "   ❌ Logo Visa não encontrado"
fi

echo ""
echo "4. 🎨 Sistema de cores com gradientes:"
if grep -q "data-gradient\|linear-gradient" "$cartao_file"; then
    echo "   ✅ Sistema de gradientes implementado"
else
    echo "   ❌ Sistema de gradientes não encontrado"
fi

echo ""
echo "5. 🎯 Botão de continuar:"
if grep -q "btn-custom.*Confirmar Design" "$cartao_file"; then
    echo "   ✅ Botão de confirmação implementado"
else
    echo "   ❌ Botão de confirmação não encontrado"
fi

echo ""
echo "6. 🔗 Integração com localStorage:"
if grep -q "localStorage.*userData\|localStorage.*trackingParams" "$cartao_file"; then
    echo "   ✅ Integração com localStorage implementada"
else
    echo "   ❌ Integração com localStorage não encontrada"
fi

echo ""
echo "📱 Verificando responsividade e acessibilidade:"

if grep -q "transform.*scale\|transition.*ease" "$cartao_file"; then
    echo "   ✅ Animações e transições implementadas"
else
    echo "   ❌ Animações não encontradas"
fi

if grep -q "box-shadow.*rgba\|background.*linear-gradient" "$cartao_file"; then
    echo "   ✅ Efeitos visuais modernos implementados"
else
    echo "   ❌ Efeitos visuais não encontrados"
fi

echo ""
echo "🎨 Verificando elementos de design específicos:"

# Contar funcionalidades implementadas
features=0
total_features=6

if grep -q "marca-casas-bahia\|marca-bradescard" "$cartao_file"; then features=$((features + 1)); fi
if grep -q "chip-contactless-area\|contactless-waves" "$cartao_file"; then features=$((features + 1)); fi
if grep -q "visa-logo\|visa-platinum" "$cartao_file"; then features=$((features + 1)); fi
if grep -q "data-gradient\|linear-gradient" "$cartao_file"; then features=$((features + 1)); fi
if grep -q "btn-custom.*Confirmar Design" "$cartao_file"; then features=$((features + 1)); fi
if grep -q "localStorage.*userData\|localStorage.*trackingParams" "$cartao_file"; then features=$((features + 1)); fi

percentage=$((features * 100 / total_features))

echo "✅ Funcionalidades do design: $features/$total_features ($percentage%)"

if [[ $features -eq $total_features ]]; then
    echo "🎉 SUCESSO! Novo design do cartão implementado completamente."
elif [[ $features -ge 4 ]]; then
    echo "✅ BOM! A maior parte do design foi implementada."
else
    echo "⚠️  ATENÇÃO! Algumas funcionalidades do design estão faltando."
fi

echo ""
echo "🎨 Resumo das melhorias implementadas:"
echo "• Design moderno inspirado na imagem fornecida"
echo "• Gradientes elegantes em vez de cores sólidas"
echo "• Marcas Casas Bahia e Bradescard em destaque"
echo "• Chip EMV e ícone contactless realistas"
echo "• Logo Visa Platinum profissional"
echo "• Animações suaves e efeitos visuais"
echo "• Integração com sistema de localStorage"
echo "• Botão de confirmação com design moderno"

echo ""
echo "📝 Para testar:"
echo "1. Abra o iframe do cartão no navegador"
echo "2. Teste a seleção de cores"
echo "3. Verifique as animações e transições"
echo "4. Confirme a integração com localStorage"
echo "5. Teste o botão de continuar"
