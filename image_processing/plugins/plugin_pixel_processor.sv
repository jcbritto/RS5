/*!\file plugin_pixel_processor.sv
 * RS5 Plugin - Simple Pixel RGB to Grayscale Converter
 *
 * Distribution: October 2025
 *
 * João Carlos Brito Filho
 * Simple single-pixel RGB to Grayscale conversion using approximate computing
 *
 * \brief
 * Hardware accelerator plugin for single pixel processing operations
 *
 * \detailed
 * This module implements RGB to Grayscale conversion for single pixels:
 * - Input: 32-bit RGB value (R[31:24], G[23:16], B[15:8], unused[7:0])
 * - Output: 32-bit Grayscale value (Gray[31:24], Gray[23:16], Gray[15:8], Gray[7:0])
 * - Algorithm: Approximate Grayscale = (R + G + B) >> 2 (divide by 4)
 * - Single-cycle operation compatible with existing plugin interface
 */

`include "RS5_pkg.sv"

module plugin_pixel_processor (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic [31:0] rgb_pixel,     // Input RGB pixel: 0xRRGGBBXX
    input  logic [31:0] unused_param,  // Unused, kept for compatibility
    output logic [31:0] gray_pixel,    // Output grayscale: 0xGGGGGG00
    output logic        busy,
    output logic        done
);

    // Extract RGB components from input pixel
    logic [7:0] red, green, blue;
    assign red   = rgb_pixel[31:24];    // Red component
    assign green = rgb_pixel[23:16];    // Green component
    assign blue  = rgb_pixel[15:8];     // Blue component
    
    // Approximate grayscale computation using simple averaging
    // Traditional: Gray = 0.299*R + 0.587*G + 0.114*B (complex multiplication)
    // Approximate: Gray = (R + G + B) >> 2 (simple addition + shift)
    // Trade-off: Slightly less accurate but much faster and simpler in hardware
    logic [9:0] sum_rgb;        // 10 bits to handle sum (3*255 = 765 < 1024)
    logic [7:0] gray_value;
    
    // Sum RGB components
    assign sum_rgb = {2'b00, red} + {2'b00, green} + {2'b00, blue};
    
    // Divide by 4 using right shift (approximate average)
    assign gray_value = sum_rgb[9:2];
    
    // Output grayscale pixel - replicate gray value in all channels for display
    assign gray_pixel = {gray_value, gray_value, gray_value, 8'h00};
    
    // Single-cycle operation (same interface as plugin_adder)
    assign busy = 1'b0;         // Never busy - immediate result
    assign done = start;        // Done immediately when started

endmodule

/*
 * USAGE NOTES:
 * 
 * Input format (rgb_pixel): 0xRRGGBBXX
 * - Bits [31:24]: Red component (0-255)
 * - Bits [23:16]: Green component (0-255)  
 * - Bits [15:8]:  Blue component (0-255)
 * - Bits [7:0]:   Unused (ignored)
 * 
 * Output format (gray_pixel): 0xGGGGGG00
 * - All RGB channels contain the same grayscale value
 * - Bits [7:0]: Always 0x00
 * 
 * Test Examples:
 * 1. Pure Red:   0xFF000000 → sum=255 → gray=63  → 0x3F3F3F00
 * 2. Pure Green: 0x00FF0000 → sum=255 → gray=63  → 0x3F3F3F00
 * 3. Pure Blue:  0x0000FF00 → sum=255 → gray=63  → 0x3F3F3F00
 * 4. White:      0xFFFFFF00 → sum=765 → gray=191 → 0xBFBFBF00
 * 5. Black:      0x00000000 → sum=0   → gray=0   → 0x00000000
 * 6. Gray:       0x808080XX → sum=384 → gray=96  → 0x60606000
 * 
 * Interface Compatibility:
 * - Same interface as plugin_adder (operand_a, operand_b → result)
 * - Can be used as drop-in replacement in plugin_memory_interface
 * - Maintains single-cycle operation for pipeline compatibility
 */