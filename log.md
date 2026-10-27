# Log de alterações

## Matriz sistólica 16×16

- `src/hardware/rtl/sys_array_tb.v`: a task `atribuir_inputs` passou a
  injetar as 16 linhas da matriz A e as 16 colunas da matriz B.
- `src/hardware/rtl/systolic_array.v`: a matriz sistólica passou a instanciar
  256 elementos d  processamento (PEs), organizados em 16 linhas e 16 colunas.
- O testbench passou a carregar integralmente os arquivos
  `src/common/matrizA.txt` e `src/common/matrizB.txt`.
- A simulação utiliza 46 ciclos: 16 ciclos para entrada dos dados e 30 ciclos
  para drenagem do pipeline da matriz sistólica.
- O testbench calcula uma multiplicação de referência e confere todos os 256
  elementos da matriz resultante.
- `src/hardware/tcl/sim_power.tcl`: o tempo de simulação foi ampliado para
  600 ns.

## Verificação

- A verificação estática com `git diff --check` foi concluída sem erros.
- A simulação não foi executada neste ambiente porque `iverilog`, `verilator`
  e `vivado` não estão instalados.
