/*
 * Teste Extensivo ADD_PLUGIN em C - 8 Valores Diferentes
 * Demonstra o uso da instrução personalizada ADD_PLUGIN via inline assembly
 * Operação: resultado = operando1 + operando2 + 5
 */

// Função que executa a instrução ADD_PLUGIN usando inline assembly
static inline unsigned int add_plugin(unsigned int a, unsigned int b) {
    unsigned int result;
    
    // Inline assembly usando encoding direto da instrução ADD_PLUGIN
    // Opcode: 0x0B, rd=x11, rs1=x11, rs2=x12, func3=0, func7=0
    __asm__ volatile(
        "mv x11, %1\n\t"        // mover a para x11
        "mv x12, %2\n\t"        // mover b para x12
        ".word 0x00c5858b\n\t"  // ADD_PLUGIN x11, x11, x12 -> x11
        "mv %0, x11"            // mover resultado para output
        : "=r"(result)          // %0 = output: result
        : "r"(a), "r"(b)        // %1 = input: a, %2 = input: b
        : "x11", "x12"          // registradores usados temporariamente
    );
    
    return result;
}

// Função para escrever na memória (debug)
void write_debug(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

// Função para validar resultado
void validate_test(int test_num, unsigned int result, unsigned int expected, unsigned int base_addr) {
    // Escrever resultado
    write_debug(base_addr + (test_num * 8), result);
    // Escrever esperado  
    write_debug(base_addr + (test_num * 8) + 4, expected);
}

// Ponto de entrada principal (_start em vez de main para embedded)
void _start() {
    unsigned int base_addr = 0x80001000;
    
    // Teste 1: Valores pequenos positivos (5 + 7 = 17)
    unsigned int a1 = 5, b1 = 7;
    unsigned int result1 = add_plugin(a1, b1);
    unsigned int expected1 = 5 + 7 + 5; // = 17
    validate_test(0, result1, expected1, base_addr);
    
    // Teste 2: Zeros (0 + 0 = 5)
    unsigned int a2 = 0, b2 = 0;
    unsigned int result2 = add_plugin(a2, b2);
    unsigned int expected2 = 0 + 0 + 5; // = 5
    validate_test(1, result2, expected2, base_addr);
    
    // Teste 3: Um operando zero (10 + 0 = 15)
    unsigned int a3 = 10, b3 = 0;
    unsigned int result3 = add_plugin(a3, b3);
    unsigned int expected3 = 10 + 0 + 5; // = 15
    validate_test(2, result3, expected3, base_addr);
    
    // Teste 4: Valores grandes (100 + 200 = 305)
    unsigned int a4 = 100, b4 = 200;
    unsigned int result4 = add_plugin(a4, b4);
    unsigned int expected4 = 100 + 200 + 5; // = 305
    validate_test(3, result4, expected4, base_addr);
    
    // Teste 5: Valores iguais (50 + 50 = 105)
    unsigned int a5 = 50, b5 = 50;
    unsigned int result5 = add_plugin(a5, b5);
    unsigned int expected5 = 50 + 50 + 5; // = 105
    validate_test(4, result5, expected5, base_addr);
    
    // Teste 6: Valor negativo + positivo (-10 + 20 = 15)
    int a6 = -10, b6 = 20;
    unsigned int result6 = add_plugin((unsigned int)a6, (unsigned int)b6);
    unsigned int expected6 = (unsigned int)(-10 + 20 + 5); // = 15
    validate_test(5, result6, expected6, base_addr);
    
    // Teste 7: Dois valores negativos (-5 + -3 = -3)
    int a7 = -5, b7 = -3;
    unsigned int result7 = add_plugin((unsigned int)a7, (unsigned int)b7);
    unsigned int expected7 = (unsigned int)(-5 + -3 + 5); // = -3 (0xFFFFFFFD)
    validate_test(6, result7, expected7, base_addr);
    
    // Teste 8: Valores muito grandes (1000 + 2000 = 3005)
    unsigned int a8 = 1000, b8 = 2000;
    unsigned int result8 = add_plugin(a8, b8);
    unsigned int expected8 = 1000 + 2000 + 5; // = 3005
    validate_test(7, result8, expected8, base_addr);
    
    // Marcador de fim dos testes (endereço 0x80001040)
    write_debug(0x80001040, 0xDEADBEEF);
    
    // Loop infinito para terminar execução
    while(1) {
        // Nada - só manter CPU ocupado
    }
}