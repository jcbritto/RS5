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
**Resultado:** ✅ Repositório inicializado, RS5 original clonado e commitado como [Step 0]
**Commit hash:** dbe723b

**Comando:** Explorar estrutura do RS5
**Tempo:** Wed Oct  1 10:08:45 -03 2025
**Resultado:** ⚠️ Simulação travou - programa assembly muito complexo ou loop infinito
**Problema:** O programa vectorlsu.s parece ter instruções vetoriais que podem estar causando travamento

**Comando:** Tentar com programa mais simples
**Resultado:** ✅ Simulação funcionando! Criado simple_test.s e rodou por 100us antes do timeout
**Tempo final:** Wed Oct  1 11:21:57 -03 2025
**Observação:** RS5 está operacional no macOS com Verilator. Pipeline de 4 estágios funcionando.

### Commit [Step 0]
**Comando:** git commit inicial com RS5 original + modificações para macOS