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

bootpack.gas: bootpack.c Makefile
	$(CC1) -o bootpack.gas bootpack.c

bootpack.nas: bootpack.gas Makefile
	$(GAS2NASK) bootpack.gas bootpack.nas

bootpack.obj: bootpack.nas Makefile
	$(NASK) bootpack.nas bootpack.obj bootpack.lst

naskfunc.obj: naskfunc.nas Makefile
	$(NASK) naskfunc.nas naskfunc.obj naskfunc.lst

hankaku.bin: hankaku.txt Makefile
	$(MAKEFONT) hankaku.txt hankaku.bin

hankaku.obj: hankaku.bin Makefile
	$(BIN2OBJ) hankaku.bin hankaku.obj _hankaku

graphic.gas: graphic.c Makefile
	$(CC1) -o graphic.gas graphic.c

graphic.nas: graphic.gas Makefile
	$(GAS2NASK) graphic.gas graphic.nas

graphic.obj: graphic.nas Makefile
	$(NASK) graphic.nas graphic.obj graphic.lst

dsctbl.gas: dsctbl.c Makefile
	$(CC1) -o dsctbl.gas dsctbl.c

dsctbl.nas: dsctbl.gas Makefile
	$(GAS2NASK) dsctbl.gas dsctbl.nas

dsctbl.obj: dsctbl.nas Makefile
	$(NASK) dsctbl.nas dsctbl.obj dsctbl.lst

bootpack.bim: bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj

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
		graphic.nas dsctbl.nas
