/*!
 * Test incrementally - only change rd first
 */

.section .init
.align 4

.globl _start
_start:
    # Load test values
    li x1, 5         # x1 = 5
    li x2, 7         # x2 = 7  
    
    # Test 1: 5 + 7 = 12 (into x3 - original)
    .word 0x0020818B  # ADD_PLUGIN x3, x1, x2
    
    # Store result 1
    li x28, 0x80001000
    sw x3, 0(x28)
    
    # Test 2: 5 + 7 = 12 (into x9 - only change rd)
    .word 0x002084CB  # ADD_PLUGIN x9, x1, x2 (change rd from 00011 to 01001)
    
    # Store result 2
    sw x9, 4(x28)
    
    # Final marker
    li x29, 0x12345678
    sw x29, 8(x28)
    
end_loop:
    j end_loop