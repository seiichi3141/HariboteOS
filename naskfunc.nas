; naskfunc

[FORMAT "WCOFF"]	; obj�t�@�C������郂�[�h���w��
[INSTRSET "i486p"]	; 486�̖��߂��g�����߂ɋL�q
[BITS 32]			; 32�r�b�g���[�h�p�̋@�B������ƒm�点��

; obj�t�@�C���̏��
[FILE "naskfunc.nas"]
        GLOBAL  _io_hlt, _write_mem8

; �֐��̎���
[SECTION .text]		; obj�t�@�C���������Ƃ��̖񑩎�

; �҂�
_io_hlt:			; void io_hlt(void);
		HLT
		RET

; ��������������
_write_mem8:		; void write_mem8(int addr, int data);
		MOV		ECX,[ESP+4]		; [ESP+4]��addr�̒l�������Ă���
		MOV		AL,[ESP+8]		; [ESP+8]��data�̒l�������Ă���
		MOV		[ECX],AL
		RET