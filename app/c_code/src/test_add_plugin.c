/*
 * Teste do ADD_PLUGIN em C
 * Demonstra como usar instrução custom em código C
 */

// Função que executa a instrução ADD_PLUGIN usando inline assembly
static inline unsigned int add_plugin(unsigned int a, unsigned int b) {
    unsigned int result;
    
    // Inline assembly para executar ADD_PLUGIN usando .insn
    // Formato R-type: .insn r opcode, func3, func7, rd, rs1, rs2
    // ADD_PLUGIN: opcode=0x0B, func3=0x0, func7=0x00
    __asm__ volatile(
        ".insn r 0x0B, 0x0, 0x00, %0, %1, %2"
        : "=r"(result)      // %0 = output: result
        : "r"(a), "r"(b)    // %1 = input: a, %2 = input: b
        :                   // sem registradores destruídos
    );
    
    return result;
}

// Função para escrever na memória (debug)
void write_debug(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

// Ponto de entrada principal (_start em vez de main para embedded)
void _start() {
    // Teste 1: Números pequenos
    unsigned int a1 = 10, b1 = 20;
    unsigned int result1 = add_plugin(a1, b1);
    write_debug(0x80001000, result1);  // Esperado: 10 + 20 + 5 = 35
    
    // Teste 2: Zero
    unsigned int a2 = 0, b2 = 100;
    unsigned int result2 = add_plugin(a2, b2);
    write_debug(0x80001004, result2);  // Esperado: 0 + 100 + 5 = 105
    
    // Teste 3: Números grandes
    unsigned int a3 = 1000, b3 = 2000;
    unsigned int result3 = add_plugin(a3, b3);
    write_debug(0x80001008, result3);  // Esperado: 1000 + 2000 + 5 = 3005
    
    // Teste 4: Números negativos (representação em complemento de 2)
    unsigned int a4 = (unsigned int)(-10);  // 0xFFFFFFF6
    unsigned int b4 = (unsigned int)(-5);   // 0xFFFFFFFB
    unsigned int result4 = add_plugin(a4, b4);
    write_debug(0x8000100C, result4);  // Esperado: -10 + -5 + 5 = -10
    
    // Marcador de fim dos testes
    write_debug(0x80001010, 0xDEADBEEF);
    
    // Loop infinito para terminar execução
    while(1) {
        // Nada - só manter CPU ocupado
    }
}