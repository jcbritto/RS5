/*!
 * Comprehensive test program for ADD_PLUGIN custom instruction
 * Tests various edge cases and scenarios
 */

.section .init
.align 4

.globl _start
_start:
    # Test 1: Basic positive numbers (5 + 7 = 12)
    li x1, 5         
    li x2, 7         
    .word 0x0020818B  # ADD_PLUGIN x3, x1, x2
    
    # Test 2: Larger numbers (100 + 200 = 300)
    li x4, 100       
    li x5, 200       
    .word 0x00528A8B  # ADD_PLUGIN x21, x4, x5
    
    # Test 3: Zero operands (0 + 0 = 0)
    li x6, 0         
    li x7, 0         
    .word 0x0073470B  # ADD_PLUGIN x14, x6, x7
    
    # Test 4: One zero operand (42 + 0 = 42)
    li x8, 42        
    li x9, 0         
    .word 0x009484CB  # ADD_PLUGIN x9, x8, x9
    
    # Test 5: Maximum positive value + 1
    li x10, 0x7FFFFFFF  # Max positive 32-bit signed int
    li x11, 1
    .word 0x00B5060B    # ADD_PLUGIN x12, x10, x11 (should overflow)
    
    # Store all results to testbench memory for verification
    li x28, 0x80001000   # Base address for results
    
    sw x3, 0(x28)        # Test 1 result (should be 12)
    sw x21, 4(x28)       # Test 2 result (should be 300 = 0x12C)
    sw x14, 8(x28)       # Test 3 result (should be 0)
    sw x9, 12(x28)       # Test 4 result (should be 42 = 0x2A)
    sw x12, 16(x28)      # Test 5 result (should be 0x80000000 - overflow)
    
    # Store test completion marker
    li x29, 0xFEEDFACE
    sw x29, 20(x28)      # Success marker
    
end_loop:
    j end_loop