# Justificativa do tempo de simulação para análise de potência

O script `src/hardware/tcl/sim_power.tcl` configura e solicita uma simulação de
até `600 ns`:

```tcl
set_property xsim.simulate.runtime 600ns [get_filesets sim_1]
...
run 600 ns
```

Esse valor é um limite com margem, definido a partir da duração estimada do
teste de multiplicação de matrizes 16×16.

## Cálculo da duração necessária

No testbench `src/hardware/rtl/sys_array_tb.v`, o relógio alterna a cada
`#5`; portanto, assumindo unidade de tempo em nanossegundos, seu período é de
`10 ns`.

Para uma malha sistólica quadrada de lado `N`, o testbench usa:

```verilog
TOTAL_CYCLES = (3 * SIZE) - 2;
```

Para `SIZE = 16`:

\[
\begin{aligned}
\text{ciclos totais} &= 3 \times 16 - 2 = 46, \\
\text{tempo de processamento} &= 46 \times 10\ \text{ns} = 460\ \text{ns}.
\end{aligned}
\]

Os 46 ciclos são compostos por 16 ciclos de injeção dos elementos das
matrizes e 30 ciclos para propagar e drenar os dados pela malha
(`2 \times (16 - 1)`).

Antes da injeção, o testbench mantém o reset ativo por duas bordas de subida
do clock e o desativa na borda de descida seguinte. Isso consome `20 ns`:

\[
\text{duração estimada do teste} = 20\ \text{ns} + 460\ \text{ns}
= 480\ \text{ns}.
\]

Assim, o limite de `600 ns` disponibiliza uma folga de `120 ns`, equivalente
a 12 períodos de clock. Ele também corresponde a um valor redondo de 60
períodos de `10 ns`.

## Comportamento efetivo

O valor de `600 ns` não obriga a simulação a executar por todo esse tempo. Ao
terminar a checagem dos 256 resultados, o testbench chama `$finish`; em uma
execução normal isso acontece aproximadamente em `480 ns`, interrompendo o
comando `run` antes de seu limite máximo. O limite ainda é útil como proteção
caso o término esperado não ocorra.

## Premissa sobre unidade de tempo

O testbench não declara `` `timescale``. O cálculo acima pressupõe que o XSim
interprete `#5` em nanossegundos, como configurado/usualmente adotado no fluxo
atual. Para eliminar qualquer ambiguidade entre simuladores ou configurações,
recomenda-se adicionar no início de `sys_array_tb.v`:

```verilog
`timescale 1ns/1ps
```

Com essa declaração, o período de 10 ns e, consequentemente, a justificativa
para o teto de 600 ns ficam explicitamente definidos no código-fonte.
