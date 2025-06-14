# Facebook Pixel Integration - CCB

## 📋 Configuração

**Pixel ID:** `1249534570141968`  
**Access Token:** `EAARfjYp6gD4BOZBnSxVPIcZCeF3ZCvXe1NnrgWO6lfHidEaHvJf9trVPGZA0lZA1V1w6fa1YSMyMdrbqs6WQuYPzghSk3SljrrKp77FqaE7G4oqVMsUKMMv0sagpJBh4waxtNZBmK0YtdzZA4qyEwSJInMI0QuDout9wOvsccDdGdFM4DiRZACMIs2fRnvwuTxkEPAZDZD`

## 🎯 Eventos Rastreados

### Eventos Automáticos
- **PageView** - Todas as páginas automaticamente
- **ViewContent** - Páginas de frete (baseado na URL)
- **InitiateCheckout** - Páginas de pagamento
- **Lead** - Página de sucesso (/ga/)

### Eventos Manuais
- **AddPaymentInfo** - Quando código PIX é gerado
- **Purchase** - Quando pagamento é confirmado

## 📁 Páginas com Pixel

### ✅ Implementadas
- `/quiz.html` - Página principal
- `/pagar-pix-sedex/index.html` - Pagamento SEDEX
- `/pagar-pix-pac/index.html` - Pagamento PAC  
- `/up2/pagar/index.html` - Upsell 2
- `/ga/index.html` - Página de sucesso
- `/sedex/index.html` - Seleção SEDEX
- `/type-sedex/index.html` - Tipo SEDEX
- `/type-pac/index.html` - Tipo PAC

## 🔄 Fluxo de Eventos

```
1. PageView (automático)
   ↓
2. ViewContent (produto visualizado)
   ↓ 
3. InitiateCheckout (iniciar pagamento)
   ↓
4. AddPaymentInfo (PIX gerado)
   ↓
5. Purchase (pagamento confirmado)
```

## 💰 Valores por Produto

- **Frete SEDEX:** R$ 28,90
- **Frete PAC:** R$ 23,90  
- **Ativação UP2:** R$ 20,00

## 🛠️ Funções Disponíveis

### JavaScript (Client-side)
```javascript
// Rastrear evento customizado
trackFacebookEvent('CustomEvent', { value: 10.50 });

// Rastrear visualização de conteúdo
trackViewContent('Produto X', 25.90);

// Rastrear início de checkout
trackInitiateCheckout('Produto Y', 30.00);

// Rastrear informações de pagamento
trackAddPaymentInfo('Produto Z', 15.50);

// Rastrear compra
trackPurchase('txn_123', 'Produto W', 40.00);

// Rastrear lead
trackLead('Lead Qualificado', 0);
```

### Server-side API
```javascript
// Endpoint para conversões server-side
POST /api/facebook-conversion
{
  "event_name": "Purchase",
  "event_time": 1671234567,
  "user_data": {
    "fbc": "fb.1.123.456",
    "fbp": "fb.1.456.789"
  },
  "custom_data": {
    "currency": "BRL", 
    "value": 28.90,
    "transaction_id": "txn_123"
  }
}
```

## 📊 Logs de Debug

O pixel gera logs no console para facilitar o debug:

```
🎯 Facebook Pixel inicializado: 1249534570141968
📊 Enviando evento Facebook: ViewContent {value: 28.9}
✅ Facebook Pixel CCB carregado com sucesso
```

## 🔗 UTM Integration

O pixel automaticamente captura e envia parâmetros UTM nas conversões:
- `utm_source`
- `utm_medium` 
- `utm_campaign`
- `utm_content`
- `utm_term`

## 🎛️ Conversions API (Server-side)

Para máxima precisão de tracking, implementamos também o server-side tracking via Conversions API do Facebook, que:

- Bypassa bloqueadores de anúncios
- Melhora a atribuição iOS 14.5+
- Reduz perda de dados por cookies
- Aumenta a qualidade dos dados

## 🚀 Como Testar

1. Abra qualquer página com o pixel
2. Abra o console do navegador (F12)
3. Procure pelos logs do Facebook Pixel
4. Verifique no Facebook Events Manager se os eventos estão sendo recebidos

## 📈 Métricas no Facebook

No Facebook Ads Manager você poderá ver:
- **Alcance** - Quantas pessoas viram seus anúncios
- **Cliques** - Quantos clicaram
- **Conversões** - Quantos compraram
- **ROI** - Retorno sobre investimento
- **CPA** - Custo por aquisição

Todos os eventos estão configurados para máxima eficiência de tracking e otimização de campanhas! 🎯
