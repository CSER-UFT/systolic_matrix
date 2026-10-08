# =====================================================
# Makefile - Projeto FPGA Seven Segment
# Vivado 2022.2
# =====================================================

VIVADO ?= vivado
TCL_DIR := tcl

BUILD_TCL     := $(TCL_DIR)/build.tcl
SIM_POWER_TCL := $(TCL_DIR)/sim_power.tcl
PROGRAM_TCL   := $(TCL_DIR)/program_fpga.tcl

.PHONY: all build sim power program clean help

# -----------------------------------------------------
# Alvo padrão
# -----------------------------------------------------
all: build sim program

# -----------------------------------------------------
# Build: síntese + implementação + bitstream
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
	rm -rf build sevenseg_activity.vcd *.jou *.log *.str *.xpr

# -----------------------------------------------------
# Ajuda
# -----------------------------------------------------
help:
	@echo ""
	@echo "Alvos disponíveis:"
	@echo "  make           -> build + sim + program"
	@echo "  make build     -> síntese, implementação e bitstream"
	@echo "  make sim       -> simulação + VCD + power"
	@echo "  make program   -> programa a FPGA"
	@echo "  make clean     -> remove arquivos gerados"
	@echo ""
