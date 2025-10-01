.section .init
.align 4

.globl _start
_start:
    # Test simple ADD (non-plugin) first
    li x1, 5         # Load 5 into x1
    li x2, 7         # Load 7 into x2  
    add x3, x1, x2   # Regular add: x3 = x1 + x2 = 12
    
    # Write result to memory to see if program runs  
    li x4, 0x80001000    # Testbench memory address
    sw x3, 0(x4)         # Store result at testbench space
    
    # Success marker
    li x5, 0xABCD        # Success value  
    sw x5, 4(x4)         # Store at testbench space
    
end_loop:
    j end_loop       # Infinite loop