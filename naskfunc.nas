; naskfunc

[FORMAT "WCOFF"]	; objファイルを作るモードを指定
[BITS 32]			; 32ビットモード用の機械語を作ると知らせる

; objファイルの情報
[FILE "naskfunc.nas"]
        GLOBAL  _io_hlt

; 関数の実態
[SECTION .txt]		; objファイルを書くときの約束事

_io_hlt:			; void io_hlt(void);
		HLT
		RET