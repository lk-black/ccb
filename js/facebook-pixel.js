// Facebook Pixel Integration - CCB
(function() {
    'use strict';
    
    // Facebook Pixel Code
    !function(f,b,e,v,n,t,s)
    {if(f.fbq)return;n=f.fbq=function(){n.callMethod?
    n.callMethod.apply(n,arguments):n.queue.push(arguments)};
    if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
    n.queue=[];t=b.createElement(e);t.async=!0;
    t.src=v;s=b.getElementsByTagName(e)[0];
    s.parentNode.insertBefore(t,s)}(window, document,'script',
    'https://connect.facebook.net/en_US/fbevents.js');

    // Initialize pixel
    fbq('init', '1249534570141968');
    
    // Track PageView automatically
    fbq('track', 'PageView');
    
    console.log('🎯 Facebook Pixel inicializado: 1249534570141968');

    // Função para obter parâmetro da URL
    function getUrlParameter(name) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(name);
    }

    // Função para obter cookie
    function getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
        return null;
    }

    // Função para rastrear eventos customizados
    window.trackFacebookEvent = function(eventName, eventData = {}) {
        console.log('📊 Enviando evento Facebook:', eventName, eventData);
        
        // Enviar via Facebook Pixel
        fbq('track', eventName, eventData);
        
        // Para eventos de conversão, também rastrear como Custom Conversion
        if (['Purchase', 'InitiateCheckout', 'AddPaymentInfo'].includes(eventName)) {
            fbq('trackCustom', eventName + '_CCB', eventData);
        }
    };

    // Função para rastrear visualização de produto
    window.trackViewContent = function(productName, value = 0) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value
        };
        
        trackFacebookEvent('ViewContent', eventData);
    };

    // Função para rastrear início do checkout
    window.trackInitiateCheckout = function(productName, value) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value,
            utm_source: getUrlParameter('utm_source') || '',
            utm_medium: getUrlParameter('utm_medium') || '',
            utm_campaign: getUrlParameter('utm_campaign') || ''
        };
        
        trackFacebookEvent('InitiateCheckout', eventData);
    };

    // Função para rastrear informações de pagamento
    window.trackAddPaymentInfo = function(productName, value) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value
        };
        
        trackFacebookEvent('AddPaymentInfo', eventData);
    };

    // Função para rastrear compra concluída
    window.trackPurchase = function(transactionId, productName, value) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value,
            transaction_id: transactionId,
            utm_source: getUrlParameter('utm_source') || '',
            utm_medium: getUrlParameter('utm_medium') || '',
            utm_campaign: getUrlParameter('utm_campaign') || ''
        };
        
        trackFacebookEvent('Purchase', eventData);
        
        // Evento customizado adicional para compra CCB
        fbq('trackCustom', 'CCB_Purchase_Complete', eventData);
    };

    // Função para rastrear leads
    window.trackLead = function(productName, value = 0) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value
        };
        
        trackFacebookEvent('Lead', eventData);
    };

    // Auto-track baseado na página atual
    document.addEventListener('DOMContentLoaded', function() {
        const path = window.location.pathname;
        
        if (path.includes('pagar-pix-sedex')) {
            trackViewContent('Frete SEDEX', 28.9);
            trackInitiateCheckout('Frete SEDEX', 28.9);
        } else if (path.includes('pagar-pix-pac')) {
            trackViewContent('Frete PAC', 23.9);
            trackInitiateCheckout('Frete PAC', 23.9);
        } else if (path.includes('up2/pagar')) {
            trackViewContent('Ativação Conta UP2', 20.0);
            trackInitiateCheckout('Ativação Conta UP2', 20.0);
        } else if (path.includes('/ga/')) {
            // Página de sucesso - rastrear como lead qualificado
            trackLead('Cartão Aprovado', 0);
        }
    });

    console.log('✅ Facebook Pixel CCB carregado com sucesso');

})();
