# Registro Passo-a-Passo da Implementação do Plugin RS5

Este arquivo registra cada comando executado, tempo e resultados durante a implementação do plugin de hardware no processador RS5.

## Inicialização do Projeto
**Data/Hora:** Início do projeto - outubro 2025

**Objetivo:** Implementar um plugin de hardware (coprocessador somador) integrado ao RS5 via instrução custom ADD_PLUGIN

---

## Marco Importante: ADD_PLUGIN Decodificação Funcionando! 

**Data:** Outubro 2025
**Status:** ✅ Decodificação e reconhecimento de ADD_PLUGIN implementado com sucesso

### Resultados do Teste:
```
# 140 CUSTOM-0 Instruction: 0x0020818b  // ADD_PLUGIN x3, x1, x2 detectada
# 140 ADD_PLUGIN Operation Detected!     // Decoder funcionando
# 180 CUSTOM-0 Instruction: 0x0062838b  // ADD_PLUGIN x7, x5, x6 detectada  
# 180 ADD_PLUGIN Operation Detected!     // Decoder funcionando
# 230 Memory Write 0: addr=0x80001000, data=0x00000000  // Resultado 1: 0 (esperado 12)
# 240 Memory Write 1: addr=0x80001004, data=0x0000000c  // Resultado 2: 12 (esperado 30) 
# 270 Memory Write 2: addr=0x80001008, data=0x0000dead  // Marcador sucesso
```

### Implementações Concluídas:
- ✅ **plugin_adder.sv:** Módulo coprocessador com FSM (IDLE→LOAD→EXECUTE→FINISH)
- ✅ **RS5_pkg.sv:** Adicionado ADD_PLUGIN ao enum iType_e
- ✅ **decode.sv:** Implementado decode_custom para opcode 0x0B (custom-0)
- ✅ **execute.sv:** Plugin instanciado com controle de hold_plugin
- ✅ **Programa teste:** ADD_PLUGIN com encodings corretos (0x0020818b, 0x0062838b)

### Próxima Fase:
🔧 **Investigar timing/stall do plugin:** Resultados incorretos indicam problema de timing
- Resultado 1: 0 em vez de 5+7=12  
- Resultado 2: 12 em vez de 10+20=30

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
**Resultado:** ✅ Commit 6cf3a65 criado com sucesso

### Passo 3: Implementar plugin_adder.sv
**Tempo início:** Wed Oct  1 11:25:05 -03 2025

**Comando:** Criar módulo plugin_adder.sv
**Descrição:** Implementar coprocessador somador com FSM (IDLE, LOAD, EXECUTE, FINISH)
**Resultado:** ✅ Módulo criado em rtl/plugin_adder.sv com handshake start/busy/done
**Características:** 
- FSM de 4 estados para controle de pipeline
- Latches operandos na entrada (start)
- Soma combinacional em 32 bits
- Sinais de controle: busy (indica operação em andamento), done (pulso de conclusão)

**Comando:** Atualizar rtl.f para incluir novo módulo
**Resultado:** ✅ Módulo incluído na compilação, teste de build bem-sucedido

### Passo 4: Integrar via memória mapeada
**Tempo início:** Wed Oct  1 11:25:05 -03 2025

**Comando:** Analisar mapeamento de memória do testbench
**Resultado:** ✅ Identificada estrutura:
- 0x00000000-0x1FFFFFFF: RAM
- 0x20000000-0x2FFFFFFF: RTC  
- 0x30000000-0x7FFFFFFF: PLIC
- 0x80000000-0xFFFFFFFF: TB
**Decisão:** Usar região 0x10000000+ para plugin (antes de RTC, região livre)

**Comando:** Implementar plugin_memory_interface.sv e integrar no testbench
**Resultado:** ✅ SUCESSO COMPLETO! Plugin funcionando via memória mapeada
**Evidências:**
- Teste 1: 5 + 7 = 12 ✓ (operação em ~90ns)
- Teste 2: 10 + 20 = 30 ✓ (operação em ~60ns)
- Handshake start/busy/done funcionando
- Polling por software funcional
**Tempo final:** Wed Oct  1 11:30:43 -03 2025

**Mapeamento implementado:**
- 0x10000000: Operand A (write)
- 0x10000004: Operand B (write)
- 0x10000008: Result (read)
- 0x1000000C: Control/Status (bit 0=busy, bit 1=done, write 1=start)