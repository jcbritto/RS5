# Test Fibonacci Plugin - Assembly Tests
# Tests the FIB_PLUGIN instruction with various inputs
# Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610...

.section .text
.global _start

_start:
    # Setup stack pointer if needed
    lui sp, 0x80001
    
    # Start memory address for results
    lui x31, 0x80001
    
    # === Test 1: FIB_PLUGIN(0) = 0 ===
    li x5, 0                    # n = 0
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(0))
    sw x3, 0(x31)               # Store result at 0x80001000
    
    # === Test 2: FIB_PLUGIN(1) = 1 ===
    li x5, 1                    # n = 1
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(1))
    sw x3, 4(x31)               # Store result at 0x80001004
    
    # === Test 3: FIB_PLUGIN(2) = 1 ===
    li x5, 2                    # n = 2
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(2))
    sw x3, 8(x31)               # Store result at 0x80001008
    
    # === Test 4: FIB_PLUGIN(3) = 2 ===
    li x5, 3                    # n = 3
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(3))
    sw x3, 12(x31)              # Store result at 0x8000100C
    
    # === Test 5: FIB_PLUGIN(4) = 3 ===
    li x5, 4                    # n = 4
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(4))
    sw x3, 16(x31)              # Store result at 0x80001010
    
    # === Test 6: FIB_PLUGIN(5) = 5 ===
    li x5, 5                    # n = 5
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(5))
    sw x3, 20(x31)              # Store result at 0x80001014
    
    # === Test 7: FIB_PLUGIN(6) = 8 ===
    li x5, 6                    # n = 6
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(6))
    sw x3, 24(x31)              # Store result at 0x80001018
    
    # === Test 8: FIB_PLUGIN(7) = 13 ===
    li x5, 7                    # n = 7
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(7))
    sw x3, 28(x31)              # Store result at 0x8000101C
    
    # === Test 9: FIB_PLUGIN(8) = 21 ===
    li x5, 8                    # n = 8
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(8))
    sw x3, 32(x31)              # Store result at 0x80001020
    
    # === Test 10: FIB_PLUGIN(10) = 55 ===
    li x5, 10                   # n = 10
    li x6, 0                    # unused operand
    .word 0x000513AB            # FIB_PLUGIN x7, x10, x0 (fib(10)) - different encoding!
    sw x7, 36(x31)              # Store result at 0x80001024
    
    # === Test 11: FIB_PLUGIN(12) = 144 ===
    li x5, 12                   # n = 12
    li x6, 0                    # unused operand
    .word 0x000291AB            # FIB_PLUGIN x3, x5, x0 (fib(12))
    sw x3, 40(x31)              # Store result at 0x80001028
    
    # === Test 12: FIB_PLUGIN(15) = 610 ===
    li x5, 15                   # n = 15
    li x6, 0                    # unused operand
    .word 0x0007942B            # FIB_PLUGIN x8, x15, x0 (fib(15)) - different encoding!
    sw x8, 44(x31)              # Store result at 0x8000102C
    
    # === Store test parameters for verification ===
    # Store input values used
    li x30, 0x12345678          # Magic marker for start of inputs
    sw x30, 48(x31)             # Store marker at 0x80001030
    
    # Store expected results for verification
    li x29, 0                   # fib(0) = 0
    sw x29, 52(x31)             # 0x80001034
    li x29, 1                   # fib(1) = 1
    sw x29, 56(x31)             # 0x80001038
    li x29, 1                   # fib(2) = 1
    sw x29, 60(x31)             # 0x8000103C
    li x29, 2                   # fib(3) = 2
    sw x29, 64(x31)             # 0x80001040
    li x29, 3                   # fib(4) = 3
    sw x29, 68(x31)             # 0x80001044
    li x29, 5                   # fib(5) = 5
    sw x29, 72(x31)             # 0x80001048
    li x29, 8                   # fib(6) = 8
    sw x29, 76(x31)             # 0x8000104C
    li x29, 13                  # fib(7) = 13
    sw x29, 80(x31)             # 0x80001050
    li x29, 21                  # fib(8) = 21
    sw x29, 84(x31)             # 0x80001054
    li x29, 55                  # fib(10) = 55
    sw x29, 88(x31)             # 0x80001058
    li x29, 144                 # fib(12) = 144
    sw x29, 92(x31)             # 0x8000105C
    
    # fib(15) = 610
    li x29, 610
    sw x29, 96(x31)             # 0x80001060
    
    # === End marker ===
    li x30, 0xDEADBEEF          # End marker
    sw x30, 100(x31)            # Store end marker at 0x80001064

# Infinite loop to end program
end_loop:
    j end_loop