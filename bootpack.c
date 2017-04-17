#include <stdio.h>
#include "bootpack.h"

extern struct KEYBUF keybuf;

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
		io_cli();
		if (keybuf.next == 0) {
			io_stihlt();
		} else {
			int j, i = keybuf.data[0];
			keybuf.next--;;
			for (j = 0; j < keybuf.next; j++) {
				keybuf.data[j] = keybuf.data[j + 1];
			}
			io_sti();
			unsigned char s[40];
			sprintf(s, "%02X", i);
			boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 0, 16, 15, 31);
			putfonts8_asc(binfo->vram, binfo->scrnx, 0, 16, COL8_FFFFFF, s);
		}
	}
}
