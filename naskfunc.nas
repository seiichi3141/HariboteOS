; naskfunc

[FORMAT "WCOFF"]	; obj�t�@�C������郂�[�h���w��
[INSTRSET "i486p"]	; 486�̖��߂��g�����߂ɋL�q
[BITS 32]			; 32�r�b�g���[�h�p�̋@�B������ƒm�点��

; obj�t�@�C���̏��
[FILE "naskfunc.nas"]
        GLOBAL  _io_hlt, _write_mem8
		GLOBAL	_io_cli, _io_out8, _io_load_eflags, _io_store_eflags

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

; ���荞�݋ߋE
_io_cli:			; void io_cli(void)
		CLI
		RET

; �f�o�C�X�ւ�IO�o��
_io_out8:			; void io_out8(int port, int data);
		MOV		EDX,[ESP+4]
		MOV		AL,[ESP+8]
		OUT		DX,AL
		RET

; EFLAGS�̎擾
_io_load_eflags:	; int io_load_eflags(void);
		PUSHFD		; PUSH EFLAGS�̈�
		POP		EAX
		RET

; EFLAGS�̐ݒ�
_io_store_eflags:	; void io_store_eflags(int eflags);
		MOV		EAX,[ESP+4]
		PUSH	EAX
		POPFD		; POP EFLAGS�̈�
		RET
