/*
 * RS5 Plugin Test - Versão que compensa offset de PC
 * 
 * O processador RS5 inicia em PC=4, então precisamos
 * adicionar um NOP ou instrução dummy no início
 */

// Endereços do plugin  
#define PLUGIN_A_ADDR     0x10000000
#define PLUGIN_B_ADDR     0x10000004  
#define PLUGIN_RESULT_ADDR 0x10000008
#define PLUGIN_ENABLE_ADDR 0x1000000C

// Assembly inline para adicionar NOP no início
asm(".section .text\n"
    ".global _start\n"
    "_start:\n"
    "nop\n"          // Instrução no endereço 0 (não será executada devido ao offset PC)
    "j main\n");     // Jump para main no endereço 4

// Função para escrever no plugin
void write_plugin(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

// Função para ler do plugin
unsigned int read_plugin(unsigned int addr) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    return *ptr;
}

int main() {
    // Teste do plugin: 5 + 7 + 5 = 17
    
    // 1. Escrever valores A e B
    write_plugin(PLUGIN_A_ADDR, 5);
    write_plugin(PLUGIN_B_ADDR, 7);
    
    // 2. Habilitar plugin (trigger para calcular)
    write_plugin(PLUGIN_ENABLE_ADDR, 1);
    
    // 3. Ler resultado
    unsigned int result = read_plugin(PLUGIN_RESULT_ADDR);
    
    // 4. Escrever resultado para endereço de debug
    volatile unsigned int *debug_ptr = (volatile unsigned int *)0x80002000;
    *debug_ptr = result;
    
    // 5. Terminar simulação
    volatile unsigned int *sim_end = (volatile unsigned int *)0x80000000;
    *sim_end = 1;
    
    return 0;
}