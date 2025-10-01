/*!
 * Final comprehensive test for ADD_PLUGIN instruction
 * Uses correctly calculated instruction encodings
 */

.section .init
.align 4

.globl _start
_start:
    # Load test values
    li x1, 5         # x1 = 5
    li x2, 7         # x2 = 7  
    li x4, 100       # x4 = 100
    li x5, 200       # x5 = 200
    li x6, 0         # x6 = 0
    li x7, 42        # x7 = 42
    
    # Test 1: 5 + 7 = 12
    .word 0x0020818B  # ADD_PLUGIN x3, x1, x2 (verified working)
    
    # Store result 1
    li x28, 0x80001000
    sw x3, 0(x28)
    
    # Test 2: 0 + 42 = 42 (usando x6 e x7 para ter certeza)
    .word 0x007304BB  # ADD_PLUGIN x9, x6, x7
    
    # Store result 2
    sw x9, 4(x28)
    
    # Test 3: 100 + 0 = 100  
    .word 0x006204BB  # ADD_PLUGIN x9, x4, x6
    
    # Store result 3
    sw x9, 8(x28)
    
    # Final marker
    li x29, 0xCAFEBABE
    sw x29, 12(x28)
    
end_loop:
    j end_loop