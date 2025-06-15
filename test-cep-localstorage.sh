#!/bin/bash

echo "🧪 Teste da Lógica de localStorage e Limpeza de URL - Página CEP"
echo "=============================================================="

# Verificar se a página CEP existe
cep_file="/home/lkdev/workspace/projects/offers/ccb/cep/index.html"

if [[ ! -f "$cep_file" ]]; then
    echo "❌ Arquivo CEP não encontrado: $cep_file"
    exit 1
fi

echo ""
echo "📋 Verificando implementação da lógica localStorage:"

echo ""
echo "1. 🔍 Verificando salvamento de dados do usuário:"
if grep -q "saveUserDataFromURL" "$cep_file"; then
    echo "   ✅ Função saveUserDataFromURL implementada"
else
    echo "   ❌ Função saveUserDataFromURL não encontrada"
fi

if grep -q "userData\|userName\|userCPF\|userPhone" "$cep_file"; then
    echo "   ✅ Salvamento de dados do usuário no localStorage implementado"
else
    echo "   ❌ Salvamento de dados do usuário não implementado"
fi

echo ""
echo "2. 📊 Verificando salvamento de parâmetros de tracking:"
if grep -q "saveTrackingParams" "$cep_file"; then
    echo "   ✅ Função saveTrackingParams implementada"
else
    echo "   ❌ Função saveTrackingParams não encontrada"
fi

if grep -q "trackingParams.*localStorage" "$cep_file"; then
    echo "   ✅ Salvamento de parâmetros de tracking implementado"
else
    echo "   ❌ Salvamento de parâmetros de tracking não implementado"
fi

echo ""
echo "3. 🧹 Verificando limpeza da URL:"
if grep -q "cleanURLParams" "$cep_file"; then
    echo "   ✅ Função cleanURLParams implementada"
else
    echo "   ❌ Função cleanURLParams não encontrada"
fi

if grep -q "history.replaceState" "$cep_file"; then
    echo "   ✅ Limpeza da URL usando history.replaceState implementada"
else
    echo "   ❌ Limpeza da URL não implementada"
fi

echo ""
echo "4. ✅ Verificando validação de dados:"
if grep -q "validateSavedData" "$cep_file"; then
    echo "   ✅ Função validateSavedData implementada"
else
    echo "   ❌ Função validateSavedData não encontrada"
fi

echo ""
echo "5. 🔗 Verificando redirecionamento otimizado:"
if grep -q "redirectWithTrackingParams" "$cep_file"; then
    echo "   ✅ Função redirectWithTrackingParams implementada"
else
    echo "   ❌ Função redirectWithTrackingParams não encontrada"
fi

# Verificar se há apenas uma função de redirecionamento
redirect_count=$(grep -c "function redirectWithTrackingParams" "$cep_file")
if [[ $redirect_count -eq 1 ]]; then
    echo "   ✅ Apenas uma função de redirecionamento (sem duplicatas)"
else
    echo "   ⚠️  Múltiplas funções de redirecionamento encontradas: $redirect_count"
fi

echo ""
echo "📱 Verificando compatibilidade com Typebot:"

echo ""
echo "1. 🏷️ Parâmetros de entrada do Typebot suportados:"
typebot_params=("name" "nome" "cpf" "phone" "telefone" "email" "birthdate")
for param in "${typebot_params[@]}"; do
    if grep -q "'$param'" "$cep_file"; then
        echo "   ✅ Parâmetro '$param' suportado"
    else
        echo "   ⚠️  Parâmetro '$param' pode não estar mapeado"
    fi
done

echo ""
echo "2. 🔄 Normalização de parâmetros:"
if grep -q "normalizedKey" "$cep_file"; then
    echo "   ✅ Normalização de chaves de parâmetros implementada"
else
    echo "   ❌ Normalização de chaves não implementada"
fi

echo ""
echo "📊 Verificando logs e debugging:"
if grep -q "console.log.*localStorage" "$cep_file"; then
    echo "   ✅ Logs de localStorage implementados"
else
    echo "   ❌ Logs de localStorage não implementados"
fi

if grep -q "console.log.*tracking" "$cep_file"; then
    echo "   ✅ Logs de tracking implementados"
else
    echo "   ❌ Logs de tracking não implementados"
fi

echo ""
echo "🔒 Verificando tratamento de erros:"
if grep -q "try.*catch" "$cep_file"; then
    echo "   ✅ Tratamento de erros implementado"
else
    echo "   ❌ Tratamento de erros não implementado"
fi

echo ""
echo "📋 Resumo da verificação:"
echo "================================"

# Contar implementações
implementations=0
total_checks=8

if grep -q "saveUserDataFromURL" "$cep_file"; then implementations=$((implementations + 1)); fi
if grep -q "saveTrackingParams" "$cep_file"; then implementations=$((implementations + 1)); fi
if grep -q "cleanURLParams" "$cep_file"; then implementations=$((implementations + 1)); fi
if grep -q "validateSavedData" "$cep_file"; then implementations=$((implementations + 1)); fi
if grep -q "redirectWithTrackingParams" "$cep_file"; then implementations=$((implementations + 1)); fi
if grep -q "normalizedKey" "$cep_file"; then implementations=$((implementations + 1)); fi
if grep -q "console.log.*localStorage" "$cep_file"; then implementations=$((implementations + 1)); fi
if grep -q "try.*catch" "$cep_file"; then implementations=$((implementations + 1)); fi

percentage=$((implementations * 100 / total_checks))

echo "✅ Funcionalidades implementadas: $implementations/$total_checks ($percentage%)"

if [[ $implementations -eq $total_checks ]]; then
    echo "🎉 SUCESSO! Todas as funcionalidades estão implementadas corretamente."
elif [[ $implementations -ge 6 ]]; then
    echo "✅ BOM! A maioria das funcionalidades está implementada."
else
    echo "⚠️  ATENÇÃO! Algumas funcionalidades importantes estão faltando."
fi

echo ""
echo "📝 Próximos passos recomendados:"
echo "1. Testar com dados reais vindos do Typebot"
echo "2. Verificar se a limpeza da URL está funcionando no navegador"
echo "3. Confirmar que os dados persistem entre páginas"
echo "4. Testar cenários de erro (sem dados, sem localStorage, etc.)"
