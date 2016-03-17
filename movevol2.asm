;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; First Attempt of Robot-Evolution        < Kernel 2.o >      Syrius/ALPiNE  ;
;                                                                            ;
; MOVEvol : REvolution MOVE + XPlodepart                                     ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

MACRO EMOVSD
 db 67h
 movsd
ENDM

MACRO BackToViruses
 sub ebx,16
 dec si
 jns @VirusLoop
 jmp @EndVirusLoop
ENDM

MACRO BackToAntiViruses
    sub ebx,16
    dec si
    jns @AntiVirusLoop
    Ret
ENDM

PROC MOVEvol
 les di,[ChainRobotPos]
 mov eax,0FFFFFFFFh
 mov cx,SQUARE/4
 rep stosd              ; Clear Buffer with Current Chain-End.

 xor eax,eax
 mov esi,eax
 mov edi,[RoboStart]
 mov cx, [RobotNum]
 dec cx
 mov si,cx
 shl si,4
 add esi,[RoboStart]
 @MOVERobots:
  mov ax, [fs:esi+0Ch]
  mov ebx,[fs:esi+04h]
  mov bl, [fs:esi+08h]
  and bl,64
  jnz  @Yminus
   add ebx,eax
   jmp @Yplus
  @YMinus:
   sub ebx,eax
  @YPlus:
  mov [fs:esi+04],bx     ; Nachkomma-Stellen saven
  shr ebx,16
  and bx,[YField]
  mov [fs:esi+06],bx  ; Vorkomma-Stellen saven
  shl bx,2
  ;----------------
  mov ax, [fs:esi+0Ah]
  mov edx,[fs:esi+00h]
  mov bl, [fs:esi+08h]
  and bl,128
  jnz  @XMinus
   add edx,eax
   jmp @Xplus
  @XMinus:
   sub edx,eax
  @XPlus:
  mov [fs:esi],dx  ; Nachkomma-Stellen saven
  shr edx,16
  and dx,[XField]
  mov [fs:esi+02],dx  ; Vorkomma-Stellen saven
  ;-----------------
  xor ebp,ebp
  shr dx,5
  xor bl,bl
  shr bx,1
  add bx,dx
  mov bp,[ChainRobot+BX]
  mov [ChainHELP+BX],CX
  inc bp
  jnz @NoNewField
   mov [ChainRobot+BX],CX
   sub esi,16
   dec cx
   JNS @MOVERobots
   jmp @EndMoveRobots
  @NoNewField:
  mov bp,[ChainHELP+BX]
  shl ebp,4
  add ebp,edi
  mov [fs:EBP+0Eh],CX
  mov [w fs:esi+0Eh],0FFFFh
  sub esi,16
  dec cx
 JNS @MOVERobots
 @EndMoveRobots:

 lea di,[ChainVirus]
 mov eax,0FFFFFFFFh
 mov cx,SQUARE/4
 rep stosd              ; Clear Buffer with Current Chain-End.

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³                                           > EBX: Current Virus...
;³ MOVE-Virus / CheckRobots...               > EDI: Current Robot...
;³                                           > eSI: Counter of Viruses 0-? !
;³                                           > ECX: RoboStart
;³                                           > BP : X of Virus
;³                                           > DX : Y of Virus

 xor ebx,ebx
 mov eax,ebx                    ; High-Word of EAX ALWAYS 0 !!!
 mov edi,ebx
 mov bx,[RobotNum]
 shl bx,4
 dec bx         ; 1Fh
 mov esi,ebx                    ; SI = 0-? !!!
 push si
 shl ebx,4                      ; *16Viruses*16 Byte per Virus
 add ebx,[MissileStart]
 push ebx
 mov ecx,[RoboStart]

 @VirusLoop:
  ;; mov al,[fs:ebx+09h]          ; Is it a Virus ?
  ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
   mov al,[fs:ebx+08h]          ; Is it a Virus ?
   shr al,2
   and al,3

   dec al
   jns @Existing1
     BackToViruses
   @Existing1:
   jnz @NoRobotThere            ; No Virus, but Antivirus, so ignore

   mov di,[fs:ebx+04h]
   mov dx,di                    ; û DX = Y
   and di,0FFC0h
   mov ax,[fs:ebx+02h]
   mov bp,ax                    ; û BP = X
   shr ax,6
   add di,ax                    ; DI = NUM!!!
   shl di,1                     ; *Word
   mov di,[ChainRobot+DI]
   inc di
   jz @NoRobotThere
    @RCheckLoop:
     dec di
     shl edi, 4
     add edi, ecx
     mov ax,[fs:edi+04h]
     sub ax,dx
     jnz @NXTRobot
      mov ax,[fs:edi+02h]
      sub ax,bp
      jnz @NXTRobot
       mov ax,si
       and si,0FFF0h
       add esi,ecx
       cmp esi,edi
       je @NXTRobot2            ; Ab hier sind EDX und EBP wieder frei!
         ;; mov [b fs:ebx+09h],0   ; Deactivate Virus
         ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
         mov [b fs:ebx+08h],0   ; Deactivate Virus

         inc [b fs:esi+08h]     ; Inc VStatus of Winner
         mov dl,[DefDec]
         sub [b fs:edi+09h],dl  ; Dec DStatus of Looser
         js @DNACopy
          xor esi,esi
          mov si,ax
          BackToViruses
         @DNACopy:
         mov [b fs:edi+09h],0FFh  ; Restore DStatus of Looser
         sub edi,ecx
         sub esi,ecx
         shl edi,5
         shl esi,5
         mov ebp,[DNAStart]
         add ebp,16
         add edi,ebp
         add esi,ebp
         mov bp,124
         @DNALoop:
          mov edx,[fs:esi]
          mov [fs:edi],edx
          dec bp
         jne @DNALoop
         xor esi,esi            ; End, Restore needed Regs, jmp back
         mov si,ax
         sub ebx,16
         dec si
         jns @VirusLoop
         jmp @EndVirusLoop
       @NXTRobot2:
       xor esi,esi
       mov si,ax
     @NXTRobot:
     mov di,[fs:edi+0Eh]
     and edi,0FFFFh
     inc di
    jnz @RCheckLoop
   @NoRobotThere:

  ; NEEDED Registers: EBX, ESI, ECX

  mov ax, [fs:ebx+0Ch]
  mov ebp,[fs:ebx+04h]
  mov dl, [fs:ebx+08h]
  and dl,1
  jnz  @YMminus
   add ebp,eax
   mov [fs:ebx],ebp        ; Nachkomma-Stellen saven
   shr ebp,16
   cmp bp,[XField]
   jb  @YMPlus
   ;; mov [b fs:ebx+09h],0   ; wenn den Feldrand erreicht ausschalten!
    ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
    mov [b fs:ebx+08h],0   ; wenn den Feldrand erreicht ausschalten!

    mov ebp,esi
    and bp,0FFF0h
    add ebp,ecx
    inc [b fs:ebp+08h]     ; Status of Missiles erh”hen !
    BackToViruses
  @YMMinus:
   sub ebp,eax
   mov [fs:ebx],ebp        ; Nachkomma-Stellen saven
   sar ebp,16
   jns  @YMPlus
    ;; mov [b fs:ebx+09h],0   ; wenn den Feldrand erreicht ausschalten!
    ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
    mov [b fs:ebx+08h],0   ; wenn den Feldrand erreicht ausschalten!
    mov ebp,esi
    and bp,0FFF0h
    add ebp,ecx
    inc [b fs:ebp+08h]     ; Status of Missiles erh”hen !
    BackToViruses
  @YMPlus:
  mov ax, [fs:esi+0Ah]
  mov edx,[fs:esi+00h]
  mov dl, [fs:esi+08h]
  and dl,1
  jnz  @XMMinus
   add edx,eax
   mov [fs:ebx+04],edx     ; Saven
   shr edx,16
   cmp dx,[YField]
   jb @XMPlus
    ;; mov [b fs:ebx+09h],0   ; wenn den Feldrand erreicht ausschalten!
    ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
    mov [b fs:ebx+08h],0   ; wenn den Feldrand erreicht ausschalten!
    mov ebp,esi
    and bp,0FFF0h
    add ebp,ecx
    inc [b fs:ebp+08h]     ; Status of Missiles erh”hen !
    BackToViruses
  @XMMinus:
   sub edx,eax
   mov [fs:ebx+04],edx     ; Saven
   sar edx,16
   jns @XMPlus
    ;; mov [b fs:ebx+09h],0   ; wenn Feldrand erreicht ausschalten!
    ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
    mov [b fs:ebx+08h],0   ; wenn Feldrand erreicht ausschalten!
    mov ebp,esi
    and bp,0FFF0h
    add ebp,ecx
    inc [b fs:ebp+08h]     ; Status of Missiles erh”hen !
    BackToViruses
  @XMPlus:
   ;; mov al,[fs:ebx+09h]
   ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
   mov al,[fs:ebx+08h]
   shr al,2

   dec al
   jz @GetChained
     BackToViruses
   @GetChained:
   and bp, 0FFC0h
   shr dx, 6
   add bp,dx
   shl bp,1
   mov di,[ChainHELP+BP]
   mov [ChainHELP+BP],SI
   inc di
   jnz @NoNewFieldV
     mov [ChainVirus+BP],SI
     BackToViruses
   @NoNewFieldV:
   dec di
   shl edi,4
   add edi,[MissileStart]
   mov [fs:edi+0Eh],SI
   mov [w fs:ebx+0Eh],0FFFFh
   xor edi,edi
   sub ebx,16
   dec si
 jns @VirusLoop
 @EndVirusLoop:

 pop ebx        ; Wieso etwas berechnen, was man schon mal berechnet hat ? :-)
 pop si
 mov ecx,[MissileStart]
 @AntiVirusLoop:
   ;; mov al,[fs:ebx+09h]          ; Is it a Virus ?
   ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
   mov al,[fs:ebx+08h]          ; Is it a Virus ?
   shr al,2

   dec al
   jnz @Existing2
    BackToAntiViruses
   @Existing2:
   jnz @OkAV
    BackToAntiViruses
   @OkAV:
   mov di,[fs:ebx+04h]
   mov dx,di                    ; û DX = Y
   and di,0FFC0h
   shl di,1
   mov ax,[fs:ebx+02h]
   mov bp,ax                    ; û BP = X
   shr ax,5
   add di,ax                    ; DI = NUM!!!
   mov di,[ChainVirus+DI]
   inc di
   jnz @Vloop
    BackToAntiViruses
    @VLoop:
     dec di
     shl edi, 4
     add edi, ecx
     mov ax,[fs:edi+04h]
     sub ax,dx
     jnz @NXTVirus
      mov ax,[fs:edi+02h]
      sub ax,bp
      jnz @NXTVirus
       mov ax,si
       mov edx,[RoboStart]
       and si,0FFF0h
       add esi,edx
       ;mov [b fs:ebx+09h],0   ; Deactivate Virus
       ;mov [b fs:edi+09h],0   ; Deactivate Virus
   ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
       mov [b fs:ebx+08h],0   ; Deactivate Virus
       mov [b fs:edi+08h],0   ; Deactivate Virus

       sub edi, ecx
       shr edi,2
       and di,0FF00h
       add edi,edx
       inc [b fs:esi+08h]     ; Inc VStatus
       inc [b fs:edi+08h]     ; Inc VStatus
       xor esi,esi            ; End, Restore needed Regs, jmp back
       mov si,ax
       BackToAntiViruses
     @NXTVirus:
     mov di,[fs:edi+0Eh]
     and edi,0FFFFh
     inc di
    jnz @VLoop
   @NoVirusThere:

   sub ebx,16
   dec si
 jns @AntiVirusLoop


 RET
ENDP




 mov edx,[RoboStart]
 xor edi,edi
 mov di,[RobotNum]
 shl di,4
 dec di
 mov cx,di
 shl edi,4
 add edi,[MissileStart]
 @VirusCheckRobot:
  ;; mov al,[fs:edi+09h]
  ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
  mov al,[fs:edi+08h]
  shr al,2

  dec al
  jnz @NoVirus          ; kein Antivirus, kein Virus...
    xor ebp,ebp
    mov bp,[fs:edi+04h]
    mov si,bp                   ;SI = Y
    shr bp,SQSHIFT
    shl bp,SQYSHIFT
    mov ax,[fs:edi+02h]
    mov bx,ax                   ;BX = X
    shr ax,SQSHIFT
    add bp,ax
    shl bp,1
    mov bp,[ChainRStart+bp]
    inc bp
    jz @NoVirus
    @CheckRobotChain:
     shl ebp,4
     add ebp,edx                ; EBP = Destination-Robot
     mov ax,[fs:ebp+04h]
     sub ax, si
     jz @YOkay
      sub edi,16
      dec cx
      jns @VirusCheckRobot
      jmp @EndVirusCheck
     @YOkay:
     mov ax,[fs:ebp+02h]
     sub ax,bx
     jz @XOkay
      sub edi,16
      dec cx
      jns @VirusCheckRobot
      jmp @EndVirusCheck
     @XOkay:                    ; Treffer :) , ab hier bx und si frei !
       xor esi,esi
       mov si,cx
       and si,0FFF0h
       add esi,edx              ; ESI = Source-Robot
       cmp [fs:esi+02h],bp
       jne @NoOwnRobi
        sub edi,16
        dec cx
        jns @VirusCheckRobot
        jmp @EndVirusCheck
       @NoOwnRobi:

          xor ebx,ebx
          mov bx, [fs:esi+02h]      ; BX = letztes Square von uns
          mov ax, [fs:esi]          ; AX = Virus vor uns
          inc ax
          jnz @NotFirstVirus2       ; gibt es noch einen vor uns ?
           mov ax,[fs:edi+0Eh]      ; nein, trage den nach uns...
           shl bx,1                 ; an die alte Position in der Chaintabelle ein
           mov [ChainRStart+bx],ax  ; ( kann auch 0FFFFh sein! )
           mov bx,ax
           inc ax
           jz @NoOneThere           ; Wir waren also sowieso die einzigen hier...
           shl bx,2                 ; Es gibt noch einen hinter uns...
           add ebx,edx              ; Wir waren vorher die ersten, also ist jetzt
           mov [w fs:ebx],0FFFFh    ; vor ihm auch keiner mehr...
           jmp @NoOneThere
          @NotFirstVirus2:
          dec ax
          mov bx,ax
          push bx
          shl bx,4                  ; berechne Position des Virus vor uns...
          add ebx,[MissileStart]    ; ...im VIRUS-Block
          mov ax,[fs:edi+0Eh]       ; AX = Virus nach uns
          mov [fs:ebx+0Eh],ax       ; Nach dem Virus vor uns soll der nach uns kommen
          xor ebx,ebx
          mov bx,ax                 ; BX = Virus nach uns
          pop ax
          inc bx                    ; gibt es noch einen Virus nach uns ?
          jz @NoOneThere
           dec bx                   ; ja, also tragen wir in dessen Chaintable ein,
           shl ebx,2                ; daá vor ihm der Virus vor uns ist...
           add ebx,edx
           mov [fs:ebx],ax
          @NoOneThere:

       ;;mov [fs:edi+09h], 0
       ;------------------------- UPDATED 22.01.1998: ID-Byte now in +08h
       mov [fs:edi+08h], 0

       inc [b fs:esi+08h]       ; Inc VStatus of Source-Robot
       mov al,[DefDec]
       sub [fs:ebp+09h],al
       js @DNACopy
        sub edi,16
        dec cx
        jns @VirusCheckRobot
        jmp @EndVirusCheck
       @DNACopy:                ; ou, ou, den hat's erwischt ;)
       mov al,[fs:esi+09h]
       add al,[DefInc]
       jnc @NoOverFlow
        mov al,255
       @NoOverFlow:
       mov [fs:esi+09h],al    ; Dem Winner sein DStatus ein biáchen auftanken
       mov [b fs:ebp+09h],0FFh  ; Dem Looser sein DStatus auf FFh
       sub ebp,edx
       sub esi,edx
       shl ebp,5
       shl esi,5
       mov ebx, [DNAStart]
       add ebx, 16              ; = 1. Instruction
       add ebp,ebx
       add esi,ebx
       mov bx, 247
       @DNALoop:
        mov ax,[fs:esi]
        mov [fs:ebp],ax
        add esi,2
        add ebp,2
        dec bx
       jns @DNALoop
  @NoVirus:
  sub edi,16
  dec cx
 jns @VirusCheckRobot
 @EndVirusCheck:


 @SCANMIS:
  push cx
  push esi
  push edi
  push ebp
  push dx                     ; Wichtig

   mov [Nearest],255
   xor bh,bh
   mov bl, [fs:ebp+EA]        ; EYE-Angle in BX!
   test bl,bl
   sets al
   add al,88h
   mov [b cs:@Modify1_M+1],al
   sub al,10h
   mov [b cs:@Modify2_M],al
   mov [b cs:@Modify3_M],al
   and bl,127                 ; BX=0-127!
   shl bl,1
   mov ax,si
   shl ax,4
   mov [w cs:@Modify4_M+2],ax
   jmp @ClearPFQ2
   @ClearPFQ2:
   dec si
   shl esi,4
   add esi,[RoboStart]
   mov ax ,[fs:esi+2]
   shl eax,16
   mov ax, [fs:esi+6]         ; YYYY.XXXX
   mov esi,eax

   xor edi,edi
   mov eax,edi
   mov [RobFound],al
   mov [DeltaX],al
   mov [DeltaY],al
   mov di,[RobotNum]
   shl di,4
   mov bp,di
   dec di
   shl edi,4
   add edi,[MissileStart]    ; ESI = X/Y, BP= COUNTER, EDI = CHECKED ROBOT
   mov cx,[ScanDif]

  ;-------------------------------------
  @MissileLoop:
   @Modify4_M:
   cmp bp, 0746h
   je  @DummyJump_M
     mov ax,[w fs:edi+02]

     cmp [b fs:edi+9],0
     je @NextMissile            ; Missile not active ?

     mov ax,[fs:edi+6]          ; Check dY
     sub ax,si
     rol esi,16
     cwd
     xor ax,dx
     sub ax,dx
     cmp ax,cx
     ja  @Nodif_M

      mov ax,[fs:edi+2]         ; Check dX
      sub ax,si
      cwd
      xor ax,dx
      sub ax,dx
      cmp ax,cx
      ja @Nodif_M

       mov cx,[fs:edi+2]
       sub cx,si                         ; WICHTIG! X ist nie gr”áer als 127
       jz @CheckForX0_M
       rol esi,16
       mov ax,[fs:edi+6]
       sub ax,si
       jz @CheckForY0_M
       @MODIFY1_M:
       js  @RestoreRegs_M                ; Wird je nach Winkel JS oder JNS
        cwd
        shl ax,8
        idiv cx
        sub ax,[TAN+bx]
        js @Signed_M
         cmp ax,[TOL+BX]
         ja @RestoreRegs_M
         jmp @OKIDOKI_M
        @Signed_M:
         neg ax
         cmp ax,[TOL+BX-1]
         ja @RestoreRegs_M
        @OKIDOKI_M:
         inc [RobFound]
         jnz @noRob256_M
          dec [RobFound]
         @NoRob256_M:
         mov dx,[fs:edi+6]
         sub dx,si
         mov ch,dl
         xor dl,dh
         sub dl,dh
         xor ax,ax                    ; DX:AX div SIN(BX)
         mov dh,ah
         div [SINTABLE+bx]
         cmp al,[Nearest]
         ja @RestoreRegs_M
          mov [Nearest],al
          mov [DeltaY],ch              ; Save Y
          mov [DeltaX],cl              ; Save X
          jmp @RestoreRegs_M
    @Nodif_M:
    rol esi,16

    @NextMissile:
   sub edi,16
   dec bp
  jne @MissileLoop
  jmp @EndMissiles
  @DummyJump_M:
   sub edi,256
   sub bp,16
  jne @MissileLoop
  jmp @EndMissiles


   @CheckForY0_M:
     or bl,bl
     jne @RestoreRegs_M
     or cl,cl
     @MODIFY2_M:
     js @RestoreRegs_M
      xor cl,ch
      sub cl,ch
      inc [RobFound]
      jnz @noRob256_2_M
       dec [RobFound]
      @NoRob256_2_M:
      cmp cl,[Nearest]
      ja @RestoreRegs_M
       mov [Nearest],cl
       mov [DeltaX],cl              ; Save X
       mov [DeltaY],al              ; Save Y
      jmp @RestoreRegs_M
   @CheckForX0_M:
     rol esi,16
     cmp bl,80h
     jne @RestoreRegs_M
     mov ax,[fs:edi+6]
     sub ax,si
     jz @RestoreRegs_M
     @MODIFY3_M:
     js @RestoreRegs_M
     xor al,ah
     sub al,ah
     inc [RobFound]
     jnz @noRob256_3_M
      dec [RobFound]
     @NoRob256_3_M:
     cmp al,[Nearest]
     ja @RestoreRegs_M
      mov [Nearest],al
      mov [DeltaX],cl              ; Save X
      mov [DeltaY],al              ; Save Y
   @RestoreRegs_M:
    mov cx,[ScanDif]
   sub edi,16
   dec bp
   jne @MissileLoop

  @EndMissiles:
  pop dx
  pop ebp
  mov bl,dh
  and bl,0Fh
  jz @NoNum_M
   mov al,[RobFound]
   mov [fs:ebp+ebx],al         ; Save Num of Found Robots
  @NoNum_M:
  mov bl,dl
  shr bl,4
  jz @NoDeltaX_M
   mov al,[DeltaX]
   mov [fs:ebp+ebx],al
  @NoDeltaX_M:
  mov bl,dl
  and bl,0Fh
  jz @NoDeltaY_M
   mov al,[DeltaY]
   mov [fs:ebp+ebx],al
  @NoDeltaY_M:
  pop edi
  pop esi
  pop cx
  jmp @Nop                     ; End!
