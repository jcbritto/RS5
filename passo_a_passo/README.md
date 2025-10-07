# PROCESSAMENTO DE IMAGENS COM RS5 + PLUGIN

Este diretório contém um guia passo-a-passo completo para processar imagens usando o processador RS5 com plugin de hardware para conversão RGB→Grayscale.

## 📋 VISÃO GERAL DO PROCESSO

O pipeline completo consiste em 7 etapas sequenciais:
1. **Seleção da imagem** - Escolher imagem das disponíveis
2. **Conversão para RS5** - Transformar imagem em formato binário
3. **Gerar programa C** - Criar código C específico para a imagem
4. **Compilar programa** - Gerar executável RISC-V
5. **Preparar simulação** - Converter binário para hexadecimal
6. **Executar Verilator** - Simular hardware com plugin
7. **Reconstruir imagem** - Gerar imagem final processada

## 🚀 COMO USAR - COMANDO POR COMANDO

### OPÇÃO 1: Script Auxiliar (RECOMENDADO)
```bash
# Executar cada passo individualmente
./run_step.sh 1  # Selecionar imagem
./run_step.sh 2  # Converter imagem
./run_step.sh 3  # Gerar programa C
./run_step.sh 4  # Compilar programa
./run_step.sh 5  # Preparar simulação
./run_step.sh 6  # Executar Verilator
./run_step.sh 7  # Reconstruir imagem
```

### OPÇÃO 2: Comandos Diretos

### PRÉ-REQUISITOS
```bash
# Verificar se está no diretório correto
pwd  # Deve estar em: /Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/passo_a_passo

# Verificar se Python 3 está instalado
python3 --version

# IMPORTANTE: Configure o ambiente Python primeiro
cd /Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo
python3 -m venv .venv
source .venv/bin/activate
pip install Pillow numpy

# Voltar para o diretório de trabalho
cd passo_a_passo

# Verificar se as dependências estão instaladas
/Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/.venv/bin/python -c "import PIL; import numpy; print('Dependências OK')"
```

### PASSO 1: SELECIONAR IMAGEM
```bash
/Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/.venv/bin/python 1_selecionar_imagem.py
```
**O que faz:**
- Lista todas as imagens disponíveis em `../imagem_entrada/`
- Permite escolher por número
- Verifica se a imagem pode ser processada (tamanho, formato)
- Salva informações da imagem escolhida

**O que observar:**
- Lista numerada das imagens
- Dimensões de cada imagem
- Tamanho estimado em pixels
- Confirmação da escolha

### PASSO 2: CONVERTER IMAGEM PARA FORMATO RS5
```bash
/Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/.venv/bin/python 2_converter_imagem.py
```
**O que faz:**
- Lê a imagem selecionada no passo anterior
- Converte pixels RGB para formato binário RS5
- Salva arquivo `.bin` em `../binarios/`
- Cria versão redimensionada para referência

**O que observar:**
- Progresso da conversão pixel por pixel
- Tamanho do arquivo binário gerado
- Localização dos arquivos criados
- Tempo total de processamento

### PASSO 3: GERAR PROGRAMA C ESPECÍFICO
```bash
python3 3_gerar_programa_c.py
```
**O que faz:**
- Cria programa C personalizado para a imagem atual
- Define tamanhos corretos de memoria e loops
- Configura interface com plugin de hardware
- Salva código C otimizado

**O que observar:**
- Nome do arquivo C gerado
- Dimensões configuradas no código
- Endereços de memória utilizados
- Algoritmo de processamento incluído

### PASSO 4: COMPILAR PROGRAMA RISC-V
```bash
python3 4_compilar_programa.py
```
**O que faz:**
- Compila código C usando toolchain RISC-V
- Gera executável `.elf` e binário `.bin`
- Verifica se compilação foi bem-sucedida
- Mostra estatísticas do executável

**O que observar:**
- Comando de compilação executado
- Saída do compilador (erros/warnings)
- Tamanho dos arquivos gerados
- Localização dos binários

### PASSO 5: PREPARAR SIMULAÇÃO
```bash
python3 5_preparar_simulacao.py
```
**O que faz:**
- Converte binário para formato hexadecimal
- Configura arquivos de simulação
- Prepara memória RAM para Verilator
- Organiza arquivos temporários

**O que observar:**
- Conversão binário → hexadecimal
- Configuração da RAM_mem.sv
- Arquivos copiados para simulação
- Status da preparação

### PASSO 6: EXECUTAR SIMULAÇÃO NO VERILATOR
```bash
python3 6_executar_verilator.py
```
**O que faz:**
- Compila design SystemVerilog com Verilator
- Executa simulação de hardware
- Monitora processamento do plugin
- Salva logs detalhados da simulação

**O que observar:**
- Compilação do Verilator (sem erros)
- Início da simulação
- Logs do plugin processando pixels
- Estatísticas de ciclos e tempo
- Finalização da simulação

### PASSO 7: RECONSTRUIR IMAGEM FINAL
```bash
python3 7_reconstruir_imagem.py
```
**O que faz:**
- Extrai dados processados da simulação
- Reconstrói imagem em escala de cinza
- Aplica algoritmo do plugin: (R+G+B)/4
- Salva imagem final processada

**O que observar:**
- Extração dos dados processados
- Progresso da reconstrução
- Estatísticas da imagem final
- Localização da imagem de saída

## 📁 ESTRUTURA DE ARQUIVOS GERADOS

Após executar todos os passos, você terá:

```
../imagem_entrada/          # Imagens originais
../imagem_redimensionada/   # Versões redimensionadas para referência
../binarios/                # Dados binários da imagem
../app/c_code/             # Programa C gerado
../sim/                    # Arquivos de simulação
../temp_files/             # Arquivos temporários
../imagem_saida/           # Imagem final processada
```

## 🔍 ONDE VERIFICAR CADA ETAPA

### Após Passo 1 - Seleção:
- Arquivo: `../temp_files/current_image_info.txt`
- Contém: informações da imagem escolhida

### Após Passo 2 - Conversão:
- Arquivo: `../binarios/current_image.bin`
- Contém: dados RGB em formato binário

### Após Passo 3 - Programa C:
- Arquivo: `../app/c_code/process_current_image.c`
- Contém: código C personalizado

### Após Passo 4 - Compilação:
- Arquivos: `../app/c_code/process_current_image.elf` e `.bin`
- Contém: executável RISC-V

### Após Passo 5 - Preparação:
- Arquivo: `../sim/program.hex`
- Contém: programa em formato hexadecimal

### Após Passo 6 - Simulação:
- Arquivo: `../temp_files/verilator_log.txt`
- Contém: log completo da simulação

### Após Passo 7 - Reconstrução:
- Arquivo: `../imagem_saida/*_processada.png`
- Contém: imagem final em escala de cinza

## 🔧 TROUBLESHOOTING

### Erro "arquivo não encontrado":
```bash
# Verificar se está no diretório correto
pwd
cd /Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/passo_a_passo
```

### Erro de dependências Python:
```bash
# Instalar dependências
pip3 install Pillow numpy
```

### Erro de compilação RISC-V:
```bash
# Verificar toolchain
which riscv32-unknown-elf-gcc
# Se não estiver instalado, instalar via Homebrew ou build manual
```

### Erro no Verilator:
```bash
# Verificar se Verilator está instalado
which verilator
# Instalar se necessário: brew install verilator
```

### Limpar arquivos temporários:
```bash
# Remover todos os arquivos temporários
rm -rf ../temp_files/*
rm -rf ../binarios/current_image.*
rm -rf ../imagem_redimensionada/*
rm -rf ../imagem_saida/*
```

## 📊 DADOS TÉCNICOS

### Plugin de Hardware:
- **Localização**: `../rtl/plugin_pixel_processor.sv`
- **Algoritmo**: GRAYSCALE = (R + G + B) / 4
- **Interface**: Memory-mapped (0x10000-0x1000C)
- **Operação**: Processa um pixel por vez

### Processador RS5:
- **Arquitetura**: RISC-V 32-bit
- **Memória RAM**: 1MB (expandida de 64KB)
- **Pipeline**: 4 estágios
- **Simulador**: Verilator

### Limitações:
- **Imagem máxima**: ~900KB (pixels * 4 bytes)
- **Formatos suportados**: PNG, JPG, JPEG
- **Processamento**: Sequencial (pixel por pixel)

## 🎯 EXEMPLO COMPLETO

Para processar uma imagem de exemplo:

```bash
# 1. Ir para o diretório
cd /Users/joaocarlosbrittofilho/Documents/doutorado/RS5_ultimo/passo_a_passo

# 2. Executar todos os passos em sequência
python3 1_selecionar_imagem.py    # Escolher imagem
python3 2_converter_imagem.py     # Converter para binário
python3 3_gerar_programa_c.py     # Gerar código C
python3 4_compilar_programa.py    # Compilar RISC-V
python3 5_preparar_simulacao.py   # Preparar simulação
python3 6_executar_verilator.py   # Executar hardware
python3 7_reconstruir_imagem.py   # Gerar imagem final

# 3. Verificar resultado
ls -la ../imagem_saida/           # Ver imagem processada
```

## 📚 ENTENDIMENTO DO PROCESSO

Este pipeline demonstra:

1. **Conversão de dados**: De formato de imagem padrão para binário RS5
2. **Programação embarcada**: Geração de código C específico para hardware
3. **Compilação cruzada**: De C para RISC-V assembly/binário
4. **Simulação de hardware**: Execução em ambiente virtual
5. **Processamento acelerado**: Plugin de hardware para operações repetitivas
6. **Reconstrução de dados**: De formato binário de volta para imagem

Cada etapa é independente e pode ser executada separadamente, permitindo debug e análise detalhada do processo.

---

**DICA**: Execute um passo por vez e verifique os resultados antes de continuar. Isso ajuda a entender o que cada parte faz e facilita o debug em caso de problemas.