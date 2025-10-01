.section .init
.align 4

.globl _start
_start:
    # Teste do plugin via memória mapeada
    # Endereços:
    # 0x10000000: Operand A
    # 0x10000004: Operand B  
    # 0x10000008: Result
    # 0x1000000C: Control/Status
    
    # Caregar endereços base
    lui x5, 0x10000          # x5 = 0x10000000 (base do plugin)
    
    # Teste 1: 5 + 7 = 12
    li x1, 5                 # operando A = 5
    li x2, 7                 # operando B = 7
    
    # Escrever operandos
    sw x1, 0(x5)            # escreve 5 em 0x10000000 (operand A)
    sw x2, 4(x5)            # escreve 7 em 0x10000004 (operand B)
    
    # Iniciar operação
    li x3, 1                # comando start
    sw x3, 12(x5)           # escreve 1 em 0x1000000C (control)
    
    # Aguardar conclusão (polling)
wait_loop1:
    lw x4, 12(x5)           # lê status de 0x1000000C
    andi x4, x4, 1          # testa bit 0 (busy)
    bnez x4, wait_loop1     # se busy=1, continua esperando
    
    # Ler resultado
    lw x6, 8(x5)            # lê resultado de 0x10000008
    
    # Teste 2: 10 + 20 = 30
    li x1, 10               # operando A = 10
    li x2, 20               # operando B = 20
    
    # Escrever operandos
    sw x1, 0(x5)            # escreve 10 em 0x10000000 (operand A)
    sw x2, 4(x5)            # escreve 20 em 0x10000004 (operand B)
    
    # Iniciar operação
    li x3, 1                # comando start
    sw x3, 12(x5)           # escreve 1 em 0x1000000C (control)
    
    # Aguardar conclusão (polling)
wait_loop2:
    lw x4, 12(x5)           # lê status de 0x1000000C
    andi x4, x4, 1          # testa bit 0 (busy)
    bnez x4, wait_loop2     # se busy=1, continua esperando
    
    # Ler resultado
    lw x7, 8(x5)            # lê resultado de 0x10000008
    
    # Resultados devem estar em x6=12 e x7=30
    # Escrever em endereço de saída para verificação
    li x8, 0x80004000       # endereço de saída do testbench
    sw x6, 0(x8)            # resultado 1
    sw x7, 0(x8)            # resultado 2
    
end:
    j end                   # loop infinito