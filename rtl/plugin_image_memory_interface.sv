/*!\file plugin_image_memory_interface.sv
 * RS5 Plugin - Image Processing Memory Mapped Interface
 *
 * Distribution: October 2025
 *
 * João Carlos Brito Filho
 * Memory mapped interface for image processing plugin
 *
 * \brief
 * Handles memory mapped access to image processing plugin
 *
 * \detailed
 * Memory map:
 * - 0x10000000: Input Start Address (write)
 * - 0x10000004: Input End Address (write) 
 * - 0x10000008: Output Start Address (write)
 * - 0x1000000C: Output End Address (write)
 * - 0x10000010: Image Width (write)
 * - 0x10000014: Image Height (write)
 * - 0x10000018: Control/Status (read/write)
 *   - bit 0: busy (read)
 *   - bit 1: done (read)
 *   - writing 1: start operation
 * - 0x1000001C: Progress Counter (read) - for debugging
 */

`include "RS5_pkg.sv"

module plugin_image_memory_interface
    import RS5_pkg::*;
(
    input  logic        clk,
    input  logic        reset_n,
    
    // Memory interface
    input  logic        enable_i,
    input  logic [3:0]  we_i,
    input  logic [31:0] addr_i,
    input  logic [31:0] data_i,
    output logic [31:0] data_o,
    
    // Plugin memory access interface
    output logic        mem_req_o,      // Memory request
    output logic        mem_we_o,       // Memory write enable
    output logic [31:0] mem_addr_o,     // Memory address
    output logic [31:0] mem_data_o,     // Memory write data
    input  logic [31:0] mem_data_i,     // Memory read data
    input  logic        mem_ready_i     // Memory ready
);

    // Plugin address definitions
    localparam logic [31:0] PLUGIN_IN_START_ADDR  = 32'h10000000;  // Input start address
    localparam logic [31:0] PLUGIN_IN_END_ADDR    = 32'h10000004;  // Input end address
    localparam logic [31:0] PLUGIN_OUT_START_ADDR = 32'h10000008;  // Output start address
    localparam logic [31:0] PLUGIN_OUT_END_ADDR   = 32'h1000000C;  // Output end address
    localparam logic [31:0] PLUGIN_WIDTH_ADDR     = 32'h10000010;  // Image width
    localparam logic [31:0] PLUGIN_HEIGHT_ADDR    = 32'h10000014;  // Image height
    localparam logic [31:0] PLUGIN_CTRL_ADDR      = 32'h10000018;  // Control/Status
    localparam logic [31:0] PLUGIN_PROGRESS_ADDR  = 32'h1000001C;  // Progress counter

    // Plugin interface signals
    logic [31:0] plugin_in_start, plugin_in_end;
    logic [31:0] plugin_out_start, plugin_out_end;
    logic [31:0] plugin_width, plugin_height;
    logic plugin_start, plugin_busy, plugin_done;
    logic [31:0] plugin_progress;
    
    // Internal registers
    logic [31:0] in_start_reg, in_end_reg;
    logic [31:0] out_start_reg, out_end_reg;
    logic [31:0] width_reg, height_reg;
    logic start_pulse;

    // Address decode
    logic sel_in_start, sel_in_end, sel_out_start, sel_out_end;
    logic sel_width, sel_height, sel_ctrl, sel_progress;
    
    assign sel_in_start  = (addr_i == PLUGIN_IN_START_ADDR);
    assign sel_in_end    = (addr_i == PLUGIN_IN_END_ADDR);
    assign sel_out_start = (addr_i == PLUGIN_OUT_START_ADDR);
    assign sel_out_end   = (addr_i == PLUGIN_OUT_END_ADDR);
    assign sel_width     = (addr_i == PLUGIN_WIDTH_ADDR);
    assign sel_height    = (addr_i == PLUGIN_HEIGHT_ADDR);
    assign sel_ctrl      = (addr_i == PLUGIN_CTRL_ADDR);
    assign sel_progress  = (addr_i == PLUGIN_PROGRESS_ADDR);

    // Write operations
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            in_start_reg  <= 32'b0;
            in_end_reg    <= 32'b0;
            out_start_reg <= 32'b0;
            out_end_reg   <= 32'b0;
            width_reg     <= 32'b0;
            height_reg    <= 32'b0;
            start_pulse   <= 1'b0;
        end else begin
            start_pulse <= 1'b0;  // Default: clear start pulse
            
            if (enable_i && we_i != 4'b0000) begin
                if (sel_in_start) begin
                    in_start_reg <= data_i;
                end
                else if (sel_in_end) begin
                    in_end_reg <= data_i;
                end
                else if (sel_out_start) begin
                    out_start_reg <= data_i;
                end
                else if (sel_out_end) begin
                    out_end_reg <= data_i;
                end
                else if (sel_width) begin
                    width_reg <= data_i;
                end
                else if (sel_height) begin
                    height_reg <= data_i;
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
            if (sel_in_start) begin
                data_o = in_start_reg;
            end
            else if (sel_in_end) begin
                data_o = in_end_reg;
            end
            else if (sel_out_start) begin
                data_o = out_start_reg;
            end
            else if (sel_out_end) begin
                data_o = out_end_reg;
            end
            else if (sel_width) begin
                data_o = width_reg;
            end
            else if (sel_height) begin
                data_o = height_reg;
            end
            else if (sel_ctrl) begin
                // Status register: bit 0=busy, bit 1=done
                data_o = {30'b0, plugin_done, plugin_busy};
            end
            else if (sel_progress) begin
                data_o = plugin_progress;
            end
        end
    end

    // Connect to plugin
    assign plugin_in_start  = in_start_reg;
    assign plugin_in_end    = in_end_reg;
    assign plugin_out_start = out_start_reg;
    assign plugin_out_end   = out_end_reg;
    assign plugin_width     = width_reg;
    assign plugin_height    = height_reg;
    assign plugin_start     = start_pulse;

    // Instantiate image processing plugin
    plugin_image_processor u_plugin_image (
        .clk            (clk),
        .reset_n        (reset_n),
        .start          (plugin_start),
        .busy           (plugin_busy),
        .done           (plugin_done),
        .in_start_addr  (plugin_in_start),
        .in_end_addr    (plugin_in_end),
        .out_start_addr (plugin_out_start),
        .out_end_addr   (plugin_out_end),
        .width          (plugin_width),
        .height         (plugin_height),
        .progress       (plugin_progress),
        
        // Memory interface
        .mem_req        (mem_req_o),
        .mem_we         (mem_we_o),
        .mem_addr       (mem_addr_o),
        .mem_wdata      (mem_data_o),
        .mem_rdata      (mem_data_i),
        .mem_ready      (mem_ready_i)
    );

endmodule