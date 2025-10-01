/*!\file plugin_memory_interface.sv
 * RS5 Plugin - Memory Mapped Interface
 *
 * Distribution: October 2025
 *
 * João Carlos Brito Filho
 * Memory mapped interface for the plugin_adder module
 *
 * \brief
 * Handles memory mapped access to plugin_adder via specific addresses
 *
 * \detailed
 * Memory map:
 * - 0x10000000: Operand A (write)
 * - 0x10000004: Operand B (write) 
 * - 0x10000008: Result (read)
 * - 0x1000000C: Control/Status (read/write)
 *   - bit 0: busy (read)
 *   - bit 1: done (read)
 *   - writing 1: start operation
 */

`include "RS5_pkg.sv"

module plugin_memory_interface
    import RS5_pkg::*;
(
    input  logic        clk,
    input  logic        reset_n,
    
    // Memory interface
    input  logic        enable_i,
    input  logic [3:0]  we_i,
    input  logic [31:0] addr_i,
    input  logic [31:0] data_i,
    output logic [31:0] data_o
);

    // Plugin address definitions
    localparam logic [31:0] PLUGIN_OPA_ADDR  = 32'h10000000;  // Operand A
    localparam logic [31:0] PLUGIN_OPB_ADDR  = 32'h10000004;  // Operand B
    localparam logic [31:0] PLUGIN_RES_ADDR  = 32'h10000008;  // Result
    localparam logic [31:0] PLUGIN_CTRL_ADDR = 32'h1000000C;  // Control/Status

    // Plugin interface signals
    logic [31:0] plugin_operand_a, plugin_operand_b, plugin_result;
    logic plugin_start, plugin_busy, plugin_done;
    
    // Internal registers
    logic [31:0] operand_a_reg, operand_b_reg;
    logic start_pulse;

    // Address decode
    logic sel_opa, sel_opb, sel_res, sel_ctrl;
    assign sel_opa  = (addr_i == PLUGIN_OPA_ADDR);
    assign sel_opb  = (addr_i == PLUGIN_OPB_ADDR);
    assign sel_res  = (addr_i == PLUGIN_RES_ADDR);
    assign sel_ctrl = (addr_i == PLUGIN_CTRL_ADDR);

    // Write operations
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            operand_a_reg <= 32'b0;
            operand_b_reg <= 32'b0;
            start_pulse   <= 1'b0;
        end else begin
            start_pulse <= 1'b0;  // Default: clear start pulse
            
            if (enable_i && we_i != 4'b0000) begin
                if (sel_opa) begin
                    // Write to operand A
                    operand_a_reg <= data_i;
                end
                else if (sel_opb) begin
                    // Write to operand B
                    operand_b_reg <= data_i;
                end
                else if (sel_ctrl) begin
                    // Write to control register
                    if (data_i[0]) begin  // bit 0 = start
                        start_pulse <= 1'b1;
                    end
                end
            end
        end
    end

    // Read operations
    always_comb begin
        data_o = 32'b0;
        if (enable_i && we_i == 4'b0000) begin  // Read operation
            if (sel_opa) begin
                data_o = operand_a_reg;
            end
            else if (sel_opb) begin
                data_o = operand_b_reg;
            end
            else if (sel_res) begin
                data_o = plugin_result;
            end
            else if (sel_ctrl) begin
                // Status register: bit 0=busy, bit 1=done
                data_o = {30'b0, plugin_done, plugin_busy};
            end
        end
    end

    // Connect to plugin_adder
    assign plugin_operand_a = operand_a_reg;
    assign plugin_operand_b = operand_b_reg;
    assign plugin_start = start_pulse;

    // Instantiate plugin_adder
    plugin_adder u_plugin_adder (
        .clk       (clk),
        .reset_n   (reset_n),
        .start     (plugin_start),
        .operand_a (plugin_operand_a),
        .operand_b (plugin_operand_b),
        .result    (plugin_result),
        .busy      (plugin_busy),
        .done      (plugin_done)
    );

endmodule