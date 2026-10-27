# Matriz sistólica 16×16 — documentação

## Estrutura

`systolic_array.v` conecta 256 elementos `block` em uma matriz 16×16.

Os barramentos `inp_west` e `inp_north` possuem 16 elementos de 8 bits cada.
`inp_west[i]` alimenta a linha `i`, enquanto `inp_north[j]` alimenta a
coluna `j`.

## Larguras

| Sinal | Largura | Finalidade |
|---|---:|---|
| Cada elemento de `inp_north` e `inp_west` | 8 bits | Operandos sem sinal de 0 a 255. |
| Saídas de passagem `outp_*` | 8 bits | Propagam os operandos à célula vizinha. |
| Produto `multi` | 16 bits | `255 × 255 = 65025`. |
| Cada elemento de `results` | 20 bits | Acumula 16 produtos (`16 × 65025 = 1040400`). |

Os 256 resultados ficam no barramento interno `results` e podem ser vistos no
testbench como `uut.results`. Cada posição ocupa 20 bits.

## Elemento de processamento

Em cada borda de subida, o PE acumula e propaga os operandos:

```verilog
result     <= result + multi;
outp_east  <= inp_west;
outp_south <= inp_north;
```

`rst` é assíncrono e ativo em nível alto. Ele zera o resultado e as saídas registradas. `multi` é combinacional: `assign multi = inp_north * inp_west;`.

## Controle

`done` é um pulso de um ciclo após 46 ciclos: 16 ciclos de dados mais os 30
ciclos necessários para drenar a malha 16×16. Ele não limpa os acumuladores.

## Arquivos

| Arquivo | Papel |
|---|---|
| `block.v` | PE com entradas de 8 bits e acumulador de 20 bits. |
| `systolic_array.v` | Topo e interconexão 16×16. |
| `sys_array_tb.v` | Carrega as matrizes 16×16, aplica os estímulos e confere os 256 resultados. |
| `tcl/sim_power.tcl` | Executa 600 ns de simulação, captura o VCD e gera o relatório de potência. |
| `tcl/build.tcl` | Sintetiza, implementa e gera relatórios de análise. |
| `tcl/sim_power.tcl` | Executa a simulação, captura VCD e gera relatório de potência. |

## Fluxo Vivado

Os scripts ficam em `src/hardware/tcl/` e gravam os artefatos em
`src/hardware/build/`. O arquivo
`src/hardware/constraints/systolic_array.xdc` já restringe o clock de 100 MHz
para análise. Ele não mapeia os 256 bits de entrada para pinos físicos; assim,
o fluxo gera relatórios de implementação, não um bitstream programável. O plano
para uma futura interface física está documentado em
`src/hardware/constraints/README.md`. A XDC da raiz do projeto é específica para
o display de sete segmentos e não deve ser usada para essa matriz.

Com o Vivado 2022.2 disponível no `PATH`, execute a partir da raiz do projeto:

```sh
vivado -mode batch -source src/hardware/tcl/build.tcl
vivado -mode batch -source src/hardware/tcl/sim_power.tcl
```

Um bitstream só pode ser gerado/programado depois de validar a peça, criar um
topo com interface física viável e completar a XDC para a placa escolhida.

## Comparação com VHDL

| Verilog | VHDL |
|---|---|
| `module ... endmodule` | `entity` e `architecture` |
| `input [3:0] a` | `a : in unsigned(3 downto 0)` |
| `wire [9:0] result` | `signal result : unsigned(9 downto 0)` |
| `always @(posedge clk or posedge rst)` | `process(clk, rst)` com `rising_edge(clk)` |
| `block P0 (...)` | `P0: entity work.block port map (...)` |

O núcleo sequencial equivalente em VHDL usa `ieee.numeric_std`:

```vhdl
if rst = '1' then
  result_reg <= (others => '0');
elsif rising_edge(clk) then
  result_reg <= result_reg + resize(inp_north * inp_west, result_reg'length);
  outp_east  <= inp_west;
  outp_south <= inp_north;
end if;
```

No VHDL, cada elemento de `inp_north` e `inp_west` seria
`unsigned(7 downto 0)` e `result_reg` seria `unsigned(19 downto 0)`.
