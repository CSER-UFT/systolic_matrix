# Justificativa do tamanho de `CHANNELS` e `results`

## Escopo

Este documento justifica o dimensionamento dos vetores internos declarados em
`src/hardware/rtl/systolic_array.v`:

```verilog
localparam integer CHANNELS = SIZE * (SIZE + 1);

wire [CHANNELS*DATA_WIDTH-1:0] horizontal;
wire [CHANNELS*DATA_WIDTH-1:0] vertical;
wire [SIZE*SIZE*RESULT_WIDTH-1:0] results;
```

No código, o nome do parâmetro é `CHANNELS` (plural). Ele dimensiona tanto o
barramento `horizontal` quanto o `vertical`; `results` armazena o resultado
acumulado de cada elemento de processamento (PE).

## Tamanho de `CHANNELS`

Para uma malha sistólica quadrada de lado `N` (`SIZE = N`), cada linha possui
`N` PEs. Para transportar os dados pelo sentido horizontal, uma linha precisa
de `N + 1` posições de canal:

1. uma posição de entrada, que recebe `inp_west`;
2. `N - 1` posições entre PEs adjacentes;
3. uma posição de saída após o último PE.

Como existem `N` linhas, o número de canais horizontais é:

\[
N \times (N + 1).
\]

Isso é exatamente o índice empregado no RTL. A entrada da linha `row` está
na posição `row*(SIZE+1)`, e o PE da coluna `col` lê essa posição mais `col`
e escreve na posição seguinte:

```verilog
// entrada da linha row
horizontal[(row*(SIZE+1))*DATA_WIDTH +: DATA_WIDTH]

// PE (row, col): lê col e produz em col + 1
horizontal[((row*(SIZE+1))+col)*DATA_WIDTH +: DATA_WIDTH]
horizontal[((row*(SIZE+1))+col+1)*DATA_WIDTH +: DATA_WIDTH]
```

O barramento vertical segue o mesmo raciocínio, agora com `N` colunas e
`N + 1` posições por coluna: uma entrada pelo norte, `N - 1` ligações entre
PEs e uma saída ao sul. Portanto, também requer:

\[
\texttt{CHANNELS} = N(N+1).
\]

Os índices `row*SIZE + col` (entrada) e `(row+1)*SIZE + col` (saída) ocupam
as `N + 1` faixas de `N` canais do vetor `vertical`, sem sobreposição e sem
deixar de fora as saídas da última linha.

Para a configuração atual, `SIZE = 16`:

\[
\texttt{CHANNELS} = 16(16+1) = 272.
\]

Assim, cada vetor de canais possui `272` elementos de `DATA_WIDTH = 8` bits,
ou `2176` bits. São dois vetores independentes (`horizontal` e `vertical`),
totalizando `544` canais de 8 bits para as duas direções de propagação.

## Tamanho de `results`

Há um PE para cada par `(row, col)` da matriz de saída. Como a malha tem `N`
linhas e `N` colunas, ela contém:

\[
N \times N
\]

PEs e, consequentemente, o mesmo número de resultados independentes. O
vetor `results` reserva um campo de `RESULT_WIDTH` bits para cada PE:

```verilog
results[((row*SIZE)+col)*RESULT_WIDTH +: RESULT_WIDTH]
```

O termo `row*SIZE + col` converte a coordenada bidimensional do PE no índice
linear correspondente. Ele percorre todos os valores de `0` a `N^2 - 1` uma
única vez; logo, a largura necessária é:

\[
N^2 \times \texttt{RESULT\_WIDTH}.
\]

Para `SIZE = 16` e `RESULT_WIDTH = 20`:

\[
16^2 \times 20 = 256 \times 20 = 5120\ \text{bits}.
\]

Portanto, `results` contém 256 acumuladores/resultados, um para cada elemento
da matriz produto `C = A \times B`.

## Adequação de `RESULT_WIDTH`

Cada PE recebe operandos sem sinal de 8 bits. O maior produto elementar é:

\[
(2^8-1)^2 = 255 \times 255 = 65025.
\]

Cada elemento de `C` acumula `SIZE = 16` desses produtos, logo o máximo é:

\[
16 \times 65025 = 1\,040\,400.
\]

Como `2^{19} = 524\,288` é insuficiente e `2^{20} = 1\,048\,576` comporta
esse valor, `RESULT_WIDTH = 20` é a menor largura inteira segura para a
configuração atual. Dessa forma, o vetor `results` tem tamanho suficiente
tanto em número de posições quanto em largura de cada acumulador.

## Resumo

| Item | Fórmula geral | Configuração `SIZE = 16` |
|---|---:|---:|
| Canais por direção | `N(N+1)` | `272` |
| Bits de `horizontal` | `N(N+1) × DATA_WIDTH` | `2176` bits |
| Bits de `vertical` | `N(N+1) × DATA_WIDTH` | `2176` bits |
| Resultados | `N²` | `256` |
| Bits de `results` | `N² × RESULT_WIDTH` | `5120` bits |

O fator adicional `+1` em `CHANNELS` é indispensável porque cada linha ou
coluna possui uma posição de entrada e uma posição após o último PE. Já
`results` não precisa dessas posições extras: há exatamente um resultado por
PE, isto é, um por elemento da matriz produto.
