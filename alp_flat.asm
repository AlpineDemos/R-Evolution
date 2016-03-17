;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³   ALPiNE Flat Real Mode Manager    ³
;³               v0.91á               ³
;³        (c) 1996/97 ALPiNE          ³
;³ coded by Ziron aka Christoph Groth ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
;ATTENTION!
;When using this system and EMM386 is 1, your STACK has to be BIGGER than
;20 kB!!!


IDEAL
P386
GROUP	Data	IData,UData
ASSUME	CS:Code,DS:Data

INCLUDE 'DECL.ASM'

SEGMENT Code	PUBLIC

MACRO 	WaitNotPressed MakeCode
LOCAL	@@1
@@1:	cmp	[Keys+MakeCode],0
	jnz	@@1
ENDM

MACRO 	JumpIfPressed MakeCode,Address
	cmp	[Keys+MakeCode],0
	jnz	Address
ENDM

PROC	InitFlat
;test if CPU is in real mode
	mov	eax,cr0
	mov	[Manager],0
	test	eax,1
	jz	@@real
IF EMM386 EQ 0
	Print	NoEMM
	jmp	@@NotInstalled
ELSE
;if not: can I kick out the memory manager?
	mov	[Manager],1
	mov	ax,1605h
	mov	di,30ah		;Windoze 3.1 >:->
	xor	bx,bx
	xor	cx,cx
	xor	dx,dx
	xor	si,si
	mov	ds,bx
	mov	es,cx		;all other regs to 0
	int	2fh		;fool manager
	mov	bx,ds
	mov	ax,Data
	mov	ds,ax
	test	cx,cx
	jnz	@@CrError	;if cx<>0
	lea	ax,[bx+si]
	test	ax,ax
	jz	@@CrError	;if switch pointer=0:0
	mov	[W ModeSwitch],si
	mov	[W ModeSwitch+2],bx
ENDIF
@@real: ;is a XMS-driver >= v2.0 present?
	mov	ax,4300h
	int	2fh
	cmp	al,80h
	jne	@@XMSError
	mov	ax,4310h
	int	2fh
	mov	[W XMST+2],es
	mov	[W XMST+0],bx
	xor	ax,ax
	call	[XMST]
	cmp	ax,200h
	jae	@@XMSok
@@XMSError:
	Print	XMSErr
	jmp	@@NotInstalled

@@XMSok: ;is enough XMS-mem available?
	mov	ax,800h
	call	[XMST]
	cmp	ax,128
	jb	@@CrError
	mov	dx,ax
	sub	dx,64		;HMA
	cmp	dx,[MinReq]
	jb	@@NotEn
	mov	[FreeFlat],dx
	mov	ax,900h
	call	[XMST]
	mov	[Handle],dx
	test	ax,ax
	jz	@@CrError
	mov	ax,0c00h
	call	[XMST]
	test	ax,ax
	jz	@@CrError
	mov	ax,dx
	shl	eax,16
	mov	ax,bx
	mov	[FlatPos],eax
	jmp	@@XMSAllocated
@@NotEn: Print	NotEnough1
	PrintW	[MinReq]
	Print	NotEnough2
	jmp	@@NotInstalled
@@XMSAllocated:	
;install own keyboard interrupt
IF Keyboard EQ 1
	push	ds
	pop	es
	mov	di,o Keys
	xor	ax,ax
	mov	cx,128/2
rep	stosw	;is a bit shorter than stosd and speed doesn't matter
	mov	ax,3509h
	int	21h
	mov	[w OldKeyInt],bx
	mov	[w OldKeyInt+2],es
	push	ds
	mov	ax,SEG KeyInt
	mov	ds,ax
	mov	dx,OFFSET KeyInt
	mov	ax,2509h
	int	21h
	pop	ds
ENDIF
;install timer interrupt
IF Timer EQ 1
	mov	ax,3508h
	int	21h
	mov	[w OldTmrInt],bx
	mov	[w OldTmrInt+2],es
	push	ds
	mov	ax,SEG SimpleTimerInt
	mov	ds,ax
	mov	dx,OFFSET SimpleTimerInt
	mov	ax,2508h
	int	21h
	pop	ds
ENDIF
;enable A20
	mov	ax,500h
	call	[XMST]
	or	ax,ax
	jz	@@CrError
IF EMM386 EQ 1
	cmp	[Manager],0
	jz	@@NowSurelyInRealMode
;switch prozessor to real mode
	mov	ax,0
	call	[ModeSwitch]
	mov	al,11111100b
	out	21h,al
	mov	ax,Data
	mov	ds,ax
	mov	eax,cr0
	test	al,1
	jz	@@NowSurelyInRealMode
	mov	al,0
	out	21h,al
	jmp	@@CrError
ENDIF
@@NowSurelyInRealMode:
;init Flat Real Mode
	mov	[GDT_Off+0],16
	mov	eax,s GDT
	shl	eax,4
	mov	bx,o GDT
	movzx	ebx,bx
	add	eax,ebx
	mov	[d GDT_Off+2],eax
	lgdt	[pword ptr GDT_OFF]
	mov	bx,8h
	push	ds
	cli
	mov	eax,cr0
	or	eax,1
	mov	cr0,eax
	jmp	@@Protected_Mode
@@Protected_Mode:
	mov	gs,bx
	mov	fs,bx
	mov	es,bx
	mov	ds,bx
	and	al,0feh
	mov	cr0,eax
	jmp	@@Real_Mode_again
@@Real_Mode_again:
	sti
	pop	ds
	mov	[FlatInst],1
	ret
@@CrError:
	Print	CrError
@@NotInstalled:
	mov	[FlatInst],0
	ret   
ENDP

PROC	DeInitFlat
	cmp	[FlatInst],0
	jz	@@FlatAlreadyUnInstalled
	mov	[FlatInst],0
;switch back to V86 Mode
IF EMM386 EQ 1
	cmp	[Manager],0
	jz	@@NotNecessary
	mov	ax,1
	call	[ModeSwitch]
	mov	ax,Data
	mov	ds,ax
	mov	al,0
	out	21h,al
ENDIF
@@NotNecessary:
;disable A20
	mov	ax,600h
	call	[XMST]
	test	ax,ax
	jz	@@CrError
;deallocate XMS
	mov	dx,[Handle]
	mov	ax,0d00h
	call	[XMST]
	or	ax,ax
	jz	@@CrError
	mov	ax,0a00h
	call	[XMST]
	or	ax,ax
	jz	@@CrError   
;vector to old keyboard interrupt
IF Keyboard EQ 1
	push	ds
	mov	dx,[W OldKeyInt]
	mov	ds,[W OldKeyInt+2]
	mov	ax,2509h
	int	21h
	pop	ds
ENDIF
;vector to old timer interrupt
IF Timer EQ 1
	push	ds
	mov	dx,[W OldTmrInt]
	mov	ds,[W OldTmrInt+2]
	mov	ax,2508h
	int	21h
	pop	ds
ENDIF
	mov	[FlatInst],0		;oki!
	ret
@@CrError:
	Print	CrError
	mov	[FlatInst],1
@@FlatAlreadyUnInstalled:
	ret
ENDP

IF Keyboard EQ 1
PROC	KeyInt FAR
	push	ax
	push	bx
	push	ds
	mov	ax,Data
	mov	ds,ax
	in	al,60h
	mov	bl,al
	and	bx,7fh
	test	al,80h
	setz	al
	mov	[bx+Keys],al
	mov	al,20h
	out	20h,al
	pop	ds
	pop	bx
	pop	ax
	iret
ENDP
ENDIF

IF Timer EQ 1
PROC	SimpleTimerInt FAR
	push	ax
	push	fs
	xor	ax,ax
	mov	fs,ax
	inc	[d fs:46ch]
	mov	al,20h
	out	20h,al
	pop	fs
	pop	ax
	iret
ENDP
ENDIF

PROC	SwitchToReal	;Destroys all Registers except ds,ss,sp,cs,ip
IF EMM386 EQ 1
	cmp	[Manager],0
	jz	@@NoManager
	push	ds
	mov	ax,0
	call	[ModeSwitch]
	pop	ds
;init Flat Real Mode
	mov	[GDT_Off+0],16
	mov	eax,s GDT
	shl	eax,4
	mov	bx,o GDT
	movzx	ebx,bx
	add	eax,ebx
	mov	[d GDT_Off+2],eax
	lgdt	[pword ptr GDT_OFF]
	mov	bx,8h
	push	ds
	cli
	mov	eax,cr0
	or	eax,1
	mov	cr0,eax
	jmp	@@Protected_Mode
@@Protected_Mode:
	mov	gs,bx
	mov	fs,bx
	mov	es,bx
	mov	ds,bx
	and	al,0feh
	mov	cr0,eax
	jmp	@@Real_Mode_again
@@Real_Mode_again:
	sti
	pop	ds
@@NoManager:
ENDIF
	ret
ENDP

PROC	SwitchToV86	;Destroys all Registers except ds,ss,sp,cs,ip
IF EMM386 EQ 1
	cmp	[Manager],0
	jz	@@NoManager
	push	ds
	mov	ax,1
	call	[ModeSwitch]
	pop	ds
@@NoManager:
ENDIF
	ret
ENDP

ENDS

SEGMENT IData	PUBLIC
NoEMM	DB	'This programm won''t run under a memory manager.',0Dh,0Ah,'$'
XMSErr	DB	'You have no XMS-driver installed or the XMS-version is lower than 2.0',0Dh,0Ah,'$'
CrError	DB	'critical error',0Dh,0Ah,'$'
NotEnough1 DB	'I need at least $'
NotEnough2 DB	' kB of free XMS-memory',0Dh,0Ah,'$'
GDT	DB	00h,00h,00h,00h,00h,00h,00h,00h
	DB	0FFh,0FFh,00h,00h,00h,92h,0CFh,0FFh
ENDS

SEGMENT UData	PUBLIC
OldKeyInt DD	?
OldTmrInt DD	?
ModeSwitch DD	?
XMST	DD	?
FlatPos DD	?
FreeFlat DW	?
MinReq	DW	?
Handle	DW	?
GDT_Off DB	6 DUP(?)
IF Keyboard EQ 1
Keys	DB	128 DUP(?)
ENDIF
Manager	DB	?	;1 if a memory manager is installed
FlatInst DB	?
ENDS
