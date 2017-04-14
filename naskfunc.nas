; naskfunc

[FORMAT "WCOFF"]	; objファイルを作るモードを指定
[INSTRSET "i486p"]	; 486の命令を使うために記述
[BITS 32]			; 32ビットモード用の機械語を作ると知らせる

; objファイルの情報
[FILE "naskfunc.nas"]
        GLOBAL  _io_hlt, _write_mem8

; 関数の実態
[SECTION .text]		; objファイルを書くときの約束事

; 待ち
_io_hlt:			; void io_hlt(void);
		HLT
		RET

; メモリ書き込み
_write_mem8:		; void write_mem8(int addr, int data);
		MOV		ECX,[ESP+4]		; [ESP+4]はaddrの値が入っている
		MOV		AL,[ESP+8]		; [ESP+8]はdataの値が入っている
		MOV		[ECX],AL
		RET