/*!\file plugin_fibonacci.sv
 * RS5 Plugin - Fibonacci Hardware Accelerator
 *
 * \brief
 * Hardware accelerator que calcula o n-ésimo número da sequência de Fibonacci
 * usando uma máquina de estados multi-ciclo.
 * 
 * Operação: FIB_PLUGIN rd, rs1, rs2
 * - rs1: índice n da sequência de Fibonacci
 * - rs2: não utilizado (ignorado)
 * - rd: resultado = fibonacci(n)
 * 
 * Sequência de Fibonacci: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...
 * fibonacci(0) = 0
 * fibonacci(1) = 1
 * fibonacci(n) = fibonacci(n-1) + fibonacci(n-2) para n >= 2
 */

`include "RS5_pkg.sv"

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
        INIT    = 3'b010,  // Inicializando variáveis
        CALC    = 3'b011,  // Calculando iterativamente
        FINISH  = 3'b100   // Resultado pronto
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
                next_state = INIT;
            end
            INIT: begin
                next_state = CALC;
            end
            CALC: begin
                // Se counter chegou ao n desejado, terminar
                if (counter_reg >= n_reg) begin
                    next_state = FINISH;
                end
                // Senão, continuar calculando
                // (permanece em CALC até completar)
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
                    // Preparar para inicialização
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                end
                
                INIT: begin
                    // Casos especiais
                    if (n_reg == 32'd0) begin
                        result_reg   <= 32'd0;
                        counter_reg  <= n_reg; // Skip CALC
                    end else if (n_reg == 32'd1) begin
                        result_reg   <= 32'd1;
                        counter_reg  <= n_reg; // Skip CALC
                    end else begin
                        // Inicializar para cálculo iterativo
                        counter_reg  <= 32'd2;    // Start from fib(2)
                        fib_prev_reg <= 32'd0;    // fib(0) = 0
                        fib_curr_reg <= 32'd1;    // fib(1) = 1
                        result_reg   <= 32'd0;    // Will be calculated
                    end
                    
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                end
                
                CALC: begin
                    // Cálculo iterativo de Fibonacci
                    if (counter_reg <= n_reg) begin
                        // fib(n) = fib(n-1) + fib(n-2)
                        logic [31:0] next_fib;
                        next_fib = fib_prev_reg + fib_curr_reg;
                        
                        // Update for next iteration
                        fib_prev_reg <= fib_curr_reg;
                        fib_curr_reg <= next_fib;
                        counter_reg  <= counter_reg + 1;
                        
                        // Store result when we reach target
                        if (counter_reg == n_reg) begin
                            result_reg <= next_fib;
                        end
                        
                        busy_reg <= 1'b1;
                        done_reg <= 1'b0;
                    end else begin
                        // Calculation complete
                        busy_reg <= 1'b1;  // Still busy until FINISH
                        done_reg <= 1'b0;
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