#ifndef _FONT_H
#define _FONT_H

#ifdef __cplusplus
extern "C" {
#endif

#define GLYPH_WIDTH 8
#define GLYPH_HEIGHT 8

#include <stdint.h>

extern uint8_t font8x8_basic[128][8];

#ifdef __cplusplus
}
#endif

#endif