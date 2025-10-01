# Simple Fibonacci Test - Only fib(5) = 5
.section .text
.global _start

_start:
    # Setup stack pointer
    lui sp, 0x80001
    
    # Test fib(5) = 5
    li x5, 5                    # n = 5
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(5))
    
    # Store result
    lui x31, 0x80001
    sw x3, 0(x31)               # Store fib(5) result
    sw x5, 4(x31)               # Store input (5)
    
    # Store expected value for comparison
    li x29, 5                   # fib(5) = 5
    sw x29, 8(x31)              # Store expected
    
    # End marker
    li x30, 0xDEADBEEF
    sw x30, 12(x31)

# Infinite loop
end_loop:
    j end_loop