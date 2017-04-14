; naskfunc

[FORMAT "WCOFF"]	; objファイルを作るモードを指定
[INSTRSET "i486p"]	; 486の命令を使うために記述
[BITS 32]			; 32ビットモード用の機械語を作ると知らせる

; objファイルの情報
[FILE "naskfunc.nas"]
        GLOBAL  _io_hlt, _write_mem8
		GLOBAL	_io_cli, _io_out8, _io_load_eflags, _io_store_eflags

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

; 割り込み近畿
_io_cli:			; void io_cli(void)
		CLI
		RET

; デバイスへのIO出力
_io_out8:			; void io_out8(int port, int data);
		MOV		EDX,[ESP+4]
		MOV		AL,[ESP+8]
		OUT		DX,AL
		RET

; EFLAGSの取得
_io_load_eflags:	; int io_load_eflags(void);
		PUSHFD		; PUSH EFLAGSの意
		POP		EAX
		RET

; EFLAGSの設定
_io_store_eflags:	; void io_store_eflags(int eflags);
		MOV		EAX,[ESP+4]
		PUSH	EAX
		POPFD		; POP EFLAGSの意
		RET
