; naskfunc

[FORMAT "WCOFF"]	; obj�t�@�C������郂�[�h���w��
[BITS 32]			; 32�r�b�g���[�h�p�̋@�B������ƒm�点��

; obj�t�@�C���̏��
[FILE "naskfunc.nas"]
        GLOBAL  _io_hlt

; �֐��̎���
[SECTION .txt]		; obj�t�@�C���������Ƃ��̖񑩎�

_io_hlt:			; void io_hlt(void);
		HLT
		RET