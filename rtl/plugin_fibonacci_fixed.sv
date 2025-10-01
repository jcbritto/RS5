// ============================================================================
// Plugin Fibonacci para RS5 - Versão Corrigida
// ============================================================================
// Este módulo implementa um acelerador de hardware para cálculo de Fibonacci
// usando máquina de estados finitos (FSM) com lógica iterativa.
//
// Uso:
//   1. Aplicar start=1 com operand_a=n (índice Fibonacci desejado)
//   2. Aguardar busy=0 e done=1
//   3. Ler resultado da saída result
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

    // FSM states para cálculo iterativo de Fibonacci
    typedef enum logic [2:0] {
        IDLE    = 3'b000,  // Aguardando operação
        LOAD    = 3'b001,  // Carregando operandos  
        CALC    = 3'b010,  // Calculando iterativamente
        FINISH  = 3'b011   // Resultado pronto
    } fib_state_t;

    // Registradores internos
    fib_state_t state, next_state;
    logic [31:0] n_reg;              // Índice alvo
    logic [31:0] counter_reg;        // Contador atual
    logic [31:0] fib_prev_reg;       // fibonacci(i-1)
    logic [31:0] fib_curr_reg;       // fibonacci(i)
    logic [31:0] result_reg;         // Resultado final
    logic busy_reg, done_reg;

    // Máquina de estados - lógica de próximo estado
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) next_state = LOAD;
            end
            LOAD: begin
                next_state = CALC;
            end
            CALC: begin
                // Se counter chegou ao n desejado, terminar
                if ((n_reg <= 1) || (counter_reg > n_reg)) begin
                    next_state = FINISH;
                end
                // Senão, continuar calculando
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
            n_reg         <= 32'b0;
            counter_reg   <= 32'b0;
            fib_prev_reg  <= 32'b0;
            fib_curr_reg  <= 32'b0;
            result_reg    <= 32'b0;
            busy_reg      <= 1'b0;
            done_reg      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    busy_reg <= 1'b0;
                    done_reg <= 1'b0;
                    if (start) begin
                        n_reg <= operand_a;  // Captura o índice n
                        busy_reg <= 1'b1;
                    end
                end
                
                LOAD: begin
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                    
                    // Inicialização baseada no valor de n
                    if (n_reg == 32'd0) begin
                        result_reg   <= 32'd0;
                        counter_reg  <= 32'd999;  // Force finish
                    end else if (n_reg == 32'd1) begin
                        result_reg   <= 32'd1;
                        counter_reg  <= 32'd999;  // Force finish
                    end else begin
                        // Inicializar para cálculo iterativo n >= 2
                        counter_reg  <= 32'd2;    // Start from fib(2)
                        fib_prev_reg <= 32'd0;    // fib(0) = 0
                        fib_curr_reg <= 32'd1;    // fib(1) = 1
                    end
                end
                
                CALC: begin
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                    
                    // Só calcula se n >= 2 e ainda não terminamos
                    if ((n_reg >= 32'd2) && (counter_reg <= n_reg)) begin
                        // fib(n) = fib(n-1) + fib(n-2)
                        logic [31:0] next_fib = fib_prev_reg + fib_curr_reg;
                        
                        // Se chegamos ao índice target, armazenar resultado
                        if (counter_reg == n_reg) begin
                            result_reg <= next_fib;
                        end
                        
                        // Atualizar para próxima iteração
                        fib_prev_reg <= fib_curr_reg;
                        fib_curr_reg <= next_fib;
                        counter_reg  <= counter_reg + 1;
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