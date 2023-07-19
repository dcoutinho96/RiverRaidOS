# Makefile for building the OS

# Directories
SRC_DIR = src
ASM_DIR = $(SRC_DIR)/assembly
C_DIR = $(SRC_DIR)/c
INC_DIR = $(C_DIR)/include
LIB_DIR = $(C_DIR)/lib
FONT_DIR = $(LIB_DIR)/font
TEXT_DIR = $(LIB_DIR)/text
VIDEO_DIR = $(LIB_DIR)/video_driver
VTTY_DIR = $(LIB_DIR)/vtty

# Assembly source file
ASM_SOURCES = $(ASM_DIR)/boot.s
# C source files
C_SOURCES = $(C_DIR)/kernel.c $(FONT_DIR)/font8x8.c $(TEXT_DIR)/text.c $(VIDEO_DIR)/video_driver.c $(VTTY_DIR)/vtty.c
# Assembly object file
ASM_OBJECT = boot.o
# C object files
C_OBJECTS = $(C_DIR)/kernel.o $(FONT_DIR)/font8x8.o $(TEXT_DIR)/text.o $(VIDEO_DIR)/video_driver.o $(VTTY_DIR)/vtty.o
# Output file name
OUTPUT = myos

# Toolchain prefix
TOOLCHAIN_PREFIX = i686-elf-

# Compiler and linker flags
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -I$(INC_DIR)
LDFLAGS = -T linker.ld -ffreestanding -O2 -nostdlib -lgcc

# QEMU command
QEMU = qemu-system-i386

all: $(OUTPUT).iso

$(OUTPUT).iso: $(OUTPUT).bin
	mkdir -p isodir/boot/grub
	cp $(OUTPUT).bin isodir/boot/$(OUTPUT).bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(OUTPUT).iso isodir

$(OUTPUT).bin: $(ASM_OBJECT) $(C_OBJECTS)
	$(TOOLCHAIN_PREFIX)gcc $(LDFLAGS) -o $(OUTPUT).bin $^

$(ASM_OBJECT): $(ASM_SOURCES)
	$(TOOLCHAIN_PREFIX)as $(ASM_SOURCES) -o $(ASM_OBJECT)

$(C_DIR)/kernel.o: $(C_DIR)/kernel.c 
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@

$(VTTY_DIR)/vtty.o: $(VTTY_DIR)/vtty.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@

$(TEXT_DIR)/text.o: $(TEXT_DIR)/text.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@


$(VIDEO_DIR)/video_driver.o: $(VIDEO_DIR)/video_driver.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@

$(FONT_DIR)/font8x8.o: $(FONT_DIR)/font8x8.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@

run: $(OUTPUT).iso
	$(QEMU) -cdrom $(OUTPUT).iso

clean:
	rm -f $(ASM_OBJECT) $(C_OBJECTS) $(OUTPUT).bin $(OUTPUT).iso
	rm -rf isodir

.PHONY: all run clean
