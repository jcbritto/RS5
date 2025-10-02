#!/usr/bin/env python3
"""
Converte dados binários da imagem para formato hex para o testbench
"""

import sys

def bin_to_hex(bin_file, hex_file):
    """Converte arquivo binário para formato hex"""
    
    with open(bin_file, 'rb') as f:
        data = f.read()
    
    # Converter para formato hex (4 bytes por linha)
    with open(hex_file, 'w') as f:
        for i in range(0, len(data), 4):
            if i + 4 <= len(data):
                # Ler 4 bytes em little endian
                word = int.from_bytes(data[i:i+4], 'little')
                f.write(f"{word:08X}\n")
            else:
                # Padding se necessário
                remaining = data[i:]
                padded = remaining + b'\x00' * (4 - len(remaining))
                word = int.from_bytes(padded, 'little')
                f.write(f"{word:08X}\n")

def main():
    if len(sys.argv) != 3:
        print("Uso: python3 bin_to_hex.py <arquivo.bin> <arquivo.hex>")
        sys.exit(1)
    
    bin_file = sys.argv[1]
    hex_file = sys.argv[2]
    
    try:
        bin_to_hex(bin_file, hex_file)
        print(f"✅ Arquivo hex criado: {hex_file}")
    except Exception as e:
        print(f"❌ Erro: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()