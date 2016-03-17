;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  ALPiNE Graphical User Interface   ³
;³               v1.00                ³
;³          (c) 1997 ALPiNE           ³
;³ coded by Ziron aka Christoph Groth ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IDEAL
P386
GROUP	Data	IData,UData
ASSUME	CS:Code,DS:Data

INCLUDE 'decl.asm'

SEGMENT Code	PUBLIC

PROC	InitGUI
	mov	ax,12h
	int	10h
	mov	dx,3c8h
	mov	al,0
	out	dx,al
	inc	dx
	mov	si,O Palette
	mov	cx,16*3
rep	outsb

	xor	cl,cl
@@1:	mov	dx,3dah
	in	ax,dx
	mov	dx,3c0h
	mov	al,cl
	out	dx,al
	out	dx,al
	inc	cl
	cmp	cl,16
	jne	@@1
	mov	al,32
	out	dx,al

	push	0a000h
	pop	es
;copy Font to RAM
	push	es
	push	ds
	mov	ax,1130h
	mov	bh,6
	int	10h
	mov	si,bp
	mov	di,o Font
	push	ds
	mov	ax,es
	mov	ds,ax
	pop	es
	mov	cx,256*16/4
rep	movsd
	pop	ds
	pop	es
;init mouse
	xor	ax,ax
	int	33h
	ret
ENDP

PROC	String	;DrawX=x, DrawY=y, si=offset to 0-terminated string, al=color
	mov	dx,3ceh
	shl	ax,8
	out	dx,ax		;set color
	mov	ax,0f01h
	out	dx,ax		;enable set/reset
	mov	di,[DrawY]
	imul	edi,80
	mov	bp,[DrawX]
	mov	cx,bp
	and	cl,7
	neg	cl
	add	cl,8		;cl:=8-cl=(-cl)+(8)
	shr	bp,3
	add	di,bp
	call	CountLength
	mov	[DrawWidth],bp
	mov	ch,16
@@1:	mov	bp,[DrawWidth]
	inc	bp
	xor	ah,ah
@@2:	mov	bl,[si]
	inc	si
	xor	bh,bh
	shl	bx,4
	add	bx,16
	sub	bl,ch
	sbb	bh,0
	add	bx,O Font
	mov	al,[bx]
	cmp	bp,1
	jne	@@3
	mov	al,0
@@3:	push	ax		;save al for next iteration
;this equals 'shld ah,al,cl' which doesn't exist :(
	push	cx
	shl	ah,cl
	neg	cl
	add	cl,8
	shr	al,cl
	or	ah,al
	pop	cx

	mov	al,8
	out	dx,ax
	xchg	[es:di],ah
	inc	di
	pop	ax
	mov	ah,al
	dec	bp
	jnz	@@2
	sub	si,[DrawWidth]
	dec	si
	sub	di,[DrawWidth]
	add	di,80-1
	dec	ch
	jnz	@@1
	ret
ENDP

PROC	Bar	;DrawX/Y/Width/Height=coordinates al=color;es must be a000h
;color to set/reset, enable set/reset to 0fh
	mov	dx,3ceh
	shl	ax,8	;same as mov ah,color; mov al,0
	out	dx,ax
	mov	ax,0f01h
	out	dx,ax
;left bitmask
	mov	cl,[B DrawX]
	and	cl,7
	mov	ax,0ff08h	;two in one: value for shifting & index
	shr	ah,cl
	out	dx,ax
;draw left part of the bar
	mov	di,[DrawX]
	shr	di,3
	mov	ax,[DrawY]
	imul	esi,eax,80	;offset y addy in si
	add	di,si		;starting offset
	mov	bp,[DrawHeight]	;height
	mov	cx,bp		;height --> y-counter
@@1:	xchg	[es:di],dl
	add	di,80
	dec	cx
	jnz	@@1
;middle bitmask
	mov	dx,3ceh
	mov	ax,0ff08h
	out	dx,ax
;draw middle part
	mov	di,[DrawX]
	mov	bx,di
	shr	di,3
	inc	di
	add	bx,[DrawWidth]
	dec	bx
	shr	bx,3
	sub	bx,di		;width
	add	di,si
	mov	cx,bp		;y-counter
@@2:	mov	ax,bx		;width --> x-counter
@@3:	mov	[es:di],dl
	inc	di
	dec	ax
	jnz	@@3
	sub	di,bx
	add	di,80		;next line
	dec	cx
	jnz	@@2
;right bitmask
	mov	dx,3ceh
	mov	cx,[DrawX]
	add	cx,[DrawWidth]
	dec	cx
	and	cl,7
	neg	cl
	add	cl,7		;same as: cl:=7-cl
	mov	ax,0ff08h	;two in one: value for shifting & index
	shl	ah,cl
	out	dx,ax
;draw left part of the bar
	mov	di,[DrawX]
	add	di,[DrawWidth]
	dec	di
	shr	di,3
	add	di,si		;starting offset
	mov	cx,bp		;height --> y-counter
@@4:	xchg	[es:di],dl
	add	di,80
	dec	cx
	jnz	@@4
	ret
ENDP

PROC	HorizLine ;DrawX/Y/Height=coordinates al=color;es must be a000h
;color to set/reset, enable set/reset to 0fh
	mov	dx,3ceh
	shl	ax,8	;same as mov ah,color; mov al,0
	out	dx,ax
	mov	ax,0f01h
	out	dx,ax
;left bitmask
	mov	cl,[B DrawX]
	and	cl,7
	mov	ax,0ff08h	;two in one: value for shifting & index
	shr	ah,cl
	out	dx,ax
;draw left part of the line
	mov	di,[DrawX]
	shr	di,3
	mov	ax,[DrawY]
	imul	esi,eax,80	;offset y addy in si
	add	di,si		;starting offset
	xchg	[es:di],dl
;middle bitmask
	mov	dx,3ceh
	mov	ax,0ff08h
	out	dx,ax
;draw middle part of the line
	mov	di,[DrawX]
	mov	bx,di
	shr	di,3
	inc	di
	add	bx,[DrawWidth]
	dec	bx
	shr	bx,3
	sub	bx,di		;width
	add	di,si
@@2:	mov	[es:di],dl
	inc	di
	dec	bx
	jnz	@@2
;right bitmask
	mov	dx,3ceh
	mov	cx,[DrawX]
	add	cx,[DrawWidth]
	dec	cx
	and	cl,7
	neg	cl
	add	cl,7		;same as: cl:=7-cl
	mov	ax,0ff08h	;two in one: value for shifting & index
	shl	ah,cl
	out	dx,ax
;draw left part of the line
	mov	di,[DrawX]
	add	di,[DrawWidth]
	dec	di
	shr	di,3
	add	di,si		;starting offset
	xchg	[es:di],dl
	ret
ENDP

PROC	VertLine ;DrawX/Y/Height=coordinates al=color;es must be a000h
;color to set/reset, enable set/reset to 0fh
	mov	dx,3ceh
	shl	ax,8	;same as mov ah,color; mov al,0
	out	dx,ax
	mov	ax,0f01h
	out	dx,ax
;bitmask
	mov	cl,[B DrawX]
	and	cl,7
	mov	ax,08008h	;two in one: value for shifting & index
	shr	ah,cl
	out	dx,ax
;draw line
	mov	di,[DrawX]
	shr	di,3
	mov	ax,[DrawY]
	imul	esi,eax,80	;offset y addy in di
	add	di,si
	mov	cx,[DrawHeight]	;height
@@1:	xchg	[es:di],dl
	add	di,80
	dec	cx
	jnz	@@1
	ret
ENDP

PROC	Box
;DrawX/X2/Width/Height=coordinates, ah=state(0=released, 1=pressed)
;es must be a000h
	mov	bp,[DrawX]
	mov	bx,[DrawY]
	mov	cx,[DrawWidth]
	mov	dx,[DrawHeight]
;draw the upper line
	pusha
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	test	ah,ah
	setz	al
	add	al,2
	call	HorizLine
;draw the left line
	popa
	pusha
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawHeight],dx
	test	ah,ah
	setz	al
	add	al,2
	call	VertLine	
;draw the right line
	popa
	pusha
	add	bp,cx
	dec	bp
	inc	bx
	mov	[DrawX],bp
	mov	[DrawY],bx
	dec	dx
	mov	[DrawHeight],dx
	test	ah,ah
	setnz	al
	add	al,2
	call	VertLine
;draw the lower line
	popa
	add	bx,dx
	dec	bx
	inc	bp
	mov	[DrawX],bp
	mov	[DrawY],bx
	dec	cx
	mov	[DrawWidth],cx
	test	ah,ah
	setnz	al
	add	al,2
	call	HorizLine
	ret
ENDP

PROC	CountLength	;si=pointer to 0-terminated string
	push	si
	xor	bp,bp
@@1:	cmp	[B si],0
	jz	@@2
	inc	si
	inc	bp
	jmp	@@1
@@2:	pop	si
	ret		;returns the length of the string in bp
ENDP

PROC	DrawMouse
	mov	ax,0bh
	int	33h
	add	[MouseX],cx
	add	[MouseY],dx

	cmp	[MouseX],0
	jnl	@@1
	mov	[MouseX],0
@@1:	cmp	[MouseX],639
	jng	@@2
	mov	[MouseX],639
@@2:
	cmp	[MouseY],0
	jnl	@@3
	mov	[MouseY],0
@@3:	cmp	[MouseY],479
	jng	@@4
	mov	[MouseY],479
@@4:
	mov	dx,3ceh
	mov	ax,0300h
	out	dx,ax
	mov	ax,0f01h
	out	dx,ax
	mov	si,[MouseX]
	shr	si,3
	mov	di,[MouseY]
	imul	edi,80
	add	di,si

	mov	al,8
	out	dx,al
	inc	dx
	mov	al,0
	out	dx,al	;al bytes come from the latch-register
;I could use write mode 1, but this is shorter
	push	di
	mov	ch,16
	mov	si,580*80
@@5:	mov	al,[es:di]
	mov	[es:si],al
	inc	di
	inc	si
	mov	al,[es:di]
	mov	[es:si],al
	inc	di
	inc	si
	mov	al,[es:di]
	mov	[es:si],al
	inc	si
	add	di,80-2
	dec	ch
	jnz	@@5
	pop	di
	mov	cx,[MouseX]
	and	cl,7
	mov	ch,16
	mov	si,O MousePointer
@@ThreeBytes:
	push	cx
	mov	al,[si]
	mov	bl,al
	shr	al,cl
	inc	si
	out	dx,al
	xchg	[es:di],al
	inc	di
	mov	al,[si]
	mov	bh,al
	inc	si
	shr	al,cl
	neg	cl
	add	cl,8
	shl	bl,cl
	or	al,bl
	cmp	[MouseX],632
	jae	@@6
	out	dx,al
	xchg	[es:di],al
	cmp	[MouseX],625
	jae	@@6
	shl	bh,cl
	mov	al,bh
	out	dx,al
	xchg	[es:di+1],al
@@6:	add	di,80-1
	pop	cx
	dec	ch
	jnz	@@ThreeBytes
	ret
ENDP

PROC	ClearMouse
	mov	si,[MouseX]
	shr	si,3
	movzx	edi,[MouseY]
	imul	edi,80
	add	di,si

	mov	dx,3ceh
	mov	ax,8
	out	dx,ax
	mov	ch,16
	mov	si,580*80
@@2:	mov	al,[es:si]
	mov	[es:di],al
	inc	di
	inc	si
	mov	al,[es:si]
	mov	[es:di],al
	inc	di
	inc	si
	mov	al,[es:si]
	mov	[es:di],al
	inc	si
	add	di,80-2
	dec	ch
	jnz	@@2
	ret
ENDP

PROC	RunGUI
	mov	[ActWindow],0
	call	ChangeActWindow
GUImain: cmp	[EndGUI],1
	je	@@GUIesc
	call	DrawMouse
	WaitVRetrace
	call	ClearMouse
	mov	ax,3
	int	33h
	test	bx,1
	jz	GUImain

	mov	cx,[MouseX]
	mov	dx,[MouseY]
	mov	si,[ActWindowOfs]
	mov	bp,[si+Window.OX]
	mov	bx,[si+Window.OY]
	sub	cx,bp
	sub	dx,bx
	mov	si,[si+Window.OInside]
@@1:	cmp	si,0
	jz	@@StillPressed
	test	[B si],80h	;all inactive controls are >= 128
	jnz	@@2
	push	cx
	sub	cx,[si+3]
	cmp	cx,[si+7]
	pop	cx
	ja	@@2
	push	dx
	sub	dx,[si+5]
	cmp	dx,[si+9]
	pop	dx
	ja	@@2
	cmp	[B si],0
	je	HandleButton
	cmp	[B si],1
	je	HandlePicture
	cmp	[B si],2
	je	HandleInputField
	cmp	[B si],3
	je	HandleCheckBox
@@2:	mov	si,[si+1]
	jmp	@@1
@@StillPressed:
	call	DrawMouse
	WaitVRetrace
	call	ClearMouse
	mov	ax,3
	int	33h
	test	bx,1
	jz	GUImain
	jmp	@@StillPressed
@@GUIesc:
	ret
ENDP

PROC	ChangeActWindow	;ActWindow=what window is now actual?
	mov	cx,[ActWindow]
	mov	di,O MainWin
	mov	[ActWindowOfs],di
	jcxz	@@2
@@1:	mov	di,[di+Window.ONext]
	dec	cx
	jnz	@@1
	mov	[ActWindowOfs],di
@@2:	call	DrawWindow
	ret
ENDP

PROC	DrawWindow	;ActWindow=what window to draw?
	mov	di,O MainWin
	mov	bp,[di+Window.OX]
	mov	bx,[di+Window.OY]
	mov	cx,[di+Window.OWidth]
	mov	dx,[di+Window.OHeight]
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	xor	al,al
	pusha
	call	Bar
	popa
	mov	si,[di+Window.OInside]
@@1:	test	si,si
	jz	@@2		;this was the last control
	pusha
	call	DrawObject
	popa
	mov	si,[si+1]
	jmp	@@1
@@2:	cmp	[ActWindow],0
	jnz	@@not0
	ret
@@not0:	mov	di,[ActWindowOfs]
	mov	bp,[di+Window.OX]
	mov	bx,[di+Window.OY]
	mov	cx,[di+Window.OWidth]
	mov	dx,[di+Window.OHeight]
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	xor	ax,ax
	pusha
	call	Box
	popa
	pusha
	inc	bp
	inc	bx
	sub	cx,2
	sub	dx,2
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	call	Bar
	popa
	mov	si,[di+Window.OInside]
@@3:	test	si,si
	jz	@@end		;this was the last control
	pusha
	call	DrawObject
	popa
	mov	si,[si+1]
	jmp	@@3
@@end:	ret
ENDP

PROC	DrawObject	;si=offset to object
	movzx	ax,[si]
	cmp	al,0
	je	DrawButton
	cmp	al,1
	je	DrawPicture
	cmp	al,2
	je	DrawInputField
	cmp	al,3
	je	DrawCheckBox


	cmp	al,128
	je	DrawTextField
	cmp	al,129
	je	DrawNumber
	cmp	al,130
	je	DrawFrame
	;...
ENDP

PROC	ReDrawObject	;si=offset to object
;this procedure should be called by the event handlers
	mov	di,[ActWindowOfs]
	mov	bp,[di+Window.OX]
	mov	bx,[di+Window.OY]
	call	DrawObject
	ret
ENDP

PROC	HandleButton	;si=offset to object
	mov	ah,1	;state
	pusha
	call	DrawButton
	popa
	cmp	[si+Button.ORepeat],0
	jz	@@1
	cmp	[si+Button.OCall],0
	jz	@@1

	pusha
	call	[si+Button.OCall]
	call	DrawMouse
	mov	cl,10
@@Wait1: WaitVRetrace
	dec	cl
	jnz	@@Wait1
	call	ClearMouse
	popa
	jmp	@@4

@@1:	pusha
	call	DrawMouse
	WaitVRetrace
	call	ClearMouse
	popa

	test	ah,ah
	jz	@@NoRep
	cmp	[si+Button.ORepeat],0
	jz	@@NoRep
	cmp	[si+Button.OCall],0
	jz	@@NoRep
	pusha
	call	[si+Button.OCall]
	call	DrawMouse
	mov	cl,3
@@Wait2: WaitVRetrace
	dec	cl
	jnz	@@Wait2
	call	ClearMouse
	popa

@@NoRep: mov	cx,[MouseX]
	mov	dx,[MouseY]
	sub	cx,bp
	sub	dx,bx
	sub	cx,[si+Button.OX]
	cmp	cx,[si+Button.OWidth]
	ja	@@2
	sub	dx,[si+Button.OY]
	cmp	dx,[si+Button.OHeight]
	ja	@@2
	mov	al,1
	jmp	@@3
@@2:	xor	al,al
@@3:	cmp	al,ah
	je	@@4
	mov	ah,al
	pusha
	call	DrawButton
	popa

@@4:	push	ax
	push	bx
	mov	ax,3
	int	33h
	test	bx,1
	pop	bx
	pop	ax
	jnz	@@1

	mov	al,ah
	xor	ah,ah
	pusha
	call	DrawButton
	popa

	test	al,al
	jz	@@5
	cmp	[si+Button.OCall],0
	jz	@@5
	cmp	[si+Button.ORepeat],1
	je	@@5
	pusha
	call	[si+Button.OCall]
	popa
@@5:	jmp	GUImain
ENDP

PROC	HandlePicture	;si=offset to object
	cmp	[si+Picture.OCall],0
	jz	@@end
@@1:	pusha
	call	DrawMouse
	WaitVRetrace
	call	ClearMouse
	popa
	push	bx
	mov	ax,3
	int	33h
	dec	bx
	pop	bx
	jz	@@1

	mov	cx,[MouseX]
	mov	dx,[MouseY]
	sub	cx,bp
	sub	dx,bx
	sub	cx,[si+Picture.OX]
	cmp	cx,[si+Picture.OWidth]
	ja	@@end
	sub	dx,[si+Picture.OY]
	cmp	dx,[si+Picture.OHeight]
	ja	@@end

	pusha
	call	[si+Picture.OCall]
	popa
@@end:	jmp	GUImain
ENDP

PROC	HandleCheckBox	;si=offset to object
@@1:	pusha
	call	DrawMouse
	WaitVRetrace
	call	ClearMouse
	popa
	push	bx
	mov	ax,3
	int	33h
	dec	bx
	pop	bx
	jz	@@1

	mov	cx,[MouseX]
	mov	dx,[MouseY]
	sub	cx,bp
	sub	dx,bx
	sub	cx,[si+CheckBox.OX]
	cmp	cx,[si+CheckBox.OWidth]
	ja	@@end
	sub	dx,[si+CheckBox.OY]
	cmp	dx,[si+CheckBox.OHeight]
	ja	@@end

	mov	di,[si+CheckBox.OVar]
	xor	[B di],1

	push	si
	call	ReDrawObject
	pop	si

	cmp	[si+CheckBox.OCall],0
	jz	@@end
	pusha
	call	[si+CheckBox.OCall]
	popa
@@end:	jmp	GUImain
ENDP

PROC	HandleInputField	;si=offset to object
@@1:	pusha
	call	DrawMouse
	WaitVRetrace
	call	ClearMouse
	popa
	push	bx
	mov	ax,3
	int	33h
	dec	bx
	pop	bx
	jz	@@1

	mov	cx,[MouseX]
	mov	dx,[MouseY]
	sub	cx,bp
	sub	dx,bx
	sub	cx,[si+InputField.OX]
	cmp	cx,[si+InputField.OWidth]
	ja	@@end
	sub	dx,[si+InputField.OY]
	cmp	dx,[si+InputField.OHeight]
	ja	@@end

	mov	di,[si+InputField.OText]
	xor	bx,bx
	mov	cl,[si+InputField.OMaxSize]
@@2:	mov	[W di+bx],0011h		;cursor
	pusha
	call	ReDrawObject
	popa
	xor	ah,ah
	int	16h
	cmp	al,0dh
	je	@@3
	mov	[B di+bx],al
	inc	bx
	dec	cl
	jnz	@@2
@@3:	mov	[B di+bx],0
	pusha
	call	ReDrawObject
	popa

@@end:	jmp	GUImain
ENDP

PROC	DrawButton	;si=pointer to an instance of Button, ah=state
;bp=x-coordinate of container, bx=y-coordinate of container
	add	bp,[si+Button.OX]
	add	bx,[si+Button.OY]
	mov	cx,[si+Button.OWidth]
	mov	dx,[si+Button.OHeight]
;draw the inner part of button
	pusha
	inc	bp
	inc	bx
	dec	cx
	dec	dx
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	mov	al,1
	call	Bar
;draw the box around
	popa
	pusha
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	call	Box
;write text into the button
	popa
	test	ah,ah
	setnz	al
	xor	ah,ah
	add	bp,ax
	add	bx,ax
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	si,[si+Button.OText]
	call	CountLength
	shl	bp,3
	sub	cx,bp
	shr	cx,1
	add	[DrawX],cx
	sub	dx,16
	shr	dx,1
	add	[DrawY],dx
	mov	al,02h
	call	String
	ret
ENDP

PROC	DrawInputField	;si=pointer to an instance of InputField
;bp=x-coordinate of container, bx=y-coordinate of container
	add	bp,[si+InputField.OX]
	add	bx,[si+InputField.OY]
	mov	cx,[si+InputField.OWidth]
	mov	dx,[si+InputField.OHeight]
;draw the inner part
	pusha
	inc	bp
	inc	bx
	dec	cx
	dec	dx
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	mov	al,1
	call	Bar
;draw the box around
	popa
	pusha
	mov	ah,1
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	call	Box
;write text into the field
	popa
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	si,[si+InputField.OText]
	call	CountLength
	shl	bp,3
	sub	cx,bp
	shr	cx,1
	add	[DrawX],cx
	sub	dx,16
	shr	dx,1
	add	[DrawY],dx
	mov	al,02h
	call	String
	ret
ENDP

PROC	DrawTextField	;si=pointer to an instance of TextField
;bp=x-coordinate of container, bx=y-coordinate of container
	add	bp,[si+TextField.OX]
	add	bx,[si+TextField.OY]
;write the text
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	si,[si+TextField.OText]
	mov	al,02
	call	String
	ret
ENDP

PROC	DrawCheckBox	;si=pointer to an instance of CheckBox
;bp=x-coordinate of container, bx=y-coordinate of container
	add	bp,[si+CheckBox.OX]
	add	bx,[si+CheckBox.OY]
;draw the box
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],20
	mov	[DrawHeight],20
	mov	di,[si+CheckBox.OVar]
	mov	ah,1
	pusha
	call	Box
	popa
;draw the inner part
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],18
	mov	[DrawHeight],18
	inc	[DrawX]
	inc	[DrawY]
	xor	al,al
	pusha
	call	Bar
	popa
;draw the X if necessary
	mov	di,[si+CheckBox.OVar]
	cmp	[B di],0
	jz	@@noX
	mov	[DrawX],bp
	mov	[DrawY],bx
	add	[DrawX],6
	add	[DrawY],2
	pusha
	mov	al,2
	mov	si,O XTXT
	call	String
	popa
@@noX:
;write the text
	mov	[DrawX],bp
	mov	[DrawY],bx
	add	[DrawX],24
	add	[DrawY],2
	mov	si,[si+CheckBox.OText]
	mov	al,2
	call	String
	ret
ENDP

PROC	DrawNumber	;si=pointer to an instance of Number
;bp=x-coordinate of container, bx=y-coordinate of container
	add	bp,[si+Number.OX]
	add	bx,[si+Number.OY]
	mov	ax,[si+Number.OWidth]
	mov	[DrawX],bp
	add	bp,ax
	mov	[DrawY],bx
	mov	[DrawWidth],ax
	mov	[DrawHeight],16

	mov	al,0
	pusha
	call	Bar
	popa

	mov	ax,[si+Number.OText]
	test	ax,ax
	jz	@@NoText
	pusha
	mov	si,ax
	mov	al,02
	call	String
	popa
@@NoText:
	mov	[DrawX],bp
	xor	eax,eax
	mov	di,[si+Number.OVar]
	cmp	[si+Number.OLength],1
	jb	@@Byte
	ja	@@DWord
	mov	ax,[di]
	mov	bx,5
	jmp	@@ok
@@Byte:	mov	al,[di]
	mov	bx,3
	jmp	@@ok
@@DWord: mov	eax,[di]
	mov	bx,10
@@ok:	mov	di,bx
	shl	di,3
	sub	[DrawX],di
	mov	di,O NumberText
	mov	[B bx+di],0
	cmp	[Hex],1
	je	@@hex
	mov	ecx,10
@@1dec:	xor	edx,edx
	div	ecx
	add	dl,'0'
	mov	[di+bx-1],dl
	dec	bx
	jz	@@3
	test	eax,eax
	jnz	@@1dec
	jmp	@@2

@@hex:	mov	ecx,16
@@1hex:	xor	edx,edx
	div	ecx
	add	dl,'0'
	cmp	dl,'9'
	jbe	@@2hex
	add	dl,'A'-'9'-1
@@2hex:	mov	[di+bx-1],dl
	dec	bx
	jz	@@3
	test	eax,eax
	jnz	@@1hex

@@2:	mov	[B di+bx-1],32
	dec	bx
	jnz	@@2

@@3:	mov	si,O NumberText
	mov	al,02h
	call	String
	ret
ENDP

PROC	DrawFrame	;si=pointer to an instance of Frame
;bp=x-coordinate of container, bx=y-coordinate of container
	add	bp,[si+Button.OX]
	add	bx,[si+Button.OY]
	mov	cx,[si+Button.OWidth]
	mov	dx,[si+Button.OHeight]
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	mov	ah,1
	pusha
	call	Box
	popa
	add	bp,2
	add	bx,2
	sub	cx,4
	sub	dx,4
	mov	ah,0
	mov	[DrawX],bp
	mov	[DrawY],bx
	mov	[DrawWidth],cx
	mov	[DrawHeight],dx
	call	Box
	ret
ENDP

PROC	DrawPicture	;si=pointer to an instance of Picture
;bp=x-coordinate of container, bx=y-coordinate of container
	call	[si+Picture.ORefresh]
	ret
ENDP

ENDS

SEGMENT IData	PUBLIC

STRUC	Window
ONext	DW	?	;pointer to next window, 0 if this is the last one
OX	DW	?	;x-coordinate of left top edge
OY	DW	?	;y-coordinate of left top edge
OWidth	DW	?	;width of the whole thing
OHeight	DW	?	;height of the whole thing
OInside DW	?	;pointer to the controls inside the window
ENDS

STRUC	Button
OType	DB	0
ONext	DW	0	;pointer to next control, 0 if this is the last one
OX	DW	?
OY	DW	?
OWidth	DW	?
OHeight	DW	?
OCall	DW	0	;if button is pressed, call...
OText	DW	?	;pointer to 0-terminated string containing the text
ORepeat	DB	0	;call multiple times
ENDS

STRUC	Picture
OType	DB	1
ONext	DW	0	;pointer to next control, 0 if this is the last one
OX	DW	?
OY	DW	?
OWidth	DW	?
OHeight	DW	?
ORefresh DW	?
OCall	DW	0
ENDS

STRUC	InputField
OType	DB	2
ONext	DW	0	;pointer to next control, 0 if this is the last one
OX	DW	?
OY	DW	?
OWidth	DW	?
OHeight	DW	18
OText	DW	?	;pointer to 0-terminated string containing the text
OMaxSize DB	1	;maximum size of the string
ENDS

STRUC	CheckBox
OType	DB	3
ONext	DW	0	;pointer to next control, 0 if this is the last one
OX	DW	?
OY	DW	?
OWidth	DW	?
OHeight	DW	20
OText	DW	?	;pointer to 0-terminated string containing the text
OVar	DW	?
OCall	DW	0
ENDS

STRUC	TextField
OType	DB	128
ONext	DW	0	;pointer to next control, 0 if this is the last one
OX	DW	?
OY	DW	?
OText	DW	?	;pointer to 0-terminated string containing the text
ENDS

STRUC	Number
OType	DB	129
ONext	DW	0	;pointer to next control, 0 if this is the last one
OX	DW	?
OY	DW	?
OWidth	DW	10*8
OText	DW	0	;pointer to 0-terminated string containing the text
			;0 if none
OVar	DW	?	;pointer to the variable
OLength	DB	0	;0=byte, 1=word, 2=dword
ENDS

STRUC	Frame
OType	DB	130
ONext	DW	0	;pointer to next control, 0 if this is the last one
OX	DW	?
OY	DW	?
OWidth	DW	?
OHeight	DW	?
ENDS

EndGUI	DB	0
Hex	DB	1
MouseX	DW	320
MouseY	DW	240
XTXT	DB	'X',0

MousePointer DB	11000000b,00000000b
	DB	11110000b,00000000b
	DB	01111100b,00000000b
	DB	01111111b,00000000b
	DB	00111111b,11000000b
	DB	00111111b,11110000b
	DB	00011111b,11111100b
	DB	00011111b,11111111b
	DB	00001111b,11111110b
	DB	00001111b,11111100b
	DB	00000111b,11111000b
	DB	00000111b,11111100b
	DB	00000011b,11111110b
	DB	00000011b,11011111b
	DB	00000001b,10001111b
	DB	00000001b,00000110b

Palette	DB	12,32,32	;background
	DB	34,34,34	;buttons
	DB	0,0,0		;a dark color
	DB	55,55,55	;a light color
	DB	50,50,50	;viruses
	DB	25,25,25	;antiviruses
	DB	16,63,16	;selected robot
	DB	0,0,0
	DB	0,0,0
	DB	0,0,0
	DB	63,8,8		;robot-team 0
	DB	8,8,63		;robot-team 1
	DB	40,40,0		;robot-team 2
	DB	0,40,40		;robot-team 3
	DB	40,0,40		;robot-team 4
	DB	0,28,0		;robot-team 5
ENDS

SEGMENT UData	PUBLIC
DrawX	DW	?
DrawY	DW	?
DrawWidth DW	?
DrawHeight DW	?
ActWindow DW	?
ActWindowOfs DW ?
NumberText DB	11 DUP (?)
Font	DB	256*16 DUP(?)
ENDS