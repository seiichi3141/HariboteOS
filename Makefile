OBJS = bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj \
		int.obj fifo.obj keyboard.obj mouse.obj memory.obj sheet.obj

TOOLPATH	= ../z_tools/
INCPATH		= ../z_tools/haribote

MAKE		= $(TOOLPATH)make.exe -r
NASK		= $(TOOLPATH)nask.exe
CC1			= $(TOOLPATH)cc1.exe -I$(INCPATH) -Os -Wall -quiet
GAS2NASK	= $(TOOLPATH)gas2nask.exe -asm
OBJ2BIM		= $(TOOLPATH)obj2bim.exe
MAKEFONT	= $(TOOLPATH)makefont.exe
BIN2OBJ		= $(TOOLPATH)bin2obj.exe
BIM2HRB		= $(TOOLPATH)bim2hrb.exe
RULEFILE	= $(TOOLPATH)haribote/haribote.rul
EDIMG		= $(TOOLPATH)edimg.exe
IMGTOL		= $(TOOLPATH)imgtol.com
COPY		= cp
DEL			= rm

# デフォルト動作

default:
	$(MAKE) img

# ファイル生成規則

ipl.bin: ipl10.nas Makefile
	$(NASK) ipl10.nas ipl.bin ipl.lst

asmhead.bin: asmhead.nas Makefile
	$(NASK) asmhead.nas asmhead.bin asmhead.lst

hankaku.bin: hankaku.txt Makefile
	$(MAKEFONT) hankaku.txt hankaku.bin

hankaku.obj: hankaku.bin Makefile
	$(BIN2OBJ) hankaku.bin hankaku.obj _hankaku

bootpack.bim: $(OBJS) Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		$(OBJS)

bootpack.hrb: bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

haribote.sys: asmhead.bin bootpack.hrb Makefile
	cat asmhead.bin bootpack.hrb > haribote.sys
# asmhead.binとbootpack.hrbの結合

haribote.img: ipl.bin haribote.sys Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		imgout:haribote.img

%.gas: %.c Makefile
	$(CC1) -o $*.gas $*.c

%.nas: %.gas Makefile
	$(GAS2NASK) $*.gas $*.nas

%.obj: %.nas Makefile
	$(NASK) $*.nas $*.obj $*.lst

# コマンド

img:
	$(MAKE) haribote.img

run:
	$(MAKE) img
	$(COPY) haribote.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

clean:
	-$(DEL) *.bin *.lst *.gas *.obj \
		bootpack.nas bootpack.map bootpack.bim bootpack.hrb haribote.sys haribote.img \
		graphic.nas dsctbl.nas int.nas fifo.nas keyboard.nas mouse.nas memory.nas sheet.nas
