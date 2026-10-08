#!/bin/bash
set -e

# 1. Ambiente Xilinx
source /tools/Xilinx/Vivado/2022.2/settings64.sh

# 2. Preparar pasta build física
# Copiamos tudo para dentro de build para o Vivado rodar "localmente" nela
mkdir -p build
cp Makefile build/
cp -r src build/
cp -r tcl build/
cp -r constraints build/ 2>/dev/null || true

# 3. Entrar na pasta build e rodar
cd build
export HOME=$(pwd)

echo "==> Executando build dentro da pasta build física..."
# Executa o make original
make

# 4. Limpeza Pós-Execução (IMPORTANTE)
# Removemos as cópias dos fontes para que o Condor traga de volta 
# APENAS o que foi gerado (bitstream, logs, reports)
echo "==> Limpando fontes para retorno..."
rm -rf src tcl constraints Makefile

echo "==> Job finalizado. Conteúdo final da pasta build:"
ls -lh
