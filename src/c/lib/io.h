#ifndef _IO_H
#define _IO_H

#ifdef __cplusplus
extern "C" {
#endif

static inline unsigned char inb(unsigned short port) {
    unsigned char value;
    __asm__ __volatile__(
        "push %%ebp\n"
        "movl %%esp, %%ebp\n"
        "movw %1, %%dx\n"    /* port */
        "xorl %%eax, %%eax\n"
        "inb %%dx, %%al\n"   /* read 1 byte */
        "pop %%ebp\n"
        : "=a"(value)
        : "d"(port)
    );
    return value;
}

// Define the inline assembly function for 'outb'
static inline void outb(unsigned short port, unsigned char value) {
    __asm__ __volatile__(
        "push %%ebp\n"
        "movl %%esp, %%ebp\n"
        "movw %0, %%dx\n"    /* port */
        "movb %1, %%al\n"    /* value */
        "outb %%al, %%dx\n"  /* output 1 byte */
        "pop %%ebp\n"
        :
        : "d"(port), "a"(value)
    );
}

#ifdef __cplusplus
}
#endif

#endif
