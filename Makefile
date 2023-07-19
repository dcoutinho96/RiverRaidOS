# Makefile for building the OS

# Directories
SRC_DIR = src
INCLUDE_DIR = include

# Assembly source file
ASM_SOURCES = $(SRC_DIR)/assembly/boot.s
# C source files
C_SOURCES = $(SRC_DIR)/c/kernel.c $(SRC_DIR)/c/video_driver.c $(SRC_DIR)/c/text.c $(SRC_DIR)/c/vtty.c $(SRC_DIR)/c/font8x8.c
# Object files
C_OBJECTS = $(C_SOURCES:$(SRC_DIR)/c/%.c=$(SRC_DIR)/c/%.o)
# Output file name
OUTPUT = myos

# Toolchain prefix
TOOLCHAIN_PREFIX = i686-elf-

# Compiler and linker flags
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -I$(INCLUDE_DIR)
LDFLAGS = -T linker.ld -ffreestanding -O2 -nostdlib -lgcc

# QEMU command
QEMU = qemu-system-i386

all: $(OUTPUT).iso

$(OUTPUT).iso: $(OUTPUT).bin
	mkdir -p isodir/boot/grub
	cp $(OUTPUT).bin isodir/boot/$(OUTPUT).bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(OUTPUT).iso isodir

$(OUTPUT).bin: boot.o $(C_OBJECTS)
	$(TOOLCHAIN_PREFIX)gcc $(LDFLAGS) -o $(OUTPUT).bin $^
 
boot.o: $(ASM_SOURCES)
	$(TOOLCHAIN_PREFIX)as $(ASM_SOURCES) -o boot.o

$(SRC_DIR)/c/%.o: $(SRC_DIR)/c/%.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@

run: $(OUTPUT).iso
	$(QEMU) -cdrom $(OUTPUT).iso

clean:
	rm -f boot.o $(C_OBJECTS) $(OUTPUT).bin $(OUTPUT).iso
	rm -rf isodir

.PHONY: all run clean
