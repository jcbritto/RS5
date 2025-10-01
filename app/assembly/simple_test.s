.section .init
.align 4

.globl _start
_start:
    # Teste básico com operações simples
    li x1, 5        # carrega 5 em x1
    li x2, 7        # carrega 7 em x2
    add x3, x1, x2  # x3 = x1 + x2 = 12
    
    # Loop simples para ter algo observável
    li x4, 10       # contador
loop:
    addi x4, x4, -1 # decrementa contador
    bne x4, x0, loop # volta se não for zero
    
    # Instrução para terminar (pode travar aqui intencionalmente)
    li x5, 0x1000   # valor de teste
    sw x3, 0(x5)    # escreve resultado em memória
    
end:
    j end           # loop infinito para observar resultado