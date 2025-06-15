#!/bin/bash

echo "=== FACEBOOK PIXEL CONSISTENCY CHECK ==="
echo ""

# Check for Facebook Pixel script inclusion
echo "🔍 Checking Facebook Pixel script inclusion:"
echo ""

pages=(
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

for page in "${pages[@]}"; do
    if [ -f "$page" ]; then
        if grep -q "facebook-pixel.js" "$page"; then
            echo "✅ $page - Facebook Pixel script included"
        else
            echo "❌ $page - Facebook Pixel script missing"
        fi
    else
        echo "⚠️  $page - File not found"
    fi
done

echo ""
echo "🎯 Checking Facebook Pixel event tracking:"
echo ""

# Check for AddPaymentInfo events
echo "📊 AddPaymentInfo Events:"
for page in "${pages[@]}"; do
    if [ -f "$page" ]; then
        if grep -q "trackAddPaymentInfo\|AddPaymentInfo" "$page"; then
            matches=$(grep -c "trackAddPaymentInfo\|AddPaymentInfo" "$page")
            echo "✅ $page - $matches AddPaymentInfo event(s)"
        fi
    fi
done

echo ""
echo "💰 Purchase Events:"
for page in "${pages[@]}"; do
    if [ -f "$page" ]; then
        if grep -q "trackPurchase\|'Purchase'" "$page"; then
            matches=$(grep -c "trackPurchase\|'Purchase'" "$page")
            echo "✅ $page - $matches Purchase event(s)"
        fi
    fi
done

echo ""
echo "👁️  ViewContent Events:"
for page in "${pages[@]}"; do
    if [ -f "$page" ]; then
        if grep -q "ViewContent" "$page"; then
            matches=$(grep -c "ViewContent" "$page")
            echo "✅ $page - $matches ViewContent event(s)"
        fi
    fi
done

echo ""
echo "=== PIX PAYMENT TRACKING VERIFICATION ==="
echo ""

pix_pages=(
    "pagar-pix-pac/index.html"
    "pagar-pix-sedex/index.html"
    "up2/pagar/index.html"
)

for page in "${pix_pages[@]}"; do
    if [ -f "$page" ]; then
        echo "🔍 Checking $page:"
        
        # Check for PIX generation tracking
        if grep -q "🎯.*PIX.*AddPaymentInfo\|trackAddPaymentInfo.*geração\|PIX gerado.*AddPaymentInfo" "$page"; then
            echo "  ✅ PIX generation tracking (AddPaymentInfo)"
        else
            echo "  ❌ PIX generation tracking missing"
        fi
        
        # Check for payment confirmation tracking
        if grep -q "🎯.*compra.*Purchase\|trackPurchase.*confirmado\|Purchase.*pagamento" "$page"; then
            echo "  ✅ Payment confirmation tracking (Purchase)"
        else
            echo "  ❌ Payment confirmation tracking missing"
        fi
        
        echo ""
    fi
done

echo "=== SUMMARY ==="
echo ""

total_pages=${#pages[@]}
pages_with_pixel=$(grep -l "facebook-pixel.js" "${pages[@]}" 2>/dev/null | wc -l)
pages_with_events=$(grep -l "fbq\|track.*\|ViewContent\|AddPaymentInfo\|Purchase" "${pages[@]}" 2>/dev/null | wc -l)

echo "📊 Total pages checked: $total_pages"
echo "🎯 Pages with Facebook Pixel: $pages_with_pixel"
echo "📈 Pages with tracking events: $pages_with_events"

if [ $pages_with_pixel -eq $total_pages ]; then
    echo ""
    echo "🎉 SUCCESS: All pages have Facebook Pixel integration!"
else
    echo ""
    echo "⚠️  Some pages are missing Facebook Pixel integration"
fi

echo ""
echo "=== FACEBOOK ADS OPTIMIZATION CHECK ==="
echo ""

echo "🎯 Critical tracking events for Facebook Ads:"
echo "1. ViewContent - Track page views for audience building"
echo "2. AddPaymentInfo - Track when PIX is generated (conversion optimization)"  
echo "3. Purchase - Track completed payments (ROAS optimization)"
echo ""

echo "📊 UTM and tracking parameter capture:"
for page in pagar-pix-pac/index.html pagar-pix-sedex/index.html up2/pagar/index.html; do
    if [ -f "$page" ]; then
        if grep -q "utm_.*facebook\|fbclid\|trackProps.*utmParams" "$page"; then
            echo "✅ $page - UTM and Facebook parameters captured"
        else
            echo "❌ $page - UTM parameter capture missing"
        fi
    fi
done

echo ""
echo "🔍 Server-side Conversions API integration:"
if [ -f "server.js" ]; then
    if grep -q "facebook-conversion\|/api/facebook" "server.js"; then
        echo "✅ Server-side Conversions API endpoint available"
    else
        echo "❌ Server-side Conversions API endpoint missing"
    fi
fi

echo ""
echo "=== FACEBOOK PIXEL INTEGRATION COMPLETE ==="
