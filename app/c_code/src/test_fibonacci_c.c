/*
 * Test Fibonacci Plugin - C Test with Inline Assembly
 * Tests the FIB_PLUGIN instruction integration with C code
 */

// Macro to use FIB_PLUGIN instruction easily in C
#define FIB_PLUGIN(result, n) \
    __asm__ volatile ( \
        "mv t0, %1\n\t"              \
        "li t1, 0\n\t"               \
        ".word 0x000291AB\n\t"       \
        "mv %0, t2\n\t"              \
        : "=r"(result)               \
        : "r"(n)                     \
        : "t0", "t1", "t2"           \
    )

int fibonacci_iterative(int n) {
    if (n <= 1) return n;
    
    int prev = 0, curr = 1;
    for (int i = 2; i <= n; i++) {
        int next = prev + curr;
        prev = curr;
        curr = next;
    }
    return curr;
}

int main() {
    // Test cases with expected values
    int test_cases[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 15};
    int expected[] = {0, 1, 1, 2, 3, 5, 8, 13, 21, 55, 144, 610};
    int num_tests = sizeof(test_cases) / sizeof(test_cases[0]);
    
    // Results storage
    volatile int *results = (volatile int *)0x80001000;
    volatile int *test_inputs = (volatile int *)0x80001100;
    volatile int *expected_vals = (volatile int *)0x80001200;
    volatile int *iterative_results = (volatile int *)0x80001300;
    
    // Store marker
    results[0] = 0xF1B0C0DE;  // Magic marker
    
    int all_passed = 1;
    
    for (int i = 0; i < num_tests; i++) {
        int n = test_cases[i];
        int hw_result = 0;
        int sw_result = fibonacci_iterative(n);
        int expected_val = expected[i];
        
        // Test hardware Fibonacci
        FIB_PLUGIN(hw_result, n);
        
        // Store results
        test_inputs[i] = n;
        results[i + 1] = hw_result;
        expected_vals[i] = expected_val;
        iterative_results[i] = sw_result;
        
        // Validate
        if (hw_result != expected_val) {
            all_passed = 0;
        }
        if (hw_result != sw_result) {
            all_passed = 0;
        }
    }
    
    // Summary
    results[50] = all_passed ? 0x600D : 0xBAD;  // GOOD or BAD
    results[51] = num_tests;
    results[52] = 0xDEADBEEF;  // End marker
    
    return all_passed ? 0 : 1;
}