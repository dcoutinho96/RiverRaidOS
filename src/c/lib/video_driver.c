#include "video_driver.h"

uint32_t argb_to_color(argb_t *c)
{
	return (       \
		c->a << 24 \
	  | c->r << 16 \
	  | c->g <<  8 \
	  | c->b <<  0 \
	);
}

uint32_t vga_to_color(uint8_t vga)
{
	switch (vga)
	{
		case 0: return 0xff000000;
		case 1: return 0xff0000ff;
		case 2: return 0xff00ff00;
		case 3: return 0xff00ffff;
		case 4: return 0xffff0000;
		case 5: return 0xffff00ff;
		case 6: return 0xff8b4513;
		case 7: return 0xffd3d3d3;
		case 8: return 0xffa9a9a9;
		case 9: return 0xff00bfff;
		case 10:return 0xff7cfc00;
		case 11:return 0xffe0ffff;
		case 12:return 0xfff08080;
		case 13:return 0xffff80ff;
		case 14:return 0xffcd8032;
		case 15:return 0xffffffff;
		default: return 0xff000000;
	}
}


uint32_t *framebuffer;
uint32_t fb_w, fb_h, fb_p, fb_bpp;

void set_framebuffer(uint32_t *mb) {
	framebuffer = (uint32_t *) mb[22];
	fb_p = mb[24];
	fb_w = mb[25];
	fb_h = mb[26];
	fb_bpp = mb[27] >> 24;
}

inline uint32_t *get_framebuffer()
{
	return framebuffer;
}

inline uint32_t get_width()
{
	return fb_w;
}

inline uint32_t get_height()
{
	return fb_h;
}

inline uint32_t get_pitch()
{
	return fb_p;
}

inline uint32_t get_bpp()
{
	return fb_bpp;
}

void putpixeli(int x, int y, uint32_t c) {
	get_framebuffer()[x + (y * get_pitch() / 4)] = c;
}
void putlinehi(int x, int y, int w, uint32_t c) {
	int p = x + y * get_pitch() / 4;
	for (int i = 0; i < w; i++)
		get_framebuffer()[p++] = c;
}
void putlinevi(int x, int y, int h, uint32_t c) {
	int p = x + (y) * get_pitch() / 4;
	for (int i = 0; i < h; i++)
		get_framebuffer()[p += get_pitch() / 4] = c;
}
void putrectsi (int x1, int y1, int x2, int y2, uint32_t c) {
	putlinehi(x1, y1, x2 - x1, c);
	putlinehi(x1, y2, x2 - x1, c);
	putlinevi(x1, y1, y2 - y1, c);
	putlinevi(x2, y1, y2 - y1, c);
}
void putrectfi (int x1, int y1, int x2, int y2, uint32_t c) {
	for (int y = y1; y < y2; y++)
		putlinehi(x1, y, (x2-x1), c);
}
void putrectsfi(int x1, int y1, int x2, int y2, uint32_t sc, uint32_t fc) {
	putrectsi(x1, y1, x2, y2, sc);
	putrectfi(x1+1, y1+1, x2, y2, fc);
}

void putpixels(int x, int y, argb_t *c) {
	get_framebuffer()[x + y * get_pitch()] = argb_to_color(c);
}
void putlinehs(int x, int y, int w, argb_t *c) {
	int p = x-1 + y * get_pitch();
	for (int i = 0; i < w; i++)
		get_framebuffer()[p++] = argb_to_color(c);
}
void putlinevs(int x, int y, int h, argb_t *c) {
	int p = x + (y-1) * get_pitch();
	for (int i = 0; i < h; i++)
		get_framebuffer()[p += get_pitch()] = argb_to_color(c);
}
void putrectss (int x1, int y1, int x2, int y2, argb_t *c) {
	putlinehs(x1, y1, x2 - x1, c);
	putlinehs(x1, y2, x2 - x1, c);
	putlinevs(x1, y1, y2 - y1, c);
	putlinevs(x2, y1, y2 - y1, c);
}
void putrectfs (int x1, int y1, int x2, int y2, argb_t *c) {
	for (int y = y1; y < y2; y++)
		putlinehs(x1, y, (x2-x1), c);
}
void putrectsfs(int x1, int y1, int x2, int y2, argb_t *sc, argb_t *fc) {
	putlinehs(x1+0, y1, x2 - x1, sc);
	putlinehs(x1-0, y2, x2 - x1, sc);
	putlinevs(x1+1, y1, y2 - y1, sc);
	putlinevs(x2-1, y1, y2 - y1, sc);
	int x = x1+1;
	int x3= x2;
	for (int y = y1+1; y < (y2); y++)
		putlinehs(x, y, x3-x, fc);
}