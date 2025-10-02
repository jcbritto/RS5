/*
 * Plugin Pipeline Debug Test
 */

typedef unsigned int uint32_t;

// Plugin memory-mapped addresses
#define PLUGIN_OPA_ADDR   0x10000000U
#define PLUGIN_OPB_ADDR   0x10000004U
#define PLUGIN_RES_ADDR   0x10000008U
#define PLUGIN_CTRL_ADDR  0x1000000CU

// Control commands
#define CMD_START    (1 << 0)

// Memory access macros
#define WRITE_REG(addr, value) (*((volatile uint32_t*)(addr)) = (value))
#define READ_REG(addr)         (*((volatile uint32_t*)(addr)))

// Output register for simulation
#define OUTPUT_NUM   0x80002000U
#define END_REG      0x80000000U

void _start(void) {
    uint32_t result1, result2, result3, result4;
    uint32_t op_a, op_b, ctrl;
    
    // Test 1: Write operands
    WRITE_REG(PLUGIN_OPA_ADDR, 5);
    WRITE_REG(PLUGIN_OPB_ADDR, 7);
    
    // Verify operands were written correctly
    op_a = READ_REG(PLUGIN_OPA_ADDR);
    op_b = READ_REG(PLUGIN_OPB_ADDR);
    
    // Output operand verification
    WRITE_REG(OUTPUT_NUM, op_a);  // Should be 5
    WRITE_REG(OUTPUT_NUM, op_b);  // Should be 7
    
    // Test 2: Start operation
    WRITE_REG(PLUGIN_CTRL_ADDR, CMD_START);
    
    // Verify control register
    ctrl = READ_REG(PLUGIN_CTRL_ADDR);
    WRITE_REG(OUTPUT_NUM, ctrl);  // Should be 1
    
    // Test 3: Read result multiple times with different timing
    result1 = READ_REG(PLUGIN_RES_ADDR);  // Immediate read
    WRITE_REG(OUTPUT_NUM, result1);       // Should be 17 = 0x11
    
    result2 = READ_REG(PLUGIN_RES_ADDR);  // Second read
    WRITE_REG(OUTPUT_NUM, result2);       // Should be 17 = 0x11
    
    result3 = READ_REG(PLUGIN_RES_ADDR);  // Third read
    WRITE_REG(OUTPUT_NUM, result3);       // Should be 17 = 0x11
    
    result4 = READ_REG(PLUGIN_RES_ADDR);  // Fourth read  
    WRITE_REG(OUTPUT_NUM, result4);       // Should be 17 = 0x11
    
    // Signal end of program
    WRITE_REG(END_REG, 1);
    
    // Infinite loop to prevent further execution
    while(1) {
        // Loop forever
    }
}