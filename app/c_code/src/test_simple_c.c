/*
 * Teste simples do ADD_PLUGIN em C
 * Executa uma única instrução e termina
 */

// Função para escrever na memória (debug)
void write_debug(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

// Ponto de entrada principal
void _start() {
    unsigned int a = 10;
    unsigned int b = 20;
    unsigned int result;
    
    // Inline assembly para executar ADD_PLUGIN usando .insn
    // Formato R-type: .insn r opcode, func3, func7, rd, rs1, rs2
    __asm__ volatile(
        ".insn r 0x0B, 0x0, 0x00, %0, %1, %2"
        : "=r"(result)      // output: result
        : "r"(a), "r"(b)    // inputs: a, b
        :                   // sem clobber
    );
    
    // Escrever resultado na memória
    write_debug(0x80001000, result);  // Esperado: 10 + 20 + 5 = 35
    
    // Terminar execução de forma controlada
    write_debug(0x80001004, 0xDEADBEEF);  // Marcador de fim
    
    // Infinite loop simples
    while(1) {
        // NOP
    }
}