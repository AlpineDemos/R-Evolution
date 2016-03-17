;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; First Attempt of Robot-Evolution        < Kernel 2.o >      Syrius/ALPiNE  ;
;                                                                            ;
; MOVEvol : REvolution MOVE + XPlodepart                                     ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

MACRO BackToViruses
  sub edi,16                ; NXT one
  sub esi,4
  dec cx
 jns @MoveViruses
 jmp @EndMoveViruses
ENDM

MACRO KillVirus
  Local @NoOneThere, @NotFirstVirus2
  mov bp, [fs:edi+0Eh]
  mov ax, [fs:esi]          ; AX = Virus vor uns
  inc ax
  jnz @NotFirstVirus2       ; gibt es noch einen vor uns ?
   mov bx, [fs:esi+02h]     ; BX = letztes Square von uns
   shl bx, 1                ; an die alte Position in der LList ein
   mov [LListVStart+bx],bp  ; ( kann auch 0FFFFh sein! )
   inc bp
   jz @NoOneThere           ; Wir waren also sowieso die einzigen hier...
    dec bp
    and ebp,0FFFFh
    shl ebp,2               ; Es gibt noch einen hinter uns...
    add ebp,edx             ; Wir waren vorher die ersten, also ist jetzt
    mov [w fs:ebp],0FFFFh   ; vor ihm auch keiner mehr...
    jmp @NoOneThere
  @NotFirstVirus2:
  dec ax
  mov ebx,eax
  shl ebx,4                 ; berechne Position des Virus vor uns...
  add ebx,[MissileStart]    ; ...im VIRUS-Block
  mov [fs:ebx+0Eh],bp       ; Nach dem Virus vor uns soll der nach uns kommen
  inc bp                    ; gibt es noch einen Virus nach uns ?
  jz @NoOneThere
   dec bp                   ; ja, also tragen wir in dessen LList ein,
   and ebp,0FFFFh
   shl ebp,2                ; daá vor ihm der Virus vor uns ist...
   add ebp,edx
   mov [fs:ebp],ax
  @NoOneThere:
;; mov [b fs:edi+09h],0       ; wenn Feldrand erreicht ausschalten!
  ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
 mov [b fs:edi+08h],0       ; wenn Feldrand erreicht ausschalten!
 mov ebp,ecx
 and bp,0FFF0h
 add ebp,[RoboStart]
 inc [b fs:ebp+08h]         ; Status of Missiles erh”hen !
 BackToViruses
ENDM

MACRO KillAntiVirus
;; mov [b fs:edi+09h],0       ; wenn Feldrand erreicht ausschalten!
  ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
 mov [b fs:edi+08h],0       ; wenn Feldrand erreicht ausschalten!
 mov ebp,ecx
 and bp,0FFF0h
 add ebp,[RoboStart]
 inc [b fs:ebp+08h]         ; Status of Missiles erh”hen !
 BackToViruses
ENDM


MACRO NextRobotCheck
    sub edi,16
    dec cx
   jns @RobotCheck
   jmp @EndRoboCheck
ENDM

MACRO NextHTab
 Local @NLoop
 mov al,bh
 xor bh,bh
 @NLoop:
  inc bl
  mov ah,[HTab+bx]
  cmp ah, al
 je @NLoop
 mov bh,ah
ENDM


PROC MOVEvol

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ MOVE Viruses / AntiViruses / Update LList of Viruses
;³

 xor edi,edi
 mov eax,edi
 mov ecx,edi
 mov esi,[LListVirus]
 mov edx,esi
 mov di,[RobotNum]
 shl di,4
 dec di
 mov cx,di
 shl edi,2
 add esi,edi                      ; ESI = LListVirus
 shl edi,2
 add edi,[MissileStart]           ; EDI = Virus-Block

 @MoveViruses:
;;  mov al,[fs:edi+09h]
  ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
  mov al,[fs:edi+08h]
  shr al,2
  and al,3
  
  dec al
  jns @SomeThingThere
   BackToViruses
  @SomeThingThere:
  jnz @AVHandling
  ;------------------------- UPDATED 22.01.1998: Dec Virus-Timer +09h
  dec [b fs:edi+09h]
  jnz @NoEndVirusTimer
   Killvirus
  @NoEndVirusTimer:
  ;--------------------------------------------------------------------------;
  ; Virus-Handling ...                                                       ;
  ;--------------------------------------------------------------------------;
  mov ax, [fs:edi+0Ch]
  mov ebp,[fs:edi+04h]
  mov bl, [fs:edi+08h]
  and bl,1
  jnz  @YMMinus
   add ebp,eax
   mov [fs:edi+04h],ebp    ; Nachkomma-Stellen saven
   shr ebp,16
   cmp bp,[YField]
   jbe @YMPlus
    KillVirus
  @YMMinus:
   sub ebp,eax
   mov [fs:edi+04h],ebp    ; Nachkomma-Stellen saven
   sar ebp,16
   jns  @YMPlus
    KillVirus
  @YMPlus:
  mov ax, [fs:edi+0Ah]
  mov bl, [fs:edi+08h]
  and bl,2
  jnz  @XMMinus
   mov ebx,[fs:edi+00h]
   add ebx,eax
   mov [fs:edi+00h],ebx     ; Saven
   shr ebx,16
   cmp bx,[XField]
   jbe @XMPlus
    KillVirus
  @XMMinus:
   mov ebx,[fs:edi+00h]
   sub ebx,eax
   mov [fs:edi+00h],ebx     ; Saven
   sar ebx,16
   jns @XMPlus
    KillVirus
  @XMPlus:
  shr bp,SQSHIFT
  shl bp,SQYSHIFT
  shr bx,SQSHIFT
  add bp,bx                 ; BP  = SQUARE-NUM
  mov bx,[fs:esi+02]        ; ESI = LListVirus, EDI = VIRUS-Block
  cmp bp,bx
  jne @NewSquareV
   BackToViruses
  @NewSquareV:

  push bp
  mov [fs:esi+02h],bp       ; in unsese LList tragen wir unsere neue
  mov bp,[fs:edi+0Eh]       ; BP = Virus NACH uns
  mov ax,[fs:esi]           ; AX = Virus vor uns
  inc ax
  jnz @NotTheFirstVirus     ; gibt es noch einen vor uns ?
   shl bx,1                 ; Nach uns -> an die alte Position in der LList
   mov [LListVStart+bx],bp  ; ( kann auch 0FFFFh sein! )
   inc bp
   jz @WriteNewV            ; Wir waren also sowieso die einzigen hier...
    dec bp
    and ebp,0FFFFh
    shl ebp,2               ; Es gibt noch einen hinter uns...
    add ebp,edx             ; Wir waren vorher die ersten, also ist jetzt
    mov [w fs:ebp],0FFFFh   ; vor ihm auch keiner mehr...
    jmp @WriteNewV
  @NotTheFirstVirus:
  dec ax
  mov ebx,eax
  shl ebx,4                 ; berechne Position des Virus vor uns...
  add ebx,[MissileStart]    ; ...im VIRUS-Block
  mov [fs:ebx+0Eh],bp       ; Nach dem Virus vor uns soll der nach uns kommen
  inc bp                    ; gibt es noch einen Virus nach uns ?
  jz @WriteNewV
   dec bp                   ; ja, also tragen wir in dessen LList ein,
   and ebp,0FFFFh
   shl ebp,2                ; daá vor ihm der Virus vor uns ist...
   add ebp,edx
   mov [fs:ebp],ax
  @WriteNewV:
  pop bp
  shl bp,1
  mov bx,cx
  xchg bx,[LListVStart+bp]  ; Wir tragen in LListVStart. unsere Num ein
  mov [fs:edi+0Eh],bx       ; nach uns kommt wer vorher in der LListVStart war
  mov [w fs:esi],0FFFFh     ; Vor uns ist niemand...
  inc bx
  jz @OneThereV             ; war vor uns berhaupt wer in LListVStart ?
    dec bx                  ; Ja, also tragen wir in seine LList ein,
    and ebx,0FFFFh
    shl ebx,2               ; daá wir vor ihm sind...
    add ebx,edx
    mov [fs:ebx],cx
  @OneThereV:
  @NEXTVIRUS:
  BackToViruses
  ;--------------------------------------------------------------------------;
  ; Anti-Virus-Handling ...                                                  ;
  ;--------------------------------------------------------------------------;
  @AVHandling:
  ;------------------------- UPDATED 22.01.1998: Dec AntiVirus-Timer +09h
  dec [b fs:edi+09h]
  jnz @NoEndAVirusTimer
   KillAntivirus
  @NoEndAVirusTimer:

  mov ax, [fs:edi+0Ch]
  mov ebp,[fs:edi+04h]
  mov bl, [fs:edi+08h]
  and bl,1
  jnz  @YAMinus
   add ebp,eax
   mov [fs:edi+04h],ebp    ; Nachkomma-Stellen saven
   shr ebp,16
   cmp bp,[YField]
   jbe @YAPlus
    KillAntiVirus
  @YAMinus:
   sub ebp,eax
   mov [fs:edi+04h],ebp    ; Nachkomma-Stellen saven
   sar ebp,16
   jns  @YAPlus
    KillAntiVirus
  @YAPlus:
  mov ax, [fs:edi+0Ah]
  mov bl, [fs:edi+08h]
  and bl,2
  jnz  @XAMinus
   mov ebx,[fs:edi+00h]
   add ebx,eax
   mov [fs:edi+00h],ebx     ; Saven
   shr ebx,16
   cmp bx,[XField]
   jbe @XAPlus
    KillAntiVirus
  @XAMinus:
   mov ebx,[fs:edi+00h]
   sub ebx,eax
   mov [fs:edi+00h],ebx     ; Saven
   sar ebx,16
   jns @XAPlus
    KillAntiVirus
  @XAPlus:
  mov ax,bp
  shr bp,SQSHIFT
  shl bp,SQYSHIFT
  shr bx,SQSHIFT
  add bp,bx                 ; BP  = SQUARE-NUM
  shl bp,1
  mov bx,[fs:edi+02h]       ; ATTENTION! AX=Y, BX=X !!!
  mov bp,[LListVStart+bp]
  inc bp
  jnz @VirusThere2
   BackToViruses
  @VirusThere2:
  mov edx,[MissileStart]
  push cx
  @AVLoop:
    dec bp
    and ebp,0FFFFh
    shl ebp,4
    add ebp,edx
    mov cx,[fs:ebp+02h]
    sub cx,bx
    jz @XOkay
    dec cx
    jz @XOkay
    add cx,2
    jnz @TakeNext
    @XOkay:
      mov cx,[fs:ebp+06h]
      sub cx,ax
      jz @YOkay
      dec cx
      jz @YOkay
      add cx,2
      jnz @TakeNext
      @YOkay:
         ;;mov [b fs:edi+09h],0
         ;;mov [b fs:ebp+09h],0
  ;------------------------- UPDATED 22.01.1998: ID-Bits now in +08h
         mov [b fs:edi+08h],0
         mov [b fs:ebp+08h],0
         mov ebx,ebp
         sub ebx,edx
         shr ebx,2
         add ebx,[LListVirus]   ; EBX = Virus in LList !
         mov ax,[fs:ebx]
         inc ax
         jnz @AnotherOne
           mov bx,[fs:ebx+02h]
           shl bx,1
           mov ax,[fs:ebp+0Eh]
           mov [LListVStart+bx],ax
           inc ax
           jz @Ready
             dec ax
             shl eax,2
             add eax,[LListVirus]
             mov [w fs:eax],0FFFFh
             xor eax,eax
             jmp @Ready
         @AnotherOne:
         dec ax
         mov ebx,eax
         shl ebx,4
         add ebx,edx
         mov cx,[fs:ebp+0Eh]
         mov [fs:ebx+0Eh],cx
         inc cx
         jz @Ready
           dec cx
           mov ebx,ecx
           shl ebx,2
           add ebx,[LListVirus]
           mov [fs:ebx],ax
         @Ready:
         pop cx
         mov ebx,ecx
         and bx,0FFF0h
         add ebx,[RoboStart]
         inc [b fs:ebx+08h]
         mov ebx,ebp
         sub ebx,edx
         shr ebx,4
         and bl,0F0h
         add ebx,[RoboStart]
         mov edx,[LListVirus]
         inc [b fs:ebx+08h]
         BackToViruses
    @TakeNext:
    mov bp,[fs:ebp+0Eh]
    inc bp
  jnz @AVLoop
  pop cx
  mov edx,[LListVirus]
  sub edi,16                ; NXT one
  sub esi,4
  dec cx
 jns @MoveViruses
 @EndMoveViruses:

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Check Virus / Robi-Crash...
;³

 xor edi,edi
 mov eax,edi
 mov di,[RobotNum]
 dec di
 mov cx,di
 shl di,4
 add edi,[RoboStart]
 mov edx,[MissileStart]

 @RobotCheck:
  mov ax, [fs:edi+0Ch]
  mov ebp,[fs:edi+04h]
  mov bl, [fs:edi+08h]
  and bl,64
  jnz  @Yminus
   add ebp,eax
   jmp @Yplus
  @YMinus:
   sub ebp,eax
  @YPlus:
  mov [fs:edi+04],bp      ; Nachkomma-Stellen saven
  shr ebp,16
  and bp,[YField]
  mov [fs:edi+06],bp      ; Vorkomma-Stellen saven
  ;----------------
  mov ax, [fs:edi+0Ah]
  mov esi,[fs:edi+00h]
  mov bl, [fs:edi+08h]
  and bl,128
  jnz  @XMinus
   add esi,eax
   jmp @Xplus
  @XMinus:
   sub esi,eax
  @XPlus:
  mov [fs:edi],si         ; Nachkomma-Stellen saven
  shr esi,16
  and si,[XField]
  mov [fs:edi+02],si      ; Vorkomma-Stellen saven
  mov ax, si
  shr si,SQSHIFT
  mov bx, bp
  shr bp,SQSHIFT
  shl bp,SQYSHIFT
  add bp, si                    ; SI frei !
  shl bp, 1                     ; BP = SQUARENUM of robot
  mov si, [LListVStart+bp]
  inc si
  jnz @VirusThere               ; BP frei
   NextRobotCheck
  @VirusThere:
   dec si
   and esi,0FFFFh
   shl esi,4
   add esi,edx
   mov bp,[fs:esi+02h]
   sub bp,ax
   jnz @NxtVirus
   mov bp,[fs:esi+06h]
   sub bp,bx
   jnz @NxtVirus
    mov ebp,esi
    sub ebp,edx
    shr ebp,8
    cmp bp,cx
    je  @NxtVirus                ; Treffer...    ax und bx frei...
      push bp
      mov ebp,esi
      sub ebp,edx
      shr ebp,2
      add ebp,[LListVirus]      ; EBP = Virus-LList-Addresse
      ;; mov [b fs:esi+09h],0      ; Virus ausschalten!
  ;------------------------- UPDATED 22.01.1998: ID-Byte copied into +08h
      mov [b fs:esi+08h],0      ; Virus ausschalten!

      mov si, [fs:esi+0Eh]      ; SI = Virus NACH uns
      mov ax, [fs:ebp]          ; AX = Virus VOR uns
      inc ax
      jnz @NotFirstVirus3       ; gibt es noch einen vor uns ?
       mov bx, [fs:ebp+02h]     ; BX = letztes Square von uns
       shl bx,1                 ; an die alte Position in der LList ein
       mov [LListVStart+bx],si  ; ( kann auch 0FFFFh sein! )
       inc si
       jz @NoOneThere           ; Wir waren also sowieso die einzigen hier...
        dec si
        and esi,0FFFFh          ; SI -> ESI
        shl esi,2               ; Es gibt noch einen hinter uns...
        add esi,[LListVirus]    ; Wir waren vorher die ersten, also ist jetzt
        mov ax,[fs:esi]
        mov [w fs:esi],0FFFFh   ; vor ihm auch keiner mehr...
        jmp @NoOneThere
      @NotFirstVirus3:
      dec ax
      mov ebx,eax               ; Virus VOR uns
      shl ebx,4                 ; berechne Position des Virus vor uns...
      add ebx,edx               ; ...im VIRUS-Block
      mov [fs:ebx+0Eh],si       ; Nach dem Virus vor uns soll der nach uns kommen
      inc si                    ; gibt es noch einen Virus nach uns ?
      jz @NoOneThere
        dec si                  ; ja, also tragen wir in dessen LList ein,
        and esi,0FFFFh          ; SI -> ESI
        shl esi,2               ; daá vor ihm der Virus vor uns ist...
        add esi,[LListVirus]
        mov [fs:esi],ax
      @NoOneThere:

      xor esi,esi
      pop si
      shl esi,4
      add esi,[RoboStart]
      inc [b fs:esi+08h]        ; EBP=Winner! Status of Missiles erh”hen !
      mov al,[DefDec]
      sub [fs:edi+09h],al
      jc @DNACopy
         NextRobotCheck
      @DNACopy:                ; ou, ou, den hat's erwischt ;)
      Call Random
      and ax,[XField]
      mov [fs:edi+02h],ax
      Call Random
      and ax,[YField]
      mov [fs:edi+06h],ax
      xor eax,eax
      mov al,[fs:esi+09h]
      add al,[DefInc]
      jnc @NoOverFlow
       mov al,255
      @NoOverFlow:
      mov [fs:esi+09h],al      ; Inc Winner-DStatus
      mov [b fs:edi+09h],0FFh  ; Dem Looser sein DStatus auf FFh
      mov ax, [fs:esi+0Eh]     ; Farb-Word
      mov [fs:edi+0Eh],ax
      mov ebp,edi
      mov ebx,[RoboStart]
      sub ebp,ebx
      sub esi,ebx
      shl ebp,5
      shl esi,5
      mov ebx, [DNAStart]
      add ebx, 16              ; = 1. Instruction
      add ebp,ebx
      add esi,ebx
      dec [MCounter]
      jns @Mutate

       mov al, [MutationTimes]
       mov [MCounter],al

        @CleanCopy:
        mov bl, 248
        @DNALoop:
         mov ax,[fs:esi]
         mov [fs:ebp],ax
         add ebp,2
         add esi,2
         dec bl
        jnz @DNALoop
        NextRobotCheck

      ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
      ; Mutations!                                                          ;
      ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
      @Mutate:
      inc [MutNum]
      push cx

      Call Random
      and al,MutPerRobot

      mov cl,al           ; cl = X -> -1
      xor bh,bh
      mov ch,bh           ; dl = 0 -> X+1
      @GenerateTab:
       Call Random
       mov bl,ch
       or  bl,bl
        @MoveLoop:
         jz @EndMoveLoop
         mov ah,[HTab+bx-1]
         cmp ah,al
         jbe @EndMoveLoop
         mov [HTab+bx],ah
         dec bl
        jmp @MoveLoop
        @EndMoveLoop:
        mov [HTab+bx],al
       inc ch
       dec cl
      jns @GenerateTab
      mov bl,ch
      mov [HTab+bx],0h
      xor bx,bx
      mov bh,[HTab]
      mov cl, 248
      xor ch,ch
      @DNALoop_Mutate:
       cmp ch,bh
       je @MutationON
        mov ax,[fs:esi]
        mov [fs:ebp],ax
        add ebp,2
        add esi,2
       inc ch
       dec cl
      jne @DNALoop_Mutate
      pop cx
      xor eax,eax
      NextRobotCheck

      @MutationON:
      call Random
      and al,3

       jg  @AddMut
        Call Random
        push bx
        mov bx,ax
        and bx,NumOpcodes
        Call Random
        mov ah,[InstructionTable+bx]
        pop bx
        mov [w fs:ebp], ax
        NextHTab
        add ebp,2
        add esi,2
        inc ch
        dec cl
        jne @DNALoop_Mutate
        pop cx
        xor eax,eax
        NextRobotCheck

       @AddMut:
       dec al
       jnz @SubMut
        Call Random
        push bx
        mov bx,ax
        and bx,NumOpcodes
        Call Random
        mov ah,[InstructionTable+bx]
        pop bx
        mov [w fs:ebp],ax
        NextHTab
        add ebp,2
        inc ch
        dec cl
        jne @DNALoop_Mutate
        pop cx
        xor eax,eax
        NextRobotCheck

       @SubMut:
        add esi,2
        NextHTab
        inc ch
        dec cl
        jne @DNALoop_Mutate
        pop cx
        xor eax,eax
        NextRobotCheck

   @NxtVirus:
   mov si,[fs:esi+0Eh]
   inc si
  jnz @VirusThere

  sub edi,16
  dec cx
 jns @RobotCheck
 @EndRoboCheck:

 RET
ENDP

