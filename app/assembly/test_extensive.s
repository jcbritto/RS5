/*!
 * BATERIA EXTENSIVA DE TESTES - ADD_PLUGIN
 * Testa múltiplos cenários, edge cases, e valores extremos
 */

.section .init
.align 4

.globl _start
_start:
    # ==========================================
    # CONFIGURAÇÃO DE VALORES DE TESTE EXTENSIVOS
    # ==========================================
    
    # Teste básicos
    li x1, 1
    li x2, 1        # 1 + 1 = 2
    li x3, 0  
    li x4, 100      # 0 + 100 = 100
    li x5, 255
    li x6, 256      # 255 + 256 = 511
    li x7, 1000
    li x8, 2000     # 1000 + 2000 = 3000
    
    # Valores grandes
    li x9, 0x7FFF   # 32767
    li x10, 0x8000  # 32768 (32767 + 32768 = 65535)
    li x11, 0xFFFF  # 65535
    li x12, 1       # 65535 + 1 = 65536
    
    # Valores negativos (two's complement)
    li x13, -1      # 0xFFFFFFFF
    li x14, -2      # 0xFFFFFFFE  (-1 + -2 = -3)
    li x15, -100
    li x16, 50      # -100 + 50 = -50
    
    # ==========================================
    # EXECUÇÃO DOS TESTES EXTENSIVOS
    # ==========================================
    
    li x28, 0x80001000  # Base address para resultados
    
    # Teste 1: ADD_PLUGIN x17, x1, x2 (1 + 1 = 2)
    .word 0x0020888B
    sw x17, 0(x28)      # Offset 0
    
    # Teste 2: ADD_PLUGIN x18, x3, x4 (0 + 100 = 100)  
    .word 0x0041890B
    sw x18, 4(x28)      # Offset 4
    
    # Teste 3: ADD_PLUGIN x19, x5, x6 (255 + 256 = 511)
    .word 0x0062898B
    sw x19, 8(x28)      # Offset 8
    
    # Teste 4: ADD_PLUGIN x20, x7, x8 (1000 + 2000 = 3000)
    .word 0x00838A0B
    sw x20, 12(x28)     # Offset 12
    
    # Teste 5: ADD_PLUGIN x21, x9, x10 (32767 + 32768 = 65535)
    .word 0x00A48A8B
    sw x21, 16(x28)     # Offset 16
    
    # Teste 6: ADD_PLUGIN x22, x11, x12 (65535 + 1 = 65536)
    .word 0x00C58B0B
    sw x22, 20(x28)     # Offset 20
    
    # Teste 7: ADD_PLUGIN x23, x13, x14 (-1 + -2 = -3)
    .word 0x00E68B8B
    sw x23, 24(x28)     # Offset 24
    
    # Teste 8: ADD_PLUGIN x24, x15, x16 (-100 + 50 = -50) 
    .word 0x01078C0B
    sw x24, 28(x28)     # Offset 28
    
    # ==========================================
    # TESTES ADICIONAIS COM VALORES EXTREMOS
    # ==========================================
    
    # Valores muito grandes
    li x25, 0x12345678
    li x26, 0x87654321
    
    # Teste 9: ADD_PLUGIN x27, x25, x26 (valores grandes)
    .word 0x01AC8D8B
    sw x27, 32(x28)     # Offset 32
    
    # Teste máximo positivo + 1 (overflow test)
    li x29, 0x7FFFFFFF  # MAX_INT
    li x30, 1
    
    # Teste 10: ADD_PLUGIN x31, x29, x30 (overflow: MAX_INT + 1)
    .word 0x01EE8F8B
    sw x31, 36(x28)     # Offset 36
    
    # ==========================================
    # MARCADOR FINAL DE SUCESSO
    # ==========================================
    li x1, 0xABCDEF01
    sw x1, 40(x28)      # Offset 40 - marcador de conclusão
    
end_loop:
    j end_loop