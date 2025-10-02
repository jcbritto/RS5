/*
 * RS5 Plugin Test - Simples com função _start
 */

// Endereços do plugin  
#define PLUGIN_A_ADDR     0x10000000
#define PLUGIN_B_ADDR     0x10000004  
#define PLUGIN_RESULT_ADDR 0x10000008
#define PLUGIN_ENABLE_ADDR 0x1000000C

void _start() {
    // Plugin test: 5 + 7 + 5 = 17
    
    // 1. Escrever valor A
    volatile unsigned int *ptr_a = (volatile unsigned int *)PLUGIN_A_ADDR;
    *ptr_a = 5;
    
    // 2. Escrever valor B  
    volatile unsigned int *ptr_b = (volatile unsigned int *)PLUGIN_B_ADDR;
    *ptr_b = 7;
    
    // 3. Habilitar plugin
    volatile unsigned int *ptr_enable = (volatile unsigned int *)PLUGIN_ENABLE_ADDR;
    *ptr_enable = 1;
    
    // 4. Ler resultado
    volatile unsigned int *ptr_result = (volatile unsigned int *)PLUGIN_RESULT_ADDR;
    unsigned int result = *ptr_result;
    
    // 5. Escrever resultado para debug
    volatile unsigned int *debug_ptr = (volatile unsigned int *)0x80002000;
    *debug_ptr = result;
    
    // 6. Terminar simulação
    volatile unsigned int *sim_end = (volatile unsigned int *)0x80000000;
    *sim_end = 1;
    
    // Loop infinito
    while(1);
}