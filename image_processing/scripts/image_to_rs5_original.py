#!/usr/bin/env python3
"""
Conversor de imagem para formato RS5 RISC-V
Processa imagens no tamanho original (limitado pela memória do RS5)
"""

import sys
import os
from PIL import Image
import struct

def convert_image_to_rs5(image_path, output_prefix="test_image_data", max_pixels=None):
    """
    Converte uma imagem para formato compatível com RS5
    
    Args:
        image_path: Caminho para a imagem
        output_prefix: Prefixo dos arquivos de saída
        max_pixels: Máximo de pixels permitidos (padrão: calcular baseado na memória RS5)
    """
    try:
        # Abrir imagem
        image = Image.open(image_path)
        original_width, original_height = image.size
        original_pixels = original_width * original_height
        
        print(f"📷 Imagem original: {original_width}x{original_height} ({original_pixels:,} pixels)")
        
        # Calcular limite de memória RS5
        # RS5 tem 64KB de RAM. Reservando espaço para código e pilha, 
        # vamos usar no máximo 40KB para dados de imagem
        max_memory_bytes = 40 * 1024  # 40KB
        bytes_per_pixel = 4  # RGBX format
        max_pixels_memory = max_memory_bytes // bytes_per_pixel
        
        if max_pixels is None:
            max_pixels = max_pixels_memory
        
        print(f"🔧 Limite de memória RS5: {max_pixels:,} pixels (~{max_pixels*4/1024:.1f}KB)")
        
        # Decidir se precisa redimensionar
        if original_pixels <= max_pixels:
            # Usar tamanho original
            processed_image = image
            print(f"✅ Usando tamanho original (dentro do limite)")
        else:
            # Redimensionar mantendo proporção
            scale_factor = (max_pixels / original_pixels) ** 0.5
            new_width = int(original_width * scale_factor)
            new_height = int(original_height * scale_factor)
            
            # Garantir que não ultrapasse o limite
            while new_width * new_height > max_pixels:
                new_width -= 1
                new_height = int(original_height * (new_width / original_width))
            
            processed_image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
            print(f"📐 Imagem redimensionada: {new_width}x{new_height} ({new_width*new_height:,} pixels)")
        
        # Converter para RGB se necessário
        if processed_image.mode != 'RGB':
            processed_image = processed_image.convert('RGB')
        
        width, height = processed_image.size
        total_pixels = width * height
        
        print(f"📊 Pixels finais: {total_pixels:,} (~{total_pixels*4/1024:.1f}KB)")
        
        # Extrair dados RGB
        rgb_data = []
        pixel_data = list(processed_image.getdata())
        
        for i, (r, g, b) in enumerate(pixel_data):
            # Formato: 0xRRGGBBXX (X = padding)
            pixel_value = (r << 24) | (g << 16) | (b << 8) | 0x00
            rgb_data.append(pixel_value)
        
        print(f"✅ Dados RGB extraídos: {len(rgb_data)} pixels")
        
        # Salvar arquivo binário
        bin_filename = f"{output_prefix}.bin"
        with open(bin_filename, 'wb') as f:
            for pixel_value in rgb_data:
                f.write(pixel_value.to_bytes(4, byteorder='little'))
        
        print(f"💾 Arquivo binário salvo: {bin_filename}")
        
        # Salvar arquivo de informações
        info_filename = f"{output_prefix}_info.txt"
        with open(info_filename, 'w') as f:
            f.write(f"Original: {image_path}\n")
            f.write(f"Dimensions: {width}x{height}\n")
            f.write(f"Total pixels: {total_pixels}\n")
            f.write(f"Data format: 0xRRGGBBXX per pixel\n\n")
            f.write("Sample pixels:\n")
            
            # Mostrar alguns pixels de exemplo
            for i in range(min(10, len(rgb_data))):
                row = i // width
                col = i % width
                pixel_val = rgb_data[i]
                r = (pixel_val >> 24) & 0xFF
                g = (pixel_val >> 16) & 0xFF
                b = (pixel_val >> 8) & 0xFF
                f.write(f"Pixel[{i}] ({col},{row}): RGB({r},{g},{b}) = 0x{pixel_val:08X}\n")
        
        print(f"📄 Arquivo de info salvo: {info_filename}")
        
        return width, height, total_pixels, bin_filename, info_filename
        
    except Exception as e:
        print(f"❌ Erro ao converter imagem: {e}")
        return None, None, None, None, None

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 image_to_rs5.py <imagem_entrada> [prefixo_saida]")
        print("Exemplo: python3 image_to_rs5.py imagem_entrada/foto.jpg minha_imagem")
        sys.exit(1)
    
    image_path = sys.argv[1]
    output_prefix = sys.argv[2] if len(sys.argv) > 2 else "test_image_data"
    
    if not os.path.exists(image_path):
        print(f"Erro: Imagem não encontrada: {image_path}")
        sys.exit(1)
    
    print(f"🖼️  Convertendo {image_path} para formato RS5...")
    print("=" * 60)
    
    result = convert_image_to_rs5(image_path, output_prefix)
    if result[0] is not None:
        width, height, pixels, bin_file, info_file = result
        print(f"\n✅ Sucesso! Imagem convertida para formato RS5")
        print(f"   Dimensões: {width}x{height} = {pixels:,} pixels")
        print(f"   Arquivos gerados:")
        print(f"     - {bin_file} (dados binários)")
        print(f"     - {info_file} (informações)")
    else:
        print("❌ Falha na conversão")
        sys.exit(1)

if __name__ == "__main__":
    main()