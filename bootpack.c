#include <stdio.h>
#include "bootpack.h"

void make_window8(unsigned char *buf, int xsize, int ysize, char *title);

void HariMain(void) {
	struct BOOTINFO *binfo = (struct BOOTINFO*)ADR_BOOTINFO;

	init_gdtidt();
	init_pic();
	io_sti();
	
	char keybuf[32], mousebuf[128];
	fifo8_init(&keyfifo, 32, keybuf);
	fifo8_init(&mousefifo, 128, mousebuf);

	init_pit();
	io_out8(PIC0_IMR, 0xf8);	/* 割り込みを許可するために設定, PITを追加 */
	io_out8(PIC1_IMR, 0xef);
	
	struct FIFO8 timerfifo;
	char timerbuf[8];
	fifo8_init(&timerfifo, 8, timerbuf);
	settimer(1000, &timerfifo, 1);

	init_keyboard();

	struct MOUSE_DEC mdec;
	enable_mouse(&mdec);

	int memtotal = memtest(0x00400000, 0xbfffffff);
	struct MEMMAN *memman = (struct MEMMAN*)MEMMAN_ADDR;
	memman_init(memman);
	memman_free(memman, 0x00001000, 0x0009e000);
	memman_free(memman, 0x00400000, memtotal - 0x00400000);

	init_palette();
	struct SHTCTL *shtctl = shtctl_init(memman, binfo->vram, binfo->scrnx, binfo->scrny);
	struct SHEET *sht_back = sheet_alloc(shtctl);
	struct SHEET *sht_mouse = sheet_alloc(shtctl);
	struct SHEET *sht_win = sheet_alloc(shtctl);
	unsigned char *buf_back = (unsigned char*)memman_alloc_4k(memman, binfo->scrnx * binfo->scrny);
	unsigned char *buf_win = (unsigned char*)memman_alloc_4k(memman, 160 * 68);
	sheet_setbuf(sht_back, buf_back, binfo->scrnx, binfo->scrny, -1);
	char buf_mouse[256];
	sheet_setbuf(sht_mouse, buf_mouse, 16, 16, 99);
	sheet_setbuf(sht_win, buf_win, 160, 68, -1);

	init_screen8(buf_back, binfo->scrnx, binfo->scrny);
	init_mouse_cursor8(buf_mouse, 99);

	make_window8(buf_win, 160, 68, "counter");

	int mx = (binfo->scrnx - 16) / 2;
	int my = (binfo->scrny - 28 - 16) / 2;

	sheet_slide(sht_back, 0, 0);
	sheet_slide(sht_mouse, mx, my);
	sheet_slide(sht_win, 80, 72);

	sheet_updown(sht_back, 0);
	sheet_updown(sht_win, 1);
	sheet_updown(sht_mouse, 2);

	char s[40];
	sprintf(s, "(%3d, %3d)", mx, my);
	putfonts8_asc(buf_back, binfo->scrnx, 0, 0, COL8_FFFFFF, s);

	sprintf(s, "memory %dMB   free : %dKB",
		memtotal / (1024 * 1024), memman_total(memman) / 1024);;
	putfonts8_asc(buf_back, binfo->scrnx, 0, 32, COL8_FFFFFF, s);
	
	sheet_refresh(sht_back, 0, 0, binfo->scrnx, 48);

	for (;;) {
		sprintf(s, "%010d", timerctl.count);
		boxfill8(buf_win, 160, COL8_C6C6C6, 40, 28, 119, 43);
		putfonts8_asc(buf_win, 160, 40, 28, COL8_000000, s);
		sheet_refresh(sht_win, 40, 28, 120, 44);

		io_cli();
		if (fifo8_status(&keyfifo) != 0) {
			int i = fifo8_get(&keyfifo);
			io_sti();
			unsigned char s[40];
			sprintf(s, "%02X", i);
			boxfill8(buf_back, binfo->scrnx, COL8_008484, 0, 16, 15, 31);
			putfonts8_asc(buf_back, binfo->scrnx, 0, 16, COL8_FFFFFF, s);
			sheet_refresh(sht_back, 0, 16, 16, 32);
		} else if (fifo8_status(&mousefifo) != 0) {
			int i = fifo8_get(&mousefifo);
			io_sti();
			if (mouse_decode(&mdec, i) != 0) {
				unsigned char s[40];
				sprintf(s, "[lcr %4d %4d]", mdec.x, mdec.y);
				if ((mdec.btn & 0x01) != 0) {
					s[1] = 'L';
				}
				if ((mdec.btn & 0x02) != 0) {
					s[3] = 'R';
				}
				if ((mdec.btn & 0x04) != 0) {
					s[2] = 'C';
				}
				boxfill8(buf_back, binfo->scrnx, COL8_008484, 32, 16, 32 + 15 * 8 - 1, 31);
				putfonts8_asc(buf_back, binfo->scrnx, 32, 16, COL8_FFFFFF, s);
				sheet_refresh(sht_back, 32, 16, 32 + 15 * 8, 32);

				mx += mdec.x;
				my += mdec.y;
				if (mx < 0) {
					mx = 0;
				}
				if (my < 0) {
					my = 0;
				}
				if (mx > binfo->scrnx - 1) {
					mx = binfo->scrnx - 1;
				}
				if (my > binfo->scrny - 1) {
					my = binfo->scrny - 1;
				}
				sprintf(s, "(%3d, %3d)", mx, my);
				boxfill8(buf_back, binfo->scrnx, COL8_008484, 0, 0, 79, 15);
				putfonts8_asc(buf_back, binfo->scrnx, 0, 0, COL8_FFFFFF, s);
				sheet_refresh(sht_back, 0, 0, 80, 16);
				sheet_slide(sht_mouse, mx, my);
			}
		} else if (fifo8_status(&timerfifo) != 0) {
			int i = fifo8_get(&timerfifo);
			io_sti();
			putfonts8_asc(buf_back, binfo->scrnx, 0, 64, COL8_FFFFFF, "10[sec]");
			sheet_refresh(sht_back, 0, 64, 56, 80);
		} else {
			io_sti();
		}
	}
}

void make_window8(unsigned char *buf, int xsize, int ysize, char *title) {
	static char closebtn[14][16] = {
		"OOOOOOOOOOOOOOO@",
		"OQQQQQQQQQQQQQ$@",
		"OQQQQQQQQQQQQQ$@",
		"OQQQ@@QQQQ@@QQ$@",
		"OQQQQ@@QQ@@QQQ$@",
		"OQQQQQ@@@@QQQQ$@",
		"OQQQQQQ@@QQQQQ$@",
		"OQQQQQ@@@@QQQQ$@",
		"OQQQQ@@QQ@@QQQ$@",
		"OQQQ@@QQQQ@@QQ$@",
		"OQQQQQQQQQQQQQ$@",
		"OQQQQQQQQQQQQQ$@",
		"O$$$$$$$$$$$$$$@",
		"@@@@@@@@@@@@@@@@"
	};
	int x, y;
	char c;
	boxfill8(buf, xsize, COL8_C6C6C6, 0, 0, xsize - 1, 0);
	boxfill8(buf, xsize, COL8_FFFFFF, 1, 1, xsize - 2, 1);
	boxfill8(buf, xsize, COL8_C6C6C6, 0, 0, 0, ysize - 1);
	boxfill8(buf, xsize, COL8_FFFFFF, 1, 1, 1, ysize - 2);
	boxfill8(buf, xsize, COL8_848484, xsize - 2, 1, xsize - 2, ysize - 2);
	boxfill8(buf, xsize, COL8_000000, xsize - 1, 0, xsize - 1, ysize - 1);
	boxfill8(buf, xsize, COL8_C6C6C6, 2, 2, xsize - 3, ysize - 3);
	boxfill8(buf, xsize, COL8_000084, 3, 3, xsize - 4, 20);
	boxfill8(buf, xsize, COL8_848484, 1, ysize - 2, xsize - 2, ysize - 2);
	boxfill8(buf, xsize, COL8_000000, 0, ysize - 1, xsize - 1, ysize - 1);
	putfonts8_asc(buf, xsize, 24, 4, COL8_FFFFFF, title);
	for (y = 0; y < 14; y++) {
		for (x = 0; x < 16; x++) {
			c = closebtn[y][x];
			if (c == '@') {
				c = COL8_000000;
			} else if (c == '$') {
				c = COL8_848484;
			} else if (c == 'Q') {
				c = COL8_C6C6C6;
			} else {
				c = COL8_FFFFFF;
			}
			buf[(5+ y) * xsize + (xsize - 21 + x)] = c;
		}
	}
}
