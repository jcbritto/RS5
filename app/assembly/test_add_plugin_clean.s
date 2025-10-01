/*!
 * Test program for ADD_PLUGIN custom instruction
 * Tests the hardware plugin directly via custom instruction
 */

.section .init
.align 4

.globl _start
_start:
    # Test 1: Simple addition (5 + 7 = 12)
    li x1, 5         # Load 5 into x1 (rs1)
    li x2, 7         # Load 7 into x2 (rs2)
    
    # Execute ADD_PLUGIN x3, x1, x2
    # Custom instruction format: opcode=0001011, funct3=000, funct7=0000000
    # Encoding: funct7[31:25] | rs2[24:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]
    #           0000000      |    00010   |   00001    |     000      |   00011  |  0001011
    .word 0x0020818B  # ADD_PLUGIN x3, x1, x2
    
    # Test result: x3 should contain 12 (0x0C)
    addi x4, x3, 0   # Copy result to x4 for verification
    
    # Test 2: Another addition (10 + 20 = 30)
    li x5, 10        # Load 10 into x5 (rs1)
    li x6, 20        # Load 20 into x6 (rs2)
    
    # Execute ADD_PLUGIN x7, x5, x6
    # Encoding: 0000000 | 00110 | 00101 | 000 | 00111 | 0001011
    .word 0x0062838B  # ADD_PLUGIN x7, x5, x6
    
    # Test result: x7 should contain 30 (0x1E)
    addi x8, x7, 0   # Copy result to x8 for verification
    
    # Write results to memory for observation
    li x9, 0x80001000    # Testbench memory address
    sw x4, 0(x9)         # Store first result (should be 12)
    sw x8, 4(x9)         # Store second result (should be 30)
    
    # Simple status indicator
    li x10, 0xDEAD       # Success indicator
    sw x10, 8(x9)        # Store success marker
    
end_loop:
    j end_loop       # Infinite loop for observation