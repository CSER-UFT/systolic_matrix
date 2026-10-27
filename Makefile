# =====================================================
# Makefile - Matriz sistólica em FPGA
# Vivado 2022.2
# =====================================================

VIVADO ?= vivado
TCL_DIR := src/hardware/tcl

BUILD_TCL     := $(TCL_DIR)/build.tcl
SIM_POWER_TCL := $(TCL_DIR)/sim_power.tcl
PROGRAM_TCL   := $(TCL_DIR)/program_fpga.tcl

.PHONY: all build sim power program clean help

# -----------------------------------------------------
# Alvo padrão
# -----------------------------------------------------
all: build sim

# -----------------------------------------------------
# Build: síntese + implementação + relatórios
# -----------------------------------------------------
build:
	@echo "==> BUILD: síntese e implementação"
	$(VIVADO) -mode batch -source $(BUILD_TCL)

# -----------------------------------------------------
# Simulação + VCD + análise de potência
# -----------------------------------------------------
sim:
	@echo "==> SIMULAÇÃO + POWER"
	$(VIVADO) -mode batch -source $(SIM_POWER_TCL)

# Alias explícito para a análise de potência feita pelo fluxo de simulação.
power: sim

# -----------------------------------------------------
# Programação da FPGA
# -----------------------------------------------------
program:
	@echo "==> PROGRAMANDO FPGA"
	$(VIVADO) -mode batch -source $(PROGRAM_TCL)

# -----------------------------------------------------
# Limpeza
# -----------------------------------------------------
clean:
	@echo "==> Limpando arquivos gerados"
	rm -rf src/hardware/build
	rm -f wave.vcd *.jou *.log *.str *.xpr

# -----------------------------------------------------
# Ajuda
# -----------------------------------------------------
help:
	@echo ""
	@echo "Alvos disponíveis:"
	@echo "  make           -> build + sim + análise de potência"
	@echo "  make build     -> síntese, implementação e relatórios"
	@echo "  make sim       -> simulação + VCD + power"
	@echo "  make power     -> alias para sim"
	@echo "  make program   -> programa a FPGA (somente com bitstream e placa conectada)"
	@echo "  make clean     -> remove arquivos gerados"
	@echo ""
