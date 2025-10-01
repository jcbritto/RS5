TARGET = c_code
CC = riscv64-elf-gcc
OBJCOPY = riscv64-elf-objcopy

# Flags simplificadas sem newlib
CFLAGS = -march=rv32im_zicsr -mabi=ilp32 -Os -Wall -nostdlib -nostartfiles
LDFLAGS = -march=rv32im_zicsr -mabi=ilp32 -nostdlib -nostartfiles -T ../common/link.ld

all: $(TARGET).bin

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) $< $@ -O binary

$(TARGET).elf: src/test_simple_c.o
	$(CC) src/test_simple_c.o -o $@ $(LDFLAGS)

src/test_simple_c.o: src/test_simple_c.c
	$(CC) -c $< -o $@ $(CFLAGS)

clean:
	rm -f src/*.o $(TARGET).elf $(TARGET).bin