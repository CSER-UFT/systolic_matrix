# Avaliação da Performance de Multiplicação Sistólica de Matrizes em FPGA

Projeto de Iniciação Científica desenvolvido na Universidade Federal do Tocantins (UFT), com foco no estudo e implementação de aceleradores de hardware para multiplicação de matrizes utilizando arquiteturas sistólicas em FPGA.

O projeto busca avaliar o desempenho computacional e a eficiência energética de uma implementação em hardware, comparando-a com uma implementação equivalente executada em CPU.

---

## Sobre o projeto

Operações de multiplicação de matrizes são fundamentais em diversas áreas da computação, especialmente em aplicações de Inteligência Artificial, Machine Learning e processamento de imagens.

Este projeto investiga o uso de uma arquitetura sistólica implementada em FPGA como alternativa para acelerar essas operações.

A arquitetura será descrita utilizando **Verilog** e implementada em uma FPGA **Xilinx Spartan-7**, utilizando o ambiente **AMD/Xilinx Vivado Design Suite**.

Como baseline de comparação será utilizada uma implementação em CPU baseada na biblioteca **OpenBLAS**, utilizando operações GEMM (*General Matrix-Matrix Multiplication*).

---

## Objetivos

O objetivo principal é desenvolver e avaliar um acelerador de hardware para multiplicação de matrizes baseado em uma arquitetura sistólica.

Entre os objetivos específicos estão:

- estudar o funcionamento da multiplicação sistólica de matrizes;
- projetar unidades MAC (*Multiply-Accumulate*);
- construir um array sistólico utilizando essas unidades;
- implementar o acelerador em FPGA;
- desenvolver uma implementação equivalente em CPU;
- utilizar OpenBLAS como baseline de desempenho;
- coletar métricas de desempenho;
- analisar consumo e eficiência energética;
- comparar as abordagens FPGA e CPU.

---

## Tecnologias

As principais tecnologias utilizadas no projeto serão:

### Hardware

- FPGA Xilinx Spartan-7
- Arquitetura sistólica
- Unidades MAC (*Multiply-Accumulate*)

### HDL

- Verilog

### FPGA Toolchain

- AMD/Xilinx Vivado Design Suite 2022.2

### CPU Baseline

- C / C++
- OpenBLAS
- GEMM (*General Matrix-Matrix Multiplication*)

### Ambiente computacional

- Linux
- Servidor Saruê
- Git
- GitHub

---

