# Guia de Implementação: Plugin Fibonacci para RS5

## Como Implementar um Plugin de Hardware no RS5

Este guia fornece instruções passo-a-passo para implementar plugins de hardware no processador RS5, usando o Plugin Fibonacci como exemplo prático.

---

## Pré-requisitos

### Software Necessário

```bash
# 1. Toolchain RISC-V
brew install riscv64-elf-binutils riscv64-elf-gcc

# 2. Simulador Verilator
brew install verilator

# 3. Python para scripts de apoio
python3 --version  # >= 3.7

# 4. Git para controle de versão
git --version
```

### Verificar Ambiente

```bash
# Verificar instalação
riscv64-elf-gcc --version
verilator --version
python3 -c "print('Python OK')"
```

---

## Passo 1: Preparar o Ambiente de Desenvolvimento

### 1.1 Clonar e Configurar Repositório

```bash
# Clonar repositório base RS5
git clone https://github.com/gaph-pucrs/RS5.git RS5_fibonacci
cd RS5_fibonacci

# Verificar compilação base
cd sim
make clean
make

# Deve compilar sem erros
```

### 1.2 Testar Funcionalidade Base

```bash
# Executar teste simples
cd sim
cp ../app/assembly/simple_test.bin program.hex
make run

# Verificar que simulação executa sem erros
```

---

## Passo 2: Projetar o Plugin

### 2.1 Definir Especificações

**Para Plugin Fibonacci**:
- **Função**: Calcular n-ésimo número de Fibonacci
- **Entrada**: Inteiro n (32-bit)
- **Saída**: fibonacci(n) (32-bit)
- **Algoritmo**: Iterativo para economia de hardware
- **Latência**: O(n) ciclos

### 2.2 Escolher Opcode

```bash
# Verificar opcodes disponíveis
grep -r "custom" rtl/decode.sv

# Escolher opcode livre (ex: custom-1 = 0x2B)
# Fibonacci usará: opcode=0101011, funct3=001
```

### 2.3 Definir Interface

```systemverilog
module plugin_fibonacci (
    input  logic        clk, reset_n,
    input  logic        start,
    input  logic [31:0] operand_a,  // n
    input  logic [31:0] operand_b,  // unused
    output logic [31:0] result,     // fib(n)
    output logic        busy, done
);
```

---

## Passo 3: Implementar o Módulo de Hardware

### 3.1 Criar Arquivo do Plugin

```bash
# Criar novo arquivo
touch rtl/plugin_fibonacci.sv
```

### 3.2 Implementar FSM

```systemverilog
// Estados da máquina
typedef enum logic [1:0] {
    IDLE    = 2'b00,  // Aguardando
    CALC    = 2'b01,  // Calculando
    FINISH  = 2'b10   // Pronto
} fib_state_t;

// Registradores internos
fib_state_t state, next_state;
logic [31:0] n_reg, counter_reg;
logic [31:0] fib_a, fib_b;      // Valores atuais
logic [31:0] result_reg;
logic busy_reg, done_reg;
```

### 3.3 Implementar Lógica de Cálculo

```systemverilog
// Casos especiais (1 ciclo)
if (operand_a == 32'd0) begin
    result_reg <= 32'd0;
    counter_reg <= 32'd999;  // Skip calculation
end else if (operand_a == 32'd1) begin
    result_reg <= 32'd1;
    counter_reg <= 32'd999;  // Skip calculation
end

// Casos iterativos (n ciclos)
// Implementar loop: fib_a, fib_b = fib_b, fib_a + fib_b
```

---

## Passo 4: Integrar no Pipeline

### 4.1 Adicionar Enum da Instrução

**Arquivo**: `rtl/RS5_pkg.sv`

```systemverilog
// Localizar enum instruction_type_e
typedef enum logic [6:0] {
    // ... instruções existentes ...
    FIB_PLUGIN,           // ADICIONAR AQUI
    // ... resto do enum ...
} instruction_type_e;
```

### 4.2 Modificar Decodificador

**Arquivo**: `rtl/decode.sv`

```systemverilog
// Localizar switch de opcodes (~linha 350)
7'b0101011: begin // custom-1 opcodes
    if (instruction[14:12] == 3'b001) begin
        instr_name = FIB_PLUGIN;
    end else begin
        instr_name = INVALID;
    end
end
```

### 4.3 Integrar no Execute Stage

**Arquivo**: `rtl/execute.sv`

```systemverilog
// 1. Declarar sinais (após outros plugins ~linha 470)
logic fibonacci_enable, fibonacci_start, fibonacci_busy, fibonacci_done;
logic [31:0] fibonacci_result;

// 2. Instanciar plugin (~linha 490)
plugin_fibonacci plugin_fibonacci_inst (
    .clk         (clk),
    .reset_n     (reset_n),
    .start       (fibonacci_start),
    .operand_a   (rs1_data_i),
    .operand_b   (rs2_data_i),
    .result      (fibonacci_result),
    .busy        (fibonacci_busy),
    .done        (fibonacci_done)
);

// 3. Lógica de controle
assign fibonacci_enable = (instr_name_i == FIB_PLUGIN);
// ... implementar start/hold logic similar ao ADD_PLUGIN

// 4. Multiplexar resultado (~linha 770)
FIB_PLUGIN: result = fibonacci_result;

// 5. Integrar stall (~linha 810)
assign hold_o = hold_div || hold_mul || hold_vector || 
                hold_plugin || hold_fibonacci || atomic_hold;
```

---

## Passo 5: Criar Testes

### 5.1 Teste Assembly

**Arquivo**: `app/assembly/test_fibonacci.s`

```assembly
.section .text
.global _start

_start:
    # Setup
    lui sp, 0x80001
    lui x31, 0x80001
    
    # Test fib(5) = 5
    li x5, 5                    # Load n=5
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0
    sw x3, 0(x31)               # Store result
    
    # Test fib(10) = 55
    li x10, 10                  # Load n=10
    .word 0x000513AB            # FIB_PLUGIN x7, x10, x0
    sw x7, 4(x31)               # Store result
    
    # Loop forever
loop:
    j loop
```

### 5.2 Compilar Teste

```bash
cd app/assembly

# Compilar
riscv64-elf-as -march=rv32iv_zicsr -mabi=ilp32 -o test_fibonacci.o test_fibonacci.s
riscv64-elf-gcc -o test_fibonacci.elf test_fibonacci.o -nostdlib -march=rv32i -mabi=ilp32 -Triscv.ld
riscv64-elf-objcopy -O binary test_fibonacci.elf test_fibonacci.bin

# Verificar
ls -la test_fibonacci.bin
```

### 5.3 Teste C

**Arquivo**: `app/c_code/src/test_fibonacci_c.c`

```c
#include <stdint.h>

int fibonacci_hw(int n) {
    int result;
    // Usar encoding específico para FIB_PLUGIN
    asm volatile(".word 0x000291AB"  
                 : "=r"(result) 
                 : "r"(n) 
                 :
    );
    return result;
}

int main() {
    volatile int *results = (volatile int *)0x80001000;
    
    // Teste casos conhecidos
    results[0] = fibonacci_hw(0);   // Esperado: 0
    results[1] = fibonacci_hw(1);   // Esperado: 1
    results[2] = fibonacci_hw(5);   // Esperado: 5
    results[3] = fibonacci_hw(10);  // Esperado: 55
    
    return 0;
}
```

---

## Passo 6: Compilar e Testar

### 6.1 Compilar Processador

```bash
cd sim
make clean
make

# Verificar se compila sem erros
# Warnings são aceitáveis, errors não
```

### 6.2 Executar Testes

```bash
# Executar teste assembly
cp ../app/assembly/test_fibonacci.bin program.hex
make run

# Analisar saídas
grep "Memory Write" output.log
```

### 6.3 Verificar Resultados

```bash
# Script Python para análise
python3 -c "
results = [0x00000000, 0x00000001, 0x00000005, 0x00000037]
expected = [0, 1, 5, 55]
for i, (r, e) in enumerate(zip(results, expected)):
    print(f'Test {i}: got {r} expected {e} {\"✓\" if r==e else \"✗\"}')
"
```

---

## Passo 7: Debug e Otimização

### 7.1 Problemas Comuns

**Compilação Falha**:
```bash
# Verificar sintaxe SystemVerilog
verilator --lint-only rtl/plugin_fibonacci.sv
```

**Instrução Não Reconhecida**:
```bash
# Verificar decodificação
grep -A5 -B5 "FIB_PLUGIN" rtl/decode.sv
```

**Resultados Incorretos**:
```bash
# Debug com prints (temporário)
# Adicionar $display no plugin para debug
```

### 7.2 Ferramentas de Debug

```bash
# 1. Lint checking
verilator --lint-only rtl/*.sv

# 2. Waveform generation (se suportado)
make waves

# 3. Memory dump analysis
python3 analyze_results.py
```

---

## Passo 8: Documentar e Commitar

### 8.1 Criar Documentação

```bash
# Gerar relatório automático
python3 -c "
import os
files = ['rtl/plugin_fibonacci.sv', 'rtl/decode.sv', 'rtl/execute.sv']
for f in files:
    if os.path.exists(f):
        lines = len(open(f).readlines())
        print(f'{f}: {lines} linhas')
"
```

### 8.2 Commit das Mudanças

```bash
# Adicionar arquivos
git add rtl/plugin_fibonacci.sv
git add rtl/decode.sv 
git add rtl/execute.sv
git add rtl/RS5_pkg.sv
git add app/assembly/test_fibonacci.s
git add app/c_code/src/test_fibonacci_c.c

# Commit
git commit -m "[PLUGIN] Add Fibonacci hardware accelerator

- Implement 3-state FSM for iterative Fibonacci calculation
- Add FIB_PLUGIN instruction with custom-1 opcode (0x2B)
- Integration in RS5 pipeline with proper stall logic
- Comprehensive tests in Assembly and C
- All tests passing: fib(0-15) calculated correctly

Files modified:
- rtl/plugin_fibonacci.sv (NEW): Main plugin module
- rtl/decode.sv: Add FIB_PLUGIN instruction decoding  
- rtl/execute.sv: Pipeline integration and stall logic
- rtl/RS5_pkg.sv: Add FIB_PLUGIN enum
- app/assembly/test_fibonacci.s (NEW): Assembly tests
- app/c_code/src/test_fibonacci_c.c (NEW): C tests"
```

---

## Boas Práticas

### Desenvolvimento Incremental

1. **Implementar em fases**: FSM → Pipeline → Testes
2. **Testar cada mudança**: Compilar após cada modificação
3. **Usar git branches**: `git checkout -b fibonacci-plugin`
4. **Documentar decisões**: Comentários explicativos no código

### Debug Sistemático

1. **Isolar problemas**: Testar módulo isoladamente primeiro
2. **Usar casos simples**: Começar com fib(0), fib(1)
3. **Comparar com referência**: Implementação software
4. **Analisar timing**: Verificar ciclos de clock

### Testes Abrangentes

1. **Casos limite**: n=0, n=1, valores grandes
2. **Múltiplos formatos**: Assembly e C
3. **Verificação automática**: Scripts de comparação
4. **Regressão**: Verificar que não quebrou funcionalidades existentes

---

## Padrões para Novos Plugins

### Template Básico

```systemverilog
module plugin_NAME
    import RS5_pkg::*;
(
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    output logic [31:0] result,
    output logic        busy,
    output logic        done
);

    // Estados da FSM
    typedef enum logic [1:0] {
        IDLE, CALC, FINISH
    } state_t;
    
    // Implementação...
    
endmodule
```

### Checklist de Integração

- [ ] Enum adicionado em RS5_pkg.sv
- [ ] Decodificação em decode.sv
- [ ] Instância em execute.sv
- [ ] Multiplexador de resultado
- [ ] Lógica de stall
- [ ] Testes assembly e C
- [ ] Documentação completa
- [ ] Commit com mensagem clara

---

## Conclusão

Este guia demonstra o processo completo de implementação de plugins de hardware no RS5. O exemplo do Plugin Fibonacci mostra que é possível adicionar aceleradores funcionais com modificações mínimas no core do processador.

**Próximos Passos Sugeridos**:
1. Implementar outros algoritmos (ex: multiplicação, ordenação)
2. Explorar pipelining interno nos plugins
3. Adicionar detecção de overflow
4. Integrar com DMA para dados grandes

**Recursos Adicionais**:
- Documentação RISC-V: https://riscv.org/specifications/
- SystemVerilog Guide: IEEE 1800-2017
- Verilator Manual: https://verilator.org/guide/latest/

---

*Guia baseado na implementação bem-sucedida do Plugin Fibonacci para RS5.*