# 🚀 **GUIA COMPLETO PARA IMPLEMENTAÇÃO DE NOVOS ACELERADORES NO RS5**

Este documento fornece um passo-a-passo detalhado para implementar novos coprocessadores de hardware no processador RS5 RISC-V.

## 📋 **RESUMO DO QUE FOI IMPLEMENTADO**

### **Arquivos Principais Modificados:**

1. **`rtl/plugin_adder.sv`** - Módulo do coprocessador (NOVO)
2. **`rtl/RS5_pkg.sv`** - Adicionado tipo `ADD_PLUGIN` 
3. **`rtl/decode.sv`** - Decodificação da instrução custom
4. **`rtl/execute.sv`** - Integração no pipeline e stall
5. **`sim/testbench.sv`** - Debug e monitoramento (opcional)

---

## 🔧 **PASSO 1: CRIAR MÓDULO DO COPROCESSADOR**

### **Template Base (`rtl/your_accelerator.sv`):**

```systemverilog
/*!\file your_accelerator.sv
 * RS5 Plugin - Hardware Accelerator Template
 *
 * \brief
 * Template para implementar novos aceleradores
 */

`include "RS5_pkg.sv"

module your_accelerator
    import RS5_pkg::*;
(
    // Clock e Reset (obrigatório)
    input  logic        clk,
    input  logic        reset_n,
    
    // Interface de controle (obrigatório)
    input  logic        start,          // Inicia operação
    output logic        busy,           // Ocupado processando
    output logic        done,           // Operação concluída
    
    // Operandos de entrada (customizável)
    input  logic [31:0] operand_a,      // Primeiro operando
    input  logic [31:0] operand_b,      // Segundo operando
    // Adicione mais operandos se necessário
    
    // Resultado (customizável) 
    output logic [31:0] result          // Resultado da operação
    // Adicione mais saídas se necessário
);

    // FSM states - customize conforme necessário
    typedef enum logic [1:0] {
        IDLE    = 2'b00,  // Aguardando operação
        LOAD    = 2'b01,  // Carregando operandos  
        EXECUTE = 2'b10,  // Executando cálculo
        FINISH  = 2'b11   // Resultado pronto
    } state_t;

    // Registradores internos
    state_t state, next_state;
    logic [31:0] op_a_reg, op_b_reg, result_reg;
    logic busy_reg, done_reg;

    // Máquina de estados
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Lógica de próximo estado
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) next_state = LOAD;
            end
            LOAD: begin
                next_state = EXECUTE;
            end
            EXECUTE: begin
                // Adicione ciclos extras aqui se necessário
                next_state = FINISH;
            end
            FINISH: begin
                next_state = IDLE;
            end
        endcase
    end

    // Datapath - CUSTOMIZE ESTA PARTE
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            op_a_reg   <= 32'b0;
            op_b_reg   <= 32'b0;
            result_reg <= 32'b0;
            busy_reg   <= 1'b0;
            done_reg   <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    busy_reg <= 1'b0;
                    done_reg <= 1'b0;
                    if (start) begin
                        op_a_reg <= operand_a;
                        op_b_reg <= operand_b;
                        busy_reg <= 1'b1;
                    end
                end
                LOAD: begin
                    // *** IMPLEMENTE SUA OPERAÇÃO AQUI ***
                    // Exemplo: result_reg <= op_a_reg * op_b_reg;  // Multiplicação
                    // Exemplo: result_reg <= op_a_reg ^ op_b_reg;  // XOR
                    // Exemplo: result_reg <= {op_a_reg[15:0], op_b_reg[15:0]}; // Concatenação
                    
                    result_reg <= op_a_reg + op_b_reg;  // Substitua pela sua operação
                    busy_reg   <= 1'b1;
                    done_reg   <= 1'b0;
                end
                EXECUTE: begin
                    // Mantenha estado se operação multi-ciclo
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                end
                FINISH: begin
                    busy_reg <= 1'b0;
                    done_reg <= 1'b1;
                end
            endcase
        end
    end

    // Saídas
    assign result = result_reg;
    assign busy   = busy_reg;
    assign done   = done_reg;

endmodule
```

---

## 🎯 **PASSO 2: ADICIONAR TIPO DA INSTRUÇÃO**

### **Modificar `rtl/RS5_pkg.sv`:**

```systemverilog
// Localizar enum iType_e e adicionar sua instrução:
typedef enum logic[6:0] {
    // ... instruções existentes ...
    ADD_PLUGIN,
    YOUR_NEW_INSTRUCTION    // <-- ADICIONE AQUI
} iType_e;
```

---

## 🔍 **PASSO 3: IMPLEMENTAR DECODIFICAÇÃO**

### **Modificar `rtl/decode.sv`:**

1. **Escolher opcode custom:** Use um dos opcodes reservados RISC-V
   - `custom-0`: `0x0B` (usado pelo ADD_PLUGIN)
   - `custom-1`: `0x2B` (disponível)
   - `custom-2`: `0x5B` (disponível)  
   - `custom-3`: `0x7B` (disponível)

2. **Adicionar decodificação:**

```systemverilog
// Localizar seção "Custom Instructions Decode" e modificar:

iType_e decode_custom;
always_comb begin
    unique case ({instruction_i[31:25], instruction_i[14:12]})
        10'b0000000000: decode_custom = ADD_PLUGIN;
        10'b0000000001: decode_custom = YOUR_NEW_INSTRUCTION;  // <-- funct3=001
        // Adicione mais combinações funct7+funct3 conforme necessário
        default:        decode_custom = INVALID;
    endcase
end

// Localizar switch principal do opcode e modificar:
always_comb begin
    unique case (opcode)
        // ... outros opcodes ...
        5'b00010: instruction_operation = decode_custom;  // custom-0 (0x0B)
        5'b01010: instruction_operation = YOUR_CUSTOM_OP; // custom-1 (0x2B) - se usar
        // ...
    endcase
end
```

---

## ⚡ **PASSO 4: INTEGRAR NO PIPELINE**

### **Modificar `rtl/execute.sv`:**

1. **Declarar sinais do acelerador:**

```systemverilog
// Localizar seção de plugin e adicionar:

//////////////////////////////////////////////////////////////////////////////
// Your New Accelerator  
//////////////////////////////////////////////////////////////////////////////

    logic [31:0] your_accelerator_result;
    logic your_accelerator_enable;
    logic your_accelerator_start;
    logic your_accelerator_busy;
    logic your_accelerator_done;
    logic your_accelerator_started;

    assign your_accelerator_enable = (instruction_operation_i == YOUR_NEW_INSTRUCTION);
    
    // Controle de start (mesmo padrão do plugin)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            your_accelerator_started <= 1'b0;
        end else if (!stall) begin
            if (your_accelerator_enable && !your_accelerator_started) begin
                your_accelerator_started <= 1'b1;
            end else if (!your_accelerator_enable) begin
                your_accelerator_started <= 1'b0;
            end
        end
    end
    
    assign your_accelerator_start = your_accelerator_enable && !your_accelerator_started && !stall;
```

2. **Instanciar o módulo:**

```systemverilog
    your_accelerator your_accelerator_inst (
        .clk         (clk),
        .reset_n     (reset_n),
        .start       (your_accelerator_start),
        .operand_a   (rs1_data_i),        // Valor do registrador rs1
        .operand_b   (rs2_data_i),        // Valor do registrador rs2
        .result      (your_accelerator_result),
        .busy        (your_accelerator_busy),
        .done        (your_accelerator_done)
    );
```

3. **Adicionar stall:**

```systemverilog
// Localizar declaração de hold_plugin e adicionar:
logic hold_your_accelerator;
assign hold_your_accelerator = your_accelerator_enable && !your_accelerator_done;

// Localizar assign hold_o e modificar:
assign hold_o = hold_div || hold_mul || hold_vector || hold_plugin || 
                hold_your_accelerator || atomic_hold;
```

4. **Adicionar resultado ao multiplexador:**

```systemverilog
// Localizar seção de result_mux e adicionar:
unique case (instruction_operation_i)
    // ... outros casos ...
    ADD_PLUGIN:           result_mux = plugin_result;
    YOUR_NEW_INSTRUCTION: result_mux = your_accelerator_result;  // <-- ADICIONE
    // ...
endcase
```

---

## 🧪 **PASSO 5: CRIAR TESTES**

### **Template de Teste Assembly:**

```assembly
.section .text
.global _start

_start:
    # Configurar operandos
    li x1, 123          # Operando A
    li x2, 456          # Operando B
    
    # Executar sua instrução custom
    # Calcule o encoding usando o script Python ou manualmente
    .word 0xYOURCODE    # YOUR_INSTRUCTION x3, x1, x2
    
    # Escrever resultado na memória para verificação
    lui x10, 0x80001
    sw x3, 0(x10)       # Resultado
    sw x1, 4(x10)       # Operando A original  
    sw x2, 8(x10)       # Operando B original
    
    # Marcador de fim
    li x31, 0xDEADBEEF
    sw x31, 12(x10)

loop:
    j loop
```

### **Calcular Encoding da Instrução:**

Use o script Python modificado:

```python
def encode_custom_instruction(rd, rs1, rs2, funct3=0, funct7=0, opcode=0x0B):
    instruction = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return f'0x{instruction:08X}'

# Exemplo: YOUR_INSTRUCTION x3, x1, x2 com funct3=001
result = encode_custom_instruction(3, 1, 2, funct3=1, opcode=0x2B)  # custom-1
print(f"YOUR_INSTRUCTION x3, x1, x2: {result}")
```

---

## 🛠️ **EXEMPLO PRÁTICO: MULTIPLICADOR**

### **1. Módulo (`rtl/plugin_multiplier.sv`):**

```systemverilog
// No estado LOAD, substitua por:
result_reg <= op_a_reg * op_b_reg;  // Multiplicação 32-bit
```

### **2. Tipo (`rtl/RS5_pkg.sv`):**

```systemverilog
MUL_PLUGIN
```

### **3. Decodificação (`rtl/decode.sv`):**

```systemverilog
10'b0000000001: decode_custom = MUL_PLUGIN;  // funct3=001
```

### **4. Teste esperado:**
- Operandos: 12 × 34 = 408
- Com pipeline: resultado em ~4 ciclos
- Resultado: 0x00000198 (408 decimal)

---

## 📊 **CHECKLIST DE IMPLEMENTAÇÃO**

- [ ] ✅ Criar módulo do acelerador (`rtl/your_accelerator.sv`)
- [ ] ✅ Adicionar tipo em `rtl/RS5_pkg.sv`  
- [ ] ✅ Implementar decodificação em `rtl/decode.sv`
- [ ] ✅ Integrar no pipeline em `rtl/execute.sv`
- [ ] ✅ Adicionar ao multiplexador de resultados
- [ ] ✅ Implementar stall no pipeline
- [ ] ✅ Criar teste assembly
- [ ] ✅ Calcular encoding da instrução
- [ ] ✅ Compilar e simular
- [ ] ✅ Validar resultados

---

## 🚨 **DICAS IMPORTANTES**

1. **Sempre use handshake start/busy/done** - garante sincronia
2. **Implemente stall corretamente** - evita que CPU avance antes da conclusão  
3. **Teste com valores extremos** - zero, negativos, overflow
4. **Use FSM simples** - facilita debug e manutenção
5. **Documente encoding** - facilita manutenção futura

---

## 🎯 **LIMITAÇÕES ATUAIS**

- **Máximo 4 operandos** (limitação RISC-V formato R)
- **Resultado único de 32-bit** (pode ser contornado com múltiplas instruções)
- **Opcodes limitados** (4 custom opcodes disponíveis)
- **Sem interrupções** (operações são síncronas)

---

**🚀 Com este guia, você pode implementar qualquer acelerador de hardware no RS5!**