/*!\file plugin_adder.sv
 * RS5 Plugin - Hardware Accelerator for Addition
 *
 * Distribution: October 2025
 *
 * João Carlos Brito Filho
 * Implementation of a 32-bit addition coprocessor plugin for RS5
 *
 * \brief
 * Hardware accelerator plugin that performs 32-bit addition A + B + 5
 *
 * \detailed
 * This module implements a simple single-cycle coprocessor that:
 * - Receives two 32-bit operands (operand_a, operand_b)
 * - Performs addition operation: operand_a + operand_b + 5
 * - Provides immediate result (combinational logic)
 * - Single-cycle operation for RISC-V pipeline compatibility
 */

`include "RS5_pkg.sv"

module plugin_adder (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    output logic [31:0] result,
    output logic        busy,
    output logic        done
);

    // Simple combinational logic - single cycle operation
    // Performs A + B + 5 as specified
    assign result = operand_a + operand_b + 32'd5;
    
    // For single-cycle operation:
    // - never busy (always ready)
    // - done when start is asserted (immediate completion)
    assign busy = 1'b0;
    assign done = start;

endmodule