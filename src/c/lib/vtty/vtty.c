
#include "../../include/vtty.h"
#include "../../include/vga.h"
#include "../../include/text.h"
#include "../../include/video_driver.h"
#include "../../include/font8x8.h"

const uint32_t start_x = 10;
const uint32_t start_y = 10;

uint32_t col = 0;
uint32_t row = 0;

uint32_t max_col, max_row;

uint32_t vga_color, bg_color;

void print_ch(char);

void terminal_setcolor(uint8_t vc)
{
	set_fg_color(vga_to_color(vc));
}
void terminal_setbgcolor(uint8_t vc)
{
	set_bg_color(vga_to_color(vc));
}

void terminal_goto(uint32_t c, uint32_t r)
{
	set_printing_coords(start_x + c*GLYPH_WIDTH, start_y + r*GLYPH_HEIGHT);
}

void print_ch_at(char c, int pos_x, int pos_y)
{
	int x = (start_x+pos_x*GLYPH_WIDTH);
	int y = (start_y+pos_y*GLYPH_HEIGHT);
	int lx; int ly;
	uint8_t *bitmap = font8x8_basic[c % 128];
	for (lx = 0; lx < GLYPH_WIDTH; lx++) {
		for (ly = 0; ly < GLYPH_HEIGHT; ly++) {
			uint8_t row = bitmap[ly];
			if ((row >> lx) & 1)
				putpixeli(x+lx, y+ly, vga_color);
			else
				putpixeli(x+lx,y+ly, bg_color);
		}
	}
}

void terminal_initialize()
{
	set_printing_coords(start_x, start_y);
	max_col = (start_x * 2 - get_width()) / GLYPH_WIDTH;
	max_row = (start_y * 2 - get_height())/ GLYPH_HEIGHT;
}

void terminal_free()
{
	vga_color = 0;
	max_col = 0;
	max_row = 0;
}

void terminal_putchar(char c)
{
	put_char(c);
}

void terminal_write(const char* data, size_t size)
{
	for (int i = 0; i < size; ++i)
	{
		terminal_putchar(data[i]);
	}
}

void terminal_writestring(const char* data)
{
	terminal_write(data, strlen(data));
}