#!/usr/bin/env python3
"""
Calculate correct encoding for custom instructions
"""

def encode_add_plugin(rd, rs1, rs2):
    """
    Encode ADD_PLUGIN instruction
    Format: funct7[31:25] | rs2[24:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]
    """
    opcode = 0b0001011    # custom-0 opcode
    funct3 = 0b000        # function 3
    funct7 = 0b0000000    # function 7
    
    # Build instruction word
    instr = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return instr

def encode_fib_plugin(rd, rs1, rs2):
    """
    Encode FIB_PLUGIN instruction
    Format: funct7[31:25] | rs2[24:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]
    """
    opcode = 0b0101011    # custom-1 opcode (0x2B)
    funct3 = 0b001        # function 3 (001 to differentiate from ADD_PLUGIN)
    funct7 = 0b0000000    # function 7
    
    # Build instruction word
    instr = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return instr

# Test cases for ADD_PLUGIN
test1 = encode_add_plugin(3, 1, 2)  # ADD_PLUGIN x3, x1, x2
test2 = encode_add_plugin(7, 5, 6)  # ADD_PLUGIN x7, x5, x6

print("=== ADD_PLUGIN Encodings ===")
print(f"ADD_PLUGIN x3, x1, x2: 0x{test1:08X}")
print(f"ADD_PLUGIN x7, x5, x6: 0x{test2:08X}")

# Test cases for FIB_PLUGIN
fib1 = encode_fib_plugin(3, 5, 0)   # FIB_PLUGIN x3, x5, x0 (fib(5))
fib2 = encode_fib_plugin(7, 10, 0)  # FIB_PLUGIN x7, x10, x0 (fib(10))
fib3 = encode_fib_plugin(8, 15, 0)  # FIB_PLUGIN x8, x15, x0 (fib(15))

print("\n=== FIB_PLUGIN Encodings ===")
print(f"FIB_PLUGIN x3, x5, x0:  0x{fib1:08X}")
print(f"FIB_PLUGIN x7, x10, x0: 0x{fib2:08X}")
print(f"FIB_PLUGIN x8, x15, x0: 0x{fib3:08X}")

# Verify bit pattern for both instructions
print(f"\n=== Bit breakdown for ADD_PLUGIN x3, x1, x2 ===")
print(f"funct7: {(test1 >> 25) & 0x7F:07b}")
print(f"rs2:    {(test1 >> 20) & 0x1F:05b}")
print(f"rs1:    {(test1 >> 15) & 0x1F:05b}") 
print(f"funct3: {(test1 >> 12) & 0x7:03b}")
print(f"rd:     {(test1 >> 7) & 0x1F:05b}")
print(f"opcode: {test1 & 0x7F:07b}")

print(f"\n=== Bit breakdown for FIB_PLUGIN x3, x5, x0 ===")
print(f"funct7: {(fib1 >> 25) & 0x7F:07b}")
print(f"rs2:    {(fib1 >> 20) & 0x1F:05b}")
print(f"rs1:    {(fib1 >> 15) & 0x1F:05b}") 
print(f"funct3: {(fib1 >> 12) & 0x7:03b}")
print(f"rd:     {(fib1 >> 7) & 0x1F:05b}")
print(f"opcode: {fib1 & 0x7F:07b}")