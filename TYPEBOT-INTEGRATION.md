# Teste de URL com parâmetros do Typebot

## Exemplo de URL que o Typebot geraria:
```
http://localhost:3000/cep/index.html?name=João%20da%20Silva&cpf=123.456.789-00&phone=(11)99999-9999&email=joao@email.com&birthdate=01/01/1990&utm_source=facebook&utm_medium=cpc&utm_campaign=cartao2024&fbclid=abc123
```

## Parâmetros suportados pelo sistema:

### Dados do usuário (salvos em localStorage):
- `name`, `nome`, `full_name`, `fullname` → normalizado para `name`
- `cpf`, `documento`, `doc` → normalizado para `cpf` 
- `phone`, `telefone`, `celular`, `whatsapp` → normalizado para `phone`
- `email`, `e_mail` → normalizado para `email`
- `birthdate`, `nascimento`, `data_nascimento` → normalizado para `birthdate`
- `mother_name`, `nome_mae` → normalizado para `mother_name`

### Parâmetros de tracking (preservados na URL):
- UTM: `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`, `utm_id`
- Facebook: `fbclid`, `fbc`, `fbp`, `fb_action_ids`, `fb_action_types`, `fb_source`
- Google: `gclid`, `gclsrc`, `gbraid`, `wbraid`
- Outros: `msclkid`, `ttclid`, `li_fat_id`, `twclid`, `referrer`, `ref`, `source`

## Fluxo implementado:

1. **Chegada na página CEP**: 
   - URL contém todos os parâmetros do Typebot
   - JavaScript captura e salva dados no localStorage
   - URL é limpa mantendo apenas a base

2. **Navegação para próxima página**:
   - Dados do usuário vêm do localStorage (não da URL)
   - Apenas parâmetros de tracking são passados na URL

3. **Vantagens**:
   - ✅ Dados sensíveis não ficam expostos na URL
   - ✅ Parâmetros de tracking preservados para analytics
   - ✅ Compatibilidade com múltiplas variações de nomes de parâmetros
   - ✅ Validação antes de prosseguir
   - ✅ Logs detalhados para debug

## Para testar:

1. Abra a página CEP com parâmetros de teste
2. Verifique o console do navegador para logs
3. Inspecione o localStorage no DevTools
4. Confirme que a URL foi limpa
5. Prossiga para próxima página e verifique se dados persistem
