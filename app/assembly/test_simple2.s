/*!
 * Super simple test - only 2 ADD_PLUGIN operations
 */

.section .init
.align 4

.globl _start
_start:
    # Carrega valores únicos nos registradores
    li x1, 5         
    li x2, 7         
    li x4, 100       
    li x5, 200       
    
    # Test 1: 5 + 7 = 12
    .word 0x0020818B  # ADD_PLUGIN x3, x1, x2
    
    # Store result
    li x28, 0x80001000
    sw x3, 0(x28)
    
    # Test 2: 100 + 200 = 300
    .word 0x00528A8B  # ADD_PLUGIN x21, x4, x5
    
    # Store result  
    sw x21, 4(x28)
    
    # End marker
    li x29, 0xFACEFEED
    sw x29, 8(x28)
    
end_loop:
    j end_loop