#!/bin/bash

echo "🧪 Testando aplicação CCB em produção..."
echo "URL: https://ccb-web.onrender.com"
echo ""

# Testar página principal
echo "📋 Testando página principal..."
curl -s -o /dev/null -w "Status: %{http_code}\n" https://ccb-web.onrender.com

# Testar página PIX SEDEX com UTMs
echo ""
echo "📋 Testando PIX SEDEX com UTMs..."
curl -s -o /dev/null -w "Status: %{http_code}\n" "https://ccb-web.onrender.com/pagar-pix-sedex/?utm_source=facebook&utm_medium=cpc&utm_campaign=teste&name=João&phone=11999887766&cpf=12345678901"

# Testar página PIX PAC com UTMs  
echo ""
echo "📋 Testando PIX PAC com UTMs..."
curl -s -o /dev/null -w "Status: %{http_code}\n" "https://ccb-web.onrender.com/pagar-pix-pac/?utm_source=facebook&utm_medium=cpc&utm_campaign=teste&name=Maria&phone=11999887766&cpf=12345678901"

echo ""
echo "✅ Teste básico de conectividade concluído!"
echo "🔧 As correções implementadas:"
echo "   • Telefone agora envia apenas números (sem formatação)"
echo "   • Validação de campos obrigatórios adicionada"
echo "   • Logs melhorados para debug"
echo "   • Fallback para telefone padrão quando inválido"
echo ""
echo "🎯 Para testar completamente:"
echo "   1. Acesse as páginas no browser"
echo "   2. Abra o console (F12)"
echo "   3. Monitore os logs de tracking"
echo "   4. Verifique se o código PIX é gerado"
