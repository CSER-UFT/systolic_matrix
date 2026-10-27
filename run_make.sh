#!/usr/bin/env bash
set -euo pipefail

# Executa a partir do diretório transferido pelo HTCondor.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Carrega Vivado apenas se ele ainda não estiver disponível no ambiente do nó.
if ! command -v vivado >/dev/null 2>&1; then
    VIVADO_SETTINGS=/tools/Xilinx/Vivado/2022.2/settings64.sh
    if [[ ! -r "$VIVADO_SETTINGS" ]]; then
        echo "Erro: Vivado 2022.2 não está disponível em $VIVADO_SETTINGS." >&2
        exit 1
    fi
    # shellcheck disable=SC1090
    source "$VIVADO_SETTINGS"
fi

echo "==> Executando síntese, implementação, simulação e análise de potência..."
make build sim

echo "==> Job finalizado. Artefatos: src/hardware/build"
