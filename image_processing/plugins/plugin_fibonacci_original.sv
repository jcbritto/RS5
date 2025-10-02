// ============================================================================
// Plugin Fibonacci para RS5 - Versão Simplificada
// ============================================================================
// Este módulo implementa um acelerador de hardware para cálculo de Fibonacci
// baseado no padrão do plugin ADD que funciona corretamente.
//
// Autores: RS5 Team
// Data: 2024
// ============================================================================

module plugin_fibonacci
    import RS5_pkg::*;
(
    // Clock e Reset (obrigatório)
    input  logic        clk,
    input  logic        reset_n,
    
    // Interface de controle (obrigatório)
    input  logic        start,          // Inicia operação
    output logic        busy,           // Ocupado processando
    output logic        done,           // Operação concluída
    
    // Operandos de entrada
    input  logic [31:0] operand_a,      // Índice n da sequência
    input  logic [31:0] operand_b,      // Não utilizado
    
    // Resultado 
    output logic [31:0] result          // fibonacci(n)
);

    // FSM states - padrão simples como ADD_PLUGIN
    typedef enum logic [1:0] {
        IDLE    = 2'b00,  // Aguardando operação
        CALC    = 2'b01,  // Calculando
        FINISH  = 2'b10   // Resultado pronto
    } fib_state_t;

    // Registradores internos
    fib_state_t state, next_state;
    
    // Registradores para cálculo
    logic [31:0] n_reg;              // Índice alvo
    logic [31:0] counter_reg;        // Contador atual
    logic [31:0] fib_a, fib_b;       // Valores atuais: fib_a = fib(i-1), fib_b = fib(i)
    logic [31:0] result_reg;         // Resultado final
    logic [31:0] next_fib;           // Próximo valor de Fibonacci
    logic busy_reg, done_reg;

    // Cálculo combinacional do próximo Fibonacci
    assign next_fib = fib_a + fib_b;

    // Máquina de estados - lógica de próximo estado
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) next_state = CALC;
            end
            CALC: begin
                // Permanecer em CALC até o cálculo terminar
                if (counter_reg > n_reg) begin
                    next_state = FINISH;
                end
            end
            FINISH: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Registrador de estado
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Datapath - lógica principal do cálculo de Fibonacci
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            n_reg        <= 32'b0;
            counter_reg  <= 32'b0;
            fib_a        <= 32'b0;
            fib_b        <= 32'b0;
            result_reg   <= 32'b0;
            busy_reg     <= 1'b0;
            done_reg     <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    busy_reg <= 1'b0;
                    done_reg <= 1'b0;
                    if (start) begin
                        n_reg <= operand_a;  // Captura o índice n
                        busy_reg <= 1'b1;
                        
                        // Inicialização baseada no valor de n
                        if (operand_a == 32'd0) begin
                            result_reg  <= 32'd0;
                            counter_reg <= 32'd999;  // Force immediate finish
                        end else if (operand_a == 32'd1) begin
                            result_reg  <= 32'd1;
                            counter_reg <= 32'd999;  // Force immediate finish
                        end else begin
                            // Para n >= 2, inicializar iteração
                            counter_reg <= 32'd2;    // Começar do fib(2)
                            fib_a       <= 32'd0;    // fib(0)
                            fib_b       <= 32'd1;    // fib(1)
                        end
                    end
                end
                
                CALC: begin
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                    
                    // Para n >= 2, calcular iterativamente
                    if ((n_reg >= 32'd2) && (counter_reg <= n_reg)) begin
                        // Se chegamos ao índice alvo, armazenar resultado ANTES de atualizar
                        if (counter_reg == n_reg) begin
                            result_reg <= next_fib;
                        end
                        
                        // Atualizar valores para próxima iteração
                        fib_a <= fib_b;
                        fib_b <= next_fib;
                        counter_reg <= counter_reg + 1;
                    end
                end
                
                FINISH: begin
                    busy_reg <= 1'b0;
                    done_reg <= 1'b1;
                end
                
                default: begin
                    busy_reg <= 1'b0;
                    done_reg <= 1'b0;
                end
            endcase
        end
    end

    // Saídas
    assign result = result_reg;
    assign busy   = busy_reg;
    assign done   = done_reg;

endmodule