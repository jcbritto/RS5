# Registro Passo-a-Passo da Implementação do Plugin RS5

Este arquivo registra cada comando executado, tempo e resultados durante a implementação do plugin de hardware no processador RS5.

## Inicialização do Projeto
**Data/Hora:** Início do projeto - outubro 2025

**Objetivo:** Implementar um plugin de hardware (coprocessador somador) integrado ao RS5 via instrução custom ADD_PLUGIN

---

### Passo 1: Preparação do Ambiente
**Tempo início:** Wed Oct  1 10:07:53 -03 2025

**Comando:** Verificar se Verilator está instalado
**Descrição:** Verilator é necessário para simulação do RS5 em SystemVerilog
**Resultado:** ✅ Verilator encontrado em /opt/homebrew/bin/verilator, versão 5.041

**Comando:** Verificar toolchain RISC-V
**Resultado:** ⚠️ riscv32-unknown-elf-gcc não encontrado, mas riscv64-elf-gcc está disponível (versão 15.2.0)
**Nota:** O compilador 64-bit pode ser usado para targets 32-bit com flags adequadas (-march=rv32i)

**Comando:** Verificar Git e preparar repositório