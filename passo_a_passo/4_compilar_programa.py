#!/usr/bin/env python3
"""
PASSO 4: Compilar Programa C para RISC-V
Compila o programa C gerado para executar no processador RS5
"""

import os
import sys
import subprocess
from pathlib import Path

def verificar_programa_c():
    """Verifica se o programa C foi gerado"""
    c_file = "../app/c_code/src/process_current_image.c"
    
    if not os.path.exists(c_file):
        print("❌ Programa C não encontrado!")
        print("   Execute primeiro: python3 3_gerar_programa_c.py")
        sys.exit(1)
    
    return c_file

def compilar_programa():
    """Compila o programa usando o Makefile do RS5"""
    
    print("🔨 Compilando programa C para RISC-V...")
    
    try:
        # Mudar para diretório do app
        app_dir = Path("../app/c_code")
        
        # Executar make
        cmd = ["make", "PROGNAME=process_current_image"]
        result = subprocess.run(cmd, cwd=app_dir, 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Compilação bem-sucedida!")
            
            # Verificar se arquivos foram gerados
            bin_file = app_dir / "process_current_image.bin"
            elf_file = app_dir / "process_current_image.elf"
            
            if bin_file.exists() and elf_file.exists():
                bin_size = bin_file.stat().st_size
                elf_size = elf_file.stat().st_size
                
                print()
                print("📁 ARQUIVOS GERADOS:")
                print(f"   - {bin_file} ({bin_size} bytes) - Binário RISC-V")
                print(f"   - {elf_file} ({elf_size} bytes) - Executável RISC-V")
                
                return True
            else:
                print("❌ Arquivos binários não foram gerados!")
                return False
        else:
            print("❌ Erro na compilação!")
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Erro ao compilar: {e}")
        return False

def main():
    print("🔨 PASSO 4: COMPILAÇÃO DO PROGRAMA")
    print("=" * 50)
    
    # Verificar se programa C existe
    c_file = verificar_programa_c()
    print(f"📁 Programa C encontrado: {c_file}")
    
    # Mostrar conteúdo do programa (primeiras linhas)
    print()
    print("📋 CONTEÚDO DO PROGRAMA (primeiras linhas):")
    with open(c_file, 'r') as f:
        linhas = f.readlines()
        for i, linha in enumerate(linhas[:15], 1):
            print(f"   {i:2d}: {linha.rstrip()}")
        if len(linhas) > 15:
            print(f"   ... (mais {len(linhas)-15} linhas)")
    
    print()
    
    # Compilar
    if compilar_programa():
        print()
        print("✅ COMPILAÇÃO CONCLUÍDA!")
        print()
        print("🔍 O QUE FOI GERADO:")
        print("   - Código RISC-V compilado para RS5")
        print("   - Binário pronto para carregar na memória")
        print("   - Programa processará pixels usando plugin hardware")
        print()
        print("🎯 PRÓXIMO PASSO:")
        print("   Execute: python3 5_preparar_simulacao.py")
    else:
        print()
        print("❌ FALHA NA COMPILAÇÃO!")
        print("   Verifique se o toolchain RISC-V está instalado")
        print("   Verifique o Makefile em ../app/c_code/")
        sys.exit(1)

if __name__ == "__main__":
    main()