B	EQU	BYTE PTR
W	EQU	WORD PTR
D	EQU	DWORD PTR
O	EQU	OFFSET
S	EQU	SEG

MACRO	WaitVRetrace
LOCAL	@@1,@@2
	mov	dx,3dah
@@1:	in	al,dx
	test	al,08h
	jnz	@@1
@@2:	in	al,dx
	test	al,08h
	jz	@@2
ENDM

MACRO	Set0Col	R,G,B
	mov	dx,3c8h
	mov	al,0
	out	dx,al
	inc	dx
	mov	al,R
	out	dx,al
	mov	al,G
	out	dx,al
	mov	al,B
	out	dx,al
ENDM

MACRO	Print	Text
	push	ax
	push	dx
	mov	ah,9h
	mov	dx,O Text
	int	21h
	pop	dx
	pop	ax
ENDM

MACRO	PrintB	Nr
	push	ax
	push	bx
	push	dx
	mov	al,Nr
Divisor = 100
REPT	3
	xor	ah,ah
	mov	bl,Divisor
	div	bl
	push	ax
	mov	ah,2
	mov	dl,al
	add	dl,30h
	int	21h
	pop	ax
	mov	al,ah
Divisor = Divisor/10
ENDM
	pop	dx
	pop	bx
	pop	ax
ENDM

MACRO	PrintW	Nr
	push	ax
	push	bx
	push	dx
	mov	ax,Nr
Divisor = 10000
REPT	5
	xor	dx,dx
	mov	bx,Divisor
	div	bx
	push	dx
	mov	ah,2
	mov	dl,al
	add	dl,30h
	int	21h
	pop	dx
	mov	ax,dx
Divisor = Divisor/10
ENDM
	pop	dx
	pop	bx
	pop	ax
ENDM

MACRO	PrintD	Nr
	push	eax
	push	ebx
	push	edx
	mov	eax,Nr
Divisor = 1000000000
REPT	10
	xor	edx,edx
	mov	ebx,Divisor
	div	ebx
	push	edx
	mov	ah,2
	mov	dl,al
	add	dl,30h
	int	21h
	pop	edx
	mov	eax,edx
Divisor = Divisor/10
ENDM
	pop	edx
	pop	ebx
	pop	eax
ENDM