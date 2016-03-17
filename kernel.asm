;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; First Attempt of Robot-Evolution        < Kernel 1.o >      Syrius/ALPiNE  ;
;                                                                            ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
B EQU BYTE PTR
W EQU WORD PTR
D EQU DWORD PTR

;-----------------------------------
 IP = 00  ;Instruction Pointer
 R1 = 01
 R2 = 02
 R3 = 03
 R4 = 04
 R5 = 05
 R6 = 06
 R7 = 07
 R8 = 08
 R9 = 09
 EA = 10  ;Eye-Angle ( for SCAN )
 CA = 11  ;Cannon-Angle
 RA = 12  ;Robot-Angle
 RS = 13  ;Robot-Speed
 CF = 14  ;Carry-Flag
 ZF = 15  ;Zero-Flag
;-----------------------------------

IDEAL
P386
GROUP DATA IData, UData
ASSUME CS:Code, DS:Data

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
SEGMENT CODE
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC Random
  push edx
  mov eax,1107030247
  mul [seed]
  add eax,97177
  mov [seed],eax
  shr eax,15
  pop edx
  ret
 ENDP

 PROC Random2
  push bx       ; Test-Proc, definierte RAND-Werte
  mov bx, [Count]
  mov ax, [RANDOMNums+bx]
  add bx,2
  mov [Count],bx
  pop bx
  Ret
 ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC BuildLLists          ; EBX Is NEEDED !
 mov ax,ds
 mov es,ax
 mov eax,0FFFFFFFFh
 lea di,[LListVStart]
 mov cx,SQNUM*2/4
 rep stosd                     ; Okay, LListRStart + LListVStart inited...
 mov [LListVirus],ebx
 xor eax,eax
 mov ax,[RobotNum]
 shl eax,4
 add ebx,eax
 Ret
ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC StartREvolution
  mov [RoboStart],ebx
  mov cx,[RobotNum]
  xor dx,dx

  @RoboPosition:       ; Random Positions
   Call Random
   and ax,[XField]

   mov [fs:ebx],dx     ; X-Vorkomma
   add ebx,2
   mov [fs:ebx],ax     ; X-Nachkomma
   add ebx,2
   Call Random
   and ax,[YField]

   mov [fs:ebx],dx     ; Y-Vorkomma
   add ebx,2
   mov [fs:ebx],ax     ; Y-Nachkomma
   add ebx,2
   mov al,[Missiles]
   mov [fs:ebx],al              ; MS: alle 16 Raketen noch abschuábereit...
   inc ebx
   mov [B fs:ebx],255                                ; DS: voll aufgetankt...
   inc ebx
   mov [fs:ebx],dx
   add ebx,2
   mov [fs:ebx],dx
   add ebx,2
   mov [fs:ebx],dx
   add ebx,2

   dec cx
  jne @RoboPosition
  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [MissileStart],ebx
  mov cx,[RobotNum]
  xor eax,eax
  @RoboMissiles:     ; Random Positions
   mov dl,16
   @Missiles:
    mov [fs:ebx+00],eax
    mov [fs:ebx+04],eax
    mov [fs:ebx+08],eax
    mov [fs:ebx+12],eax
    add ebx,16
    dec dl
   jne @Missiles
   dec cx
  jne @RoboMissiles
  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [DNAStart],ebx
  mov esi,[RoboStart]
  mov cx,[RobotNum]
  @RoboDNA:
   mov [b fs:ebx],8 ; IP immer 16 BYTES! : Erste Instruction = 16 ( vorher Regs! )
   inc ebx
   xor al,al
   mov dl,11                            ; Regs: R1-R9,EA,CA,RA,RS,CF,ZF auf 0
   @Regs0:
    mov [fs:ebx],al
    inc ebx
    dec dl
   jne @Regs0

   call Random                    ; RA

   xor ah,ah
   mov bp,ax                      ; sin...
   mov [fs:ebx],al
   inc ebx
   add al,64                      ; cos...  WRAP-AROUND!!! Deswegen AL
   mov di,ax

   test di,128                    ; Setze INCX = COS
   jz  @NoMXI
    or [b fs:esi+08h],128
    and di,127
   @NoMXI:
   shl di,1
   mov di,[SINTable+DI]

   test bp,128                    ; Setze INCY = SIN
   jz  @NoMYI
    or [b fs:esi+08h],64
    and bp,127
   @NoMYI:
   shl bp,1
   mov bp,[SINTable+bp]

   call Random                    ; RS

   mov [fs:ebx],al
   inc ebx

   or al,al
   jz @StandStill                 ; bei 0 Stillstand

   xor ah,ah

   xor  dx,dx
   xchg ax,di
   div  di                        ; Endgltiger INCX
   mov [fs:esi+0Ah],ax

   xor dx,dx
   mov ax,bp
   div di
   mov [fs:esi+0Ch],ax

   @StandStill:

   xor ax,ax
   mov [fs:ebx],ax
   add ebx,2
   push si
   lea si, [DNAStandardCode]        ; Okay, jetzt noch DNA einprogrammieren..
   mov dx,248                                            ; ( 496 Bytes Code )
   @DNATransfer:
    lodsw
    mov [fs:ebx],ax
    add ebx,2
    dec dx
   jne @DNATransfer     ; Okay, Robot fertig initialisiert, Ready for Mission
   pop si
   add esi, 16
   dec cx
  jne @RoboDNA
  Call BuildLLists
  call InitLList
  mov eax,ebx
  ret
 ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

 MACRO CheckF        ; Check CF and ZF
  SETB al
  mov [fs:ebp+CF],al
  SETZ al
  mov [fs:ebp+ZF],al
 ENDM

PROC WriteHex
 push ax
 @lp2:
  mov al,dl
  and al,15
  add al,'0'
  cmp al,'9'
  jbe @nohex
   add al,'A'-'9'-1
  @nohex:
  mov [B es:di+bx-2],al
  shr edx,4
  sub bx,2
 jne @lp2
 pop ax
 Ret
ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC InitLList
 pushad
 push es
 mov ax,ds
 mov es,ax
 mov eax, -1
 lea di,[LListVStart]
 mov cx,SQNum*2/4
 rep stosd                  ; Clear LListVStart
 xor edi,edi
 mov di,[RobotNum]
 shl di,4
 dec di
 mov esi,edi
 mov cx,di
 shl edi,4
 shl esi,2
 add edi,[MissileStart]
 add esi,[LListVirus]
 mov eax, SQNum*65536+0FFFFh
 @VClear:
  mov [fs:esi],eax
  mov [fs:edi+0Eh],ax
  sub edi,16
  sub esi,4
  dec cx
 jns @VClear
 pop es
 popad
 Ret
ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC WATCH
 PUSHAD
 mov dx,0B800h
 mov es,dx
 xor di,di

 xor edx,edx
 mov dx,ax
 mov di,12*160+42
 mov bx,4
 call WriteHex           ;Number of Robot

 mov esi,eax
 shl esi,4
 add esi,[RoboStart]     ;esi=RobotCode!

 mov edx,[fs:esi]        ;X
 mov di, 14*160+66
 mov bx, 8
 call WriteHex
 mov di, 14*160+56
 mov bx, 8
 call WriteHex

 mov edx,[fs:esi+4]      ;Y
 mov di,15*160+66
 mov bx, 8
 call WriteHex
 mov di, 15*160+56
 mov bx, 8
 call WriteHex

 mov dl,[fs:esi+8]       ;Flags/ SV
 mov di, 16*160+56
 test dl,128
 setnz dh
 add dh,'0'
 mov [es:di],dh
 test dl,64
 setnz dh
 add dh,'0'
 mov [es:di+2],dh
 add di,6
 and dl,31
 mov bx, 4
 call WriteHex
 mov dl,[fs:esi+9]       ;SD
 mov di, 17*160+56
 mov bx, 4
 call WriteHex

 mov dx,[fs:esi+10]
 mov di,18*160+56
 mov bx, 8
 call WriteHex

 mov dx,[fs:esi+12]
 mov di,19*160+56
 mov bx, 8
 call WriteHex

 mov di,21*160+56
 mov dx,[fs:esi+0Eh]
 mov bx,8
 Call WriteHex
 mov esi, eax

 shl esi, 8
 add esi,[MissileStart]
 mov ebp,eax
 shl ebp,2+4
 add ebp,[LListVirus]
 mov cx, 16
 mov di, 26*160+8
 @MLoop:

  mov dx,[fs:ebp]
  mov bx, 8
  call WriteHex
  add di, 10
  mov dx, [fs:ebp+02]
  mov bx, 8
  call WriteHex
  add di, 20
  mov edx,[fs:esi]
  mov bx, 8
  call WriteHex
  sub di, 10
  mov bx, 8
  call WriteHex
  mov edx,[fs:esi+4]
  add di, 30
  mov bx, 8
  call WriteHex
  sub di, 10
  mov bx, 8
  call WriteHex
  mov dx,[fs:esi+8]
  add di, 20
  test dl,2
  setnz bl
  add bl,'0'
  mov [es:di],bl  ; X-Flag
  test dl,1
  setnz bl
  add bl,'0'
  mov [es:di+2],bl    ; Y-Flag
  shr dx, 8

IF MARKMISSILES EQ 1
  or  dl,dl
  setz dl
  add dl,7
  mov bx, -59
  mov dh,52
  @aloop:
   mov [es:di+bx],dl
   add bx,2
   dec dh
  jne @aloop
  mov dl,[fs:esi+9]
ENDIF
  add di, 06
  mov bx, 4
  call WriteHex

  mov dx,[fs:esi+0Ah]
  add di, 6
  mov bx, 8
  call WriteHex

  mov dx,[fs:esi+0Ch]
  add di, 10
  mov bx, 8
  call WriteHex

  mov dx,[fs:esi+0Eh]
  add di, 10
  mov bx, 8
  call WriteHex

  add ebp, 4
  add esi, 16
  add di, 68
  dec cx
 jne @MLoop

 mov esi,eax
 shl esi, 9
 add esi,16
 add esi,[DNAStart]
 mov cx, 14
 mov di, 27*160+130

 mov al,'1'
 dec esi
 mov bx,4
 mov dl,[fs:esi]
 or  dl,dl
 jnz  @ZF11
  mov al,'0'
 @ZF11:
 mov [es:di+2],al
 sub di,160

 mov al,'1'
 dec esi
 mov bx,4
 mov dl,[fs:esi]
 or  dl,dl
 jnz  @CF11
  mov al,'0'
 @CF11:
 mov [es:di+2],al
 sub di,160

 @RLoop:
  dec esi
  mov bx,4
  mov dl,[fs:esi]
  call WriteHex
  sub di,160
  dec cx
 jne @RLoop
 mov dl,[fs:esi]
 shl dx,1
 add esi,edx
 mov dx,[fs:esi]
 mov di,41*160+126
 mov bx,4
 call WriteHex
 sub di,6
 mov bx,4
 call WriteHex


; Danger!
 mov esi,0
 shl esi,9
 add esi,[DNAStart]
 add esi,16
 mov di,1*160+146
 mov cx,40
 @TLoop:
   mov bx,8
   mov dx,[fs:esi]
   call WriteHex
   add di,160
   add esi,2
  dec cx
 jne @Tloop


 mov di,0
 mov edx,[TCounter]
 mov bx,16
 Call WriteHex

 POPAD
 RET
ENDP

;----------------------
; Process R-Evolution:
;  EDI : IP
;  ESI : JMP-Index ( free )
;  EBP : Pointer to Regs/DNA-Start of current Robot.
;  EBX : ---
;   CX : Counter ( depends on InstrNum )
;  EAX : ---
;-----------------------

 PROC ProcessREvolution
  xor esi,esi
  mov edi,esi
  mov si,[RobotNum]    ; Anzahl Robots immer in CX
  mov ebp,esi
  dec bp
  shl ebp,9
  add ebp,[DNAStart]
  ;--------------------
  @MegaStartLoop:
   mov cx, [InstrNum]              ; Wieviele Befehle auf einmal abarbeiten ?

   mov di,[fs:ebp]
   and di,255                      ; nur unteres Byte!
   shl di,1                        ; Real IP = Ip * 2 (2 Bytes/Instruction)
   xor ebx,ebx
   ;--------------------
   @InstructionLoop:      ; EBP, SI, DI, CX !!!!

    mov dx,[fs:ebp+edi]
    xor bx,bx
    mov bl,dh
    shl bx,1    ; 1 Word!
    Jmp [JmpIndex+bx]

    INCLUDE "INSTRUCT.ASM"

    @NOP:
    add di,2
    cmp di,512
    jb  @JMPS
     mov di,16                     ;erste Instruction nach den Regs.
    @JMPS:

    mov ax,di
    shr ax,1
    mov [fs:ebp],al

   dec cx
   jne @InstructionLoop
   @exitinsts:
   sub ebp,512        ;
   dec si
  jne @MegaStartLoop
  Ret
 ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

INCLUDE "MOVEvol.ASM"

ENDS


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
SEGMENT IDATA
Seed    dd 0
Count   dw 0

MARKMISSILES = 1
REVOLMODE = 1

IF REVOLMODE EQ 1
 SQSHIFT  = 6
 SQYSHIFT = 6
 XField   dw 4095
 YField   dw 4095
 YQ       = 64
 YQA      = 64
 SQNUM    = YQ*YQA
ELSE
 SQSHIFT  = 4
 SQYSHIFT = 4
 XField   dw 255
 YField   dw 127
 YQ       = 16
 YQA      = 8
 SQNUM    = YQ*YQA
ENDIF


 ;---------------------------------------------- Ab hier einstellbar! ------;
  VirusTimer = 250
  MaxRobSpeed = 2

  MutNum dd ?     ; Anzahl gemachter Mutationen...
  MutationTimes  db  10   ; Nach wievielen Mutationen soll wieder mal nix
                          ; mutiert werden ?
  MutPerRobot EQU 7    ; Power of 2 minus 1 !
  NumOpcodes  EQU 255  ; Power of 2 minus 1 !

  InstrNum    dw 01    ; 10 Instructions in einem Loop
  RobotNum    dw 02    ; X Roboter insgesamt
  Missiles    db 01    ; Anzahl Missiles.
  Mutations   db 00    ; 1 = Mutation-Mode aktiv, 0 = Battle-Mode aktiv
  DefDec      db 80h   ; Bei Treffer wieviel von D-Status abgezogen
  DefInc      db 80h   ; Bei Winner wieviel zu D-Status des Winners addiert
  ScanDif     dw 7Fh   ; Scan-Entfernung! Quadrat
 ;--------------------------------------------------------------------------;


DNAStandardCode dw 01AC1h      ;08
                dw 0B123h      ;09
                dw 00101h      ;0A
                dw 00101h      ;0B
                dw 01AD7h      ;0C
                dw 0A123h      ;0D
                dw 00101h      ;0E
                dw 00101h      ;0F
                dw 00101h      ;10
                dw 00101h      ;11
                dw 00101h      ;12
                dw 00101h      ;13
                dw 00101h      ;14
                dw 00101h      ;15
                dw 00101h      ;16
                dw 00101h      ;17
                dw 00101h      ;17
                dw 00101h      ;17
                dw 00101h      ;17
                dw 0FFFFh      ;17

                dw 227 dup (0101h)
                dw 0FFFFh




RANDOMNums DW 00000h , 00000h ;  X,  Y
           DW 000FFh , 0003Fh
           DW 00001h , 00000h ; RA, RS
           DW 000C0h , 00000h
           ; Lines to Change
           DW 005h
           DW 0FFh
           DW 0FFh
           DW 0FFh
           DW 0FFh
           DW 0FFh
           DW 0FFh
           DW 0FFh
           DW 007h      ;)
           DW 030h


INCLUDE 'JMPINDEX.ASM'     ; Indices in JMPINDEX.ASM ausgelagert

SINTABLE DW 00000h,00648h,00C90h,012D5h,01918h,01F56h,02590h,02BC4h
         DW 031F1h,03817h,03E34h,04447h,04A50h,0504Dh,0563Eh,05C22h
         DW 061F8h,067BEh,06D74h,0731Ah,078ADh,07E2Fh,0839Ch,088F6h
         DW 08E3Ah,09368h,09880h,09D80h,0A268h,0A736h,0ABEBh,0B086h
         DW 0B505h,0B968h,0BDAFh,0C1D8h,0C5E4h,0C9D1h,0CD9Fh,0D14Dh
         DW 0D4DBh,0D848h,0DB94h,0DEBEh,0E1C6h,0E4AAh,0E76Ch,0EA0Ah
         DW 0EC83h,0EED9h,0F109h,0F314h,0F4FAh,0F6BAh,0F854h,0F9C8h
         DW 0FB15h,0FC3Bh,0FD3Bh,0FE13h,0FEC4h,0FF4Eh,0FFB1h,0FFECh
         DW 0FFFFh,0FFECh,0FFB1h,0FF4Eh,0FEC4h,0FE13h,0FD3Bh,0FC3Bh
         DW 0FB15h,0F9C8h,0F854h,0F6BAh,0F4FAh,0F314h,0F109h,0EED9h
         DW 0EC83h,0EA0Ah,0E76Ch,0E4AAh,0E1C6h,0DEBEh,0DB94h,0D848h
         DW 0D4DBh,0D14Dh,0CD9Fh,0C9D1h,0C5E4h,0C1D8h,0BDAFh,0B968h
         DW 0B505h,0B086h,0ABEBh,0A736h,0A268h,09D80h,09880h,09368h
         DW 08E3Ah,088F6h,0839Ch,07E2Fh,078ADh,0731Ah,06D74h,067BEh
         DW 061F8h,05C22h,0563Eh,0504Dh,04A50h,04447h,03E34h,03817h
         DW 031F1h,02BC4h,02590h,01F56h,01918h,012D5h,00C90h,00648h;256 Bytes..

TAN  DW 00000h,00006h,0000Ch,00012h,00019h,0001Fh,00025h,0002Ch
     DW 00032h,00039h,00040h,00046h,0004Dh,00054h,0005Bh,00062h
     DW 0006Ah,00071h,00079h,00080h,00088h,00091h,00099h,000A2h
     DW 000ABh,000B4h,000BDh,000C7h,000D2h,000DCh,000E8h,000F3h
     DW 00100h,0010Ch,0011Ah,00128h,00137h,00148h,00159h,0016Bh
     DW 0017Fh,00194h,001ABh,001C3h,001DEh,001FCh,0021Dh,00241h
     DW 0026Ah,00297h,002CBh,00306h,0034Bh,0039Dh,003FEh,00474h
     DW 00506h,005C3h,006BDh,0081Bh,00A27h,00D8Eh,0145Ah,028BCh
     DW 07F00h,0D744h,0EBA6h,0F272h,0F5D9h,0F7E5h,0F943h,0FA3Dh
     DW 0FAFAh,0FB8Ch,0FC02h,0FC63h,0FCB5h,0FCFAh,0FD35h,0FD69h
     DW 0FD96h,0FDBFh,0FDE3h,0FE04h,0FE22h,0FE3Dh,0FE55h,0FE6Ch
     DW 0FE81h,0FE95h,0FEA7h,0FEB8h,0FEC9h,0FED8h,0FEE6h,0FEF4h
     DW 0FF00h,0FF0Dh,0FF18h,0FF24h,0FF2Eh,0FF39h,0FF43h,0FF4Ch
     DW 0FF55h,0FF5Eh,0FF67h,0FF6Fh,0FF78h,0FF80h,0FF87h,0FF8Fh
     DW 0FF96h,0FF9Eh,0FFA5h,0FFACh,0FFB3h,0FFBAh,0FFC0h,0FFC7h
     DW 0FFCEh,0FFD4h,0FFDBh,0FFE1h,0FFE7h,0FFEEh,0FFF4h,0FFFAh; 256 Byte !!

TOL  DW 00004h,00004h,00004h,00004h,00004h,00004h,00004h,00004h
     DW 00004h,00004h,00004h,00004h,00004h,00005h,00005h,00005h
     DW 00005h,00005h,00005h,00005h,00005h,00005h,00005h,00005h
     DW 00006h,00006h,00006h,00006h,00006h,00007h,00007h,00007h
     DW 00007h,00008h,00008h,00009h,00009h,0000Ah,0000Ah,0000Bh
     DW 0000Ch,0000Ch,0000Dh,0000Fh,00010h,00011h,00013h,00015h
     DW 00018h,0001Bh,0001Fh,00023h,0002Ah,00031h,0003Ch,0004Ah
     DW 0005Fh,0007Eh,000B0h,00107h,001B5h,00367h,00A32h,02B22h
     DW 053DFh,00A32h,00367h,001B5h,00107h,000B0h,0007Eh,0005Fh
     DW 0004Ah,0003Ch,00031h,0002Ah,00023h,0001Fh,0001Bh,00018h
     DW 00015h,00013h,00011h,00010h,0000Fh,0000Dh,0000Ch,0000Ch
     DW 0000Bh,0000Ah,0000Ah,00009h,00009h,00008h,00008h,00007h
     DW 00007h,00007h,00007h,00006h,00006h,00006h,00006h,00006h
     DW 00005h,00005h,00005h,00005h,00005h,00005h,00005h,00005h
     DW 00005h,00005h,00005h,00004h,00004h,00004h,00004h,00004h
     DW 00004h,00004h,00004h,00004h,00004h,00004h,00004h,00004h ;256 Byte

LABEL InstructionTable BYTE
 INCLUDE "INSTAB.ASM"



SQUARETABLE  DW 0, 2, 2*YQ, 2*YQ+2    ; fr  0-3F
             DW 0,-2, 2*YQ, 2*YQ-2    ; fr 40-7F
             DW 0,-2,-2*YQ,-2*YQ-2    ; fr 80-BF
             DW 0, 2,-2*YQ,-2*YQ+2    ; fr C0-FF
SQUARETABLE2 DW 0, 0,    0,      0    ; fr Rand...

ENDS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
SEGMENT UData
 LListVStart DW SQNum+1 DUP (?)
 MCounter DB ?                  ; HelpCounter von 0 bis MutationTimes...

 RoboStart    DD ?
 MissileStart DD ?
 DNAStart     DD ?
 LListVirus   DD ?

 DeltaX   db ?
 DeltaY   db ?
 Nearest  db ?
 RobFound db ?
 VSpeed   db ?
 SaveSI   dw ?
 SQUARE   dw ?                  ; Current Square <SCANVIRUS>
 SAVECOUNTER dw ?               ; Current Robot  <SCANVIRUS>

 HTab db MutperRobot+2 dup (?)

 TCounter DD ?
ENDS