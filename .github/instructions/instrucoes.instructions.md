---
applyTo: '**'
---
Diretrizes Gerais (para incluir no prompt do Copilot):

Não fabular nem simplificar em demasia: O Copilot deve evitar suposições não verificadas e não criar arquivos ou comportamentos simulados. Todas as implementações precisam ser concretas e baseadas no hardware real do RS5.

Adicionar, não remover: O Copilot deve preservar o funcionamento atual do RS5, adicionando o plugin e as instruções associadas sem quebrar funcionalidades existentes. Não deve apagar código a menos que seja estritamente necessário e justificado.

Entender o RS5 antes de modificar: Se necessário, o Copilot deve inspecionar arquivos do RS5 para compreender como o processador funciona (por exemplo, pipeline, interface de memória, mapeamento de periféricos). O RS5 é escrito em SystemVerilog
github.com
 e implementa um núcleo RISC-V de 32 bits com vários módulos. Ele possui suporte a periféricos mapeados em memória (endereços acima de 64 KB)
github.com
 e inclui aplicações de teste (como “Hello World”
github.com
).

Testar a cada passo: Após cada modificação, o Copilot deve compilar/simular o processador (por exemplo, usando Verilator) e verificar se tudo funciona conforme esperado antes de prosseguir. Qualquer falha deve ser corrigida antes de avançar.

Commits incrementais e claros: O Copilot deve preparar commits separados para cada passo concluído, com mensagens descritivas (em inglês) do tipo "[Step X] Description of changes". Isso facilita revisão e rollback, se necessário.

Com essas diretrizes em mente, vamos detalhar os passos. Cada passo deve ser passado ao Copilot, junto com as instruções específicas, para guiá-lo na implementação.

Passo 1: Preparação do Ambiente e Projeto no Macbook

Antes de codificar, configure o ambiente de desenvolvimento no macOS (por exemplo, um Macbook com Apple Silicon). Certifique-se de ter as ferramentas necessárias instaladas:

Verifique o simulador suportado pelo RS5: O repositório RS5 fornece scripts para ModelSim/Questa, Cadence Xcelium e Verilator
github.com
. No macOS, provavelmente utilizaremos o Verilator, pois é compatível e de código aberto. Obs.: Icarus Verilog pode não suportar todos os recursos SystemVerilog usados. Portanto, se não estiver instalado, instale o Verilator (por exemplo, via Homebrew: brew install verilator).

Linguagem de descrição de hardware: Confirme que o código do RS5 está em SystemVerilog (arquivos .sv)
github.com
. Isso é importante porque precisamos de um simulador que suporte SystemVerilog (o Verilator suporta grande parte do SystemVerilog).

Toolchain RISC-V: Instale o conjunto de ferramentas RISC-V (compilador, assembler e linker) compatível com RV32I, pois vamos compilar programas de teste para o RS5. O README do RS5 menciona um guia de instalação na seção "Requirements" e o uso de um Makefile para compilar programas
github.com
. Certifique-se de ter acesso ao comando riscv32-unknown-elf-gcc ou similar.

Projeto Git limpo: Crie um novo repositório Git local para o projeto (como mostrado nos comandos que você forneceu). Por exemplo:

git init
git remote add origin https://github.com/jcbritto/RS5.git


Em seguida, clone o repositório oficial do RS5 (da PUCRS) ou adicione-o como segunda origem, e copie seu conteúdo para o novo repositório. Como alternativa, você pode fazer:

git clone https://github.com/gaph-pucrs/RS5.git RS5-temp
cp -r RS5-temp/* RS5-temp/.* .   # copie todos os arquivos para o repositório atual
git add . 
git commit -m "[Step 0] Import original RS5 repository"
git push origin main


Isso cria o primeiro commit no seu repositório (first commit contendo o RS5 original). Observação: garanta que os arquivos ocultos (como configurações do git ou arquivos temporários) não sejam copiados indevidamente.

Verificação inicial (Hello World): Antes de qualquer modificação, teste se o ambiente de simulação está funcionando com um exemplo conhecido. O RS5 possui aplicativos de amostra; por exemplo, um programa de Hello World que imprime texto via UART
github.com
. Vamos utilizá-lo para um teste rápido:

Compile o Hello World: Navegue até a pasta de aplicações (RS5/App/samplecode ou semelhante, conforme estrutura do repositório) e procure pelo código "Hello World". Compile-o usando make (segundo o README, rodar make compila todas as aplicações de samplecode
github.com
). Isso deve gerar um binário, provavelmente chamado hello_world.bin ou similar.

Configure a memória para a simulação: Abra o arquivo sim/RAM_mem.sv no RS5. Altere o path default do binário para apontar para o binário do Hello World que você compilou. (No README: "edit the binary file path on the RAM_mem.sv file"
github.com
). Certifique-se de que RAM_mem.sv carregue o conteúdo correto na memória do programa.

Execute a simulação: Na pasta sim/, rode o Verilator conforme instruções do repositório. Por exemplo:

make          # se o Makefile invoca o Verilator corretamente
# ou manualmente:
verilator --cc testbench.sv --exe tb_top_verilator.cpp --build --Wall
./obj_dir/Vtestbench


Isso irá iniciar a simulação do testbench. Verifique se a mensagem "Hello World" aparece na saída padrão do terminal, indicando que o processador executou corretamente o programa e escreveu no UART (stdout). O sucesso deste passo confirma que:

O RS5 está funcional no seu ambiente Mac (Apple M1/M2) usando Verilator.

A toolchain gerou um binário compatível e a memória foi inicializada com ele.

O mecanismo de saída (UART) está operando (ele usa o mapeamento de periférico para saída serial).

Se algo der errado (por exemplo, nenhuma saída no UART), verifique conexões do testbench, clock, reset, e se necessário abra a waveform (o testbench provavelmente gera um .vcd ou similar) para inspecionar sinais. Não prossiga até ter o RS5 original funcionando, pois nossas alterações devem começar de uma base estável.

(Citar evidências: RS5 usa SystemVerilog
github.com
 e tem suporte a Verilator conforme README
github.com
. O Hello World existe como exemplo
github.com
 e a carga de binário é feita via RAM_mem.sv
github.com
.)

Passo 2: Planejar o Mapeamento de Memória para o Coprocessador

Com o RS5 básico rodando, começamos a projetar o plugin de hardware. Primeiro, defina quais endereços de memória serão usados para comunicação entre o processador principal e o coprocessador. Como o RS5 utiliza memória unificada para dados e periféricos, precisamos escolher endereços fora da região normal de RAM para evitar conflitos:

Tamanho da memória principal: Pelo README, a memória de dados do RS5 tem 64 KB. Endereços acima desse range são tratados como periféricos
github.com
. Portanto, utilizaremos endereços a partir de 0x10000 (64 KiB em decimal) para nosso plugin. Isso garante que não sobreporemos a memória interna.

Endereços para o plugin: Reserve alguns registradores de memória mapeada para o plugin, por exemplo:

0x10000: Operando A (32 bits) – o primeiro valor a somar.

0x10004: Operando B (32 bits) – o segundo valor a somar.

0x10008: Resultado (32 bits) – onde o coprocessador escreverá a soma.

0x1000C: Registro de controle/status (opcional, 32 bits) – usado para iniciar a operação e indicar término. (Por exemplo, escrever 1 aqui poderia acionar o início do cálculo; quando o resultado estiver pronto, o hardware pode zerar ou mudar um bit deste registro para indicar “done”.)

Observação: Poderíamos simplificar e não usar um registro separado de controle, iniciando a operação quando ambos os operandos forem escritos, mas isso complica garantir sincronização. Usar um registro de controle explícito clarifica a separação entre escrever dados e acionar o processamento.

Comunicação via memória mapeada vs instrução custom: Duas abordagens são possíveis para alimentar o plugin com dados:

Memória mapeada (periférico clássico): O CPU escreve os operandos nessas posições de memória (0x10000 e 0x10004), então escreve em 0x1000C para dar o comando “start”. O plugin então lê os operandos internamente, realiza a soma e escreve o resultado em 0x10008. O CPU, por sua vez, pode ficar esperando a indicação de término – isso pode ser feito de duas formas:

Polling (sondagem): O software em loop verifica repetidamente um bit de “done” no registro de status em 0x1000C até notar que virou 1 (ou 0, dependendo do protocolo). Enquanto não estiver pronto, o processador principal executa esse loop (ocupando o pipeline mas efetivamente “esperando”).

Stall/backpressure via hardware: O plugin, integrado à interface de memória, poderia fazer o acesso do CPU a 0x1000C bloquear até que a operação finalize. Ou seja, quando o CPU faz uma leitura em 0x1000C, o plugin não retorna os dados (mantendo talvez uma linha de handshake baixa) até estar pronto, segurando a pipeline. Essa abordagem implementa um “backpressure” de hardware de fato. No entanto, isso exigiria modificar a controladora de barramento do RS5 para suportar espera em leitura de periférico. É uma melhoria possível, mas inicialmente podemos trabalhar com a sondagem por software para validar a funcionalidade.

Instrução custom (aceleração integrada): Adicionar uma instrução nova no conjunto RISC-V (chamada ADD_PLUGIN) que faz com que o CPU passe os operandos diretamente ao coprocessador durante a fase de execução, espera o resultado e continua. Essa abordagem envolve mudanças na decodificação e no pipeline – abordaremos nos próximos passos. De fato, o enunciado final pede uma instrução add_plugin, então implementaremos essa via. Contudo, mesmo com instrução custom, provavelmente usaremos também os endereços acima para armazenar ou verificar resultados (por exemplo, o plugin pode ainda usar essas áreas para leitura/escrita de dados, ou pelo menos para inicialização/teste).

Verificar conflitos: Consulte os arquivos de mapeamento de periféricos no RS5 (por exemplo, possivelmente algo como Peripherals.sv ou no módulo de memória). Veja se endereços em torno de 0x10000 já são usados. O README menciona a existência de UART e RTC (real-time clock) mapeados, mas não especifica os endereços ali. Muitas implementações colocam UART próximo a 0x10000. Se houver conflito, escolha outro bloco não usado, por exemplo 0x10010+.

Definir constantes (se aplicável): Facilite futuras referências definindo parâmetros ou localparam no código para esses endereços, por exemplo:

localparam int PLUGIN_OPA_ADDR = 32'h00010000;
localparam int PLUGIN_OPB_ADDR = 32'h00010004;
localparam int PLUGIN_RES_ADDR = 32'h00010008;
localparam int PLUGIN_CTRL_ADDR = 32'h0001000C;


Esses podem residir no módulo de periféricos ou em um include global de endereços. Assim, evitamos números “mágicos” espalhados no código. O Copilot deve inserir essas definições no local apropriado (onde outros mapeamentos de periféricos são definidos).

Comentário no prompt: “Copilot, não assuma valores de endereços sem checar; se não tiver certeza se 0x10000 está livre, abra os arquivos relevantes no repositório RS5 para confirmar. Procure por outras constantes de endereços (ex: 0x10010, etc). Use endereços alinhados a 4 bytes para manter alinhamento de palavra. Lembre-se que 64KB em hex é 0x10000.”

Após este passo, teremos claramente onde o plugin buscará e armazenará dados em memória.

(Citar referência do mapeamento de memória: periféricos acima de 64KB
github.com
 para justificar uso de 0x10000.)

Passo 3: Implementar o Módulo de Coprocessador (Somador de 32 bits)

Agora vamos criar o módulo de hardware que realizará o trabalho do plugin. Este módulo será em SystemVerilog, integrando-se ao projeto. Vamos chamá-lo de, por exemplo, plugin_adder.sv.

Requisitos do módulo:

Entradas:

Dois operandos de 32 bits (operand_a, operand_b), correspondentes aos valores a somar.

Sinal de início (start): quando o processador principal solicitar a operação (via instrução ou escrita em registro de controle), este sinal é ativado por 1 ciclo (ou mantido em 1 enquanto plugin estiver ocupado, dependendo da interface).

(Opcional) Clock e reset: certamente o módulo terá input clk e input reset_n (ou similar) para sincronismo, já que faz parte do sistema síncrono.

Saídas:

Resultado de 32 bits (result).

Sinal de conclusão (done): indica que o resultado está pronto.

Sinal busy/ocupado (busy): indica que o coprocessador está processando e ainda não terminou. Poderíamos usar apenas busy e inferir done quando ele baixa, mas para claridade, dois sinais são úteis (ex: busy fica alto durante operação, done dá um pulso ou fica alto após concluir).

(Opcional) Sinal de backpressure para CPU: não é estritamente necessário se integrarmos via busy no pipeline, mas se fosse um periférico, poderíamos ter um plugin_wait que conecta a lógica de stall da CPU.

Funcionalidade:

Quando o módulo recebe start=1, e se ele não estiver ocupado (busy=0), ele deve latch (armazenar) internamente os valores de operand_a e operand_b (por exemplo, em registradores internos) e então afirmar busy=1.

Em seguida, entra no estado de processamento: como nossa operação é trivial (uma soma de 32 bits), isso pode ser feito combinacionalmente em 1 ciclo. Mas para simular um pipeline ou latência, podemos inserir alguns ciclos de atraso usando uma máquina de estados (por exemplo, permanecer 1 ou 2 ciclos em um estado "calculando").

Calcule result = operand_a + operand_b (aritmética de 32 bits, ignorando overflow para simplificar).

Armazene o result em um registrador de saída interno do plugin.

Aseguir, marque a operação como concluída: busy volta a 0 e done é acionado (por exemplo, pode ser um pulso de 1 ciclo ou manter done=1 até ser resetado quando o CPU ler o resultado).

Opcionalmente, se usarmos um protocolo com registro de controle: o plugin pode também esperar que start volte a 0 antes de resetar done – detalhes da interface que precisamos definir claramente no design.

Reset: se o sistema for resetado, busy e done voltam a 0, e o resultado interno é inválido (pode ser zeroado). O plugin deve estar pronto para uma nova operação.

Máquina de estados (FSM) proposta:

IDLE: Estado inicial, busy=0, done=0. Aguarda start=1. Os operandos de entrada podem estar variando, mas não importam até o start.

LOAD: Quando start é detectado (e talvez um sinal enable de handshake da CPU, dependendo da integração), transicione para LOAD: aqui você copia operand_a e operand_b para regs internos. (Dura 1 ciclo; neste ciclo poderíamos também iniciar a soma combinacionalmente).

EXECUTE: (Este estado pode ser fundido com LOAD se quisermos operação single-cycle, mas explicitar um estado separado permite simular um pipeline). Neste estado, compute o resultado se já não feito. Por segurança, podemos computar no próprio LOAD via combinacional logic e armazenar no fim do ciclo em um reg result_reg.

WRITE/FINISH: Coloque result_reg disponível na saída (se não já) e marque done=1. Mantenha busy=1 até que o resultado seja oficialmente tomado pelo CPU. Poderíamos manter done=1 por 1 ciclo e depois desativar, ou mantê-lo até o próximo comando/reset. Vamos adotar: done fica alto quando resultado pronto e permanece alto até o CPU reconhecer (por exemplo, até uma nova operação começar ou um reset).

Voltar a IDLE: Assim que o CPU inicia uma nova operação (novo start) ou após ter reconhecido o fim (talvez pelo CPU escrever algo no registro de controle para limpar), o plugin retorna a IDLE, limpando done e pronto para próxima.

Este FSM simples garante que o plugin não vai sobrescrever o resultado antes do CPU lê-lo.

Implementação no Copilot: Instrua o Copilot para criar um novo arquivo rtl/plugin_adder.sv (ou dentro de rtl/ ou rtl/peripherals/, dependendo da organização do repositório) com o módulo descrito. Exemplo de definição do módulo:

module plugin_adder (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    output logic [31:0] result,
    output logic        busy,
    output logic        done
);
    // implementação da FSM interna
    typedef enum logic [1:0] {IDLE, LOAD, EXECUTE, FINISH} state_t;
    state_t state;
    logic [31:0] op_a_reg, op_b_reg, result_reg;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            busy <= 1'b0;
            done <= 1'b0;
            result_reg <= 32'b0;
            op_a_reg <= 32'b0;
            op_b_reg <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    done <= 1'b0;
                    if (start) begin
                        // Latch inputs and go to LOAD
                        op_a_reg <= operand_a;
                        op_b_reg <= operand_b;
                        busy <= 1'b1;
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    // We have latched operands, start calculation
                    result_reg <= op_a_reg + op_b_reg;
                    state <= EXECUTE;
                end
                EXECUTE: begin
                    // Calculation done (could insert multi-cycle logic here if needed)
                    state <= FINISH;
                end
                FINISH: begin
                    // Output the result and signal done
                    // (busy still 1 here to indicate operation in progress until fully done)
                    done <= 1'b1;
                    result_reg <= result_reg;  // (result already computed)
                    state <= IDLE;
                    // Note: We choose to return to IDLE immediately.
                    // Alternatively, wait here until CPU acknowledges done.
                end
            endcase
        end
    end

    assign result = result_reg;
endmodule


Nota: A FSM acima imediatamente retorna a IDLE após definir done=1. Isso dá um pulso curto em done. Dependendo da sincronização com CPU, talvez fosse melhor segurar no estado FINISH até uma confirmação. Mas para simplificar, vamos supor que o CPU vai ler o resultado no ciclo seguinte e não iniciará outra operação instantaneamente sem novo start. Podemos ajustar conforme necessidade de sincronização.

Validação do módulo isoladamente: Embora não seja trivial testar isoladamente sem todo o processador, podemos, por curiosidade, criar um mini testbench para o plugin e verificar se operand_a + operand_b produz o resultado correto com a temporização esperada. No entanto, como o plugin será testado integrado ao RS5, não gastaremos muito tempo com um teste stand-alone. Mas, seria prudente simular mentalmente a sequência:

start pulso em 1 -> no próximo ciclo, state passa de IDLE para LOAD, busy=1.

LOAD state -> computa result_reg = op_a + op_b, next state = EXECUTE.

EXECUTE state -> next state = FINISH (could simulate a delay).

FINISH state -> done=1 (for one cycle), busy ainda 1 nesse ciclo? (No código acima, busy foi setado em IDLE e nunca explicitamente limpo antes de voltar a IDLE. Precisamos decidir: busy representa "em progresso". Talvez devemos manter busy=1 até final do FINISH, e só limpar ao entrar em IDLE novamente, o que o código efetivamente faz, pois retorna a IDLE e lá busy<=0.)

Quando retorna a IDLE no final do clock, busy vai a 0, done volta a 0 na sequência (porque em IDLE done é setado 0 imediatamente). Assim, done foi 1 apenas naquele último ciclo FINISH.

Isso significa que o CPU, para detectar o fim, precisaria capturar o pulso de done sincronicamente ou ler algum registro. Esse detalhe de interface vai importar ao integrar no pipeline. Podemos modificar FINISH para não voltar a IDLE automaticamente, ficando travado até o CPU mandar um ack. Mas isso complicaria a lógica de controle.

Vamos adotar o seguinte protocolo simplificado: O plugin gera um pulso em done, e confia que a integração no pipeline vai segurar o CPU até o ciclo do done. Em outras palavras, faremos com que a própria presença de busy cause um stall no pipeline do CPU; quando busy sai (após FINISH), significa que operação terminou e CPU pode prosseguir. Assim, não precisamos que done seja nível alto por vários ciclos – um pulso basta, pois o pipeline vai continuar apenas quando plugin soltar o CPU.

Ajuste no prompt: “Copilot, ao implementar o módulo plugin, documente claramente o comportamento do handshake start/busy/done. Garanta que busy seja mantido enquanto a operação estiver em andamento, e que done pelo menos pulse ou fique ativo no momento da conclusão. Podemos usar busy internamente para sinalizar ao CPU que deve esperar.”

Inserir comentários no código SystemVerilog: Para ajudar na manutenção, oriente o Copilot a incluir comentários explicando cada parte do código (estados da FSM, etc.). Isso também ajuda a verificar se o Copilot não deturpou a lógica.

Após este passo, teremos o módulo plugin_adder.sv implementado. Faça um commit: "[Step 1] Add plugin_adder module (hardware accelerator for addition)". Nota: O commit step 1 aqui corresponde à implementação do plugin após a base, pois o step 0 foi o commit do código base importado.

Passo 4: Integrar o Plugin à Interface de Memória (Mapeamento de Periférico)

Agora que o módulo do coprocessador existe, precisamos conectá-lo ao processador RS5. Inicialmente, vamos integrar via interface de memória mapeada, pois é a forma mais clara de inseri-lo no design existente. Mais adiante, introduziremos a instrução custom para acionar o plugin de forma mais direta.

Tarefas de integração via memória:

Encontrar o módulo de memória/periféricos: No RS5, deve haver um ponto no RTL onde acessos à memória de dados são tratados. Provavelmente há um módulo responsável por multiplexar acessos entre a memória RAM interna (0x0000–0xFFFF) e os periféricos (>=0x10000). Dado o README, há referência a um "peripherals module" e um "data memory interface"
github.com
github.com
. Procure por arquivos com nome sugerindo periferia, ex: rtl/Peripherals.sv ou dentro de RS5_FPGA_Platform.sv.

Vamos supor que exista algo como:

module Peripherals (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] addr,
    input  logic        write_enable,
    input  logic [31:0] write_data,
    output logic [31:0] read_data,
    output logic        read_data_valid,
    // possivelmente sinais de interrupção etc.
);


E internamente ele decodifica o addr para diferentes dispositivos (UART, timer, etc.). Precisamos inserir nosso plugin aqui.

Decodificação de endereço: No módulo de periféricos (ou similar), adicione lógica para reconhecer nossos endereços:

logic sel_plugin; 
assign sel_plugin = (addr == PLUGIN_OPA_ADDR) || (addr == PLUGIN_OPB_ADDR) ||
                    (addr == PLUGIN_RES_ADDR) || (addr == PLUGIN_CTRL_ADDR);


Ou talvez melhor: defina um range se os endereços do plugin forem contíguos. Em nosso exemplo, eles cobrem 0x10000–0x1000C, que é um bloco contíguo de 16 bytes. Então poderíamos fazer:

assign sel_plugin = (addr >= 32'h00010000 && addr < 32'h00010010);


Se nenhum outro periférico usa esse intervalo, isso funciona.

Instanciar o módulo plugin dentro do periférico: No mesmo módulo, instancie plugin_adder:

plugin_adder u_plugin (
    .clk       (clk),
    .reset_n   (reset_n),
    .start     (plugin_start_signal),
    .operand_a (plugin_op_a),
    .operand_b (plugin_op_b),
    .result    (plugin_result),
    .busy      (plugin_busy),
    .done      (plugin_done)
);


Precisaremos de sinais auxiliares:

plugin_op_a e plugin_op_b para armazenar operandos escritos.

plugin_result conectará na lógica de leitura.

plugin_start_signal gerado quando CPU escreve no registro de controle 0x1000C com um valor de “start”.

Podemos ou não usar plugin_done aqui; se usarmos polling, plugin_done pode alimentar um bit de status no read_data quando CPU ler 0x1000C.

Lógica de escrita (CPU -> plugin): Quando o CPU faz uma escrita em um endereço mapeado no plugin:

Se escreve em PLUGIN_OPA_ADDR (0x10000): capture write_data no registrador plugin_op_a.

Se escreve em PLUGIN_OPB_ADDR (0x10004): capture write_data em plugin_op_b.

Se escreve em PLUGIN_CTRL_ADDR (0x1000C): isso deve acionar o plugin_start_signal. Por exemplo, se write_data == 1 ou algum valor específico para iniciar:

Podemos definir: escrever 1 inicia a operação. Então faça plugin_start_signal <= 1 por um ciclo (talvez use um pulso de clock ou uma FSM pequena).

Opcionalmente, se quisermos permitir limpar o plugin, escrever 0 poderia resetar/idle (mas o reset global já cuida disso).

Importante: se o plugin estiver busy no momento de um novo start, podemos ignorar ou enfileirar. Simplicidade: se já busy, talvez ignorar o novo start até terminar (ou retornar um stall no barramento, mas isso complica).

O Copilot deve implementar essa lógica com cuidado: provavelmente introduzindo um registro de estado plugin_request_pending ou similar para acionar o start do plugin no próximo ciclo, respeitando busy.

Escritas no endereço de resultado (0x10008) não fazem sentido para nosso design (resultado é somente leitura). Podemos ignorar ou prevenir isso (não gerar nenhuma ação se CPU tentar escrever lá).

Lógica de leitura (plugin -> CPU): Quando o CPU lê (load) de um endereço:

0x10000: retornar o valor atual de plugin_op_a (opcional – CPU talvez não precise reler o operando, mas nada impede).

0x10004: retornar plugin_op_b.

0x10008: retornar plugin_result (a soma calculada). Se o plugin ainda não terminou, podemos retornar um valor desatualizado (por ex, residual de última operação ou zero). Para evitar confusão, poderíamos designar que o valor em 0x10008 só é válido depois que plugin_done=1. Documentar isso.

0x1000C: retornar um status. Podemos definir bits do status:

bit 0: busy (1 se o plugin está ocupado realizando cálculo).

bit 1: done (1 se a última operação terminou e o resultado está pronto; pode ser auto-limpado ou persistir até leitura).

Os demais bits poderiam ser zero.

Assim, o software pode ler 0x1000C e checar bit 0 para ver se ainda está ocupado, ou bit 1 para ver se acabou. (Uma convenção comum é 0 = busy, 1 = done, mas tanto faz se documentado.)

Implementação: read_data = {30'b0, plugin_done, plugin_busy} ao ler 0x1000C, por exemplo.

Limpeza do done: Se quisermos que ler o status reconheça o done (limpando-o), podemos fazer a leitura de 0x1000C limpar plugin_done interno. Ou então, quando CPU escrever 1 em start novamente, isso automaticamente reseta done para 0 até próxima conclusão.

Backpressure (stall de leitura): Uma melhoria opcional: se o CPU tentar ler 0x10008 (resultado) antes de estar pronto, em vez de devolver lixo, poderíamos fazer o bus esperar. Em SystemVerilog, isso exigiria a interface de memória suportar um sinal de “wait” ou “valid”. O README cita read_data_valid no testbench ou semelhante. Se essa arquitetura suporta espera, podemos:

Assegurar que, ao ler 0x10008 enquanto plugin_busy=1, o read_data_valid seja mantido em 0 até plugin_done ficar 1, atrasando o pipeline. Isso é um backpressure real.

Contudo, isso pode ser complexo dependendo de como a pipeline do RS5 lida com memórias de latência variável. Pelo safe side, não implementaremos isso agora — deixaremos a sincronia a cargo do software ou do handshake via instrução custom.

Integrar no testbench/top: Se o RS5 instanciar Peripherals ou similar no top-level (por ex., RS5_Core ou RS5_FPGA_Platform.sv), pode ser necessário passar sinais do plugin até lá. Como mínimo, possivelmente um sinal de interrupção (IRQ) se plugin fosse gerar (não é o caso aqui) ou apenas conectar o plugin no barramento interno.

Por exemplo, se antes havia algo como:

if (access_to_peripherals) begin
   peripherals.write_enable = write;
   peripherals.addr = address;
   ...
   data_out = peripherals.read_data;
end
else begin
   data_out = memory[address];
end


Agora dentro de peripherals, incluímos nosso plugin logic. Pode ser que o Peripherals.sv já exista e o top instancie ele; nesse caso, só modificamos internamente.

Teste rápido da integração: Sem a instrução custom ainda, podemos testar o plugin via memória mapeada usando instruções RISC-V normais de load/store:

Por exemplo, escrever um pequeno trecho no programa em C/assembly após o Hello World:

// Pseudocódigo de teste:
*(volatile int*)0x00010000 = 5;    // escreve operando A
*(volatile int*)0x00010004 = 7;    // escreve operando B
*(volatile int*)0x0001000C = 1;    // escreve 1 para iniciar (start)
// Agora espera:
while((*(volatile int*)0x0001000C & 0x1) != 0x0) {
    // bit0 busy == 1 enquanto em operação, espera ficar 0 (ou checar bit1 done).
}
int result = *(volatile int*)0x00010008;  // lê resultado
printf("Resultado do plugin = %d\n", result);


Isso em C utilizaria load/store normais. Em assembly, seriam li instruções para carregar literais e sw/lw para armazenar/carregar desses endereços.

Para realizar esse teste, insira esse código no final do main do programa de teste (pode modificar o hello_world ou criar um novo). Compila e roda a simulação. Deve ver no console algo como "Resultado do plugin = 12" se 5+7 foi somado, além do Hello World original.

Observe no log ou waveform se, após o write de start, o CPU entrou em loop (software) até plugin terminar. Isso confirmará que a sincronização básica funciona.

Commit: Se integração estiver funcionando em nível de periférico, faça commit: "[Step 2] Integrate plugin into memory-mapped IO (peripheral interface)". Inclua alterações no módulo de periféricos e instância do plugin.

(Citação útil: O manual descreve periferia mapeada após 64KB
github.com
, confirmando que estamos usando a interface correta.)

Passo 5: Adicionar Instrução Customizada ADD_PLUGIN no Pipeline do RS5

Com o plugin operacional via interface de memória, damos o próximo passo: incorporar uma instrução personalizada no conjunto RISC-V para acionar o plugin de forma mais direta, sem precisar de múltiplas instruções de store/load para mandar operandos e receber resultado. Essa instrução ADD_PLUGIN fará o papel de um “atajo” no pipeline do processador principal para usar o acelerador.

Subpassos para adicionar a instrução:

Escolher opcode e formato: No RISC-V, as instruções personalizadas geralmente usam os opcodes reservados para custom (por exemplo, opcodes que começam com 0b0001011 ou similares – no espaço chamados custom-0, custom-1, etc). Precisamos selecionar um que não conflite com instruções existentes.

O RS5 suporta RV32I, M, A, C, V e algumas Z* e até possivelmente custom (Xosvm)
github.com
. É importante não colidir com nada implementado. Uma escolha comum é usar opcode 0x0B (decimal 11) no campo funct7/funct3 apropriado.

Por exemplo, poderíamos definir ADD_PLUGIN xdest, xsrc1, xsrc2 com um encoding do tipo R (três registradores). Talvez usar o major opcode custom-0 (which is 0b0001011 as the 7-bit opcode) and use funct3 to differentiate if needed.

Para simplicidade, digamos que:

opcode (7 bits) = 0b0001011 (custom-0 opcode space).

funct3 = 000 (we can use this as it's our only custom instruction).

funct7 = 0000000 (could encode variations if needed; not necessary here).

rs1 = operand register 1, rs2 = operand register 2, rd = destination register (will hold the result).

This effectively defines a new instruction that looks like an R-type: similar to a normal ADD (which in RISC-V has opcode 0b0110011), but we place it in custom space to not conflict.

Documentar decisão: Instrução custom ADD_PLUGIN (pseudo-op) utilizará o formato R:

31.........25  24...20 19...15 14..12 11...7  6.....0
funct7(7b)    rs2     rs1    funct3  rd     opcode(7b)
0000000       XXXXX   YYYYY  000     ZZZZZ  0001011


Onde:

XXXXX = código do registrador fonte 2.

YYYYY = código do registrador fonte 1.

ZZZZZ = código do registrador de destino.

O opcode 0001011 sinaliza custom-0.

Vamos supor que o RS5 atual não usa custom-0 (precisar conferir nos arquivos de decode se esse opcode já é capturado para algo).

Nota: Se o RS5 já tiver outra instrução custom implementada, poderíamos escolher custom-1 (opcode 0101011) ou outra. Mas assumiremos que não, para seguir.

Modificar a Unidade de Decodificação: Localize o decodificador do RS5 (provavelmente um arquivo chamado Decoder.sv ou parte do Decode stage). Lá dentro deve haver lógica para identificar instruções e gerar sinais de controle. Pode ser uma combinação de:

sinais one-hot para cada instrução ou tipo (ex.: instr_add, instr_sub, etc.),

ou um grande case discriminando opcodes e funct3/funct7.

Adicione uma entrada para nosso opcode custom. Por exemplo:

logic instr_add_plugin;
always_comb begin
    instr_add_plugin = 1'b0;
    ...
    unique casez (instruction[6:0]) 
        7'b0001011: begin  // custom-0 opcodes
            // further differentiate by funct3/funct7 if multiple
            if (instruction[14:12] == 3'b000 && instruction[31:25] == 7'b0000000) begin
                instr_add_plugin = 1'b1;
            end
        end
        ... // other existing cases
    endcase
end


(O exato formato dependerá do estilo do decodificador no RS5.)

O importante é produzir um sinal de controle que indique à pipeline: "a instrução atual é ADD_PLUGIN". Esse sinal será usado para direcionar o fluxo na etapa de execução.

Além disso, se o decodificador preenche algum microcódigo ou campos de controle (por exemplo, seletores de ALU, mem read/write, etc.), talvez seja necessário adicionar campos para este caso:

Provavelmente, para ALU opnormais, há algo como alu_op = ADD quando instr_add=1. No nosso caso, não queremos que a ALU normal some esses operandos, pois quem somará é o plugin.

Podemos criar um novo tipo de operação, ou simplesmente sinalizar uma exceção no Execute: se instr_add_plugin=1, então bypass a ALU e acione o plugin.

Modificar a Unidade de Execução: Encontre a parte do pipeline que executa instruções (talvez Execute.sv). Precisamos integrar a lógica:

Instancie ou conecte nosso plugin_adder aqui? Alternativamente, se já instanciamos dentro de Peripherals, podemos usar a via de memória. Mas pelo pipeline, talvez seja melhor instanciar diretamente no Execute stage para passar operandos.

No Execute stage, quando instr_add_plugin for 1:

Em vez de usar ALU, tome os operandos (rs1_val, rs2_val) e passe-os para o plugin.

Assert um sinal de start do plugin. Como o Execute stage dura 1 ciclo por design, a questão é: precisamos manter a instrução em execução até plugin terminar, ou podemos iniciar plugin e passar? Raciocinemos:

Se fosse um pipeline normal com latência multi-ciclo, idealmente o stage de Execute deveria segurar esta instrução até conclusão. O RS5 já lida com stalls de memória (por exemplo, load/store podem inserir bolhas esperando memória). Podemos aproveitar mecanismo similar.

Checar se há algo como memory_stall ou handshake no RS5. Talvez na interface de memória, se valid não é pronto, a pipeline pára. Se integrarmos plugin como espécie de “memória lenta”, poderíamos usar isso.

Simples: podemos setar uma condição de stall interno: enquanto plugin_busy for 1 (após start), mantenha a instrução presente no Execute stage (não deixa ir para Retire).

Implementação:

Ao detectar instr_add_plugin, lance plugin_start (pode ser 1 ciclo pulsando quando a instrução entra no Execute pela primeira vez).

Coloque os operandos no plugin (talvez conectados diretamente se plugin for instanciado no Execute).

Sinal de stall: O Execute stage ou alguma unidade central deve ter algo como execute_done ou similar. Podemos usar plugin_busy para indicar que não está pronto. Por exemplo, o Retire stage só escreve resultado quando pronto.

Talvez tenha de interagir com a lógica de hazard: a decodificação possivelmente vai detectar que o destino (rd) está ocupado até write-back. Com um stall, as próximas instruções já não entram em execute, então deve ser ok.

Uma abordagem concreta: No Retire stage (write-back), condicionar: se instr_add_plugin em execução e plugin_busy=1, então inserir bolha (não avançar PC, não escreverback ainda). Quando plugin_done=1, então capture plugin_result e prosseguir.

Coleta do resultado: Quando plugin_done for detectado, o valor do plugin (plugin_result) deve ser encaminhado para o registrador de destino (rd) da instrução. Ou seja, no ciclo em que finaliza:

Enviar plugin_result para o pipeline de write-back. Possivelmente via o mesmo caminho que resultados de ALU vão: por exemplo, um multiplexador que escolhe entre ALU_result, memory_data, CSR_data... nós introduziremos plugin_result lá.

Assegure que o identificador do registrador de destino (rd) da instrução ADD_PLUGIN siga junto até a conclusão.

Limpeza: Após concluir, se formos reutilizar o plugin para outra instrução, certifique que plugin_start seja desativado e plugin esteja pronto para próxima (nosso plugin volta a IDLE rapidamente de qualquer forma).

Adicionar comentários para explicar o fluxo:

// If the instruction is ADD_PLUGIN, trigger the hardware plugin and stall the pipeline until done.
if (instr_add_plugin) begin
plugin_operand_a <= op_rs1; // capture operands (if needed, or directly wire)
plugin_operand_b <= op_rs2;
if (!plugin_busy) begin
plugin_start <= 1'b1; // launch plugin operation on first cycle
end
if (plugin_done) begin
// Plugin finished, retrieve result and allow write-back
wb_value <= plugin_result;
wb_enable <= 1'b1; // allow write-back of result
plugin_start <= 1'b0; // reset start
// (Consider plugin_busy will drop automatically)
end else begin
// Plugin still running, stall pipeline (suppress write-back)
wb_enable <= 1'b0;
// perhaps assert a stall signal to fetch/decode to not proceed
end
end

   - A implementação exata vai depender do design do RS5 pipeline. Pode ser necessário interagir com signals de hazard/stall global. Alguns CPUs têm um sinal global `stall` ou `wait` que bubbles the pipeline.
   - **Integração com módulo plugin:** Podemos reaproveitar a instância do plugin dentro de Peripherals, **desde que** possamos conectar os operandos do pipeline a ele. Isso seria estranho, pois perifericos normalmente conectado só via mem. Melhor instanciar **outro plugin_adder dentro do Execute stage** (ou, se quiser economizar, mover plugin_adder para um lugar central e ter tanto a interface mem quanto a custom instr usando o mesmo hardware). Porém, compartilhar pode complicar porque você teria dois caminhos de ativação (mem e instr).
   - Para simplicidade, **instancie o plugin módulo diretamente no Execute unit** para uso exclusivo da instrução custom:
     - Nomeie diferente para não confundir com periferico? Ou reuse? Pode usar o mesmo `u_plugin` se ele foi instanciado at top and signals routed. Mas provavelmente não foi, pois implementamos dentro de Peripherals.
     - Então, instancie `plugin_adder u_plugin_exec (...)` dentro do Execute stage.
     - Conecte `clk` e `reset_n` aos globais do core.
     - Conecte `operand_a` = valor do registrador rs1 (que deve estar disponível no Execute stage), `operand_b` = valor do rs2.
     - `start` = nossa lógica de start gerada quando instrução entra.
     - Receba `busy`, `done`, `result`.
   - **Cuidado:** Ter duas instâncias do plugin (uma em perifericos, outra no execute) duplicaria hardware. Talvez aceitável dada simplicidade. Se quisermos, poderíamos decidir usar **apenas** via instrução custom e não expor via periferico mem-mapped. Mas o enunciado inicialmente falava em enviar valores para memória e tal — possivelmente esperando um mem-mapped approach. No entanto, pediram especificamente para usar como instrução `add_plugin`, então damos preferência a isso.
   - *Decisão:* Vamos supor que o **plugin será usado apenas via instrução custom** daqui em diante. Ou seja, poderíamos até remover ou ignorar a interface mem-mapeada. Mas não há mal em tê-la (podemos deixar para debug, ou se usuário quiser usar via mem também). Documente isso: "A instrução custom `add_plugin` substitui a necessidade de escrever nos endereços 0x10000 etc manualmente; ela internalmente faz isso. Entretanto, a interface de memória permanece como caminho alternativo."

4. **Atualizar estágios seguintes (Retire/Write-back):** Assegure que a instrução ADD_PLUGIN complete corretamente:
   - O Retire stage provavelmente apenas escreve o valor calculado no banco de registradores. Precisamos garantir que quando plugin_done chega, o Retire escreva o valor certo para o `rd`. 
   - Pode ser que Retire stage simplesmente veja um sinal dizendo "ALU result valid" ou "memory result valid". Talvez introduzir um mux:
     - E.g.: `result_mux = (instr_load) ? mem_data : ((instr_add_plugin) ? plugin_result : alu_result);`
     - E um sinal que indica ao register file para escrever (e qual rd).
   - **Evitar flushes indevidos:** Verifique como branch mispredicts ou jumps são tratados — tags/flow etc. Nosso plugin instruction não deve interferir nisso (não é uma mudança de PC, nem trap, então deve fluir normal).
   - **Exceções:** Se RS5 tem tratamento de exceptions, possivelmente a instrução desconhecida antes seria illegal. Agora que definimos, precisamos evitar que dispare illegal instruction trap. Provavelmente no decode, se não reconhece uma instrução, gera trap. Após adicionar no decode, isso não ocorre para nosso opcode.

5. **Testar via instrução custom:** Escreva um novo programa (ou adapte o teste anterior) para utilizar **diretamente a instrução `ADD_PLUGIN`**:
   - Em assembly, algo como:
     ```asm
     li x5, 5           # carga imediato 5 em x5 (operando A)
     li x6, 7           # carga imediato 7 em x6 (operando B)
     add_plugin x7, x5, x6  # x7 = x5 + x6 via coprocessador
     # (Precisaremos definir a macro ou encoding para add_plugin)
     ```
     Depois, usar o valor em x7: por exemplo, escrevê-lo na saída UART para verificar.
   - Como o assembler não conhece `add_plugin`, podemos usar diretivas:
     - RISC-V assembler (`gas`) tem `.insn` pseudo-instruction to encode custom opcodes. Sintaxe: `.insn r opcode, funct3, rd, rs1, rs2` (precisar confirmar). Ou usar `.word` with the 32-bit binary encoding.
     - Exemplo: Se nosso encoding for conforme acima, podemos calcular o valor binário:
       - opcode 7 bits = `0001011` (binary) = 0x0B.
       - funct3 3 bits = `000` (0).
       - funct7 7 bits = `0000000` (0).
       - Suppose rd=7 (x7 -> b0111), rs1=5 (x5 -> b00101), rs2=6 (x6 -> b00110).
       - Binary: funct7(0000000) rs2(00110) rs1(00101) funct3(000) rd(00111) opcode(0001011).
       - Grouping: 0000000 00110 00101 000 00111 0001011.
       - In hex, that's: 0x (we can compute manually or let Copilot do).
       - Em todo caso, para evitar erros manuais, podemos usar `.insn`:
         ```
         .insn r 0x0B, 0, x7, x5, x6   # if gas supports custom encoding, 0x0B is the opcode, funct3=0
         ```
         Ou:
         ```
         .word 0x[hex]   # the exact 32-bit value
         ```
     - Consulte a documentação do assembler RISC-V para sintaxe de `.insn`. (Copilot pode ajudar aqui com base em padrões conhecidos).
   - Em C, poderíamos usar asm volatile com .word, mas melhor escrever um pequeno asm mesmo.
   - **Programa de teste completo:** Monte algo como:
     ```c
     #include <stdio.h>
     int main() {
         int a=5, b=7, c=0;
         // ideally, call the custom instruction:
         asm volatile(".insn r 0x0B, 0, %0, %1, %2" : "=r"(c) : "r"(a), "r"(b));
         printf("Resultado do add_plugin: %d\n", c);
         return 0;
     }
     ```
     Isso depende se `.insn r opcode, funct3,...` funciona – se não, usar `.word`.
   - Compile este programa com o toolchain RISC-V. Ajuste o Makefile se necessário (adicionando este novo programa na lista PROGNAME conforme instruções do README:contentReference[oaicite:19]{index=19}). Gere o binário.
   - Atualize o `RAM_mem.sv` para apontar para esse binário e rode a simulação novamente.
   - **Comportamento esperado:** O valor impresso deve ser `12`. Além disso, observe se a execução travou enquanto calculava:
     - Como nosso plugin soma praticamente de imediato, pode ser difícil ver a pausa. Podemos modificar temporariamente o plugin FSM para inserir um delay artificial de alguns ciclos no EXECUTE state (por exemplo, permanecer X ciclos antes de FINISH) só para testar o stall.
     - Outra tática: incrementar os operandos a valores maiores e modificar o plugin para fazer, e.g., uma soma iterativa (loop) para gastar tempo. Mas não necessário se confiamos no handshake.
   - Confira também via ondas ou logs se nenhuma outra instrução executou enquanto plugin estava busy (indicando stall correto).

   Se o resultado não bater ou o CPU não esperar adequadamente:
   - Depure sinais: verifique se `instr_add_plugin` está sendo detectado, se `plugin_start` acionou, se possivelmente o pipeline não reconheceu e pulou.
   - Pode ser útil inserir prints no Verilator TB (tb_top_verilator.cpp) quando plugin done acontece, ou monitorar ciclos.
   - Ajuste a lógica de stall: talvez precisar usar o sinal global de hazard. Às vezes, pipelinas têm algo como um sinal `stall_Fetch` ou `insert_nop` etc. Use o mesmo mecanismo que loads usam quando esperando memória (no RS5, o decode insere NOPs quando detecta hazard ou mem stall:contentReference[oaicite:20]{index=20}:contentReference[oaicite:21]{index=21}). Podemos reutilizar isso: ex: assuma `plugin_busy` as a kind of memory stall signal.

- **Commit:** Depois de implementar e testar, faça commit: `"[Step 3] Add ADD_PLUGIN custom instruction and pipeline integration"`. Incluir todas as mudanças em decode, execute, etc.

*(Podemos citar o trecho do README sobre hazard e stall na decode para justificar nossa abordagem de inserir bolhas:contentReference[oaicite:22]{index=22}, se coubesse, mas não necessário. Citar também que o core é 4-stage pipeline:contentReference[oaicite:23]{index=23} – relevante para entender que nosso plugin stall afeta do execute pro fetch.)*

## Passo 6: Testes Finais, Validação e Depuração

Agora vem a parte de **garantir que tudo funciona conforme o esperado** com o sistema completo:

- **Teste do programa com instrução custom:** Execute novamente a simulação com o programa que usa `ADD_PLUGIN`. Verifique:
  - Saída correta (`Resultado do add_plugin: 12`, por exemplo).
  - O processador não travou (a não ser intencionalmente enquanto espera o plugin, mas depois continuou).
  - **Verificar registradores:** Se possível, utilize o testbench ou mods no código para ler o valor do registrador de destino após a instrução. Por exemplo, se temos acesso ao banco de registradores no testbench (muitos testbenches têm, ou podemos instrumentar imprimindo o valor de x7 após completado).
  - **Condições de borda:** Teste outro caso, por exemplo a=10, b=20 -> resultado 30. Ou teste com números negativos (two’s complement) só para ver se soma sinalizada funciona. Deve funcionar igual a ADD normal exceto por overflow (que não tratamos especificamente, mas também não precisamos).
  - **Timing:** Introduza, temporariamente, um delay no plugin (por ex., faça a FSM esperar 5 ciclos no EXECUTE state) e re-simule para ver se a CPU realmente espera esses ciclos sem executar próxima instrução. Cheque contagem de ciclos ou waveform: a instrução ADD_PLUGIN deve permanecer no execute por vários ciclos e somente então liberar.
  - **Polling vs stall:** Se ainda implementamos a interface mem, poderíamos também tentar usar o método antigo (escrever nos endereços e polling) para ver se também funciona com o mesmo hardware. (Isso seria um teste extra: efetuar as stores e loads manualmente e ver se plugin dá resultado – útil se quisermos assegurar que nenhuma modificação no plugin que fizemos para custom quebrou o mem-mapped.)

- **Depuração de possíveis problemas:**
  - *Sintoma:* Resultado incorreto ou `x7` não mudou -> verifique se plugin recebeu os operandos certos. Pode ser erro no wiring de rs1/rs2. Também cheque se rd não estava x0 (registrador zero) por erro de encoding do opcode.
  - *Sintoma:* CPU travou permanentemente -> talvez o handshake não libera. Ex.: plugin_done pulso perdido e CPU continua esperando. Solução: usar plugin_busy como condição de espera e plugin_busy efetivamente vai a 0, assim CPU prossegue mesmo se done perdeu.
  - *Sintoma:* Instrução seguinte executou sem esperar -> stall logic falhou. Insira printouts ou LED (if FPGA) para ver se plugin_busy foi ignorado. Pode precisar setar um sinal de hazard para decode stage. Ex.: definir `hazard <= 1` enquanto plugin_busy, semelhante a hazard de load-use.
  - *Sintoma:* Illegal instruction trap acionada -> decode não reconheceu a instrução custom. Confirme se opcode e campos estão alinhados com o que assembler emitiu. Ajuste se necessário.
  - *Outros:* Conflitos com pipelining – ex.: se uma interrupção ocorrer bem quando plugin em andamento? (Nosso teste não envolve interrupções, então ignoremos por ora.)

- **Limpeza de código e comentários:** Depois de tudo funcionando, assegure que:
  - Todos os **trechos adicionados estão comentados** suficientemente (para futura manutenção).
  - Código segue convenções do projeto (nomes de sinal em minúsculas/camelCase, etc.).
  - Remova qualquer debug leftover (como prints no testbench, ou delays intencionais no plugin FSM usados para teste).
  - Atualize documentações se houver: por exemplo, adicionar no README uma descrição da instrução `add_plugin` e do hardware (mas isso pode ser feito manualmente depois).

- **Considerações finais:** Nosso plugin de soma é simples, mas estabelece o arcabouço para plugins mais complexos. Ele demonstra como usar backpressure no pipeline e comunicação via memória mapeada. 

  Antes de finalizar, **reitere ao Copilot**:
  - **Não introduzir comportamento especulativo:** Certifique-se que o plugin só opera quando instruído. Por ex, se por bug `plugin_start` ficasse sempre 1, isso seria errado. 
  - **Não quebrar outras instruções:** Verificar se, por exemplo, a adição normal (ADD) ainda funciona, se load/store ainda funcionam. (Rodar o riscv-tests or pelo menos um subset pode dar confiança).
  - **Performance:** Note que estamos fazendo o CPU esperar ativamente. Isso é esperado para uma operação sincrônica. Em designs avançados, poderíamos liberar o CPU para fazer outra coisa e sinalizar interrupção quando pronto – mas isso fugiria do escopo.
  - **Commit final:** Faça um último commit consolidando eventuais ajustes pós-teste: `"[Step 4] Fixes and final validation for plugin integration"`.

Finalmente, **envie todos os commits para o repositório remoto** (`git push`). Agora o projeto em `github.com/jcbritto/RS5` deve conter:

- Código original do RS5.
- O novo módulo `plugin_adder.sv`.
- Modificações no decodificador, execute (e possivelmente periféricos).
- Um programa de teste (por exemplo, em `App/samplecode/add_plugin_test.c` ou `.S`) incluído no build.
- Atualizações no Makefile do software se necessárias.
- (Opcional) Atualização no README.md documentando a novidade.

Cada commit isolado deve compilar e simular, mas principalmente o estado final deve passar em todos os testes planejados.

**Recapitulando de forma concisa (para o Copilot seguir passo-a-passo):**

- **Step 1:** *Setup environment & initial commit.* Clone RS5, confirm SystemVerilog and Verilator use (evidência: RS5 escrito em SystemVerilog:contentReference[oaicite:24]{index=24}, simulação via Verilator disponível:contentReference[oaicite:25]{index=25}). Teste Hello World para baseline.
- **Step 2:** *Memory mapping.* Define plugin I/O addresses (e.g. 0x10000+), update peripheral interface to route these to plugin (periféricos mapeados acima de 64KB:contentReference[oaicite:26]{index=26}).
- **Step 3:** *Hardware module.* Implement `plugin_adder.sv` (32-bit adder with start/done handshake).
- **Step 4:** *Memory integration.* Integrate `plugin_adder` via memory-mapped registers (update peripheral module to handle writes/reads to 0x10000-0x1000C).
- **Step 5:** *Custom instruction.* Add `ADD_PLUGIN` instruction:
  - Update decoder (new opcode recognition).
  - Update execute stage (instantiate plugin, stall until done, forward result to write-back).
  - Ensure pipeline waits on plugin (backpressure).
- **Step 6:** *Testing & commits.* Compile test program using `ADD_PLUGIN` (use `.insn` or `.word` in assembly to emit opcode). Simulate and verify correct behavior (result matches, CPU stalled during calc). Fix any issues. Commit each step with clear messages. Push to repo.

Inclua todas essas instruções e contexto no prompt do Copilot, para que ele tenha uma visão completa do objetivo e possa executar **sequencialmente cada ação** necessária, sem inventar atalhos. Lembre-o constantemente de **testar e validar** antes de seguir adiante. 

Seguindo esse plano detalhado, o Copilot deve conseguir implementar o plugin de hardware para o RS5 no seu Macbook, garantindo que o processador principal e o coprocessador trabalhem em conjunto conforme especificado. Boa sorte no desenvolvimento!

:contentReference[oaicite:27]{index=27}:contentReference[oaicite:28]{index=28}:contentReference[oaicite:29]{index=29}:contentReference[oaicite:30]{index=30}:contentReference[oaicite:31]{index=31}