/*!
 * Debug test - simple sequential ADD_PLUGIN tests
 */

.section .init
.align 4

.globl _start
_start:
    # Test 1: 5 + 7 = 12
    li x1, 5         
    li x2, 7         
    .word 0x0020818B  # ADD_PLUGIN x3, x1, x2
    
    # Store result immediately
    li x28, 0x80001000
    sw x3, 0(x28)
    
    # Test 2: 10 + 20 = 30
    li x4, 10        
    li x5, 20        
    .word 0x00528A8B  # ADD_PLUGIN x21, x4, x5
    
    # Store result immediately  
    sw x21, 4(x28)
    
    # Test 3: 100 + 1 = 101
    li x6, 100       
    li x7, 1         
    .word 0x0073470B  # ADD_PLUGIN x14, x6, x7
    
    # Store result immediately
    sw x14, 8(x28)
    
    # Completion marker
    li x29, 0xDEADBEEF
    sw x29, 12(x28)
    
end_loop:
    j end_loop