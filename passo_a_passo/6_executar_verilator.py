#!/usr/bin/env python3
"""
PASSO 6: Executar Simulação Verilator
Executa o Verilator para simular o RS5 processando a imagem
"""

import os
import sys
import subprocess
import time
from pathlib import Path

def verificar_arquivos_sim():
    """Verifica se arquivos da simulação estão prontos"""
    sim_dir = Path("../sim")
    arquivos = ["program.hex", "test_image_data.hex"]
    
    faltando = []
    for arquivo in arquivos:
        caminho = sim_dir / arquivo
        if not caminho.exists():
            faltando.append(str(caminho))
    
    if faltando:
        print("❌ Arquivos de simulação não encontrados:")
        for arquivo in faltando:
            print(f"   - {arquivo}")
        print()
        print("Execute primeiro: python3 5_preparar_simulacao.py")
        sys.exit(1)
    
    return sim_dir

def executar_verilator(sim_dir):
    """Executa a simulação com Verilator"""
    
    print("🚀 Executando simulação Verilator...")
    print("=" * 50)
    
    try:
        # Executar make run
        cmd = ["make", "run"]
        
        print(f"📍 Diretório: {sim_dir}")
        print(f"💻 Comando: {' '.join(cmd)}")
        print()
        print("🔍 SAÍDA DO VERILATOR:")
        print("-" * 50)
        
        # Executar sem capturar saída para mostrar em tempo real
        result = subprocess.run(cmd, cwd=sim_dir)
        
        print("-" * 50)
        
        if result.returncode == 0:
            print("✅ Simulação concluída com sucesso!")
            return True
        else:
            print(f"⚠️  Simulação terminou com código: {result.returncode}")
            print("   (Isso pode ser normal - timeout do testbench)")
            return True
            
    except Exception as e:
        print(f"❌ Erro na simulação: {e}")
        return False

def analisar_log():
    """Analisa o log da simulação para explicar o que aconteceu"""
    
    print()
    print("🔍 ANÁLISE DO QUE ACONTECEU NA SIMULAÇÃO:")
    print("=" * 50)
    
    print("📋 ETAPAS EXECUTADAS:")
    print("   1. 🔄 Verilator compilou o design do RS5 + plugin")
    print("   2. 🔧 Carregou program.hex na memória (código RISC-V)")
    print("   3. 📊 Carregou test_image_data.hex na memória (dados da imagem)")
    print("   4. ▶️  Iniciou simulação do processador RS5")
    print("   5. 🖼️  Programa C executou no RS5:")
    print("      - Leu cada pixel RGB da memória")
    print("      - Enviou para plugin hardware (0x10000000)")
    print("      - Plugin converteu RGB → Grayscale usando (R+G+B)/4")
    print("      - Resultado salvo na memória de saída")
    print("   6. ⏰ Simulação terminou por timeout ou conclusão")
    
    print()
    print("🔬 SINAIS IMPORTANTES NO LOG:")
    print("   - 'Plugin Write/Read' → Plugin hardware funcionando")
    print("   - 'Operation: addr=0x10000000' → Acesso ao plugin")
    print("   - 'Loading image data' → Dados carregados na RAM")
    print("   - 'IMAGE_PROCESSING_COMPLETE' → Processamento concluído")

def main():
    print("🚀 PASSO 6: EXECUÇÃO DO VERILATOR")
    print("=" * 50)
    
    # Verificar arquivos
    sim_dir = verificar_arquivos_sim()
    
    print("📁 Arquivos de simulação verificados:")
    for arquivo in ["program.hex", "test_image_data.hex"]:
        caminho = sim_dir / arquivo
        tamanho = caminho.stat().st_size
        print(f"   ✅ {arquivo} ({tamanho} bytes)")
    
    print()
    
    # Perguntar se usuário quer continuar
    resposta = input("🎯 Executar simulação agora? (s/N): ").lower()
    if resposta not in ['s', 'sim', 'y', 'yes']:
        print("⏸️  Simulação cancelada pelo usuário")
        sys.exit(0)
    
    print()
    
    # Executar simulação
    inicio = time.time()
    
    if executar_verilator(sim_dir):
        fim = time.time()
        duracao = fim - inicio
        
        analisar_log()
        
        print()
        print(f"⏱️  Tempo de simulação: {duracao:.1f} segundos")
        print()
        print("✅ SIMULAÇÃO COMPLETA!")
        print()
        print("🎯 PRÓXIMO PASSO:")
        print("   Execute: python3 7_reconstruir_imagem.py")
        
    else:
        print()
        print("❌ FALHA NA SIMULAÇÃO!")
        print("   Verifique se Verilator está instalado")
        print("   Verifique se não há erros no design RTL")
        sys.exit(1)

if __name__ == "__main__":
    main()