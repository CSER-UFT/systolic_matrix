# Auditoria do fluxo Make e HTCondor

## Escopo e conclusão

Foram examinados `Makefile`, `run_make.sh` e `run_make.sub`, além dos TCLs
referenciados. A sintaxe Bash de `run_make.sh` é válida, mas o fluxo não está
operacional nem suficientemente configurado para uma execução reprodutível no
HTCondor. Os problemas abaixo impedem o job de completar como está.

## Falhas bloqueantes

1. Em `run_make.sh`, o comando abaixo não informa um destino e falha. Como o
   script usa `set -e`, o job termina imediatamente:

   ```sh
   cp -r src/hardware/constraints/
   ```

2. Ainda que o destino fosse `build/`, o script copiaría os diretórios como
   `build/rtl`, `build/tcl` e `build/constraints`. Dentro de `build/`, o
   Makefile procura `src/hardware/tcl/build.tcl`; portanto, `make` não
   encontra o script de build.

3. O alvo padrão é `all: build sim program`. Os TCLs de build e de potência
   aceitam a XDC de análise atual, que restringe somente o clock, e geram os
   relatórios sem exigir o mapeamento físico completo da interface. Já
   `program_fpga.tcl` exige um bitstream e uma FPGA conectada. Assim, `make`
   falha na programação; essa etapa também não é apropriada para um nó Condor.

## Inconsistências adicionais

- O alvo `power` está listado em `.PHONY`, mas não possui receita.
- `clean` remove artefatos antigos na raiz (`build/` e
  `sevenseg_activity.vcd`), enquanto o fluxo sistólico usa
  `src/hardware/build/`.
- O cabeçalho do Makefile e os diretórios `tcl/` e `constraints/` da raiz
  descrevem o exemplo de sete segmentos, não a matriz sistólica. O submit
  transfere esses diretórios sem necessidade.
- O submit não solicita CPU, memória ou disco, apesar de os TCLs executarem
  síntese/implementação com `-jobs 4`.
- Redefinir `HOME` no job não é necessário e pode afetar configurações de
  licença e cache do Vivado.

## Fluxo recomendado

O job deve executar no diretório que o Condor já prepara, sem copiar fontes
para uma subpasta. A ação automatizada deve limitar-se a:

```sh
make build sim
```

`make program` deve permanecer manual, em uma máquina com a FPGA conectada e
após a geração válida de bitstream. Uma configuração base para o submit é:

```text
transfer_input_files = Makefile, src
transfer_output_files = src/hardware/build
request_cpus = 4
request_memory = 8GB
request_disk = 10GB
```

Também é necessário garantir que os nós elegíveis tenham Vivado 2022.2 e a
licença correspondente disponíveis. A auditoria de build e simulação não
requer uma XDC completa: basta a restrição de clock fornecida para analisar os
caminhos internos. Uma XDC completa e uma interface física viável só serão
necessárias caso a programação da placa seja reativada.

## Correções aplicadas

As configurações foram atualizadas conforme o fluxo recomendado: `make` agora
executa somente `build` e `sim`; `program` permanece explícito e manual; e
`power` passou a ser um alias válido para `sim`. A limpeza foi alinhada a
`src/hardware/build/`.

O `run_make.sh` não copia mais fontes, não redefine `HOME` e executa `make
build sim` diretamente no diretório preparado pelo Condor. Ele verifica a
disponibilidade do Vivado e carrega o ambiente 2022.2 apenas quando necessário.
O submit transfere somente `Makefile` e `src`, retorna
`src/hardware/build` e solicita quatro CPUs, 8 GB de memória e 10 GB de disco.

Essas alterações foram verificadas estaticamente. A validação final requer a
submissão em um nó elegível com Vivado 2022.2 e licença disponíveis.
