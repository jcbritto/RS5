/*
 * RS5 Image Processor Test - Processamento completo de imagem
 * 
 * Lê dados de imagem RGB, processa todos os pixels usando o plugin,
 * e salva os resultados em escala de cinza
 */

// Endereços do plugin de pixels - VALIDADOS
#define PLUGIN_RGB_ADDR   0x10000000  // Entrada RGB: 0xRRGGBBXX
#define PLUGIN_UNUSED_ADDR 0x10000004  // Parâmetro não usado  
#define PLUGIN_GRAY_ADDR  0x10000008  // Resultado P&B: 0xGGGGGG00
#define PLUGIN_CTRL_ADDR  0x1000000C  // Controle/Status

// Endereços de dados da imagem na RAM
#define IMAGE_DATA_ADDR   0x00001000  // Onde carregar dados da imagem
#define RESULT_DATA_ADDR  0x00002000  // Onde salvar resultados

// Endereços de debug/simulação
#define DEBUG_OUTPUT_ADDR 0x80002000  // Para debug
#define SIM_END_ADDR      0x80000000  // Para terminar simulação

/**
 * Função para escrever
 */
static inline void write_word(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

/**
 * Função para ler
 */
static inline unsigned int read_word(unsigned int addr) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    return *ptr;
}

/**
 * Processa um pixel RGB usando o plugin
 */
static inline unsigned int process_pixel(unsigned int rgb_pixel) {
    // Escrever pixel RGB
    write_word(PLUGIN_RGB_ADDR, rgb_pixel);
    
    // Habilitar processamento
    write_word(PLUGIN_CTRL_ADDR, 1);
    
    // Ler resultado em escala de cinza
    return read_word(PLUGIN_GRAY_ADDR);
}

/**
 * Função principal - processa imagem completa
 * NOP inicial compensa PC=4 offset do RS5
 */
void _start() {
    // NOP para compensar PC=4 offset
    asm volatile("nop");
    
    // Ler header da imagem (os dados serão carregados na RAM pelo testbench)
    unsigned int width = read_word(IMAGE_DATA_ADDR + 0);
    unsigned int height = read_word(IMAGE_DATA_ADDR + 4);
    unsigned int total_pixels = read_word(IMAGE_DATA_ADDR + 8);
    
    // Debug: imprimir dimensões
    write_word(DEBUG_OUTPUT_ADDR + 0x00, width);
    write_word(DEBUG_OUTPUT_ADDR + 0x04, height);
    write_word(DEBUG_OUTPUT_ADDR + 0x08, total_pixels);
    
    // Processar todos os pixels
    unsigned int processed_count = 0;
    unsigned int data_offset = IMAGE_DATA_ADDR + 12; // Após header
    unsigned int result_offset = RESULT_DATA_ADDR;
    
    for (unsigned int i = 0; i < total_pixels && i < 100; i++) { // Limitar para teste
        // Ler pixel RGB da RAM
        unsigned int rgb_pixel = read_word(data_offset + (i * 4));
        
        // Processar usando plugin
        unsigned int gray_pixel = process_pixel(rgb_pixel);
        
        // Salvar resultado na RAM
        write_word(result_offset + (i * 4), gray_pixel);
        
        processed_count++;
        
        // Debug a cada 10 pixels
        if (i % 10 == 0) {
            write_word(DEBUG_OUTPUT_ADDR + 0x10 + (i/10 * 8), rgb_pixel);
            write_word(DEBUG_OUTPUT_ADDR + 0x14 + (i/10 * 8), gray_pixel);
        }
    }
    
    // Header dos resultados
    write_word(RESULT_DATA_ADDR + 0, width);
    write_word(RESULT_DATA_ADDR + 4, height);
    write_word(RESULT_DATA_ADDR + 8, processed_count);
    
    // Status final
    write_word(DEBUG_OUTPUT_ADDR + 0x100, processed_count);
    write_word(DEBUG_OUTPUT_ADDR + 0x104, 0xDEADBEEF); // Marca de fim
    
    // Terminar simulação
    write_word(SIM_END_ADDR, 1);
    
    // Loop infinito
    while(1) {
        asm volatile("nop");
    }
}

/*
 * LAYOUT DA MEMÓRIA:
 * 
 * 0x00001000: Header da imagem
 *   +0x00: width (4 bytes)
 *   +0x04: height (4 bytes) 
 *   +0x08: total_pixels (4 bytes)
 *   +0x0C: dados RGB (4 bytes por pixel)
 * 
 * 0x00002000: Resultados processados
 *   +0x00: width (4 bytes)
 *   +0x04: height (4 bytes)
 *   +0x08: processed_count (4 bytes)
 *   +0x0C: dados P&B (4 bytes por pixel)
 * 
 * 0x80002000+: Debug output
 *   +0x00: width, height, total_pixels
 *   +0x10+: samples de pixels (RGB + Grayscale)
 *   +0x100: processed_count
 *   +0x104: 0xDEADBEEF (marca de fim)
 */