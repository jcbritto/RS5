#!/usr/bin/env python3
"""
PASSO 2: Converter Imagem para Formato RS5
Converte a imagem selecionada para formato binário compatível com RS5
"""

import os
import sys
from pathlib import Path
from PIL import Image

def ler_imagem_selecionada():
    """Lê qual imagem foi selecionada no passo anterior"""
    if not os.path.exists("imagem_selecionada.txt"):
        print("❌ Nenhuma imagem selecionada!")
        print("   Execute primeiro: python3 1_selecionar_imagem.py")
        sys.exit(1)
    
    with open("imagem_selecionada.txt", "r") as f:
        caminho = f.read().strip()
    
    return Path(caminho)

def converter_imagem(imagem_path):
    """Converte imagem para formato RS5"""
    print(f"🖼️  Convertendo: {imagem_path.name}")
    
    # Abrir imagem
    image = Image.open(imagem_path)
    original_width, original_height = image.size
    original_pixels = original_width * original_height
    
    print(f"📐 Dimensões originais: {original_width}x{original_height} ({original_pixels:,} pixels)")
    
    # Com 1MB de RAM, processar no tamanho original
    processed_image = image
    print(f"✅ Processando no tamanho original")
    
    # Converter para RGB se necessário
    if processed_image.mode != 'RGB':
        processed_image = processed_image.convert('RGB')
    
    width, height = processed_image.size
    total_pixels = width * height
    
    print(f"📊 Pixels finais: {total_pixels:,} (~{total_pixels*4/1024:.1f}KB)")
    
    # Salvar imagem redimensionada para comparação
    redimensionada_path = f"../imagem_redimensionada/{imagem_path.stem}_redimensionada_{width}x{height}.png"
    os.makedirs("../imagem_redimensionada", exist_ok=True)
    processed_image.save(redimensionada_path)
    print(f"🖼️  Imagem redimensionada salva: {redimensionada_path}")
    
    # Extrair dados RGB
    rgb_data = []
    pixel_data = list(processed_image.getdata())
    
    for i, (r, g, b) in enumerate(pixel_data):
        # Formato: 0xRRGGBBXX (X = padding)
        pixel_value = (r << 24) | (g << 16) | (b << 8) | 0x00
        rgb_data.append(pixel_value)
    
    print(f"✅ Dados RGB extraídos: {len(rgb_data)} pixels")
    
    # Salvar arquivo binário
    os.makedirs("../binarios", exist_ok=True)
    bin_filename = f"../binarios/current_image.bin"
    with open(bin_filename, 'wb') as f:
        for pixel_value in rgb_data:
            f.write(pixel_value.to_bytes(4, byteorder='little'))
    
    print(f"💾 Arquivo binário salvo: {bin_filename}")
    
    # Salvar arquivo de informações
    os.makedirs("../temp_files", exist_ok=True)
    info_filename = f"../temp_files/current_image_info.txt"
    with open(info_filename, 'w') as f:
        f.write(f"Original: {imagem_path}\n")
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
    
    print(f"📄 Arquivo de informações salvo: {info_filename}")
    
    return width, height, total_pixels

def main():
    print("🔄 PASSO 2: CONVERSÃO DE IMAGEM")
    print("=" * 50)
    
    # Ler imagem selecionada
    imagem_path = ler_imagem_selecionada()
    
    if not imagem_path.exists():
        print(f"❌ Imagem não encontrada: {imagem_path}")
        sys.exit(1)
    
    # Converter imagem
    try:
        width, height, pixels = converter_imagem(imagem_path)
        
        print()
        print("✅ CONVERSÃO CONCLUÍDA!")
        print(f"   Dimensões: {width}x{height}")
        print(f"   Total pixels: {pixels:,}")
        print()
        print("📁 ARQUIVOS GERADOS:")
        print("   - ../binarios/current_image.bin (dados para RS5)")
        print("   - ../temp_files/current_image_info.txt (informações)")
        print(f"   - ../imagem_redimensionada/*_redimensionada_{width}x{height}.png (comparação)")
        print()
        print("🎯 PRÓXIMO PASSO:")
        print("   Execute: python3 3_gerar_programa_c.py")
        
    except Exception as e:
        print(f"❌ Erro na conversão: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()