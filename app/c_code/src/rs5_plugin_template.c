/*
 * RS5 Plugin Template - Versão com Compensação de PC
 * 
 * IMPORTANTE: O processador RS5 inicia em PC=4 em vez de PC=0
 * Para compensar isso, usamos uma função _start() que será
 * colocada automaticamente no endereço correto pelo linker
 */

// Endereços do plugin - VALIDADOS e FUNCIONAIS
#define PLUGIN_A_ADDR     0x10000000  // Operando A
#define PLUGIN_B_ADDR     0x10000004  // Operando B  
#define PLUGIN_RESULT_ADDR 0x10000008 // Resultado
#define PLUGIN_ENABLE_ADDR 0x1000000C // Enable/Status

// Endereços de debug/simulação - VALIDADOS
#define DEBUG_OUTPUT_ADDR 0x80002000  // Para escrever resultados
#define SIM_END_ADDR      0x80000000  // Para terminar simulação

/**
 * Função para escrever no plugin
 */
static inline void plugin_write(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

/**
 * Função para ler do plugin
 */
static inline unsigned int plugin_read(unsigned int addr) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    return *ptr;
}

/**
 * Função principal que será chamada automaticamente
 * O linker garante que _start esteja no endereço correto
 * IMPORTANTE: Primeiro NOP compensa PC=4 offset do RS5
 */
void _start() {
    // NOP para compensar PC=4 offset (instrução no endereço 0 não é executada)
    asm volatile("nop");
    
    // Exemplo de uso do plugin: soma 5 + 7 + 5 = 17
    
    // 1. Escrever operandos
    plugin_write(PLUGIN_A_ADDR, 5);
    plugin_write(PLUGIN_B_ADDR, 7);
    
    // 2. Habilitar plugin para calcular
    plugin_write(PLUGIN_ENABLE_ADDR, 1);
    
    // 3. Ler resultado
    unsigned int result = plugin_read(PLUGIN_RESULT_ADDR);
    
    // 4. Escrever resultado para debug (verificar no log da simulação)
    plugin_write(DEBUG_OUTPUT_ADDR, result);
    
    // 5. Terminar simulação
    plugin_write(SIM_END_ADDR, 1);
    
    // Loop infinito (necessário para evitar comportamento indefinido)
    while(1) {
        asm volatile("nop");
    }
}

/*
 * INSTRUÇÕES DE USO:
 * 
 * 1. Copie este arquivo como base para seus programas
 * 2. Modifique a função _start() com sua lógica específica
 * 3. Compile com: make PROGNAME=seu_programa
 * 4. O programa será executado corretamente no RS5
 * 
 * ENDEREÇOS VALIDADOS:
 * - 0x10000000: Plugin operando A (escrita)
 * - 0x10000004: Plugin operando B (escrita)  
 * - 0x10000008: Plugin resultado (leitura)
 * - 0x1000000C: Plugin enable (escrita 1=start)
 * - 0x80002000: Debug output (para verificar resultados)
 * - 0x80000000: Fim de simulação (escrita 1=stop)
 */