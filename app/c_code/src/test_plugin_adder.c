/*
 * Test Plugin Adder via Memory-Mapped Interface
 * 
 * Tests the plugin_adder module through memory-mapped registers
 * - 0x10000000: Operand A (write)
 * - 0x10000004: Operand B (write) 
 * - 0x10000008: Result (read)
 * - 0x1000000C: Control/Status (read/write)
 */

// Basic type definitions
typedef unsigned int uint32_t;

// Plugin memory-mapped addresses
#define PLUGIN_OPA_ADDR   0x10000000U
#define PLUGIN_OPB_ADDR   0x10000004U
#define PLUGIN_RES_ADDR   0x10000008U
#define PLUGIN_CTRL_ADDR  0x1000000CU

// Status bits
#define STATUS_BUSY  (1 << 0)
#define STATUS_DONE  (1 << 1)

// Control commands
#define CMD_START    (1 << 0)

// Memory access macros
#define WRITE_REG(addr, value) (*((volatile uint32_t*)(addr)) = (value))
#define READ_REG(addr)         (*((volatile uint32_t*)(addr)))

// Output register for simulation
#define OUTPUT_REG   0x80004000U
#define OUTPUT_NUM   0x80002000U
#define END_REG      0x80000000U

void print_char(char c) {
    *((volatile char*)OUTPUT_REG) = c;
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

void print_number(uint32_t num) {
    *((volatile uint32_t*)OUTPUT_NUM) = num;
}

void test_plugin_addition(uint32_t a, uint32_t b) {
    print_string("Testing: ");
    print_number(a);
    print_string(" + ");
    print_number(b);
    print_string("\n");
    
    // Write operands
    WRITE_REG(PLUGIN_OPA_ADDR, a);
    WRITE_REG(PLUGIN_OPB_ADDR, b);
    
    // Start operation
    WRITE_REG(PLUGIN_CTRL_ADDR, CMD_START);
    
    // Wait for completion
    uint32_t status;
    int timeout = 1000;
    do {
        status = READ_REG(PLUGIN_CTRL_ADDR);
        timeout--;
        if (timeout <= 0) {
            print_string("ERROR: Timeout!\n");
            return;
        }
    } while (status & STATUS_BUSY);
    
    // Read result
    uint32_t result = READ_REG(PLUGIN_RES_ADDR);
    uint32_t expected = a + b;
    
    print_string("Result: ");
    print_number(result);
    print_string(" Expected: ");
    print_number(expected);
    
    if (result == expected) {
        print_string(" SUCCESS\n");
    } else {
        print_string(" ERROR\n");
    }
}

int main() {
    print_string("=== Plugin Adder Test ===\n");
    
    // Test cases
    test_plugin_addition(5, 7);
    test_plugin_addition(100, 200);
    test_plugin_addition(0, 42);
    
    print_string("=== Tests completed ===\n");
    
    // End simulation
    *((volatile uint32_t*)END_REG) = 1;
    
    return 0;
}