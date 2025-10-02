/*
 * Teste do Plugin de Processamento de Imagem - Dados Pequenos
 * 
 * Este programa testa o plugin de conversão RGB para P&B usando uma
 * imagem sintética de 2x2 pixels para validar a funcionalidade.
 */

// Endereços do plugin de imagem
#define PLUGIN_IN_START_ADDR    0x10000000
#define PLUGIN_IN_END_ADDR      0x10000004
#define PLUGIN_OUT_START_ADDR   0x10000008
#define PLUGIN_OUT_END_ADDR     0x1000000C
#define PLUGIN_WIDTH_ADDR       0x10000010
#define PLUGIN_HEIGHT_ADDR      0x10000014
#define PLUGIN_CTRL_ADDR        0x10000018
#define PLUGIN_PROGRESS_ADDR    0x1000001C

// Área de memória para dados de teste
#define IMAGE_INPUT_BASE        0x80002000  // Base para imagem RGB
#define IMAGE_OUTPUT_BASE       0x80003000  // Base para imagem P&B
#define DEBUG_OUTPUT_BASE       0x80001000  // Base para debug

// Função para escrever em endereço de memória
void write_mem(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

// Função para ler de endereço de memória
unsigned int read_mem(unsigned int addr) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    return *ptr;
}

// Função para configurar plugin de imagem
void setup_image_plugin(unsigned int in_start, unsigned int in_end,
                       unsigned int out_start, unsigned int out_end,
                       unsigned int width, unsigned int height) {
    write_mem(PLUGIN_IN_START_ADDR, in_start);
    write_mem(PLUGIN_IN_END_ADDR, in_end);
    write_mem(PLUGIN_OUT_START_ADDR, out_start);
    write_mem(PLUGIN_OUT_END_ADDR, out_end);
    write_mem(PLUGIN_WIDTH_ADDR, width);
    write_mem(PLUGIN_HEIGHT_ADDR, height);
}

// Função para iniciar o plugin e aguardar conclusão
void run_image_plugin() {
    // Iniciar operação
    write_mem(PLUGIN_CTRL_ADDR, 1);
    
    // Aguardar conclusão (polling no bit done)
    unsigned int status;
    do {
        status = read_mem(PLUGIN_CTRL_ADDR);
    } while ((status & 0x2) == 0);  // bit 1 = done
}

// Função para verificar se plugin está ocupado
unsigned int is_plugin_busy() {
    unsigned int status = read_mem(PLUGIN_CTRL_ADDR);
    return (status & 0x1);  // bit 0 = busy
}

// Função para obter progresso
unsigned int get_plugin_progress() {
    return read_mem(PLUGIN_PROGRESS_ADDR);
}

void _start() {
    // ============================================================================
    // TESTE 1: Imagem 2x2 com pixels conhecidos
    // ============================================================================
    
    // Criar imagem de teste 2x2 pixels:
    // Pixel (0,0): RGB(255, 0, 0)     -> Vermelho puro
    // Pixel (0,1): RGB(0, 255, 0)     -> Verde puro  
    // Pixel (1,0): RGB(0, 0, 255)     -> Azul puro
    // Pixel (1,1): RGB(128, 128, 128) -> Cinza médio
    
    // Formato: 0xRRGGBB00
    write_mem(IMAGE_INPUT_BASE + 0, 0xFF000000);  // Pixel 0: Vermelho
    write_mem(IMAGE_INPUT_BASE + 4, 0x00FF0000);  // Pixel 1: Verde
    write_mem(IMAGE_INPUT_BASE + 8, 0x0000FF00);  // Pixel 2: Azul
    write_mem(IMAGE_INPUT_BASE + 12, 0x80808000); // Pixel 3: Cinza
    
    // Configurar plugin para processar imagem 2x2
    setup_image_plugin(
        IMAGE_INPUT_BASE,           // in_start = 0x80002000
        IMAGE_INPUT_BASE + 16,      // in_end = 0x80002010 (4 pixels * 4 bytes)
        IMAGE_OUTPUT_BASE,          // out_start = 0x80003000
        IMAGE_OUTPUT_BASE + 16,     // out_end = 0x80003010
        2,                          // width = 2
        2                           // height = 2
    );
    
    // Debug: Salvar configuração
    write_mem(DEBUG_OUTPUT_BASE + 0, 0x12345678);  // Marcador início teste
    write_mem(DEBUG_OUTPUT_BASE + 4, IMAGE_INPUT_BASE);
    write_mem(DEBUG_OUTPUT_BASE + 8, IMAGE_OUTPUT_BASE);
    write_mem(DEBUG_OUTPUT_BASE + 12, 2);          // width
    write_mem(DEBUG_OUTPUT_BASE + 16, 2);          // height
    
    // Executar processamento
    run_image_plugin();
    
    // Verificar resultados
    unsigned int result0 = read_mem(IMAGE_OUTPUT_BASE + 0);
    unsigned int result1 = read_mem(IMAGE_OUTPUT_BASE + 4);
    unsigned int result2 = read_mem(IMAGE_OUTPUT_BASE + 8);
    unsigned int result3 = read_mem(IMAGE_OUTPUT_BASE + 12);
    
    // Salvar resultados para análise
    write_mem(DEBUG_OUTPUT_BASE + 20, result0);  // Resultado pixel 0
    write_mem(DEBUG_OUTPUT_BASE + 24, result1);  // Resultado pixel 1  
    write_mem(DEBUG_OUTPUT_BASE + 28, result2);  // Resultado pixel 2
    write_mem(DEBUG_OUTPUT_BASE + 32, result3);  // Resultado pixel 3
    
    // ============================================================================
    // ANÁLISE DOS RESULTADOS ESPERADOS
    // ============================================================================
    // 
    // Algoritmo aproximado: Gray = (R + G + B) / 4
    //
    // Pixel 0 - RGB(255,0,0):   Gray = (255+0+0)/4 = 63.75 ≈ 63  (0x3F3F3F00)
    // Pixel 1 - RGB(0,255,0):   Gray = (0+255+0)/4 = 63.75 ≈ 63  (0x3F3F3F00)
    // Pixel 2 - RGB(0,0,255):   Gray = (0+0+255)/4 = 63.75 ≈ 63  (0x3F3F3F00)
    // Pixel 3 - RGB(128,128,128): Gray = (128+128+128)/4 = 96     (0x60606000)
    //
    // ============================================================================
    
    // Verificação automática dos resultados
    unsigned int expected0 = 0x3F3F3F00;  // ~63 para vermelho
    unsigned int expected1 = 0x3F3F3F00;  // ~63 para verde
    unsigned int expected2 = 0x3F3F3F00;  // ~63 para azul
    unsigned int expected3 = 0x60606000;  // 96 para cinza
    
    // Verificar se resultados estão corretos (com tolerância)
    unsigned int test_pass = 1;
    
    // Extrair componente gray de cada resultado (assumindo formato 0xGGGGGG00)
    unsigned int gray0 = (result0 >> 24) & 0xFF;
    unsigned int gray1 = (result1 >> 24) & 0xFF;
    unsigned int gray2 = (result2 >> 24) & 0xFF;
    unsigned int gray3 = (result3 >> 24) & 0xFF;
    
    // Salvar valores gray extraídos
    write_mem(DEBUG_OUTPUT_BASE + 36, gray0);
    write_mem(DEBUG_OUTPUT_BASE + 40, gray1);
    write_mem(DEBUG_OUTPUT_BASE + 44, gray2);
    write_mem(DEBUG_OUTPUT_BASE + 48, gray3);
    
    // Verificar se estão próximos dos valores esperados (±2)
    if (gray0 < 61 || gray0 > 65) test_pass = 0;
    if (gray1 < 61 || gray1 > 65) test_pass = 0;
    if (gray2 < 61 || gray2 > 65) test_pass = 0;
    if (gray3 < 94 || gray3 > 98) test_pass = 0;
    
    // Resultado do teste
    write_mem(DEBUG_OUTPUT_BASE + 52, test_pass);  // 1 = PASS, 0 = FAIL
    
    // ============================================================================
    // TESTE 2: Imagem 1x1 (caso extremo)
    // ============================================================================
    
    write_mem(IMAGE_INPUT_BASE + 100, 0xAABBCC00);  // Pixel RGB(170,187,204)
    
    setup_image_plugin(
        IMAGE_INPUT_BASE + 100,     // in_start
        IMAGE_INPUT_BASE + 104,     // in_end
        IMAGE_OUTPUT_BASE + 100,    // out_start  
        IMAGE_OUTPUT_BASE + 104,    // out_end
        1,                          // width = 1
        1                           // height = 1
    );
    
    run_image_plugin();
    
    unsigned int result_1x1 = read_mem(IMAGE_OUTPUT_BASE + 100);
    write_mem(DEBUG_OUTPUT_BASE + 56, result_1x1);
    
    // Esperado: (170+187+204)/4 = 140.25 ≈ 140 (0x8C)
    unsigned int gray_1x1 = (result_1x1 >> 24) & 0xFF;
    write_mem(DEBUG_OUTPUT_BASE + 60, gray_1x1);
    
    // Teste 1x1 passa se gray está entre 138-142
    unsigned int test_1x1_pass = (gray_1x1 >= 138 && gray_1x1 <= 142) ? 1 : 0;
    write_mem(DEBUG_OUTPUT_BASE + 64, test_1x1_pass);
    
    // ============================================================================
    // FINALIZAÇÂO
    // ============================================================================
    
    // Resultado final dos testes
    unsigned int all_tests_pass = test_pass && test_1x1_pass;
    write_mem(DEBUG_OUTPUT_BASE + 68, all_tests_pass);
    
    // Marcador de fim
    write_mem(DEBUG_OUTPUT_BASE + 72, 0xDEADBEEF);
    
    // Loop infinito
    while(1) {
        // Fim do programa
    }
}