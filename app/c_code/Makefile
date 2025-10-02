TARGET ?= test_add_plugin
CC = riscv64-elf-gcc
OBJCOPY = riscv64-elf-objcopy

# Override TARGET with PROGNAME if provided
ifdef PROGNAME
TARGET = $(PROGNAME)
endif

# Flags simplificadas sem newlib
CFLAGS = -march=rv32im_zicsr -mabi=ilp32 -Os -Wall -nostdlib -nostartfiles
LDFLAGS = -march=rv32im_zicsr -mabi=ilp32 -nostdlib -nostartfiles -T ../common/link.ld

all: $(TARGET).bin

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) $< $@ -O binary

$(TARGET).elf: src/$(TARGET).o
	$(CC) src/$(TARGET).o -o $@ $(LDFLAGS)

src/$(TARGET).o: src/$(TARGET).c
	$(CC) -c $< -o $@ $(CFLAGS)

clean:
	rm -f src/*.o $(TARGET).elf $(TARGET).bin