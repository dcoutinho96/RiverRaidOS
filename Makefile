# Makefile for building the OS

# Assembly source file
ASM_SOURCES = boot.s
# C source files
C_SOURCES = kernel.c video_driver.c text.c vtty.c font8x8.c
# Object files
C_OBJECTS = $(patsubst %.c, %.o, $(C_SOURCES))
# Output file name
OUTPUT = myos

# Toolchain prefix
TOOLCHAIN_PREFIX = i686-elf-

# Compiler and linker flags
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
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
	$(TOOLCHAIN_PREFIX)gcc $(LDFLAGS) -o $(OUTPUT).bin boot.o $(C_OBJECTS)
 
boot.o: $(ASM_SOURCES)
	$(TOOLCHAIN_PREFIX)as $(ASM_SOURCES) -o boot.o

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@

run: $(OUTPUT).iso
	$(QEMU) -cdrom $(OUTPUT).iso

clean:
	rm -f boot.o $(C_OBJECTS) $(OUTPUT).bin $(OUTPUT).iso
	rm -rf isodir

.PHONY: all run clean
