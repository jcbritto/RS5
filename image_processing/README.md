# 🖼️ RS5 Image Processing Plugin

## 📋 Visão Geral

Este projeto implementa um **plugin de processamento de imagem** completo para o processador **RS5 RISC-V**, incluindo hardware personalizado, pipeline automatizado e documentação técnica detalhada.

### ✨ Características Principais

- 🔧 **Plugin de Hardware**: Processamento RGB→Grayscale em SystemVerilog
- 🐍 **Pipeline Python**: Automatização completa do fluxo de trabalho
- 🖼️ **Suporte Universal**: Qualquer formato/tamanho de imagem
- 📊 **Otimização Inteligente**: Uso eficiente da memória RS5 (64KB)
- 🚀 **Performance**: Processamento single-cycle no hardware

## 🎯 Resultados

**✅ 5 imagens processadas com sucesso:**
- Dimensões: até 113×90 pixels (máximo possível no RS5)
- Qualidade: Algoritmo (R+G+B)/4 otimizado para hardware
- Performance: ~1-2 segundos por imagem (pipeline completo)

## 📁 Estrutura do Projeto

```
image_processing/
├── 📂 plugins/          # Hardware SystemVerilog
│   ├── plugin_pixel_processor.sv
│   └── plugin_pixel_memory_interface.sv
├── 📂 scripts/          # Pipeline Python
│   ├── pipeline_automatico.py
│   ├── image_to_rs5_original.py
│   ├── bin_to_hex.py
│   └── analyze_real_processing.py
├── 📂 docs/            # Documentação Técnica
│   ├── DOCUMENTACAO_TECNICA_COMPLETA.md
│   ├── RELATORIO_FINAL_PLUGIN_IMAGEM.md
│   └── RELATORIO_PIPELINE_AUTOMATICO.md
└── 📂 examples/        # Resultados e Comparações
    ├── PROVA_FUNCIONAMENTO.png
    └── comparacao_processamento.png

imagem_entrada/         # Imagens de teste
imagem_saida/          # Resultados processados
```

## 🚀 Como Usar

### Requisitos
- Python 3.8+ com PIL/numpy
- RISC-V toolchain (riscv64-elf-gcc)
- Verilator para simulação

### Processamento Individual
```bash
cd /path/to/RS5_ultimo
source .venv/bin/activate
python3 image_processing/scripts/pipeline_automatico.py imagem_entrada/foto.jpg
```

### Processamento em Lote
```bash
python3 image_processing/scripts/pipeline_automatico.py imagem_entrada/*.jpg
```

### Resultados
As imagens processadas aparecem em `imagem_saida/` com o formato:
- `original_processada.png`

## 🔧 Arquitetura Técnica

### Hardware Plugin
- **Algoritmo**: (R+G+B)/4 para simplicidade de hardware
- **Latência**: 1 ciclo por pixel
- **Interface**: Memory-mapped I/O (0x10000000-0x1000000F)
- **Formato**: 0xRRGGBBXX → 0xGGGGGG00

### Pipeline Software
1. **Conversão**: Imagem → formato RS5 binário
2. **Geração**: Código C dinâmico com dimensões corretas
3. **Compilação**: RISC-V toolchain
4. **Simulação**: Verilator + RS5 + Plugin
5. **Reconstrução**: Resultados → imagem final

## 📊 Validação

### Testes de Pixel
| Input RGB | Output Gray | Status |
|-----------|-------------|--------|
| (255,0,0) | 63 | ✅ |
| (0,255,0) | 63 | ✅ |
| (255,255,255) | 191 | ✅ |
| (0,0,0) | 0 | ✅ |

### Imagens Processadas
- **images.jpeg**: 201×251 → 90×113 (✅)
- **360_F_...**: 450×360 → 113×90 (✅)
- **1464f5c...**: 720×722 → 101×101 (✅)
- **24d509e...**: 720×718 → 101×101 (✅)
- **ce179cb...**: 720×722 → 101×101 (✅)

## 📚 Documentação

- **[Documentação Técnica Completa](image_processing/docs/DOCUMENTACAO_TECNICA_COMPLETA.md)**: Explicação detalhada do hardware e software
- **[Relatório Final Plugin](image_processing/docs/RELATORIO_FINAL_PLUGIN_IMAGEM.md)**: Resultados e validação
- **[Relatório Pipeline](image_processing/docs/RELATORIO_PIPELINE_AUTOMATICO.md)**: Sistema automatizado

## 🏆 Conquistas

### ✅ Hardware
- Plugin funcional em SystemVerilog
- Integração perfeita com RS5
- Algoritmo otimizado para hardware
- Interface memory-mapped estável

### ✅ Software  
- Pipeline completamente automatizado
- Suporte a qualquer formato de imagem
- Gerenciamento inteligente de memória
- Geração dinâmica de código C

### ✅ Sistema
- 100% das imagens processadas com sucesso
- Performance de segundos por imagem
- Documentação técnica completa
- Estrutura extensível para novos algoritmos

## 🔄 Fluxo Completo

```mermaid
graph LR
    A[Imagem Original] --> B[Conversão Python]
    B --> C[Programa C Dinâmico]
    C --> D[Compilação RISC-V]
    D --> E[Simulação RS5+Plugin]
    E --> F[Extração Resultados]
    F --> G[Imagem Processada]
```

## 🚀 Próximos Passos

- **Algoritmos avançados**: Filtros, convoluções, detecção de bordas
- **Pipeline de hardware**: Processamento paralelo de pixels
- **Otimização de memória**: Compressão e cache
- **Interface gráfica**: Frontend para uso interativo

---

**Projeto desenvolvido para o processador RS5 RISC-V**  
**Status**: ✅ Completo e funcional  
**Licença**: Conforme projeto RS5 original