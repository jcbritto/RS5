/*
 * Teste Simples ADD_PLUGIN em C 
 * Teste único para debug de carregamento de operandos
 */

// Função para escrever na memória (debug)
void write_debug(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

// Ponto de entrada principal
void _start() {
    unsigned int a = 5;
    unsigned int b = 7;
    unsigned int result;
    
    // Debug: escrever valores de entrada
    write_debug(0x80001000, a);      // Escrever valor de a
    write_debug(0x80001004, b);      // Escrever valor de b
    
    // Inline assembly mais explícito
    __asm__ volatile(
        "li x11, 5\n\t"            // carregar valor 5 diretamente em x11
        "li x12, 7\n\t"            // carregar valor 7 diretamente em x12  
        ".word 0x00c5858b\n\t"     // ADD_PLUGIN x11, x11, x12 -> x11 (5+7+5=17)
        "mv %0, x11"               // mover resultado para output
        : "=r"(result)             // %0 = output: result
        :                          // sem inputs
        : "x11", "x12"             // registradores modificados
    );
    
    // Debug: escrever resultado
    write_debug(0x80001008, result);         // Resultado calculado
    write_debug(0x8000100C, 17);             // Resultado esperado (5+7+5)
    
    // Loop infinito
    while(1) {
        // Nada
    }
}