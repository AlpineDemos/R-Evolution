;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; First Attempt of Robot-Evolution        < Kernel 1.o >      Syrius/ALPiNE  ;
;                                                                            ;
; INSTRUCT: Instruction Handler of Kernel                                    ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

 @1:

;----------------------------- MOV
 @MOV_IMM:
  xor bx,bx
  mov bl,dh
  and bl,15
  mov [fs:ebp+ebx],dl
  jmp @NOP
;----------------------------- ADD
 @ADD_IP:
   xor bx,bx
   xor dh,dh
   shl dx,1
   add di,dx
   cmp di,512
   jb  @JMPS
    mov di,510
    Jmp @JMPS
 @ADD_IMM:
  xor bx,bx
  mov bl,dh
  and bl,15
  add [fs:ebp+ebx],dl
  CHECKF
  Jmp @NOP
;----------------------------- SUB
 @SUB_IP:
   xor bx,bx
   xor dh,dh
   shl dx,1
   sub di,dx
   cmp di,16
   jg  @JMPS
    mov di,16
    Jmp @JMPS
 @SUB_IMM:
  xor bx,bx
  mov bl,dh
  and bl,15
  sub [fs:ebp+ebx],dl
  CHECKF
  Jmp @NOP
;----------------------------- AND
 @AND_IMM:
  xor bx,bx
  mov bl,dh
  and bl,15
  and [fs:ebp+ebx],dl
  CHECKF
  Jmp @NOP
;----------------------------- OR
 @OR_IMM:
  xor bx,bx
  mov bl,dh
  and bl,15
  or  [fs:ebp+ebx],dl
  CHECKF
  Jmp @NOP
;----------------------------- XOR
 @XOR_IMM:
  xor bx,bx
  mov bl,dh
  and bl,15
  xor [fs:ebp+ebx],dl
  CHECKF
  Jmp @NOP
;----------------------------- XOR
 @TST_IMM:
  xor bx,bx
  mov bl,dh
  and bl,15
  test [fs:ebp+ebx],dl
  CHECKF
  Jmp @NOP
;----------------------------- CMP
 @CMP_IMM:
  xor bx,bx
  mov bl,dh
  and bl,15
  cmp [fs:ebp+ebx],dl
  CHECKF
  Jmp @NOP
;----------------------------- MOV Reg,Reg
 @MOV:
  xor bx,bx
  mov bl,dl
  and bl,15
  mov al,[fs:ebp+ebx]
  mov bl,dl
  shr bl,4
  jz  @NOP
   mov [fs:ebp+ebx],al
   jmp @NOP
;----------------------------- ADD Reg,Reg
 @ADD:
  xor bx,bx
  mov bl,dl
  and bl,15
  mov al,[fs:ebp+ebx]
  mov bl,dl
  shr bl,4
  jz  @NOP
   add [fs:ebp+ebx],al
   CHECKF
   jmp @NOP
;----------------------------- SUB Reg,Reg
 @SUB:
  xor bx,bx
  mov bl,dl
  and bl,15
  mov al,[fs:ebp+ebx]
  mov bl,dl
  shr bl,4
  jz  @NOP
   sub [fs:ebp+ebx],al
   CHECKF
   jmp @NOP
;----------------------------- XCH Reg,Reg
 @XCH:
  xor bx,bx
  mov bl,dl
  shr bl,4
  mov al,[fs:ebp+ebx]
  mov bl,dl
  and bl,15
  mov ah,[fs:ebp+ebx]
  jz @NotW
   mov [fs:ebp+ebx],al
  @NotW:
  mov bl,dl
  shr bl,4
  jz @Nop
   mov [fs:ebp+ebx],ah
   jmp @NOP
;----------------------------- INC Reg,---
 @INC:
  xor bx,bx
  mov bl,dl
  and bl,15
  jz  @NOP
   inc [B fs:ebp+ebx]
   SETZ al
   mov [fs:ebp+ZF],al       ; Wichtig! CF wird NICHT ver„ndert!
   jmp @NOP
;----------------------------- DEC Reg
 @DEC:
  xor bx,bx
  mov bl,dl
  and bl,15
  jz  @NOP
   dec [B fs:ebp+ebx]
   SETZ al
   mov [fs:ebp+ZF],al       ; Wichtig! CF wird NICHT ver„ndert!
   jmp @NOP
;----------------------------- SHL Reg,Imm4
 @SHL:
  xor bx,bx
  mov bl,dl
  and bl,15
  jz  @NOP
  push cx
  mov cl,dl
  shr cl,4
  shl [B fs:ebp+ebx],cl
  CHECKF
  pop cx
  jmp @NOP
;----------------------------- SHR Reg,Imm4
 @SHR:
  xor bx,bx
  mov bl,dl
  and bl,15
  jz  @NOP
  push cx
  mov cl,dl
  shr cl,4
  shr [B fs:ebp+ebx],cl
  CHECKF
  pop cx
  jmp @NOP
;----------------------------- ROL Reg,Imm4
 @ROL:
  xor bx,bx
  mov bl,dl
  and bl,15
  jz  @NOP
  push cx
  mov cl,dl
  shr cl,4
  rol [B fs:ebp+ebx],cl
  SETB al
  mov [fs:ebp+CF],al       ; Wichtig! ZF wird NICHT ver„ndert!
  pop cx
  jmp @NOP
;----------------------------- ROR Reg,Imm4
 @ROR:
  xor bx,bx
  mov bl,dl
  and bl,15
  jz  @NOP
  push cx
  mov cl,dl
  shr cl,4
  ror [B fs:ebp+ebx],cl
  SETB al
  mov [fs:ebp+CF],al   ; Wichtig! ZF wird NICHT ver„ndert!
  pop cx
  jmp @NOP
;----------------------------- NEG Reg
 @NEG:
  xor bx,bx
  mov bl,dl
  and bl,15
  jz  @NOP
  neg [B fs:ebp+ebx]
  CHECKF
  jmp @NOP
;----------------------------- AND Reg,Reg
 @AND:
  xor bx,bx
  mov bl,dl
  and bl,15
  mov ah,[fs:ebp+ebx]
  mov bl,dl
  shr bl,4
  jz  @NOP
  mov al,[fs:ebp+ebx]
  and al,ah
  mov [fs:ebp+ebx],al
  CHECKF
  jmp @nop
;----------------------------- OR  Reg,Reg
 @OR :
  xor bx,bx
  mov bl,dl
  and bl,15
  mov ah,[fs:ebp+ebx]
  mov bl,dl
  shr bl,4
  jz  @NOP
  mov al,[fs:ebp+ebx]
  or  al,ah
  mov [fs:ebp+ebx],al
  CHECKF
  jmp @nop
;----------------------------- XOR Reg,Reg
 @XOR:
  xor bx,bx
  mov bl,dl
  and bl,15
  mov ah,[fs:ebp+ebx]
  mov bl,dl
  shr bl,4
  jz  @NOP
  mov al,[fs:ebp+ebx]
  xor al,ah
  mov [fs:ebp+ebx],al
  CHECKF
  jmp @nop
;----------------------------- TST Reg,Reg
 @TST:
  xor bx,bx
  mov bl,dl
  shr bl,4
  mov al,[fs:ebp+ebx]
  mov bl,dl
  and bl,15
  mov ah,[fs:ebp+ebx]
  test al,ah
  CHECKF
  jmp @nop
;----------------------------- CMP Reg,Reg
 @CMP:
  xor bx,bx
  mov bl,dl
  shr bl,4
  mov al,[fs:ebp+ebx]
  mov bl,dl
  and bl,15
  mov ah,[fs:ebp+ebx]
  cmp al,ah
  CHECKF
  jmp @nop
;----------------------------- JMPs
 @JMP:
  xor bx,bx
  cmp dl,8
  jae @okay
   mov dl,8
  @okay:
  xor dh,dh
  shl dx,1
  mov di,dx
  jmp @JMPS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @JMP_ZF1:
  xor bx,bx
  mov al,[fs:ebp+ZF]
  or  al,al
  jz  @NOP
  cmp dl,8
  jae @okayZ1
   mov dl,8
  @okayZ1:
  xor dh,dh
  shl dx,1
  mov di,dx
  jmp @JMPS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @JMP_ZF0:
  xor bx,bx
  mov al,[fs:ebp+ZF]
  or  al,al
  jnz @NOP
  cmp dl,8
  jae @okayZ0
   mov dl,8
  @okayZ0:
  xor dh,dh
  shl dx,1
  mov di,dx
  jmp @JMPS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @JMP_ZF0CF0:
  xor bx,bx
  mov al,[fs:ebp+CF]
  or  al,al
  jnz @NOP
  mov al,[fs:ebp+ZF]
  or  al,al
  jnz @NOP
  cmp dl,8
  jae @okayZC0
   mov dl,8
  @okayZC0:
  xor dh,dh
  shl dx,1
  mov di,dx
  jmp @JMPS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @JMP_CF1:
  xor bx,bx
  mov al,[fs:ebp+CF]
  or  al,al
  jz  @NOP
  cmp dl,8
  jae @okayC1
   mov dl,8
  @okayC1:
  xor dh,dh
  shl dx,1
  mov di,dx
  jmp @JMPS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @JMP_CF0:
  xor bx,bx
  mov al,[fs:ebp+CF]
  or  al,al
  jnz @NOP
  cmp dl,8
  jae @okayC0
   mov dl,8
  @okayC0:
  xor dh,dh
  shl dx,1
  mov di,dx
  jmp @JMPS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @JMP_CF1ZF1:
  xor bx,bx
  mov al,[fs:ebp+CF]
  or  al,al
  jnz @CF1
  mov al,[fs:ebp+ZF]
  or  al,al
  jz  @NOP
  @CF1:
  cmp dl,8
  jae @okayZC1
   mov dl,8
  @okayZC1:
  xor dh,dh
  shl dx,1
  mov di,dx
  jmp @JMPS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @GETSV:
  mov bx,si
  dec bx
  shl ebx,4
  add ebx,[RoboStart]
  mov al,[fs:ebx+8]
  and al,31
  xor ebx,ebx
  mov bl,dl
  and bl,15
  jz @NOP
  mov [fs:ebp+ebx],al
  jmp @NOP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @GETSD:
  mov bx,si
  dec bx
  shl ebx,4
  add ebx,[RoboStart]
  mov al,[fs:ebx+9]
  xor ebx,ebx
  mov bl,dl
  and bl,15
  jz @NOP
  mov [fs:ebp+ebx],al
  jmp @NOP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @FIRECONST:
  or dl,dl
  jz @NOP                 ; Parameter 0 darf nicht bergeben werden!
  push di
  mov [SaveSI],si
  dec si
  mov edi,esi
  shl di,4                ; DI = Add in LListVirus
  mov bx,si
  shl ebx,8
  add ebx,[MissileStart]  ; ebx: Missiles!!!
  cmp dh,03
  sete al

  shl esi,4
  add esi,[RoboStart]     ; esi: Robots!!!
  mov dh ,[fs:esi+8]
  mov ah,dh
  and ah,192              ; Save Flags
  and dh,31
  dec dh
  js @BACKFC              ; Keine Missiles mehr ?
  add dh,ah               ; Add Flags
  mov [fs:esi+8],dh

  @FindMissile:
  ;; mov dh,[fs:ebx+9]      ; ID=0 ? Dann Missile noch nicht aktiviert!
  ;------------------------- UPDATED 22.01.1998: ID-Byte copied into +08h
   mov dh,[fs:ebx+08h]      ; ID=0 ? Dann Missile noch nicht aktiviert!
   shr dh,2
   and dh,3
   or  dh,dh
   jz  @MissileFound
   add ebx,16
   inc di
  jmp @FindMissile
  @MissileFound:
  or  al,al
  jnz @AVirus
   shl edi, 2
   add edi, [LListVirus]
   mov [w fs:edi],0FFFFh
   mov [w fs:ebx+0Eh],0FFFFh
   mov [w fs:edi+2],SQNum
   xor edi,edi
  @AVirus:
  inc al
;;  mov [fs:ebx+09h],al     ; ID-Byte setzen
  ;------------------------- UPDATED 22.01.1998: ID-Byte copied into +08h
  shl al, 2
  mov [fs:ebx+08h],al     ; ID-Bits 2,3 von Byte +08h setzen
  ;------------------------- UPDATED 22.01.1998: Timer set into +09h
  mov [b fs:ebx+09h],VirusTimer

  mov [VSpeed],dl         ; Geschwindigkeit ( TEMPORR ) speichern!
  mov edx,[fs:esi]        ; Koordinaten kopieren
  mov [fs:ebx],edx        ;
  mov edx,[fs:esi+4]      ;
  mov [fs:ebx+4],edx

  mov esi,ebx             ; ESI = Missile-Block
  xor bx,bx
  mov bl,[fs:ebp+CA]
  test bl,128
  setnz al
  and bl,127
;;  mov [b fs:esi+08h], al  ; SIN = Y, BIT 0!
  ;------------------------- UPDATED 22.01.1998: Taking care of ID-Bits +08h
  or [b fs:esi+08h], al  ; SIN = Y, BIT 0!

  shl bx,1
  mov ax,[SINTable+bx]
  xor dx,dx
  mov bh,dh
  mov bl,[VSpeed]         ; Temporary!
  div bx
  mov [fs:esi+0Ch],ax

  mov bl,[fs:ebp+CA]
  add bl,64
  test bl,128
  setnz al
  and bl,127
  shl al,1
  or  [b fs:esi+08h],al   ; COS = X, BIT 1!

  shl bx,1
  mov ax,[SINTable+bx]
  xor dx,dx
  mov bh,dh
  mov bl,[VSpeed]         ; Temporary!
  div bx
  mov [fs:esi+0Ah],ax

  @BACKFC:
  xor esi,esi
  mov ebx,esi
  mov si,[SaveSI]
  pop di
  jmp @Nop


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

 @FIREREG:
  xor bx,bx
  and dl,15
  mov bl,dl
  mov dl,[fs:ebp+ebx]
  or dl,dl
  jz @NOP                 ; Parameter 0 darf nicht bergeben werden!
  push di
  mov [SaveSI],si
  dec si
  mov edi,esi
  shl di,4                ; DI = Add in LListVirus
  mov bx,si
  shl ebx,8
  add ebx,[MissileStart]  ; ebx: Missiles!!!
  cmp dh,04
  sete al
  shl esi,4
  add esi,[RoboStart]     ; esi: Robots!!!
  mov dh ,[fs:esi+8]
  mov ah,dh
  and ah,192              ; Save Flags
  and dh,31
  dec dh
  js @BACKRG              ; Keine Missiles mehr ?
  add dh,ah               ; Add Flags
  mov [fs:esi+8],dh


  @FindMissileR:
  ;; mov dh,[fs:ebx+9]      ; ID=0 ? Dann Missile noch nicht aktiviert!
  ;------------------------- UPDATED 22.01.1998: ID-Byte copied into +08h
   mov dh,[fs:ebx+08h]      ; ID=0 ? Dann Missile noch nicht aktiviert!
   shr dh,2
   and dh,3
   
   or  dh,dh
   jz  @MissileFoundR
   add ebx,16
   inc di
  jmp @FindMissileR
  @MissileFoundR:
  or  al,al
  jnz @AVirusRG
   shl edi, 2
   add edi, [LListVirus]
   mov [w fs:edi],0FFFFh
   mov [w fs:ebx+0Eh],0FFFFh
   mov [w fs:edi+2],SQNum
   xor edi,edi
  @AVirusRG:
  inc al
;;  mov [fs:ebx+09h],al
  ;------------------------- UPDATED 22.01.1998: ID-Byte copied into +08h
  shl al, 2
  mov [fs:ebx+08h],al     ; ID-Bits 2,3 von Byte +08h setzen
  ;------------------------- UPDATED 22.01.1998: Timer set into +09h
  mov [b fs:ebx+09h],VirusTimer

  mov [VSpeed],dl         ; Geschwindigkeit ( TEMPORR ) speichern!
  mov edx,[fs:esi]        ; Koordinaten kopieren
  mov [fs:ebx],edx        ;
  mov edx,[fs:esi+4]      ;
  mov [fs:ebx+4],edx

  mov esi,ebx             ; ESI = Missile-Block
  xor bx,bx
  mov bl,[fs:ebp+CA]
  test bl,128
  setnz al
  and bl,127
;;  mov [b fs:esi+08h], al  ; Bit 0!
  ;------------------------- UPDATED 22.01.1998: Taking care of ID-Bits +08h
  or [b fs:esi+08h], al  ; SIN = Y, BIT 0!

  shl bx,1                ; SIN = Y !!!
  mov ax,[SINTable+bx]
  xor dx,dx
  mov bh,dh
  mov bl,[VSpeed]         ; TEMPORARY
  div bx
  mov [fs:esi+0Ch],ax

  mov bl,[fs:ebp+CA]      ; COS = X !!!
  add bl,64
  test bl,128
  setnz al
  and bl,127
  shl al,1
  or  [b fs:esi+08h],al   ; Bit 1!

  shl bx,1
  mov ax,[SINTable+bx]
  xor dx,dx
  mov bh,dh
  mov bl,[VSpeed]         ; TEMPORARY
  div bx
  mov [fs:esi+0Ah],ax

  @BACKRG:
  xor esi,esi
  mov ebx,esi
  mov si,[SaveSI]
  pop di
  jmp @Nop

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 @SETDIR:
   push si
   dec si
   shl si, 4
   add esi,[RoboStart]
   and [b fs:esi+08h], 31

   mov bl,[fs:ebp+RA]   ;SIN = Y
   test bl,128
   setnz al
   shl al,6
   and bl,127
   or  [b fs:esi+08h], al

   shl bx,1
   mov ax,[SINTable+bx]

   xor dx,dx
   mov bh,dh
   mov bl,[fs:ebp+RS]
   or bl,bl
   jz @StandStill1      ;RS=0 -> extra Routine!

;------------------------- UPDATED 20.01.1998: Maximum Speed <> 1
   cmp bl,MaxRobSpeed
   jae @NoSpeedLimitNeeded1
    mov bl,MaxRobSpeed
   @NoSpeedLimitNeeded1:
   div bx
   mov [fs:esi+0Ch],ax

   mov bl,[fs:ebp+RA]   ;COS = X
   add bl,64
   test bl,128
   setnz al
   shl al,7
   and bl,127
   or  [b fs:esi+08h],al

   shl bx,1
   mov ax,[SINTable+bx]

   xor dx,dx
   mov bh,dh
   mov bl,[fs:ebp+RS]
;------------------------- UPDATED 20.01.1998: Maximum Speed <> 1
   cmp bl,MaxRobSpeed
   jae @NoSpeedLimitNeeded2
    mov bl,MaxRobSpeed
   @NoSpeedLimitNeeded2:

   div bx
   mov [fs:esi+0Ah],ax
   xor esi,esi
   pop si
   xor bx,bx
   jmp @Nop

   @StandStill1:
     xor eax,eax
     mov [fs:esi+0Ah],eax
     xor esi,esi
     pop si
     xor bx,bx
     jmp @NOP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

 @SCANROB:
  push cx
  push esi
  push edi
  push ebp
  push dx                     ; Wichtig

   mov bl, [fs:ebp+EA]        ; EYE-Angle in BX!
   xor bh,bh

   dec si
   shl esi,4
   add esi,[RoboStart]
   mov ax ,[fs:esi+2]
   shl eax,16
   mov ax, [fs:esi+6]         ; YYYY.XXXX
   mov esi,eax
   xor edi,edi
   mov di,[RobotNum]
   mov bp,di
   dec di
   shl edi,4
   add edi,[RoboStart]        ; ESI = X/Y, BP= COUNTER, EDI = CHECKED ROBOT

   mov [Nearest],255
   mov [RobFound],bh
   mov [DeltaX],bh
   mov [DeltaY],bh
   mov dl,bl
   and dl,0C0h
   cmp dl,bl
   jne @STANDARD_SCANR
    cmp dl,0C0h
     je @SCANR_C0
    cmp dl,080h
     je @SCANR_80
    cmp dl,040h
     je @SCANR_40
    jmp @SCANR_00
   @STANDARD_SCANR:
   test bl,bl
   setns al
   add al,78h
   mov [b cs:@Modify1],al
   and bl,127                 ; BX=0-127!
   shl bl,1
   jmp @ClearPFQ
   @ClearPFQ:

   mov cx,[ScanDif]
   @SCANROBLOOP:
     mov ax,[fs:edi+6]          ; Check dY
     sub ax,si
     rol esi,16
     jz @nodif
     cwd
     xor ax,dx
     sub ax,dx
     cmp ax,cx
     ja  @nodif

      mov ax,[fs:edi+2]         ; Check dX
      sub ax,si
      jz @nodif
      cwd
      xor ax,dx
      sub ax,dx
      cmp ax,cx
      ja @nodif

        mov cx,[fs:edi+2]
        sub cx,si                          ; WICHTIG! X ist nie gr”áer als 127
        rol esi,16
        mov ax,[fs:edi+6]
        sub ax,si
        @MODIFY1:
        jns  @AngleOkay                    ; Wird je nach Winkel JS oder JNS
            mov cx,[ScanDif]
            sub edi,16
            dec bp
            jne @SCANROBLOOP
            jmp @BackToSCR
        @AngleOkay:
         cwd
         shl ax,8
         idiv cx
         sub ax,[TAN+bx]
         js @Signed
          cmp ax,[TOL+BX]
          jbe @OKIDOKI
            mov cx,[ScanDif]
            sub edi,16
            dec bp
            jne @SCANROBLOOP
            jmp @BackToSCR
         @Signed:
          neg ax
          cmp ax,[TOL+BX-2]
          jbe @OKIDOKI
            mov cx,[ScanDif]
            sub edi,16
            dec bp
            jne @SCANROBLOOP
            jmp @BackToSCR
         @OKIDOKI:
          inc [RobFound]
          jnz @noRob256
           dec [RobFound]
          @NoRob256:
          mov dx,[fs:edi+6]
          sub dx,si
          mov ch,dl
          xor dl,dh
          sub dl,dh
          xor ax,ax                    ; DX:AX div SIN(BX)
          mov dh,ah
          div [SINTABLE+bx]
          cmp al,[Nearest]
          jbe @NEARESTROB
            mov cx,[ScanDif]
            sub edi,16
            dec bp
            jne @SCANROBLOOP
            jmp @BackToSCR
          @NEARESTROB:
           mov [Nearest],al
           mov [DeltaY],ch              ; Save Y
           mov [DeltaX],cl              ; Save X
           mov cx,[ScanDif]
           sub edi,16
           dec bp
           jne @SCANROBLOOP
           jmp @BackToSCR
    @nodif:
    rol esi,16
    sub edi,16
    dec bp
   jne @SCANROBLOOP
   @BackToSCR:
   pop dx
   pop ebp
   mov bl,dh
   and bl,0Fh
   jz @NoNum
    mov al,[RobFound]
    mov [fs:ebp+ebx],al         ; Save Num of Found Robots
   @NoNum:
   mov bl,dl
   shr bl,4
   jz @NoDeltaX
    mov al,[DeltaX]
    mov [fs:ebp+ebx],al
   @NoDeltaX:
   mov bl,dl
   and bl,0Fh
   jz @NoDeltaY
    mov al,[DeltaY]
    mov [fs:ebp+ebx],al
   @NoDeltaY:
   pop edi
   pop esi
   pop cx
   jmp @Nop                     ; End!

   ;ÄÄ Special Angles for SCANR: 00øR ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
   @SCANR_00:
   @SCANROBLOOP_00:
     mov ax,[fs:edi+6]          ; Check dY
     sub ax,si
     jnz @NoDif_00
      rol esi,16
      mov ax,[fs:edi+2]         ; Check dX
      sub ax,si
      rol esi,16
      jz  @NoDif_00             ; Eigener Robi -> raus
      cmp al,127
      ja  @NoDif_00             ; Nicht Weiter weg als 127 !
          inc [RobFound]
          jnz @noRob256_00
           dec [RobFound]
          @NoRob256_00:
          cmp al,[Nearest]
          jbe @NearestRob_00
            sub edi,16
            dec bp
            jne @SCANROBLOOP_00
            jmp @BackToSCR
          @NearestRob_00:
           mov [Nearest],al
           mov [DeltaY],ah              ; Save Y
           mov [DeltaX],al              ; Save X
    @NoDif_00:
    sub edi,16
    dec bp
   jne @SCANROBLOOP_00
   jmp @BackToSCR

   ;ÄÄ Special Angles for SCANR: 40øR ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
   @SCANR_40:
   rol esi,16
   @SCANROBLOOP_40:
     mov ax,[fs:edi+2]         ; Check dX
     sub ax,si
     jnz @NoDif_40
      rol esi,16
      mov ax,[fs:edi+6]          ; Check dY
      sub ax,si
      rol esi,16
      jz @NoDif_40
      cmp al,127
      ja  @NoDif_40
          inc [RobFound]
          jnz @noRob256_40
           dec [RobFound]
          @NoRob256_40:
          cmp al,[Nearest]
          jbe @NearestRob_40
            sub edi,16
            dec bp
            jne @SCANROBLOOP_40
            jmp @BackToSCR
          @NearestRob_40:
           mov [Nearest],al
           mov [DeltaY],al              ; Save Y
           mov [DeltaX],ah              ; Save X
    @NoDif_40:
    sub edi,16
    dec bp
   jne @SCANROBLOOP_40
   jmp @BackToSCR

   ;ÄÄ Special Angles for SCANR: 80øR ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
   @SCANR_80:
   @SCANROBLOOP_80:
     mov ax,[fs:edi+6]          ; Check dY
     sub ax,si
     jnz @NoDif_80
      rol esi,16
      mov ax,[fs:edi+2]         ; Check dX
      sub ax,si
      rol esi,16
      cmp al, -127
      jb @NoDif_80
          inc [RobFound]
          jnz @noRob256_80
           dec [RobFound]
          @NoRob256_80:
          neg ax
          cmp al,[Nearest]
          jbe @NearestRob_80
            sub edi,16
            dec bp
            jne @SCANROBLOOP_80
            jmp @BackToSCR
          @NearestRob_80:
           mov [Nearest],al
           neg al
           mov [DeltaY],ah              ; Save Y
           mov [DeltaX],al              ; Save X
    @NoDif_80:
    sub edi,16
    dec bp
   jne @SCANROBLOOP_80
   jmp @BackToSCR

   ;ÄÄ Special Angles for SCANR: C0øR ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
   @SCANR_C0:
   rol esi,16
   @SCANROBLOOP_C0:
     mov ax,[fs:edi+2]         ; Check dX
     sub ax,si
     jnz @NoDif_C0
      rol esi,16
      mov ax,[fs:edi+6]          ; Check dY
      sub ax,si
      rol esi,16
      cmp al, -127
      jb  @NoDif_C0
          inc [RobFound]
          jnz @noRob256_C0
           dec [RobFound]
          @NoRob256_C0:
          neg ax
          cmp al,[Nearest]
          jbe @NearestRob_C0
            sub edi,16
            dec bp
            jne @SCANROBLOOP_C0
            jmp @BackToSCR
          @NearestRob_C0:
           mov [Nearest],al
           neg al
           mov [DeltaY],al              ; Save Y
           mov [DeltaX],ah              ; Save X
    @NoDif_C0:
    sub edi,16
    dec bp
   jne @SCANROBLOOP_C0
   jmp @BackToSCR


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

; FUNZT EINWANDFREI !!!!

 @SCANVIRUS:
  push cx
  push esi
  push edi
  push ebp
  push dx                     ; Wichtig

   mov bl, [fs:ebp+EA]        ; EYE-Angle in BX!
   xor bh,bh
   mov [Nearest],255
   mov [RobFound],bh
   mov [DeltaX],bh
   mov [DeltaY],bh

   dec si
   mov dx,si
   mov [SAVECOUNTER],dx
   shl esi,4
   add esi,[RoboStart]

   mov bp,[fs:esi+06h]
   mov si,[fs:esi+02h]
   mov cx,si
   shl esi,16
   mov si,bp                  ; ESI = XXXX/YYYY!
   shr bp,SQSHIFT
   setz al                      ; AL = Y-DANGER
   cmp bp,YQA-1
   jne @NoY2
    mov al,2
   @NoY2:
   shl bp,SQYSHIFT
   shr cx,SQSHIFT
   setz ah
   cmp cx,YQ-1
   jne @NoX2
    mov ah,2
   @NoX2:
   add bp,cx
   shl bp,1
   mov [SQUARE],bp


   mov cl, bl
   and cl, 0C0h
   or ax,ax
   jne @Danger
    cmp bl,cl
    jne @SCANV_DEFAULT
   @Danger:
     ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     cmp bl,0C0h
     je @SCANV_C0
     jb @NoDir_C0
       cmp al,01
       jne @No1_C0
        cmp ah,02
        jne @NoBoth_C0
         push 2
         jmp @DangerFilter
        @NoBoth_C0:
        push 4
        mov [SquareTable2+2],+2
        mov ax,offset SquareTable2
        mov [w cs:@SCANMAN1+2],ax
        jmp @DangerFilter
       @No1_C0:
       cmp ah,02
       jne @SCANV_DEFAULT
        push 4
        mov [SquareTable2+2],-2*YQ
        mov ax,offset SquareTable2
        mov [w cs:@SCANMAN1+2],ax
        jmp @DangerFilter
     @NoDir_C0:
     ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     cmp bl,080h
     je @SCANV_80
     jb @NoDir_80
       cmp al,01
       jne @No1_80
        cmp ah,01
        jne @NoBoth_80
         push 2
         jmp @DangerFilter
        @NoBoth_80:
        push 4
        mov [SquareTable2+2],-2
        mov ax,offset SquareTable2
        mov [w cs:@SCANMAN1+2],ax
        jmp @DangerFilter
       @No1_80:
       cmp ah,01
       jne @SCANV_DEFAULT
        push 4
        mov [SquareTable2+2],-2*YQ
        mov ax,offset SquareTable2
        mov [w cs:@SCANMAN1+2],ax
        jmp @DangerFilter
     @NoDir_80:
     ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     cmp bl,040h
     je @SCANV_40
     jb @NoDir_40
       cmp al,02
       jne @No1_40
        cmp ah,01
        jne @NoBoth_40
         push 2
         jmp @DangerFilter
        @NoBoth_40:
        push 4
        mov [SquareTable2+2],-2
        mov ax,offset SquareTable2
        mov [w cs:@SCANMAN1+2],ax
        jmp @DangerFilter
       @No1_40:
       cmp ah,01
       jne @SCANV_DEFAULT
        push 4
        mov [SquareTable2+2],+2*YQ
        mov ax,offset SquareTable2
        mov [w cs:@SCANMAN1+2],ax
        jmp @DangerFilter
     @NoDir_40:
     ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     or bl,bl
     jz @SCANV_00
     jb @NoDir_00
       cmp al,02
       jne @No1_00
        cmp ah,02
        jne @NoBoth_00
         push 2
         jmp @DangerFilter
        @NoBoth_00:
        push 4
        mov [SquareTable2+2],+2
        mov ax,offset SquareTable2
        mov [w cs:@SCANMAN1+2],ax
        jmp @DangerFilter
       @No1_00:
       cmp ah,02
       jne @SCANV_DEFAULT
        push 4
        mov [SquareTable2+2],+2*YQ
        mov ax,offset SquareTable2
        mov [w cs:@SCANMAN1+2],ax
        jmp @DangerFilter
     @NoDir_00:


   @SCANV_DEFAULT:
    push 8                     ; 4 Squares * 2 Bytes
    shr cl,3
    xor ch,ch
    add cx,offset SQUARETABLE
    mov [w cs:@SCANMAN1+2],cx
   @DangerFilter:

   test bl,bl
   sets al
   add al,88h
   mov [b cs:@VModify+1],al
   and bl,127
   shl bl,1                   ; BX = READY!
   jmp @VClearPFQ
   @VClearPFQ:


   mov di,[LListVStart+bp]
   mov ebp,[MissileStart]
   @SCANVLOOP:
    inc di
    jz @NXTSquare
     dec di
     mov ax,di                ; Check, if own Missile!
     and edi,0FFFFh
     shl edi,4
     add edi,ebp
     shr ax,4
     sub ax,dx
     jz @VNoDif


     mov ax,[fs:edi+06h]
     sub ax,si
     @VModify:
     jns @VNoDif
     jz @VNoDif
       rol esi,16
       mov cx,[fs:edi+02h]
       sub cx,si
       rol esi,16
       jz @VNoDif

        cwd
        shl ax,8
        idiv cx
        sub ax,[TAN+bx]
        js @VSigned
         cmp ax,[TOL+BX]
         jbe @VOkay
           mov dx,[SAVECOUNTER]
           mov di,[fs:edi+0Eh]
           jmp @SCANVLOOP
        @VSigned:
         neg ax
         cmp ax,[TOL+BX-2]
         jbe @VOkay
           mov dx,[SAVECOUNTER]
           mov di,[fs:edi+0Eh]
           jmp @SCANVLOOP
        @VOkay:
         inc [RobFound]
         jnz @NoV256
          dec [RobFound]
         @NoV256:
         mov dx,[fs:edi+06h]
         sub dx,si
         mov ch,dl
         xor dl,dh
         sub dl,dh
         xor ax,ax                    ; DX:AX div SIN(BX)
         mov dh,ah
         div [SINTABLE+bx]
         cmp al,[Nearest]
         jbe @Nearer
          mov dx,[SAVECOUNTER]
          mov di,[fs:edi+0Eh]
          jmp @SCANVLOOP
         @Nearer:
          mov [Nearest],al
          mov [DeltaY],ch              ; Save Y
          mov [DeltaX],cl              ; Save X
          mov dx,[SAVECOUNTER]
          mov di,[fs:edi+0Eh]
          jmp @SCANVLOOP
     @VNoDif:
     mov di,[fs:edi+0Eh]
     jmp @SCANVLOOP
    @NXTSquare:
    pop di
    sub di,2
    jz @ENDScanVirus
     push di
     @SCANMAN1:
     mov di,[SQUARETABLE+di]
     add di,[SQUARE]
     mov di,[LListVStart+Di]
    jmp @SCANVLOOP

    ;ÄÄ³ SPECIAL CASE:  X = -> , Y = 0 ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
    @SCANV_00:
      mov di,[LListVStart+bp]
      mov ebp,[MissileStart]
      cmp ah,02h
      jne @NoProb_00
       push 2
       jmp @SCANVLOOP00
      @NoProb_00:
      push 4
      @SCANVLOOP00:
       inc di
       jz @NXTSquare00
        dec di
        mov ax,di                ; Check, if own Missile!
        and edi,0FFFFh
        shl edi,4
        add edi,ebp
        shr ax,4
        sub ax,dx
        jz @VNoDif00

        mov ax,[fs:edi+06h]
        sub ax,si
        jnz @VNoDif00
          rol esi,16
          mov cx,[fs:edi+02h]
          sub cx,si
          rol esi,16
          js @VNoDif00
            inc [RobFound]
            jnz @NoV25600
             dec [RobFound]
            @NoV25600:
            cmp cl,[Nearest]
            jbe @Nearer00
             mov di,[fs:edi+0Eh]
             jmp @SCANVLOOP00
            @Nearer00:
             mov [Nearest],cl
             mov [DeltaY],al              ; Save Y
             mov [DeltaX],cl              ; Save X
             mov di,[fs:edi+0Eh]
             jmp @SCANVLOOP00
        @VNoDif00:
        mov di,[fs:edi+0Eh]
        jmp @SCANVLOOP00
       @NXTSquare00:
       pop di
       sub di,2
       jz @ENDScanVirus
        push di
        add di,[SQUARE]
        mov di,[LListVStart+Di]
       jmp @SCANVLOOP00
    ;                                 ³
    ;ÄÄ³ SPECIAL CASE:  X = 0, Y =  v    ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
    @SCANV_40:
      mov di,[LListVStart+bp]
      mov ebp,[MissileStart]
      cmp al,02
      jne @NoProb_40
       push 2*YQ
       jmp @SCANVLOOP40
      @NoProb_40:
      push 4*YQ
      @SCANVLOOP40:
       inc di
       jz @NXTSquare40
        dec di
        mov ax,di                ; Check, if own Missile!
        and edi,0FFFFh
        shl edi,4
        add edi,ebp
        shr ax,4
        sub ax,dx
        jz @VNoDif40

        mov ax,[fs:edi+06h]
        sub ax,si
        js @VNoDif40
          rol esi,16
          mov cx,[fs:edi+02h]
          sub cx,si
          rol esi,16
          jnz @VNoDif40
            inc [RobFound]
            jnz @NoV25640
             dec [RobFound]
            @NoV25640:
            cmp al,[Nearest]
            jbe @Nearer40
             mov di,[fs:edi+0Eh]
             jmp @SCANVLOOP40
            @Nearer40:
             mov [Nearest],al
             mov [DeltaY],al              ; Save Y
             mov [DeltaX],cl              ; Save X
             mov di,[fs:edi+0Eh]
             jmp @SCANVLOOP40
        @VNoDif40:
        mov di,[fs:edi+0Eh]
        jmp @SCANVLOOP40
       @NXTSquare40:
       pop di
       sub di,2*YQ
       jz @ENDScanVirus
        push di
        add di,[SQUARE]
        mov di,[LListVStart+Di]
       jmp @SCANVLOOP40

    ;ÄÄ³ SPECIAL CASE:  X = <- , Y = 0   ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
    @SCANV_80:
      mov di,[LListVStart+bp]
      mov ebp,[MissileStart]
      cmp ah,01
      jne @NoProb_80
       push -2
       jmp @SCANVLOOP80
      @NoProb_80:
      push -4
      @SCANVLOOP80:
       inc di
       jz @NXTSquare80
        dec di
        mov ax,di                ; Check, if own Missile!
        and edi,0FFFFh
        shl edi,4
        add edi,ebp
        shr ax,4
        sub ax,dx
        jz @VNoDif80

        mov ax,[fs:edi+06h]
        sub ax,si
        jnz @VNoDif80
          rol esi,16
          mov cx,[fs:edi+02h]
          sub cx,si
          rol esi,16
          jns @VNoDif80
            inc [RobFound]
            jnz @NoV25680
             dec [RobFound]
            @NoV25680:
            mov ch,cl
            neg ch
            cmp ch,[Nearest]
            jbe @Nearer80
             mov di,[fs:edi+0Eh]
             jmp @SCANVLOOP80
            @Nearer80:
             mov [Nearest],ch
             mov [DeltaY],al              ; Save Y
             mov [DeltaX],cl              ; Save X
             mov di,[fs:edi+0Eh]
             jmp @SCANVLOOP80
        @VNoDif80:
        mov di,[fs:edi+0Eh]
        jmp @SCANVLOOP80
       @NXTSquare80:
       pop di
       add di,2
       jz @ENDScanVirus
        push di
        add di,[SQUARE]
        mov di,[LListVStart+Di]
       jmp @SCANVLOOP80

    ;ÄÄ³ SPECIAL CASE:  X = 0  , Y = ^   ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
    @SCANV_C0:
      mov di,[LListVStart+bp]
      mov ebp,[MissileStart]
      cmp al,01
      jne @NoProb_C0
       push -2*YQ
       jmp @SCANVLOOPC0
      @NoProb_C0:
      push -4*YQ
      @SCANVLOOPC0:
       inc di
       jz @NXTSquareC0
        dec di
        mov ax,di                ; Check, if own Missile!
        and edi,0FFFFh
        shl edi,4
        add edi,ebp
        shr ax,4
        sub ax,dx
        jz @VNoDifC0

        mov ax,[fs:edi+06h]
        sub ax,si
        jns @VNoDifC0
          rol esi,16
          mov cx,[fs:edi+02h]
          sub cx,si
          rol esi,16
          jnz @VNoDifC0
            inc [RobFound]
            jnz @NoV256C0
             dec [RobFound]
            @NoV256C0:
            mov ah,al
            neg ah
            cmp ah,[Nearest]
            jbe @NearerC0
             mov di,[fs:edi+0Eh]
             jmp @SCANVLOOPC0
            @NearerC0:
             mov [Nearest],ah
             mov [DeltaY],al              ; Save Y
             mov [DeltaX],cl              ; Save X
             mov di,[fs:edi+0Eh]
             jmp @SCANVLOOPC0
        @VNoDifC0:
        mov di,[fs:edi+0Eh]
        jmp @SCANVLOOPC0
       @NXTSquareC0:
       pop di
       add di,2*YQ
       jz @ENDScanVirus
        push di
        add di,[SQUARE]
        mov di,[LListVStart+Di]
       jmp @SCANVLOOPC0

  @ENDScanVirus:
  pop dx
  pop ebp
  mov bl,dh
  and bl,0Fh
  jz @VNoNum
   mov al,[RobFound]
   mov [fs:ebp+ebx],al         ; Save Num of Found Robots
  @VNoNum:
  mov bl,dl
  shr bl,4
  jz @VNoDeltaX
   mov al,[DeltaX]
   mov [fs:ebp+ebx],al
  @VNoDeltaX:
  mov bl,dl
  and bl,0Fh
  jz @VNoDeltaY
   mov al,[DeltaY]
   mov [fs:ebp+ebx],al
  @VNoDeltaY:
  pop edi
  pop esi
  pop cx
  jmp @Nop                     ; End!

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;