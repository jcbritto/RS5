/*!
 * Test with NOPs to avoid hazards
 */

.section .init
.align 4

.globl _start
_start:
    # Carrega valores únicos nos registradores
    li x1, 5         
    nop
    nop
    nop
    li x2, 7         
    nop
    nop 
    nop
    li x4, 100       
    nop
    nop
    nop
    li x5, 200       
    nop
    nop
    nop
    
    # Test 1: 5 + 7 = 12
    .word 0x0020818B  # ADD_PLUGIN x3, x1, x2
    nop
    nop
    nop
    nop
    
    # Store result
    li x28, 0x80001000
    sw x3, 0(x28)
    
    # Test 2: 100 + 200 = 300
    .word 0x005205AB  # ADD_PLUGIN x21, x4, x5 (re-corrected)
    nop
    nop
    nop
    nop
    
    # Store result  
    sw x21, 4(x28)
    
    # End marker
    li x29, 0xFACEFEED
    sw x29, 8(x28)
    
end_loop:
    j end_loop