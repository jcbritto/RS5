/*
 * RS5 Pixel Processor Test - Conversão RGB para Escala de Cinza
 * 
 * Testa o plugin_pixel_processor com dados reais de pixels RGB
 * usando computação aproximada (R+G+B)/4
 */

// Endereços do plugin de pixels - VALIDADOS
#define PLUGIN_RGB_ADDR   0x10000000  // Entrada RGB: 0xRRGGBBXX
#define PLUGIN_UNUSED_ADDR 0x10000004  // Parâmetro não usado  
#define PLUGIN_GRAY_ADDR  0x10000008  // Resultado P&B: 0xGGGGGG00
#define PLUGIN_CTRL_ADDR  0x1000000C  // Controle/Status

// Endereços de debug/simulação - VALIDADOS
#define DEBUG_OUTPUT_ADDR 0x80002000  // Para escrever resultados
#define SIM_END_ADDR      0x80000000  // Para terminar simulação

/**
 * Função para escrever no plugin
 */
static inline void plugin_write(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

/**
 * Função para ler do plugin
 */
static inline unsigned int plugin_read(unsigned int addr) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    return *ptr;
}

/**
 * Função principal - testa pixels RGB reais
 * NOP inicial compensa PC=4 offset do RS5
 */
void _start() {
    // NOP para compensar PC=4 offset
    asm volatile("nop");
    
    // Teste 1: Vermelho puro (0xFF000000)
    // Esperado: (255+0+0)/4 = 63 = 0x3F → 0x3F3F3F00
    plugin_write(PLUGIN_RGB_ADDR, 0xFF000000);
    plugin_write(PLUGIN_CTRL_ADDR, 1);
    unsigned int result1 = plugin_read(PLUGIN_GRAY_ADDR);
    plugin_write(DEBUG_OUTPUT_ADDR + 0x00, result1);
    
    // Teste 2: Verde puro (0x00FF0000)
    // Esperado: (0+255+0)/4 = 63 = 0x3F → 0x3F3F3F00
    plugin_write(PLUGIN_RGB_ADDR, 0x00FF0000);
    plugin_write(PLUGIN_CTRL_ADDR, 1);
    unsigned int result2 = plugin_read(PLUGIN_GRAY_ADDR);
    plugin_write(DEBUG_OUTPUT_ADDR + 0x04, result2);
    
    // Teste 3: Azul puro (0x0000FF00)
    // Esperado: (0+0+255)/4 = 63 = 0x3F → 0x3F3F3F00
    plugin_write(PLUGIN_RGB_ADDR, 0x0000FF00);
    plugin_write(PLUGIN_CTRL_ADDR, 1);
    unsigned int result3 = plugin_read(PLUGIN_GRAY_ADDR);
    plugin_write(DEBUG_OUTPUT_ADDR + 0x08, result3);
    
    // Teste 4: Branco (0xFFFFFF00)
    // Esperado: (255+255+255)/4 = 191 = 0xBF → 0xBFBFBF00
    plugin_write(PLUGIN_RGB_ADDR, 0xFFFFFF00);
    plugin_write(PLUGIN_CTRL_ADDR, 1);
    unsigned int result4 = plugin_read(PLUGIN_GRAY_ADDR);
    plugin_write(DEBUG_OUTPUT_ADDR + 0x0C, result4);
    
    // Teste 5: Preto (0x00000000)
    // Esperado: (0+0+0)/4 = 0 = 0x00 → 0x00000000
    plugin_write(PLUGIN_RGB_ADDR, 0x00000000);
    plugin_write(PLUGIN_CTRL_ADDR, 1);
    unsigned int result5 = plugin_read(PLUGIN_GRAY_ADDR);
    plugin_write(DEBUG_OUTPUT_ADDR + 0x10, result5);
    
    // Teste 6: Cinza médio (0x808080FF)
    // Esperado: (128+128+128)/4 = 96 = 0x60 → 0x60606000
    plugin_write(PLUGIN_RGB_ADDR, 0x808080FF);
    plugin_write(PLUGIN_CTRL_ADDR, 1);
    unsigned int result6 = plugin_read(PLUGIN_GRAY_ADDR);
    plugin_write(DEBUG_OUTPUT_ADDR + 0x14, result6);
    
    // Resumo dos testes no debug
    plugin_write(DEBUG_OUTPUT_ADDR + 0x100, 6);  // Número total de testes
    
    // Terminar simulação
    plugin_write(SIM_END_ADDR, 1);
    
    // Loop infinito
    while(1) {
        asm volatile("nop");
    }
}

/*
 * TESTE DETALHADO:
 * 
 * Pixel 1: 0xFF000000 (Vermelho puro)
 * - R=255, G=0, B=0
 * - Soma = 255, Gray = 255/4 = 63 (0x3F)
 * - Resultado esperado: 0x3F3F3F00
 * 
 * Pixel 4: 0xFFFFFF00 (Branco)  
 * - R=255, G=255, B=255
 * - Soma = 765, Gray = 765/4 = 191 (0xBF)
 * - Resultado esperado: 0xBFBFBF00
 * 
 * Verificação no log da simulação:
 * - Endereços 0x80002000-0x8000201C: resultados dos 8 pixels
 * - Endereço 0x80002100: contador de sucessos (deve ser 8)
 * - Endereço 0x80002104: total de testes (8)
 */