#!/bin/bash

# Script auxiliar para execução dos scripts Python
# Uso: ./run_step.sh <numero_do_passo>

PYTHON_PATH="/Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/.venv/bin/python"
SCRIPT_DIR="/Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/passo_a_passo"

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <numero_do_passo>"
    echo "Exemplo: $0 1  (para executar o passo 1)"
    echo ""
    echo "Passos disponíveis:"
    echo "  1 - Selecionar imagem"
    echo "  2 - Converter imagem"
    echo "  3 - Gerar programa C"
    echo "  4 - Compilar programa"
    echo "  5 - Preparar simulação"
    echo "  6 - Executar Verilator"
    echo "  7 - Reconstruir imagem"
    exit 1
fi

STEP=$1

if [ "$STEP" -lt 1 ] || [ "$STEP" -gt 7 ]; then
    echo "❌ Passo inválido. Use números de 1 a 7."
    exit 1
fi

echo "🚀 Executando passo $STEP..."
echo ""

cd "$SCRIPT_DIR"
$PYTHON_PATH "${STEP}_"*.py

echo ""
echo "✅ Passo $STEP concluído!"

if [ "$STEP" -lt 7 ]; then
    NEXT_STEP=$((STEP + 1))
    echo ""
    echo "🎯 PRÓXIMO PASSO:"
    echo "   $0 $NEXT_STEP"
fi