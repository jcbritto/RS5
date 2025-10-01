.section .text
.global _start

_start:
    # Inicializar registradores
    li x1, 5        # Carrega imediato 5 em x1 (operando A)
    li x2, 7        # Carrega imediato 7 em x2 (operando B)
    
    # Teste simples: ADD_PLUGIN x3, x1, x2 (5 + 7 + 5 = 17)
    .word 0x0020818B    # Instrução ADD_PLUGIN x3, x1, x2
    
    # Teste comparação: esperamos resultado 17
    li x4, 17       # Valor esperado (5 + 7 + 5 = 17)
    
    # Escrever resultado na memória para verificação
    lui x5, 0x80001          # Base de endereço de memória de dados
    sw x3, 0(x5)            # Escreve resultado do plugin em 0x80001000
    sw x4, 4(x5)            # Escreve valor esperado em 0x80001004
    
    # Escrever marcador de fim de teste
    li x6, 0xDEADBEEF
    sw x6, 8(x5)
    
    # Loop infinito para terminar execução
loop:
    j loop

.section .data