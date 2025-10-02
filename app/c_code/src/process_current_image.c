/*
 * RS5 Image Processor - Processamento automático via pipeline
 * Gerado automaticamente para imagem 201x251
 */

// Definições da imagem atual
#define IMAGE_WIDTH  201
#define IMAGE_HEIGHT 251
#define TOTAL_PIXELS 50451

// Endereços do plugin de pixels - VALIDADOS
#define PLUGIN_RGB_ADDR   0x10000000  // Entrada RGB: 0xRRGGBBXX
#define PLUGIN_UNUSED_ADDR 0x10000004  // Parâmetro não usado  
#define PLUGIN_GRAY_ADDR  0x10000008  // Resultado P&B: 0xGGGGGG00
#define PLUGIN_CTRL_ADDR  0x1000000C  // Controle/Status

// Endereços de dados da imagem na RAM
#define IMAGE_DATA_ADDR   0x00001000  // Onde carregar dados da imagem
#define RESULT_DATA_ADDR  0x00002000  // Onde salvar resultados

// Função para aguardar conclusão do plugin
void wait_plugin_ready() {
    // Aguardar alguns ciclos para plugin processar
    for (volatile int i = 0; i < 10; i++);
}

// Função simples para print via UART
void print_uart(const char* str) {
    volatile unsigned int* uart_base = (volatile unsigned int*)0x80000000;
    while (*str) {
        *uart_base = *str++;
    }
}

int main() {
    // Ponteiros para dados de entrada e saída
    volatile unsigned int* input_ptr = (volatile unsigned int*)IMAGE_DATA_ADDR;
    volatile unsigned int* output_ptr = (volatile unsigned int*)RESULT_DATA_ADDR;
    
    // Registradores do plugin
    volatile unsigned int* plugin_rgb = (volatile unsigned int*)PLUGIN_RGB_ADDR;
    volatile unsigned int* plugin_ctrl = (volatile unsigned int*)PLUGIN_CTRL_ADDR;
    volatile unsigned int* plugin_result = (volatile unsigned int*)PLUGIN_GRAY_ADDR;
    
    // Processar todos os pixels da imagem
    for (int i = 0; i < TOTAL_PIXELS; i++) {
        // Ler pixel RGB da memória
        unsigned int rgb_pixel = *(input_ptr + i);
        
        // Enviar para plugin
        *plugin_rgb = rgb_pixel;
        *plugin_ctrl = 1;  // Disparar processamento
        
        // Aguardar processamento
        wait_plugin_ready();
        
        // Ler resultado (pixel em escala de cinza)
        unsigned int gray_pixel = *plugin_result;
        
        // Salvar resultado na memória
        *(output_ptr + i) = gray_pixel;
    }
    
    // Sinalizar conclusão
    print_uart("IMAGE_PROCESSING_COMPLETE\n");
    
    return 0;
}
