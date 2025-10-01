.section .text
.global _start

_start:
    # Teste 1: Números pequenos (1 + 2 = 8)
    li x1, 1
    li x2, 2
    .word 0x0020818B    # ADD_PLUGIN x3, x1, x2
    lui x10, 0x80001
    sw x3, 0(x10)       # Resultado em 0x80001000
    
    # Teste 2: Zero + número (0 + 42 = 47)  
    li x4, 0
    li x5, 42
    .word 0x0052028B    # ADD_PLUGIN x5, x4, x5
    sw x4, 4(x10)       # Resultado em 0x80001004
    
    # Teste 3: Números negativos (-1 + -2 = 2)
    li x6, -1           # 0xFFFFFFFF
    li x7, -2           # 0xFFFFFFFE 
    .word 0x0073028B    # ADD_PLUGIN x5, x6, x7
    sw x5, 8(x10)       # Resultado em 0x80001008
    
    # Teste 4: Números grandes (1000 + 2000 = 3005)
    li x8, 1000         # 0x3E8
    li x9, 2000         # 0x7D0
    .word 0x0094030B    # ADD_PLUGIN x6, x8, x9
    sw x6, 12(x10)      # Resultado em 0x8000100C
    
    # Teste 5: Overflow (0x7FFFFFFF + 1 = 0x80000005)
    lui x11, 0x80000    # MAX_INT = 0x7FFFFFFF
    addi x11, x11, -1
    li x12, 1
    .word 0x00C5838B    # ADD_PLUGIN x7, x11, x12
    sw x7, 16(x10)      # Resultado em 0x80001010
    
    # Marcador de fim
    li x31, 0xDEADBEEF
    sw x31, 20(x10)     # Fim em 0x80001014

loop:
    j loop

.section .data