.section .text
.global _start

_start:
    nop                          # Instrução no endereço 0 (não executada devido a PC=4)
    # Carregar endereço base do plugin em t0
    lui     t0, 0x10000          # t0 = 0x10000000 (agora no endereço 4)
    
    # Escrever valor 5 no registro A (offset 0)
    addi    t1, zero, 5          # t1 = 5
    sw      t1, 0(t0)            # [0x10000000] = 5
    
    # Escrever valor 7 no registro B (offset 4) 
    addi    t1, zero, 7          # t1 = 7
    sw      t1, 4(t0)            # [0x10000004] = 7
    
    # Habilitar plugin (offset 12)
    addi    t1, zero, 1          # t1 = 1
    sw      t1, 12(t0)           # [0x1000000C] = 1
    
    # Ler resultado (offset 8)
    lw      t2, 8(t0)            # t2 = [0x10000008]
    
    # Escrever resultado no endereço de debug
    lui     t3, 0x80002          # t3 = 0x80002000
    sw      t2, 0(t3)            # [0x80002000] = resultado
    
    # Terminar simulação
    lui     t3, 0x80000          # t3 = 0x80000000
    addi    t1, zero, 1          # t1 = 1
    sw      t1, 0(t3)            # [0x80000000] = 1
    
    # Loop infinito
loop:
    j       loop