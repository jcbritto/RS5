/*
 * Minimal Plugin Test - Direct Memory Access
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

// Assembly NOP to pad start
__asm__(".section .text\n\t"
        ".global _start\n\t"
        "_start:\n\t"
        "nop\n\t"           // NOP at address 0
        "j main\n\t");      // Jump to main at address 4

void main(void) {
    uint32_t result;
    
    // Set operands first
    WRITE_REG(PLUGIN_OPA_ADDR, 5);
    WRITE_REG(PLUGIN_OPB_ADDR, 7);
    
    // Start plugin operation
    WRITE_REG(PLUGIN_CTRL_ADDR, CMD_START);
    
    // Wait for plugin to complete with multiple reads
    result = READ_REG(PLUGIN_RES_ADDR);
    result = READ_REG(PLUGIN_RES_ADDR); 
    result = READ_REG(PLUGIN_RES_ADDR);
    result = READ_REG(PLUGIN_RES_ADDR);
    
    // Output result for verification
    WRITE_REG(OUTPUT_NUM, result);
    
    // Signal end of program
    WRITE_REG(END_REG, 1);
    
    // Infinite loop to prevent further execution
    while(1) {
        // Loop forever
    }
}