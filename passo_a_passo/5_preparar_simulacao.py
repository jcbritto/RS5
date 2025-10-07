#!/usr/bin/env python3
"""
PASSO 5: Preparar Simulação
Converte arquivos binários para hex e prepara para simulação no Verilator
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def verificar_arquivos():
    """Verifica se todos os arquivos necessários existem"""
    arquivos = {
        "programa": "../app/c_code/process_current_image.bin",
        "dados": "../binarios/current_image.bin"
    }
    
    faltando = []
    for nome, caminho in arquivos.items():
        if not os.path.exists(caminho):
            faltando.append(f"{nome}: {caminho}")
    
    if faltando:
        print("❌ Arquivos não encontrados:")
        for arquivo in faltando:
            print(f"   - {arquivo}")
        print()
        print("Execute os passos anteriores:")
        print("   1. python3 1_selecionar_imagem.py")
        print("   2. python3 2_converter_imagem.py") 
        print("   3. python3 3_gerar_programa_c.py")
        print("   4. python3 4_compilar_programa.py")
        sys.exit(1)
    
    return arquivos

def converter_bin_para_hex(bin_file, hex_file):
    """Converte arquivo binário para formato hex"""
    
    print(f"🔄 Convertendo {bin_file} -> {hex_file}")
    
    try:
        # Usar o script bin_to_hex.py
        script_path = "/Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/image_processing/scripts/bin_to_hex.py"
        python_exec = "/Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/.venv/bin/python"
        cmd = [python_exec, script_path, bin_file, hex_file]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            if os.path.exists(hex_file):
                tamanho = os.path.getsize(hex_file)
                print(f"✅ Convertido: {hex_file} ({tamanho} bytes)")
                return True
            else:
                print(f"❌ Arquivo hex não foi criado: {hex_file}")
                return False
        else:
            print(f"❌ Erro na conversão: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Erro ao converter: {e}")
        return False

def preparar_simulacao(arquivos):
    """Prepara todos os arquivos para simulação"""
    
    print("📋 Preparando arquivos para simulação...")
    
    # Converter programa para hex
    programa_hex = "../app/c_code/process_current_image.hex"
    if not converter_bin_para_hex(arquivos["programa"], programa_hex):
        return False
    
    # Converter dados da imagem para hex
    dados_hex = "../binarios/current_image.hex"
    if not converter_bin_para_hex(arquivos["dados"], dados_hex):
        return False
    
    # Criar diretório sim se não existir
    sim_dir = Path("../sim")
    sim_dir.mkdir(exist_ok=True)
    
    # Copiar arquivos para sim
    print()
    print("📁 Copiando para pasta de simulação...")
    
    try:
        # Copiar programa
        shutil.copy(programa_hex, sim_dir / "program.hex")
        print(f"✅ Copiado: program.hex")
        
        # Copiar dados da imagem  
        shutil.copy(dados_hex, sim_dir / "test_image_data.hex")
        print(f"✅ Copiado: test_image_data.hex")
        
        return True
        
    except Exception as e:
        print(f"❌ Erro ao copiar arquivos: {e}")
        return False

def mostrar_conteudo_hex(arquivo, linhas=5):
    """Mostra algumas linhas do arquivo hex para verificação"""
    if os.path.exists(arquivo):
        print(f"📄 Conteúdo de {arquivo} (primeiras {linhas} linhas):")
        with open(arquivo, 'r') as f:
            for i, linha in enumerate(f, 1):
                if i <= linhas:
                    print(f"   {i:2d}: {linha.rstrip()}")
                else:
                    break

def main():
    print("📋 PASSO 5: PREPARAÇÃO DA SIMULAÇÃO")
    print("=" * 50)
    
    # Verificar arquivos necessários
    arquivos = verificar_arquivos()
    
    for nome, caminho in arquivos.items():
        tamanho = os.path.getsize(caminho)
        print(f"📁 {nome.capitalize()}: {caminho} ({tamanho} bytes)")
    
    print()
    
    # Preparar simulação
    if preparar_simulacao(arquivos):
        print()
        print("✅ SIMULAÇÃO PREPARADA!")
        print()
        print("📁 ARQUIVOS NA PASTA SIM:")
        sim_dir = Path("../sim")
        for arquivo in ["program.hex", "test_image_data.hex"]:
            caminho = sim_dir / arquivo
            if caminho.exists():
                tamanho = caminho.stat().st_size
                print(f"   - {arquivo} ({tamanho} bytes)")
        
        print()
        print("🔍 VERIFICAÇÃO DOS ARQUIVOS HEX:")
        mostrar_conteudo_hex("../sim/program.hex", 3)
        print()
        mostrar_conteudo_hex("../sim/test_image_data.hex", 3)
        
        print()
        print("✅ PRONTO PARA SIMULAÇÃO!")
        print()
        print("🎯 PRÓXIMO PASSO:")
        print("   Execute: python3 6_executar_verilator.py")
        
    else:
        print()
        print("❌ FALHA NA PREPARAÇÃO!")
        sys.exit(1)

if __name__ == "__main__":
    main()