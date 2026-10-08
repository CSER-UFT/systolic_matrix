# Matriz sistólica 3×3 — documentação

## Estrutura

`systolic_array.v` conecta nove elementos `block` em uma matriz 3×3.

```text
                 inp_north0  inp_north1  inp_north2
                     |            |           |
inp_west0  -->      P0  ------>  P1  ------> P2
                     |            |           |
inp_west3  -->      P3  ------>  P4  ------> P5
                     |            |           |
inp_west6  -->      P6  ------>  P7  ------> P8
```

As entradas `inp_west0`, `inp_west3` e `inp_west6` alimentam as três linhas. As entradas `inp_north0`, `inp_north1` e `inp_north2` alimentam as três colunas.

## Larguras

| Sinal | Largura | Finalidade |
|---|---:|---|
| Entradas `inp_north*` e `inp_west*` | 4 bits | Operandos sem sinal de 0 a 15. |
| Saídas de passagem `outp_*` | 4 bits | Propagam os operandos à célula vizinha. |
| Produto `multi` | 8 bits | `15 × 15 = 225`. |
| Acumuladores `result0` a `result8` | 10 bits | Acumulam até três produtos de 8 bits (`3 × 225 = 675`). |

Os resultados são internos e podem ser vistos como `uut.result0` até `uut.result8`. Dez bits comportam os três produtos de uma operação 3×3; fluxos mais longos sem reset ainda podem causar estouro.

## Elemento de processamento

Em cada borda de subida, o PE acumula e propaga os operandos:

```verilog
result     <= result + multi;
outp_east  <= inp_west;
outp_south <= inp_north;
```

`rst` é assíncrono e ativo em nível alto. Ele zera o resultado e as saídas registradas. `multi` é combinacional: `assign multi = inp_north * inp_west;`.

## Controle

`done` é um pulso de um ciclo quando o contador alcança 5: ocorre na sexta borda após reset e repete a cada seis ciclos. Ele é um temporizador fixo e não limpa os acumuladores.

## Arquivos

| Arquivo | Papel |
|---|---|
| `block.v` | PE com entradas de 4 bits. |
| `systolic_array.v` | Topo e interconexão 3×3. |
| `sys_array_tb.v` | Estímulos de 4 bits. |
| `sim.do` | Compila o testbench e define execução de 80 ns. |

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

No VHDL, `inp_north` e `inp_west` seriam `unsigned(3 downto 0)` e `result_reg` seria `unsigned(9 downto 0)`.
