# Makefile for building the OS

# Directories
SRC_DIR = src
ASM_DIR = $(SRC_DIR)/asm
C_DIR = $(SRC_DIR)/c
LIB_DIR = $(C_DIR)/lib

# Assembly source files
ASM_SOURCES := $(wildcard $(ASM_DIR)/*.s)
# C source files
C_SOURCES := $(wildcard $(C_DIR)/*.c $(LIB_DIR)/*.c)
# Assembly object files
ASM_OBJECTS := $(patsubst $(ASM_DIR)/%.s, $(ASM_DIR)/%.o, $(ASM_SOURCES))
# C object files
C_OBJECTS := $(patsubst $(C_DIR)/%.c, $(C_DIR)/%.o, $(C_SOURCES))
# Output file name
OUTPUT = myos

# Toolchain prefix
TOOLCHAIN_PREFIX = i686-elf-

# Compiler and linker flags
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -I$(C_DIR)
LDFLAGS = -T linker.ld -ffreestanding -O2 -nostdlib -lgcc

# QEMU command
QEMU = qemu-system-i386

all: $(OUTPUT).iso

$(OUTPUT).iso: $(OUTPUT).bin
	mkdir -p isodir/boot/grub
	cp $(OUTPUT).bin isodir/boot/$(OUTPUT).bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(OUTPUT).iso isodir

$(OUTPUT).bin: $(ASM_OBJECTS) $(C_OBJECTS)
	$(TOOLCHAIN_PREFIX)gcc $(LDFLAGS) -o $(OUTPUT).bin $^

$(ASM_DIR)/%.o: $(ASM_DIR)/%.s
	$(TOOLCHAIN_PREFIX)as $< -o $@

$(C_DIR)/%.o: $(C_DIR)/%.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@

run: $(OUTPUT).iso
	$(QEMU) -cdrom $(OUTPUT).iso

clean:
	rm -f $(ASM_OBJECTS) $(C_OBJECTS) $(OUTPUT).bin $(OUTPUT).iso

	rm -rf isodir

.PHONY: all run clean
