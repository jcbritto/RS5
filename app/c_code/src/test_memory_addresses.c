/*
 * Memory Address Test - Verificar se problema é específico do endereço
 */

typedef unsigned int uint32_t;

// Plugin memory-mapped addresses
#define PLUGIN_OPA_ADDR   0x10000000U
#define PLUGIN_OPB_ADDR   0x10000004U
#define PLUGIN_RES_ADDR   0x10000008U
#define PLUGIN_CTRL_ADDR  0x1000000CU

// Test different memory addresses
#define TEST_ADDR_1      0x80001000U  // Different address in same region
#define TEST_ADDR_2      0x80003000U  // Another different address
#define RAM_ADDR         0x00001000U  // Normal RAM address
#define OUTPUT_NUM       0x80002000U  // Original output address
#define END_REG          0x80000000U

// Memory access macros
#define WRITE_REG(addr, value) (*((volatile uint32_t*)(addr)) = (value))
#define READ_REG(addr)         (*((volatile uint32_t*)(addr)))

void _start(void) {
    uint32_t result;
    uint32_t test_value = 0x12345678;
    
    // Test 1: Write and read from normal RAM
    WRITE_REG(RAM_ADDR, test_value);
    result = READ_REG(RAM_ADDR);
    WRITE_REG(OUTPUT_NUM, result);  // Should be 0x12345678
    
    // Test 2: Write and read from different testbench addresses
    WRITE_REG(TEST_ADDR_1, test_value);
    result = READ_REG(TEST_ADDR_1);
    WRITE_REG(OUTPUT_NUM, result);  // Should be 0x12345678
    
    WRITE_REG(TEST_ADDR_2, test_value);
    result = READ_REG(TEST_ADDR_2);
    WRITE_REG(OUTPUT_NUM, result);  // Should be 0x12345678
    
    // Test 3: Plugin test (known working hardware)
    WRITE_REG(PLUGIN_OPA_ADDR, 10);
    WRITE_REG(PLUGIN_OPB_ADDR, 20);
    WRITE_REG(PLUGIN_CTRL_ADDR, 1);
    result = READ_REG(PLUGIN_RES_ADDR);
    WRITE_REG(OUTPUT_NUM, result);  // Should be 35 (10+20+5)
    
    // Test 4: Simple immediate value test
    result = 0xABCDEF00;
    WRITE_REG(OUTPUT_NUM, result);  // Should be 0xABCDEF00
    
    // Signal end
    WRITE_REG(END_REG, 1);
    
    while(1) {}
}