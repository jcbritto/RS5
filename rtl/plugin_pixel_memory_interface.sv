/*!\file plugin_pixel_memory_interface.sv
 * RS5 Plugin - Memory Mapped Interface for Pixel Processing
 *
 * Distribution: October 2025
 *
 * João Carlos Brito Filho
 * Memory mapped interface for the plugin_pixel_processor module
 *
 * \brief
 * Handles memory mapped access to plugin_pixel_processor via specific addresses
 *
 * \detailed
 * Memory map:
 * - 0x10000000: RGB Pixel Input (write) - Format: 0xRRGGBBXX
 * - 0x10000004: Unused parameter (write) - For interface compatibility 
 * - 0x10000008: Grayscale Result (read) - Format: 0xGGGGGG00
 * - 0x1000000C: Control/Status (read/write)
 *   - bit 0: busy (read)
 *   - bit 1: done (read)
 *   - writing 1: start operation
 */

`include "RS5_pkg.sv"

module plugin_pixel_memory_interface
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
    localparam logic [31:0] PLUGIN_RGB_ADDR   = 32'h10000000;  // RGB Pixel Input
    localparam logic [31:0] PLUGIN_UNUSED_ADDR = 32'h10000004;  // Unused parameter
    localparam logic [31:0] PLUGIN_GRAY_ADDR  = 32'h10000008;  // Grayscale Result
    localparam logic [31:0] PLUGIN_CTRL_ADDR  = 32'h1000000C;  // Control/Status

    // Plugin interface signals
    logic [31:0] plugin_rgb_pixel, plugin_unused_param, plugin_gray_result;
    logic plugin_start, plugin_busy, plugin_done;
    
    // Internal registers
    logic [31:0] rgb_pixel_reg, unused_param_reg;
    logic start_pulse;

    // Address decode
    logic sel_rgb, sel_unused, sel_gray, sel_ctrl;
    assign sel_rgb    = (addr_i == PLUGIN_RGB_ADDR);
    assign sel_unused = (addr_i == PLUGIN_UNUSED_ADDR);
    assign sel_gray   = (addr_i == PLUGIN_GRAY_ADDR);
    assign sel_ctrl   = (addr_i == PLUGIN_CTRL_ADDR);

    // Write operations
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rgb_pixel_reg   <= 32'b0;
            unused_param_reg <= 32'b0;
            start_pulse     <= 1'b0;
        end else begin
            start_pulse <= 1'b0;  // Default: clear start pulse
            
            if (enable_i && we_i != 4'b0000) begin
                if (sel_rgb) begin
                    // Write RGB pixel data
                    rgb_pixel_reg <= data_i;
                end
                else if (sel_unused) begin
                    // Write unused parameter (for compatibility)
                    unused_param_reg <= data_i;
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
            if (sel_rgb) begin
                data_o = rgb_pixel_reg;
            end
            else if (sel_unused) begin
                data_o = unused_param_reg;
            end
            else if (sel_gray) begin
                data_o = plugin_gray_result;
            end
            else if (sel_ctrl) begin
                // Status register: bit 0=busy, bit 1=done
                data_o = {30'b0, plugin_done, plugin_busy};
            end
        end
    end

    // Connect to plugin_pixel_processor
    assign plugin_rgb_pixel = rgb_pixel_reg;
    assign plugin_unused_param = unused_param_reg;
    assign plugin_start = start_pulse;

    // Instantiate plugin_pixel_processor
    plugin_pixel_processor u_plugin_pixel_processor (
        .clk          (clk),
        .reset_n      (reset_n),
        .start        (plugin_start),
        .rgb_pixel    (plugin_rgb_pixel),
        .unused_param (plugin_unused_param),
        .gray_pixel   (plugin_gray_result),
        .busy         (plugin_busy),
        .done         (plugin_done)
    );

endmodule