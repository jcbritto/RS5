# RS5 RISC-V Processor com Plugin de Processamento de Imagem

Sistema completo de processamento de imagem em hardware usando o processador RISC-V RS5.

## 📁 Estrutura do Projeto

```
RS5_ultimo/
├── 📚 documentacao/          # Toda a documentação (.md)
│   ├── README.md             # Documentação principal
│   ├── GUIA_IMPLEMENTACAO_*.md
│   ├── RELATORIO_*.md
│   └── RESUMO_*.md
├── 🔧 scripts/               # Scripts auxiliares
│   └── encode_instruction.py
├── 💾 binarios/              # Arquivos binários e executáveis
│   ├── *.bin                 # Dados binários
│   ├── *.elf                 # Executáveis
│   └── *.hex                 # Arquivos hex para simulação
├── 📝 temp_files/            # Arquivos temporários
│   ├── *.txt                 # Informações de imagem
│   └── *.png                 # Imagens temporárias
├── 🖼️ image_processing/      # Sistema de processamento de imagem
│   ├── plugins/              # Hardware plugins SystemVerilog
│   ├── scripts/              # Scripts Python automatizados
│   ├── docs/                 # Documentação técnica
│   └── examples/             # Exemplos e testes
├── 📷 imagem_entrada/        # Imagens de entrada
├── 📤 imagem_saida/          # Imagens processadas
├── ⚙️ rtl/                   # Código SystemVerilog do RS5
├── 🧪 sim/                   # Simulação
├── 📱 app/                   # Aplicações e testes
└── 📋 docs/                  # Documentação adicional
```

## 🚀 Uso Rápido

### Processar uma imagem:
```bash
python3 image_processing/scripts/pipeline_automatico.py imagem_entrada/sua_imagem.jpg
```

### Processar múltiplas imagens:
```bash
python3 image_processing/scripts/pipeline_automatico.py imagem_entrada/*.jpg
```

## 📊 Resultados

- ✅ Sistema 100% funcional
- 🎯 5/5 imagens testadas com sucesso
- ⚡ Processamento: ~1-2 segundos por imagem
- 🧠 Plugin hardware implementado: (R+G+B)/4 grayscale
- 📐 Máximo: 113×90 pixels (limitação memória RS5)

## 📖 Documentação

- **Principal**: `documentacao/README.md`
- **Técnica**: `image_processing/docs/DOCUMENTACAO_TECNICA_COMPLETA.md`
- **Implementação**: `documentacao/DIARIO_IMPLEMENTACAO_PLUGIN_IMAGEM.md`

## 🔧 Estrutura Técnica

- **Hardware**: Plugin SystemVerilog integrado ao RS5
- **Software**: Pipeline Python automatizado end-to-end
- **Simulação**: Verilator com testbench validado
- **Resultado**: Imagens grayscale salvas em `imagem_saida/`

---
*RS5 RISC-V Processor - PUC-RS - 2024*