/*
 * Simple Load/Store Test - Verificar operação básica de memória
 */

typedef unsigned int uint32_t;

// Memory access macros
#define WRITE_REG(addr, value) (*((volatile uint32_t*)(addr)) = (value))
#define READ_REG(addr)         (*((volatile uint32_t*)(addr)))

// Test addresses
#define RAM_TEST_ADDR    0x00001000U
#define OUTPUT_ADDR      0x80002000U
#define END_REG          0x80000000U

void _start(void) {
    uint32_t read_value;
    
    // Test 1: Write known value to RAM
    WRITE_REG(RAM_TEST_ADDR, 0x11111111);
    
    // Test 2: Try to read it back
    read_value = READ_REG(RAM_TEST_ADDR);
    
    // Test 3: Output what we read
    WRITE_REG(OUTPUT_ADDR, read_value);
    
    // Test 4: Output expected value for comparison  
    WRITE_REG(OUTPUT_ADDR, 0x11111111);
    
    // End simulation
    WRITE_REG(END_REG, 1);
    
    while(1) {}
}