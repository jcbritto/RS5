#!/usr/bin/env python3
"""
Calculate correct encoding for ADD_PLUGIN instruction
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

# Test cases
test1 = encode_add_plugin(3, 1, 2)  # ADD_PLUGIN x3, x1, x2
test2 = encode_add_plugin(7, 5, 6)  # ADD_PLUGIN x7, x5, x6

print(f"ADD_PLUGIN x3, x1, x2: 0x{test1:08X}")
print(f"ADD_PLUGIN x7, x5, x6: 0x{test2:08X}")

# Verify bit pattern
print(f"\nBit breakdown for ADD_PLUGIN x3, x1, x2:")
print(f"funct7: {(test1 >> 25) & 0x7F:07b}")
print(f"rs2:    {(test1 >> 20) & 0x1F:05b}")
print(f"rs1:    {(test1 >> 15) & 0x1F:05b}") 
print(f"funct3: {(test1 >> 12) & 0x7:03b}")
print(f"rd:     {(test1 >> 7) & 0x1F:05b}")
print(f"opcode: {test1 & 0x7F:07b}")