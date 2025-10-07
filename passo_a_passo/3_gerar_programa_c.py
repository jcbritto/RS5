#!/usr/bin/env python3
"""
PASSO 3: Gerar Programa C para Processamento
Cria o programa C que será executado no RS5 para processar a imagem
"""

import os
import sys
from pathlib import Path

def ler_info_imagem():
    """Lê informações da imagem convertida"""
    info_path = "../temp_files/current_image_info.txt"
    
    if not os.path.exists(info_path):
        print("❌ Arquivo de informações não encontrado!")
        print("   Execute primeiro: python3 2_converter_imagem.py")
        sys.exit(1)
    
    with open(info_path, "r") as f:
        info_lines = f.readlines()
    
    # Extrair dimensões
    dims_line = [l for l in info_lines if "Dimensions:" in l][0]
    width, height = map(int, dims_line.split(":")[1].strip().split("x"))
    
    pixels_line = [l for l in info_lines if "Total pixels:" in l][0]
    total_pixels = int(pixels_line.split(":")[1].strip())
    
    return width, height, total_pixels

def gerar_programa_c(width, height, total_pixels):
    """Gera o programa C personalizado para a imagem"""
    
    c_template = f'''/*
 * RS5 Image Processor - Processamento manual passo a passo
 * Gerado automaticamente para imagem {width}x{height}
 */

// Definições da imagem atual
#define IMAGE_WIDTH  {width}
#define IMAGE_HEIGHT {height}
#define TOTAL_PIXELS {total_pixels}

// Endereços do plugin de pixels - VALIDADOS
#define PLUGIN_RGB_ADDR   0x10000000  // Entrada RGB: 0xRRGGBBXX
#define PLUGIN_UNUSED_ADDR 0x10000004  // Parâmetro não usado  
#define PLUGIN_GRAY_ADDR  0x10000008  // Resultado P&B: 0xGGGGGG00
#define PLUGIN_CTRL_ADDR  0x1000000C  // Controle/Status

// Endereços de dados da imagem na RAM
#define IMAGE_DATA_ADDR   0x00001000  // Onde carregar dados da imagem
#define RESULT_DATA_ADDR  0x00002000  // Onde salvar resultados

// Função para aguardar conclusão do plugin
void wait_plugin_ready() {{
    // Aguardar alguns ciclos para plugin processar
    for (volatile int i = 0; i < 10; i++);
}}

// Função simples para print via UART
void print_uart(const char* str) {{
    volatile unsigned int* uart_base = (volatile unsigned int*)0x80000000;
    while (*str) {{
        *uart_base = *str++;
    }}
}}

int main() {{
    // Ponteiros para dados de entrada e saída
    volatile unsigned int* input_ptr = (volatile unsigned int*)IMAGE_DATA_ADDR;
    volatile unsigned int* output_ptr = (volatile unsigned int*)RESULT_DATA_ADDR;
    
    // Registradores do plugin
    volatile unsigned int* plugin_rgb = (volatile unsigned int*)PLUGIN_RGB_ADDR;
    volatile unsigned int* plugin_ctrl = (volatile unsigned int*)PLUGIN_CTRL_ADDR;
    volatile unsigned int* plugin_result = (volatile unsigned int*)PLUGIN_GRAY_ADDR;
    
    // Processar todos os pixels da imagem
    for (int i = 0; i < TOTAL_PIXELS; i++) {{
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
    }}
    
    // Sinalizar conclusão
    print_uart("IMAGE_PROCESSING_COMPLETE\\n");
    
    return 0;
}}
'''
    
    # Criar diretório se não existir
    os.makedirs("../app/c_code/src", exist_ok=True)
    
    # Salvar programa C
    c_file_path = "../app/c_code/src/process_current_image.c"
    with open(c_file_path, 'w') as f:
        f.write(c_template)
    
    return c_file_path

def main():
    print("🔧 PASSO 3: GERAÇÃO DO PROGRAMA C")
    print("=" * 50)
    
    # Ler informações da imagem
    try:
        width, height, total_pixels = ler_info_imagem()
        print(f"📐 Imagem: {width}x{height} ({total_pixels:,} pixels)")
        
    except Exception as e:
        print(f"❌ Erro ao ler informações: {e}")
        sys.exit(1)
    
    # Gerar programa C
    try:
        c_file_path = gerar_programa_c(width, height, total_pixels)
        
        print()
        print("✅ PROGRAMA C GERADO!")
        print(f"📁 Arquivo: {c_file_path}")
        print()
        print("📋 O PROGRAMA FAZ:")
        print("   1. Lê cada pixel RGB da memória (0x1000)")
        print("   2. Envia pixel para plugin hardware (0x10000000)")
        print("   3. Dispara processamento (0x1000000C = 1)")
        print("   4. Aguarda plugin processar")
        print("   5. Lê resultado grayscale (0x10000008)")
        print("   6. Salva na memória de saída (0x2000)")
        print("   7. Repete para todos os pixels")
        print()
        print("🎯 PRÓXIMO PASSO:")
        print("   Execute: python3 4_compilar_programa.py")
        
    except Exception as e:
        print(f"❌ Erro ao gerar programa: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()