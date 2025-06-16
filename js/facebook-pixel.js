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

    // Função para gerar um ID único para evento (para desduplicação)
    function generateEventID() {
        return Date.now().toString() + '_' + Math.random().toString(36).substr(2, 9);
    }

    // Função para obter FBP (Facebook Browser ID)
    function getFBP() {
        return getCookie('_fbp') || '';
    }

    // Função para obter FBC (Facebook Click ID)
    function getFBC() {
        return getCookie('_fbc') || getUrlParameter('fbclid') || '';
    }

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
    window.trackFacebookEvent = function(eventName, eventData = {}, eventID = null) {
        // Gerar eventID único se não fornecido
        const uniqueEventID = eventID || generateEventID();
        
        console.log('📊 Enviando evento Facebook:', eventName, eventData, 'EventID:', uniqueEventID);
        
        // Enviar via Facebook Pixel com eventID para desduplicação
        fbq('track', eventName, eventData, {
            eventID: uniqueEventID
        });
        
        // Para eventos de conversão, também enviar via servidor para redundância
        if (['Purchase', 'InitiateCheckout', 'AddPaymentInfo'].includes(eventName)) {
            // Enviar para servidor com mesmo eventID para desduplicação
            sendServerEvent(eventName, eventData, uniqueEventID);
            
            // Evento customizado adicional
            fbq('trackCustom', eventName + '_CCB', eventData, {
                eventID: uniqueEventID + '_custom'
            });
        }
        
        return uniqueEventID;
    };

    // Função para enviar eventos via servidor (API de Conversões)
    function sendServerEvent(eventName, eventData, eventID) {
        try {
            const serverEventData = {
                event_name: eventName,
                event_time: Math.floor(Date.now() / 1000),
                event_id: eventID, // Mesmo ID para desduplicação
                event_source_url: window.location.href,
                action_source: 'website',
                user_data: {
                    fbp: getFBP(),
                    fbc: getFBC(),
                    client_user_agent: navigator.userAgent
                },
                custom_data: {
                    ...eventData,
                    utm_source: getUrlParameter('utm_source') || '',
                    utm_medium: getUrlParameter('utm_medium') || '',
                    utm_campaign: getUrlParameter('utm_campaign') || '',
                    utm_content: getUrlParameter('utm_content') || '',
                    utm_term: getUrlParameter('utm_term') || ''
                }
            };

            // Enviar para endpoint do servidor
            fetch('/api/facebook-conversion', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(serverEventData)
            }).then(response => {
                if (response.ok) {
                    console.log('✅ Evento enviado para servidor:', eventName, eventID);
                } else {
                    console.error('❌ Erro ao enviar evento para servidor:', response.status);
                }
            }).catch(error => {
                console.error('❌ Erro na requisição servidor:', error);
            });
        } catch (error) {
            console.error('❌ Erro ao enviar evento servidor:', error);
        }
    }

    // Função para rastrear visualização de produto
    window.trackViewContent = function(productName, value = 0) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value
        };
        
        return trackFacebookEvent('ViewContent', eventData);
    };

    // Função para rastrear início do checkout
    window.trackInitiateCheckout = function(productName, value) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value
        };
        
        return trackFacebookEvent('InitiateCheckout', eventData);
    };

    // Função para rastrear informações de pagamento
    window.trackAddPaymentInfo = function(productName, value) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value
        };
        
        return trackFacebookEvent('AddPaymentInfo', eventData);
    };

    // Função para rastrear compra concluída
    window.trackPurchase = function(transactionId, productName, value) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value,
            transaction_id: transactionId
        };
        
        const eventID = trackFacebookEvent('Purchase', eventData);
        
        // Salvar o eventID para possível uso posterior
        localStorage.setItem('last_purchase_event_id', eventID);
        localStorage.setItem('last_purchase_transaction_id', transactionId);
        
        return eventID;
    };

    // Função para rastrear leads
    window.trackLead = function(productName, value = 0) {
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value
        };
        
        return trackFacebookEvent('Lead', eventData);
    };

    // Função para rastrear compra via terceiros (para desduplicação externa)
    window.trackExternalPurchase = function(transactionId, productName, value, externalEventID = null) {
        const eventID = externalEventID || generateEventID();
        
        const eventData = {
            content_name: productName,
            content_category: 'frete',
            currency: 'BRL',
            value: value,
            transaction_id: transactionId
        };
        
        console.log('💳 Rastreando compra externa:', transactionId, 'EventID:', eventID);
        
        // Enviar apenas via servidor para evitar duplicação com pixel de terceiros
        sendServerEvent('Purchase', eventData, eventID);
        
        // Salvar informações para debug
        localStorage.setItem('external_purchase_event_id', eventID);
        localStorage.setItem('external_purchase_transaction_id', transactionId);
        
        return eventID;
    };

    // Auto-track baseado na página atual
    document.addEventListener('DOMContentLoaded', function() {
        const path = window.location.pathname;
        
        // Evitar múltiplos eventos na mesma sessão
        const sessionKey = 'fb_events_' + path.replace(/[^a-zA-Z0-9]/g, '_');
        const lastEventTime = localStorage.getItem(sessionKey);
        const now = Date.now();
        
        // Só disparar eventos se passou mais de 30 segundos da última vez
        if (!lastEventTime || (now - parseInt(lastEventTime)) > 30000) {
            if (path.includes('pagar-pix-sedex')) {
                // Páginas PIX: disparar InitiateCheckout (são páginas de checkout real)
                trackViewContent('Frete SEDEX', 28.9);
                const eventID = trackInitiateCheckout('Frete SEDEX', 28.9);
                console.log('🎯 InitiateCheckout SEDEX PIX EventID:', eventID);
            } else if (path.includes('pagar-pix-pac')) {
                // Páginas PIX: disparar InitiateCheckout (são páginas de checkout real)
                trackViewContent('Frete PAC', 23.9);
                const eventID = trackInitiateCheckout('Frete PAC', 23.9);
                console.log('🎯 InitiateCheckout PAC PIX EventID:', eventID);
            } else if (path.includes('pagar-sedex')) {
                // Páginas de seleção de frete: apenas ViewContent
                trackViewContent('Seleção Frete SEDEX', 28.9);
                console.log('👁️ ViewContent SEDEX Seleção');
            } else if (path.includes('pagar-pac')) {
                // Páginas de seleção de frete: apenas ViewContent
                trackViewContent('Seleção Frete PAC', 23.9);
                console.log('👁️ ViewContent PAC Seleção');
            } else if (path.includes('up2/pagar')) {
                trackViewContent('Ativação Conta UP2', 20.0);
                const eventID = trackInitiateCheckout('Ativação Conta UP2', 20.0);
                console.log('🎯 InitiateCheckout UP2 EventID:', eventID);
            } else if (path.includes('/ga/')) {
                // Página de sucesso - rastrear como lead qualificado
                const eventID = trackLead('Cartão Aprovado', 0);
                console.log('🎯 Lead EventID:', eventID);
            }
            
            // Salvar timestamp para evitar duplicações
            localStorage.setItem(sessionKey, now.toString());
        } else {
            console.log('⏰ Eventos já enviados recentemente para:', path);
        }
    });

    console.log('✅ Facebook Pixel CCB carregado com sucesso');
    console.log('🔄 Sistema de desduplicação ativo');
    console.log('📊 Eventos de conversão enviados via Pixel + API de Conversões');

})();
