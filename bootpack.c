#include <stdio.h>
#include "bootpack.h"

void HariMain(void) {
	struct BOOTINFO *binfo = (struct BOOTINFO*)ADR_BOOTINFO;

	init_gdtidt();
	init_pic();
	io_sti();
	
	init_palette();
	init_screen(binfo->vram, binfo->scrnx, binfo->scrny);

	int mx = (binfo->scrnx - 16) / 2;
	int my = (binfo->scrny - 28 - 16) / 2;
	char mcursor[256];
	init_mouse_cursor8(mcursor, COL8_008484);
	putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

	char s[40];
	sprintf(s, "(%d, %d)", mx, my);
	putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, s);

	io_out8(PIC0_IMR, 0xf9);
	io_out8(PIC1_IMR, 0xef);
	
	for (;;) {
		io_hlt();
	}
}
