#!/usr/bin/env python3
"""
PASSO 1: Selecionar Imagem para Processamento
Mostra todas as imagens disponíveis e permite escolher uma por número
"""

import os
import sys
from pathlib import Path

def listar_imagens():
    """Lista todas as imagens disponíveis na pasta imagem_entrada"""
    pasta_imagens = Path("../imagem_entrada")
    
    if not pasta_imagens.exists():
        print("❌ Pasta imagem_entrada não encontrada!")
        return []
    
    # Extensões de imagem suportadas
    extensoes = ['.jpg', '.jpeg', '.png', '.bmp', '.tiff']
    
    imagens = []
    for arquivo in pasta_imagens.iterdir():
        if arquivo.suffix.lower() in extensoes:
            imagens.append(arquivo)
    
    return sorted(imagens)

def main():
    print("🖼️  PASSO 1: SELEÇÃO DE IMAGEM")
    print("=" * 50)
    
    imagens = listar_imagens()
    
    if not imagens:
        print("❌ Nenhuma imagem encontrada na pasta imagem_entrada/")
        sys.exit(1)
    
    print(f"📁 Encontradas {len(imagens)} imagens:")
    print()
    
    for i, imagem in enumerate(imagens, 1):
        tamanho = imagem.stat().st_size
        tamanho_kb = tamanho / 1024
        print(f"  {i:2d}. {imagem.name:<40} ({tamanho_kb:6.1f} KB)")
    
    print()
    
    while True:
        try:
            escolha = input(f"Digite o número da imagem (1-{len(imagens)}) ou 'q' para sair: ")
            
            if escolha.lower() == 'q':
                print("👋 Saindo...")
                sys.exit(0)
            
            numero = int(escolha)
            
            if 1 <= numero <= len(imagens):
                imagem_escolhida = imagens[numero - 1]
                print()
                print(f"✅ Imagem selecionada: {imagem_escolhida.name}")
                print(f"📁 Caminho: {imagem_escolhida}")
                
                # Salvar escolha em arquivo temporário
                with open("imagem_selecionada.txt", "w") as f:
                    f.write(str(imagem_escolhida))
                
                print()
                print("🎯 PRÓXIMO PASSO:")
                print("   Execute: python3 2_converter_imagem.py")
                break
            else:
                print(f"❌ Número inválido! Digite um número entre 1 e {len(imagens)}")
                
        except ValueError:
            print("❌ Digite um número válido!")
        except KeyboardInterrupt:
            print("\n👋 Saindo...")
            sys.exit(0)

if __name__ == "__main__":
    main()