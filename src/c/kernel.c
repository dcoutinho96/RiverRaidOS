#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "lib/video_driver.h"
#include "lib/vtty.h"

 
/* This tutorial will only work for the 32-bit ix86 targets. */
#if !defined(__i386__)
#error "wrong compiler"
#endif

void kernel_main(uint32_t *multiboot) {
    set_framebuffer(multiboot);
    terminal_initialize();
    terminal_writestring("Hello World!\nI'm writing using C and VESA video\nand I even can break lines!!!\n123123125");
}