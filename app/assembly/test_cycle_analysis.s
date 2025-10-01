.section .text
.global _start

_start:
    # Teste MUITO simples e específico para análise ciclo-a-ciclo
    # Vamos usar valores únicos para rastrear exatamente o que acontece
    
    # Carregar valores específicos e únicos
    li x1, 100      # A = 100 (0x64)
    li x2, 200      # B = 200 (0xC8)
    
    # NOP para garantir que valores estão carregados
    nop
    nop
    
    # Executar ADD_PLUGIN x3, x1, x2
    # Resultado esperado: 100 + 200 + 5 = 305 (0x131)
    .word 0x0020818B    # ADD_PLUGIN x3, x1, x2
    
    # NOP para dar tempo ao pipeline
    nop
    nop
    
    # Escrever resultado na memória para verificação
    lui x4, 0x80001     # Base de endereço
    sw x3, 0(x4)        # Escreve resultado em 0x80001000
    
    # Escrever valores originais para comparação
    sw x1, 4(x4)        # A em 0x80001004
    sw x2, 8(x4)        # B em 0x80001008
    
    # Calcular resultado esperado manualmente
    li x5, 305          # 100 + 200 + 5 = 305
    sw x5, 12(x4)       # Esperado em 0x8000100C
    
    # Marcador de fim
    li x6, 0xDEADBEEF
    sw x6, 16(x4)       # Fim em 0x80001010
    
    # Loop infinito
loop:
    j loop

.section .data