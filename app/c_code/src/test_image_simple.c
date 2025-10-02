/*
 * Teste básico do Plugin de Imagem - Apenas verificação de endereços
 */

// Função para escrever em endereço de memória
void write_mem(unsigned int addr, unsigned int value) {
    volatile unsigned int *ptr = (volatile unsigned int *)addr;
    *ptr = value;
}

void _start() {
    // Teste 1: Escrever marcador de início
    write_mem(0x80001000, 0x12345678);
    
    // Teste 2: Tentar escrever no plugin 
    write_mem(0x10000000, 0x80002000);  // Input start address
    write_mem(0x80001004, 0xAAAAAAAA);  // Marcador que chegou até aqui
    
    write_mem(0x10000004, 0x80002010);  // Input end address  
    write_mem(0x80001008, 0xBBBBBBBB);  // Marcador que chegou até aqui
    
    write_mem(0x10000008, 0x80003000);  // Output start address
    write_mem(0x8000100C, 0xCCCCCCCC);  // Marcador que chegou até aqui
    
    write_mem(0x1000000C, 0x80003010);  // Output end address
    write_mem(0x80001010, 0xDDDDDDDD);  // Marcador que chegou até aqui
    
    write_mem(0x10000010, 2);           // Width
    write_mem(0x80001014, 0xEEEEEEEE);  // Marcador que chegou até aqui
    
    write_mem(0x10000014, 2);           // Height
    write_mem(0x80001018, 0xFFFFFFFF);  // Marcador que chegou até aqui
    
    // Teste 3: Finalizar
    write_mem(0x8000101C, 0xDEADBEEF);
    
    // Loop infinito
    while(1) {
        // Fim do programa
    }
}