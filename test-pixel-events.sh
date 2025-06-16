#!/bin/bash

# Teste para verificar se há duplicações de eventos Pixel
echo "🔍 Verificando duplicações de eventos Facebook Pixel..."

echo ""
echo "=== Análise PAC ==="
echo "Eventos InitiateCheckout em pagar-pac:"
grep -n "InitiateCheckout" pagar-pac/index.html | grep -v "function\|comment"

echo ""
echo "Eventos AddPaymentInfo em pagar-pac:"
grep -n "AddPaymentInfo" pagar-pac/index.html | grep -v "function\|comment"

echo ""
echo "=== Análise SEDEX ==="
echo "Eventos InitiateCheckout em pagar-sedex:"
grep -n "InitiateCheckout" pagar-sedex/index.html | grep -v "function\|comment"

echo ""
echo "Eventos AddPaymentInfo em pagar-sedex:"
grep -n "AddPaymentInfo" pagar-sedex/index.html | grep -v "function\|comment"

echo ""
echo "=== Verificando botões duplicados ==="
echo "Botões em pagar-pac:"
grep -n "Pagar Frete" pagar-pac/index.html

echo ""
echo "Botões em pagar-sedex:"
grep -n "Pagar Frete" pagar-sedex/index.html

echo ""
echo "=== Verificando event listeners automáticos ==="
echo "DOMContentLoaded em pagar-pac:"
grep -n "DOMContentLoaded" pagar-pac/index.html

echo ""
echo "DOMContentLoaded em pagar-sedex:"
grep -n "DOMContentLoaded" pagar-sedex/index.html

echo ""
echo "✅ Análise concluída!"
