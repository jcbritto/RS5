/*!\file plugin_adder.sv
 * RS5 Plugin - Hardware Accelerator for Addition
 *
 * Distribution: October 2025
 *
 * João Carlos Brito Filho
 * Implementation of a 32-bit addition coprocessor plugin for RS5
 *
 * \brief
 * Hardware accelerator plugin that performs 32-bit addition with handshake protocol
 *
 * \detailed
 * This module implements a simple coprocessor that:
 * - Receives two 32-bit operands (operand_a, operand_b)
 * - Performs addition operation
 * - Provides result with start/busy/done handshake signals
 * - Uses FSM states: IDLE, LOAD, EXECUTE, FINISH
 */

`include "RS5_pkg.sv"

module plugin_adder
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

    // FSM states for plugin operation
    typedef enum logic [1:0] {
        IDLE    = 2'b00,  // Waiting for operation to start
        LOAD    = 2'b01,  // Loading operands and starting calculation
        EXECUTE = 2'b10,  // Performing calculation (could simulate multi-cycle)
        FINISH  = 2'b11   // Operation completed, result ready
    } state_t;

    // Internal registers
    state_t state, next_state;
    logic [31:0] op_a_reg, op_b_reg, result_reg;
    logic busy_reg, done_reg;

    // State register
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = LOAD;
                end
            end
            LOAD: begin
                next_state = EXECUTE;
            end
            EXECUTE: begin
                // Can add delay cycles here if needed for multi-cycle operation
                next_state = FINISH;
            end
            FINISH: begin
                // Return to IDLE after completing operation
                next_state = IDLE;
            end
        endcase
    end

    // Datapath registers
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
                        // Latch input operands when starting operation
                        op_a_reg <= operand_a;
                        op_b_reg <= operand_b;
                        busy_reg <= 1'b1;
                    end
                end
                LOAD: begin
                    // Operands are latched, start calculation (A + B + 5)
                    result_reg <= op_a_reg + op_b_reg + 32'd5;  // Perform addition with +5
                    busy_reg   <= 1'b1;
                    done_reg   <= 1'b0;
                end
                EXECUTE: begin
                    // Keep calculation result, maintain busy state
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                end
                FINISH: begin
                    // Signal completion and release busy
                    busy_reg <= 1'b0;
                    done_reg <= 1'b1;  // Pulse done for one cycle
                end
            endcase
        end
    end

    // Output assignments
    assign result = result_reg;
    assign busy   = busy_reg;
    assign done   = done_reg;

endmodule