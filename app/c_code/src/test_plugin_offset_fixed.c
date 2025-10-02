/*
 * Test com offset de PC compensado
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
    // NOP space para compensar PC offset - INSTRUÇÕES REAIS AQUI
    
    // Load base address for plugin (este deveria estar no PC=0, mas está no PC=4)
    volatile uint32_t* plugin_base = (volatile uint32_t*)PLUGIN_OPA_ADDR;
    
    // Set operands
    plugin_base[0] = 5;  // PLUGIN_OPA_ADDR
    plugin_base[1] = 7;  // PLUGIN_OPB_ADDR
    plugin_base[3] = 1;  // PLUGIN_CTRL_ADDR (start)
    
    // Read result
    uint32_t result = plugin_base[2];  // PLUGIN_RES_ADDR
    
    // Output result
    WRITE_REG(OUTPUT_NUM, result);
    
    // Signal end
    WRITE_REG(END_REG, 1);
    
    while(1) {}
}