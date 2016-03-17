IDEAL
P386
GROUP   Data    IData,UData
ASSUME  cs:Code,ds:Data

EMM386  EQU     0
Timer   EQU     0
Keyboard EQU    0

INCLUDE 'alp_flat.asm'
INCLUDE 'gui.asm'
INCLUDE 'kernel.asm'

SEGMENT Code    PUBLIC

PROC    DrawRobots
;clear buffer
        mov     dx,3c4h
        mov     ax,0f02h
        out     dx,ax           ;write to all pages
        mov     al,[es:0]       ;fill latch-reg with 0
        mov     al,[Zoom]
        xor     al,1
        and     al,[Grid]
        jnz     @@grid
        mov     dx,3ceh
        mov     ax,0ff08h       ;bitmask to 0ffh
        out     dx,ax
        mov     ax,0200h
        out     dx,ax           ;set color
        mov     ax,0f01h
        out     dx,ax           ;enable set/reset
        mov     di,57344        ;the last 8192 bytes of VGA-RAM
        mov     cx,256*8
@@a1:   mov     [es:di],eax
        add     di,4
        dec     cx
        jnz     @@a1
        jmp     @@okay
@@grid: mov     dx,3ceh
        mov     ax,07708h       ;bitmask to 077h
        out     dx,ax
        mov     ax,0200h
        out     dx,ax           ;set color
        mov     ax,0f01h
        out     dx,ax           ;enable set/reset
        mov     di,57344        ;the last 8192 bytes of VGA-RAM
        mov     ch,0            ;256
@@a2:   mov     cl,8
        mov     bl,ch
        and     bl,3
        jnz     @@a3
        mov     ax,00008h       ;bitmask to 000h
        out     dx,ax
@@a3:   mov     [es:di],eax
        add     di,4
        dec     cl
        jnz     @@a3
        test    bl,bl
        jnz     @@a4
        mov     ax,07708h       ;bitmask to 077h
        out     dx,ax
@@a4:   dec     ch
        jnz     @@a2
@@okay: cmp     [Zoom],1
        je      @@zoom
;draw viruses
        mov     esi,[MissileStart]
        mov     bp,[RobotNum]   ;how many robots?
        shl     bp,4
        mov     dx,3ceh
        mov     ax,0f01h
        out     dx,ax           ;enable set/reset
@@b2:   cmp     [B fs:esi+8],0
        jz      @@b3            ;if virus inactive
        mov     ax,[fs:esi+2]
        shr     ax,4
        mov     bx,[fs:esi+6]
        shr     bx,4
        shl     bx,5
        mov     cl,al
        shr     al,3
        add     bx,ax
        add     bx,57344        ;adress is ready
        and     cl,7
        mov     ah,80h          ;top bit is set
        shr     ah,cl           ;bitmask ready
        mov     al,08
        out     dx,ax           ;set bitmask
        xor     al,al
        mov     ah,[fs:esi+9]
        add     ah,3
        out     dx,ax           ;set color
        xchg    al,[es:bx]
@@b3:
        add     esi,16
        dec     bp
        jnz     @@b2
;draw robots
        mov     esi,[RoboStart]
        mov     bp,[RobotNum]   ;how many robots?
        mov     dx,3ceh
        mov     ax,0f01h
        out     dx,ax           ;enable set/reset
@@b1:   mov     ax,[fs:esi+2]
        shr     ax,4
        mov     bx,[fs:esi+6]
        shr     bx,4
        shl     bx,5
        mov     cl,al
        shr     al,3
        add     bx,ax
        add     bx,57344        ;adress is ready
        and     cl,7
        mov     ah,80h          ;top bit is set
        shr     ah,cl           ;bitmask ready
        mov     al,08
        out     dx,ax           ;set bitmask
        xor     al,al
        mov     ah,[fs:esi+15]
        add     ah,10
        out     dx,ax           ;set clolor
        xchg    al,[es:bx]
        add     esi,16
        dec     bp
        jnz     @@b1
;draw actual robot again
        movzx   esi,[ActRobot]
        shl     esi,4
        add     esi,[RoboStart]
        mov     ax,[fs:esi+2]
        shr     ax,4
        mov     bx,[fs:esi+6]
        shr     bx,4
        shl     bx,5
        mov     cl,al
        shr     al,3
        add     bx,ax
        add     bx,57344        ;adress is ready
        and     cl,7
        mov     ah,80h          ;top bit is set
        shr     ah,cl           ;bitmask ready
        mov     al,08
        out     dx,ax           ;set bitmask
        mov     ax,0600h
        out     dx,ax           ;set clolor
        xchg    al,[es:bx]
        jmp     @@ready

@@zoom: movzx   esi,[ActRobot]
        shl     esi,4
        add     esi,[RoboStart]
        mov     ax,[fs:esi+2]
        sub     ax,128
        jns     @@d1
        xor     ax,ax
@@d1:   cmp     ax,4095-255
        jbe     @@d2
        mov     ax,4095-255
@@d2:   mov     bx,[fs:esi+6]
        sub     bx,128
        jns     @@d3
        xor     bx,bx
@@d3:   cmp     bx,4095-255
        jbe     @@d4
        mov     bx,4095-255
@@d4:   mov     [DrawRobX],ax
        mov     [DrawRobY],bx
        mov     dx,3ceh
        cmp     [Grid],0
        jz      @@NoGrid

;draw vertical lines
        push    bx
        mov     bl,1
@@g1:   movzx   cx,bl
        imul    cx,64
        dec     cx
        add     cx,ax
        and     cx,0ffc0h
        sub     cx,ax
        mov     di,cx
        shr     di,3
        add     di,57344
        push    ax
        and     cl,7
        mov     ax,07f08h
        ror     ah,cl
        out     dx,ax
        pop     ax
        mov     ch,0
@@g2:   mov     [es:di],al
        add     di,32
        dec     ch
        jnz     @@g2
        inc     bl
        cmp     bl,5
        jb      @@g1
        pop     bx
;draw hotizontal lines
        mov     ax,0008h
        out     dx,ax
        mov     al,1
@@g3:   movzx   cx,al
        imul    cx,64
        dec     cx
        add     cx,bx
        and     cx,0ffc0h
        sub     cx,bx
        mov     di,cx
        shl     di,5
        add     di,57344
        mov     ch,8
@@g4:   mov     [es:di],eax
        add     di,4
        dec     ch
        jnz     @@g4
        inc     al
        cmp     al,5
        jb      @@g3

@@NoGrid:
        mov     esi,[MissileStart]
        mov     bp,[RobotNum]   ;how many robots?
        shl     bp,4
        mov     ax,0f01h
        out     dx,ax           ;enable set/reset
@@b2_:  cmp     [B fs:esi+8],0
        jz      @@b3_           ;if virus inactive
        mov     ax,[fs:esi+2]
        sub     ax,[DrawRobX]
        test    ah,ah
        jnz     @@b3_           ;if bigger than 255
        mov     bx,[fs:esi+6]
        sub     bx,[DrawRobY]
        test    bh,bh
        jnz     @@b3_           ;if bigger than 255
        shl     bx,5
        mov     cl,al
        shr     al,3
        add     bx,ax
        add     bx,57344        ;adress is ready
        and     cl,7
        mov     ah,80h          ;top bit is set
        shr     ah,cl           ;bitmask ready
        mov     al,08
        out     dx,ax           ;set bitmask
        xor     al,al
        mov     ah,[fs:esi+9]
        add     ah,3
        out     dx,ax           ;set color
        xchg    al,[es:bx]
@@b3_:
        add     esi,16
        dec     bp
        jnz     @@b2_
;draw robots
        mov     esi,[RoboStart]
        mov     bp,[RobotNum]   ;how many robots?
        mov     dx,3ceh
        mov     ax,0f01h
        out     dx,ax           ;enable set/reset
@@b1_:  mov     ax,[fs:esi+2]
        sub     ax,[DrawRobX]
        test    ah,ah
        jnz     @@b4_           ;test if bigger than 255
        mov     bx,[fs:esi+6]
        sub     bx,[DrawRobY]
        test    bh,bh
        jnz     @@b4_           ;test if bigger than 255
        shl     bx,5
        mov     cl,al
        shr     al,3
        add     bx,ax
        add     bx,57344        ;adress is ready
        and     cl,7
        mov     ah,80h          ;top bit is set
        shr     ah,cl           ;bitmask ready
        mov     al,08
        out     dx,ax           ;set bitmask
        xor     al,al
        mov     ah,[fs:esi+15]
        add     ah,10
        out     dx,ax           ;set clolor
        xchg    al,[es:bx]
@@b4_:  add     esi,16
        dec     bp
        jnz     @@b1_
;draw actual robot again
        movzx   esi,[ActRobot]
        shl     esi,4
        add     esi,[RoboStart]
        mov     ax,[fs:esi+2]
        sub     ax,[DrawRobX]
        mov     bx,[fs:esi+6]
        sub     bx,[DrawRobY]
        shl     bx,5
        mov     cl,al
        shr     al,3
        add     bx,ax
        add     bx,57344        ;adress is ready
        and     cl,7
        mov     ah,80h          ;top bit is set
        shr     ah,cl           ;bitmask ready
        mov     al,08
        out     dx,ax           ;set bitmask
        mov     ax,0600h
        out     dx,ax           ;set clolor
        xchg    al,[es:bx]
@@ready:
;copy buffer to screen
        mov     dx,3c4h
        mov     ax,0f02h
        out     dx,ax           ;write to all pages
        mov     dx,3ceh
        mov     al,05
        out     dx,al
        inc     dx
        in      al,dx
        and     al,11111100b
        or      al,1
        out     dx,al           ;write mode 1
        mov     si,57344
        mov     di,16/8+32*80   ;top left edge
        mov     cl,0            ;256 :-)
@@c1:   mov     ch,32
@@c2:   mov     al,[es:si]
        mov     [es:di],al
        inc     si
        inc     di
        dec     ch
        jnz     @@c2
        add     di,80-32
        dec     cl
        jnz     @@c1
        mov     dx,3ceh
        mov     al,5
        out     dx,al
        inc     dx
        in      al,dx
        and     al,11111100b
        out     dx,al           ;write mode 0
        ret
ENDP

PROC    Adios
        mov     [EndGUI],1
        ret
ENDP

PROC    OpenEnd
        mov     [ActWindow],1
        call    ChangeActWindow
        ret
ENDP

PROC    OpenVirInfo
        call    CopyVirInfoToVar
        mov     [ActWindow],2
        call    ChangeActWindow
        ret
ENDP

PROC    OpenTeams
        mov     ax,[RobotNum]
        mov     [NrRobots],ax
        mov     [ActWindow],3
        call    ChangeActWindow
        ret
ENDP

PROC    CloseWin
        mov     [ActWindow],0
        call    ChangeActWindow
        ret
ENDP

PROC    RefrRUp
        mov     ax,[RefreshRate]
        inc     ax
        test    ax,ax
        jne     @@1
        dec     ax
@@1:    mov     [RefreshRate],ax
        mov     si,O NRefrR
        call    ReDrawObject
        ret
ENDP

PROC    RefrRDn
        mov     ax,[RefreshRate]
        dec     ax
        test    ax,ax
        jne     @@1
        inc     ax
@@1:    mov     [RefreshRate],ax
        mov     si,O NRefrR
        call    ReDrawObject
        ret
ENDP

PROC    ActRobUp
        mov     ax,[ActRobot]
        inc     ax
        cmp     ax,[RobotNum]
        jne     @@1
        dec     ax
@@1:    mov     [ActRobot],ax
        mov     si,O NActRob
        call    ReDrawObject

        call    CopyRegsToVar
        mov     si,O NIP
        mov     cl,20
@@2:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@2
        call    DrawRobots
        ret
ENDP

PROC    ActRobDn
        mov     ax,[ActRobot]
        dec     ax
        cmp     ax,65535
        jne     @@1
        inc     ax
@@1:    mov     [ActRobot],ax
        mov     si,O NActRob
        call    ReDrawObject

        call    CopyRegsToVar
        mov     si,O NIP
        mov     cl,20
@@2:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@2
        call    DrawRobots
        ret
ENDP

PROC    RunREvolution
        cmp     [Blank],1
        je      @@blank
        mov     ax,[RefreshRate]
        mov     [RefreshCounter],ax
@@1:    mov     ax,3
        int     33h
        test    bx,2
        jnz     @@2
        movzx   eax,[InstrNum]
        add     [CommandCounter],eax
        call    ProcessREvolution
        call    MOVEvol
        dec     [RefreshCounter]
        jnz     @@1
        call    DrawRobots
        mov     si,O NComm
        call    ReDrawObject
        mov     si,O NMutNum
        call    ReDrawObject
        mov     ax,[RefreshRate]
        mov     [RefreshCounter],ax
        jmp     @@1
@@2:    call    CopyRegsToVar
        mov     si,O NComm
        call    ReDrawObject
        mov     si,O NMutNum
        call    ReDrawObject
        mov     si,O NIP
        mov     cl,20
@@3:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@3
        call    DrawRobots
        ret
@@blank:
;clear screen
        mov     dx,3c4h
        mov     ax,0f02h
        out     dx,ax           ;write to all pages
        mov     dx,3ceh
        mov     ax,0ff08h       ;bitmask to 0ffh
        out     dx,ax
        mov     ax,0200h
        out     dx,ax           ;set color
        mov     ax,0f01h
        out     dx,ax           ;enable set/reset
        xor     di,di
        mov     cx,20*480
@@a1:   mov     [es:di],eax
        add     di,4
        dec     cx
        jnz     @@a1
;set border to black
        mov     dx,3dah
        in      al,dx
        mov     dx,3c0h
        mov     al,11h+32
        out     dx,al
        mov     al,2
        out     dx,al

@@1_:   mov     ax,3
        int     33h
        test    bx,2
        jnz     @@2_
        movzx   eax,[InstrNum]
        add     [CommandCounter],eax
        call    ProcessREvolution
        call    MOVEvol
        jmp     @@1_
@@2_:
;set border to gray again
        mov     dx,3dah
        in      al,dx
        mov     dx,3c0h
        mov     al,11h+32
        out     dx,al
        xor     al,al
        out     dx,al
        call    CopyRegsToVar
        call    ChangeActWindow         ;refresh screen
        ret
ENDP

PROC    SingleRun
        movzx   eax,[InstrNum]
        add     [CommandCounter],eax
        call    ProcessREvolution
        call    MOVEvol
        call    DrawRobots
        call    CopyRegsToVar
        mov     si,O NComm
        call    ReDrawObject
        mov     si,O NMutNum
        call    ReDrawObject
        mov     si,O NIP
        mov     cl,20
@@1:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@1
        ret
ENDP

PROC    CopyRegsToVar
        movzx   esi,[ActRobot]
        shl     esi,9
        add     esi,[DNAStart]
        mov     di,O RegIP
        mov     cl,4
@@1:    mov     eax,[fs:esi]
        add     esi,4
        mov     [di],eax
        add     di,4
        dec     cl
        jnz     @@1

        movzx   esi,[ActRobot]
        shl     esi,4
        add     esi,[RoboStart]
        mov     ax,[fs:esi+2]
        mov     [RobXPos],ax
        mov     ax,[fs:esi+6]
        mov     [RobYPos],ax
        mov     ax,[fs:esi+8]   ;two in one
        and     al,7
        mov     [W SV],ax
        ret
ENDP

PROC    ChooseRobot
        mov     cx,[MouseX]
        mov     dx,[MouseY]
        sub     cx,[si+Picture.OX]
        sub     dx,[si+Picture.OY]

        cmp     [Zoom],1
        je      @@zoom

        mov     esi,[RoboStart]
        mov     bp,0
        mov     di,0ffffh
@@1:    mov     ax,[fs:esi+2]
        shr     ax,4
        mov     bx,[fs:esi+6]
        shr     bx,4
        sub     ax,cx
        jns     @@2
        neg     ax
@@2:    sub     bx,dx
        jns     @@3
        neg     bx
@@3:    add     ax,bx
        cmp     ax,di
        ja      @@4
        mov     di,ax
        mov     [ActRobot],bp
@@4:    add     esi,16
        inc     bp
        cmp     bp,[RobotNum]
        jb      @@1
        jmp     @@ready

@@zoom: movzx   esi,[ActRobot]
        shl     esi,4
        add     esi,[RoboStart]
        mov     ax,[fs:esi+2]
        sub     ax,128
        jns     @@d1
        xor     ax,ax
@@d1:   cmp     ax,4095-255
        jbe     @@d2
        mov     ax,4095-255
@@d2:   mov     bx,[fs:esi+6]
        sub     bx,128
        jns     @@d3
        xor     bx,bx
@@d3:   cmp     bx,4095-255
        jbe     @@d4
        mov     bx,4095-255
@@d4:   mov     [DrawRobX],ax
        mov     [DrawRobY],bx

        mov     esi,[RoboStart]
        mov     bp,0
        mov     di,0ffffh
@@1_:   mov     ax,[fs:esi+2]
        sub     ax,[DrawRobX]
        test    ah,ah
        jnz     @@4_
        mov     bx,[fs:esi+6]
        sub     bx,[DrawRobY]
        test    bh,bh
        jnz     @@4_
        sub     ax,cx
        jns     @@2_
        neg     ax
@@2_:   sub     bx,dx
        jns     @@3_
        neg     bx
@@3_:   add     ax,bx
        cmp     ax,di
        ja      @@4_
        mov     di,ax
        mov     [ActRobot],bp
@@4_:   add     esi,16
        inc     bp
        cmp     bp,[RobotNum]
        jb      @@1_

@@ready:
        call    DrawRobots
        call    CopyRegsToVar
        mov     si,O NActRob
        call    ReDrawObject
        mov     si,O NIP
        mov     cl,20
@@5:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@5
        ret
ENDP

PROC    RobSave
        mov     si,O RobSaveName
        call    CountLength
        test    bp,bp
        jz      @@end
        push    es
        push    ds
        pop     es
        mov     cx,bp
        mov     si,O RobSaveName
        mov     di,O TempName
rep     movsb
        pop     es
        mov     [D di],'mcr.'
        mov     [B di+4],0

        mov     dx,O TempName
        mov     ah,3ch
        xor     cx,cx
        int     21h
        jc      @@end
        mov     bx,ax

        movzx   esi,[ActRobot]
        shl     esi,9
        add     esi,[DNAStart]
        add     esi,16
        mov     di,O FileBuffer
        mov     cl,496/4
@@1:    mov     eax,[fs:esi]
        mov     [di],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@1

        mov     ah,40h
        mov     dx,O FileBuffer
        mov     cx,496
        int     21h

        mov     ah,3eh
        int     21h

;disassemble
        mov     si,O RobSaveName
        call    CountLength
        test    bp,bp
        jz      @@end
        push    es
        push    ds
        pop     es
        mov     cx,bp
        mov     si,O RobSaveName
        mov     di,O TempName
rep     movsb
        pop     es
        mov     [D di],'sar.'
        mov     [B di+4],0

        mov     dx,O TempName
        mov     ah,3ch
        xor     cx,cx
        int     21h
        jc      @@end
        mov     bx,ax

        push    bx              ;save handle

        movzx   esi,[ActRobot]
        shl     esi,9
        add     esi,[DNAStart]
        add     esi,16
        mov     di,O FileBuffer
        xor     bp,bp
@@2:    mov     ax,[fs:esi]
        add     esi,2
        mov     [B di],9
        inc     di
        mov     bx,ax
        xor     bl,bl
        shr     bx,5
        add     bx,O Commands
        mov     cx,[bx]         ;cl=type, ch=length of command
        add     bx,2
@@3:    mov     dl,[bx]
        mov     [di],dl
        inc     bx
        inc     di
        dec     ch
        jnz     @@3
        mov     [B di],9
        inc     di
        cmp     cl,No
        je      @@No
        cmp     cl,RegX1
        je      @@RegX1
        cmp     cl,RegX2
        je      @@RegX2
        cmp     cl,RegX3
        je      @@RegX3
        cmp     cl,_Const
        je      @@Const
        cmp     cl,RegConst4
        je      @@RegConst4
;must be RegConst8
@@RegConst8:
        mov     bl,ah
        and     bx,0fh
        shl     bl,1
        add     bx,O Registers
        mov     cx,[bx]
        mov     [di],cx
        add     di,2
        mov     [B di],','
        inc     di
        xor     ah,ah
        mov     bl,10
        div     bl
        add     ah,'0'
        mov     [di+2],ah
        xor     ah,ah
        div     bl
        add     ah,'0'
        mov     [di+1],ah
        add     al,'0'
        mov     [di],al
        add     di,3
        jmp     @@No
@@RegConst4:
        mov     bl,al
        and     bx,0f0h
        shr     bl,3
        add     bx,O Registers
        mov     cx,[bx]
        mov     [di],cx
        add     di,2
        mov     [B di],','
        inc     di
        and     ax,0fh
        mov     bl,10
        div     bl
        add     ah,'0'
        mov     [di+1],ah
        add     al,'0'
        mov     [di],al
        add     di,2
        jmp     @@No
@@RegX1:
        mov     bl,al
        and     bx,0fh
        shl     bl,1
        add     bx,O Registers
        mov     cx,[bx]
        mov     [di],cx
        add     di,2
        jmp     @@No
@@RegX2:
        mov     bl,al
        and     bx,0f0h
        shr     bl,3
        add     bx,O Registers
        mov     cx,[bx]
        mov     [di],cx
        add     di,2
        mov     [B di],','
        inc     di
        mov     bl,al
        and     bx,0fh
        shl     bl,1
        add     bx,O Registers
        mov     cx,[bx]
        mov     [di],cx
        add     di,2
        jmp     @@No
@@RegX3:
        mov     bl,ah
        and     bx,0fh
        shl     bl,1
        add     bx,O Registers
        mov     cx,[bx]
        mov     [di],cx
        add     di,2
        mov     [B di],','
        inc     di
        mov     bl,al
        and     bx,0f0h
        shr     bl,3
        add     bx,O Registers
        mov     cx,[bx]
        mov     [di],cx
        add     di,2
        mov     [B di],','
        inc     di
        mov     bl,al
        and     bx,0fh
        shl     bl,1
        add     bx,O Registers
        mov     cx,[bx]
        mov     [di],cx
        add     di,2
        jmp     @@No
@@Const: xor    ah,ah
        mov     bl,10
        div     bl
        add     ah,'0'
        mov     [di+2],ah
        xor     ah,ah
        div     bl
        add     ah,'0'
        mov     [di+1],ah
        add     al,'0'
        mov     [di],al
        add     di,3
@@No:
        mov     [W di],';'*256+9
        add     di,2
        mov     ax,bp
        add     al,8
        mov     bl,10
        div     bl
        add     ah,'0'
        mov     [di+2],ah
        xor     ah,ah
        div     bl
        add     ah,'0'
        mov     [di+1],ah
        add     al,'0'
        mov     [di],al
        add     di,3

        mov     [W di],0a0dh
        add     di,2
        inc     bp
        cmp     bp,248
        jb      @@2

        pop     bx

        sub     di,2
        mov     cx,di
        sub     cx,O FileBuffer
        mov     ah,40h
        mov     dx,O FileBuffer
        int     21h

        mov     ah,3eh
        int     21h

@@end:  ret
ENDP

PROC    RobLoad
        mov     si,O RobLoadName
        call    CountLength
        test    bp,bp
        jz      @@end
        push    es
        push    ds
        pop     es
        mov     cx,bp
        mov     si,O RobLoadName
        mov     di,O TempName
rep     movsb
        pop     es
        mov     [D di],'mcr.'
        mov     [B di+4],0

        mov     dx,O TempName
        mov     ax,3d00h
        int     21h
        jc      @@end
        mov     bx,ax

        mov     ah,3fh
        mov     dx,O FileBuffer
        mov     cx,496
        int     21h
        jc      @@end

        mov     ah,3eh
        int     21h
        jc      @@end

        movzx   esi,[ActRobot]
        shl     esi,9
        add     esi,[DNAStart]
        mov     [B fs:esi],8    ;init IP
        mov     [B fs:esi+1],0
        mov     [D fs:esi+2],0
        mov     [D fs:esi+6],0
        mov     [W fs:esi+10],0
        mov     [W fs:esi+14],0
        add     esi,16
        mov     di,O FileBuffer
        mov     cl,496/4
@@1:    mov     eax,[di]
        mov     [fs:esi],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@1

        call    CopyRegsToVar
        mov     si,O NIP
        mov     cl,18
@@2:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@2

@@end:  ret
ENDP

PROC    SShotSave
        mov     si,O SShotSaveName
        call    CountLength
        test    bp,bp
        jz      @@end
        push    es
        push    ds
        pop     es
        mov     cx,bp
        mov     si,O SShotSaveName
        mov     di,O TempName
rep     movsb
        pop     es
        mov     [D di],'pns.'
        mov     [B di+4],0

        mov     dx,O TempName
        mov     ah,3ch
        xor     cx,cx
        int     21h
        jc      @@end
        mov     bx,ax

        push    es
        push    ds
        pop     es
        mov     di,O FileBuffer
        mov     ax,[RobotNum]
        stosw
        mov     ax,[InstrNum]
        stosw
        mov     eax,[Seed]
        stosd
        mov     eax,[CommandCounter]
        stosd
        mov     eax,[MutNum]
        stosd
        mov     al,[Missiles]
        stosb
        mov     al,[Mutations]
        stosb
        mov     al,[DefDec]
        stosb
        mov     al,[DefInc]
        stosb
        mov     al,[MutationTimes]
        stosb
        pop     es
        mov     dx,O FileBuffer
        mov     ah,40h
        mov     cx,21
        int     21h
        jc      @@end

        mov     bp,[RobotNum]
        mov     esi,[RoboStart]
@@1:    mov     cl,4
        mov     di,O FileBuffer
        mov     dx,di
@@2:    mov     eax,[fs:esi]
        mov     [di],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@2
        mov     ah,40h
        mov     cx,16
        int     21h
        jc      @@end
        dec     bp
        jnz     @@1

        mov     bp,[RobotNum]
        mov     esi,[MissileStart]
@@3:    mov     cl,4*16
        mov     di,O FileBuffer
        mov     dx,di
@@4:    mov     eax,[fs:esi]
        mov     [di],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@4
        mov     ah,40h
        mov     cx,16*16
        int     21h
        jc      @@end
        dec     bp
        jnz     @@3

        mov     bp,[RobotNum]
        mov     esi,[DNAStart]
@@5:    mov     cl,128
        mov     di,O FileBuffer
        mov     dx,di
@@6:    mov     eax,[fs:esi]
        mov     [di],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@6
        mov     ah,40h
        mov     cx,512
        int     21h
        jc      @@end
        dec     bp
        jnz     @@5

        mov     ah,3eh
        int     21h

@@end:  ret
ENDP

PROC    SShotLoad
        mov     si,O SShotLoadName
        call    CountLength
        test    bp,bp
        jz      @@end
        push    es
        push    ds
        pop     es
        mov     cx,bp
        mov     si,O SShotLoadName
        mov     di,O TempName
rep     movsb
        pop     es
        mov     [D di],'pns.'
        mov     [B di+4],0

        mov     dx,O TempName
        mov     ax,3d00h
        int     21h
        jc      @@end
        mov     bx,ax

        mov     dx,O FileBuffer
        mov     ah,3fh
        mov     cx,21
        int     21h
        jc      @@end

        mov     si,O FileBuffer
        lodsw
        mov     [RobotNum],ax
        lodsw
        mov     [InstrNum],ax
        lodsd
        mov     [Seed],eax
        lodsd
        mov     [CommandCounter],eax
        lodsd
        mov     [MutNum],eax
        lodsb
        mov     [Missiles],al
        lodsb
        mov     [Mutations],al
        lodsb
        mov     [DefDec],al
        lodsb
        mov     [DefInc],al
        lodsb
        mov     [MutationTimes],al

        push    [Seed]
        push    bx
        push    es
        mov     ebx,[FlatPos]
        call    StartREvolution
        pop     es
        pop     bx
        pop     [Seed]

        mov     bp,[RobotNum]
        mov     esi,[RoboStart]
@@1:    mov     dx,O FileBuffer
        mov     ah,3fh
        mov     cx,16
        int     21h
        jc      @@end
        mov     di,O FileBuffer
        mov     cl,4
@@2:    mov     eax,[di]
        mov     [fs:esi],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@2
        dec     bp
        jnz     @@1

        mov     bp,[RobotNum]
        mov     esi,[MissileStart]
@@3:    mov     dx,O FileBuffer
        mov     ah,3fh
        mov     cx,16*16
        int     21h
        jc      @@end
        mov     di,O FileBuffer
        mov     cl,4*16
@@4:    mov     eax,[di]
        mov     [fs:esi],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@4
        dec     bp
        jnz     @@3

        mov     bp,[RobotNum]
        mov     esi,[DNAStart]
@@5:    mov     dx,O FileBuffer
        mov     ah,3fh
        mov     cx,512
        int     21h
        jc      @@end
        mov     di,O FileBuffer
        mov     cl,128
@@6:    mov     eax,[di]
        mov     [fs:esi],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@6
        dec     bp
        jnz     @@5

        mov     ah,3eh
        int     21h

        call    InitLList

        mov     [ActRobot],0
        call    CopyRegsToVar
        call    ChangeActWindow         ;redraw screen

@@end:  ret
ENDP

PROC    CopyVirInfoToVar
        movzx   esi,[ActRobot]
        shl     esi,8
        add     esi,[MissileStart]
        mov     di,O VirInfo
        mov     cl,64
@@1:    mov     eax,[fs:esi]
        mov     [di],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@1
        ret
ENDP

PROC    _SingleRun
        movzx   eax,[InstrNum]
        add     [CommandCounter],eax
        call    ProcessREvolution
        call    MOVEvol
        call    CopyRegsToVar
        call    CopyVirInfoToVar
        mov     si,O _NIP
        mov     cl,142
@@1:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@1
        ret
ENDP

PROC    _ActRobUp
        mov     ax,[ActRobot]
        inc     ax
        cmp     ax,[RobotNum]
        jne     @@1
        dec     ax
@@1:    mov     [ActRobot],ax
        call    CopyRegsToVar
        call    CopyVirInfoToVar
        mov     si,O _NIP
        mov     cl,21
@@2:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@2
        mov     si,O TXCoord
        mov     cl,119
@@3:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@3
        ret
ENDP

PROC    _ActRobDn
        mov     ax,[ActRobot]
        dec     ax
        cmp     ax,65535
        jne     @@1
        inc     ax
@@1:    mov     [ActRobot],ax
        call    CopyRegsToVar
        call    CopyVirInfoToVar
        mov     si,O _NIP
        mov     cl,21
@@2:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@2
        mov     si,O TXCoord
        mov     cl,119
@@3:    push    cx
        push    si
        call    ReDrawObject
        pop     si
        pop     cx
        mov     si,[si+Number.ONext]
        dec     cl
        jnz     @@3
        ret
ENDP

PROC    NrTeamsUp
        mov     al,[NrTeams]
        inc     al
        cmp     al,7
        jne     @@1
        dec     al
@@1:    mov     [NrTeams],al
        mov     si,O NNrTeams
        call    ReDrawObject
        ret
ENDP

PROC    NrTeamsDn
        mov     al,[NrTeams]
        dec     al
        test    al,al
        jnz     @@1
        inc     al
@@1:    mov     [NrTeams],al
        mov     si,O NNrTeams
        call    ReDrawObject
        ret
ENDP

PROC    TeamsOk
;check if all files are OK
        mov     [Temp],0
@@1:    mov     si,[Temp]
        imul    si,20
        add     si,O Team0Name
        push    si
        call    CountLength
        pop     si
        test    bp,bp
        jz      @@end
        push    es
        push    ds
        pop     es
        mov     cx,bp
        mov     di,O TempName
rep     movsb
        pop     es
        mov     [D di],'mcr.'
        mov     [B di+4],0

        mov     dx,O TempName
        mov     ax,3d00h
        int     21h
        jc      @@end
        mov     bx,ax
        mov     ah,3eh
        int     21h
        jc      @@end

        inc     [Temp]
        mov     ax,[Temp]
        cmp     al,[NrTeams]
        jb      @@1
        mov     ax,[NrRobots]
        mov     [RobotNum],ax
        mov     ebx,[FlatPos]
        push    es
        call    StartRevolution
        pop     es
;all files are OK!
        mov     ax,[RobotNum]
        xor     dx,dx
        movzx   bx,[NrTeams]
        div     bx
        mov     [Temp1],ax
        mov     [Temp2],dx

        mov     [Temp],0        ;team-counter
        mov     [Temp3],0       ;robot-counter
@@2:    mov     si,[Temp]
        imul    si,20
        add     si,O Team0Name
        push    si
        call    CountLength
        pop     si
        push    es
        push    ds
        pop     es
        mov     cx,bp
        mov     di,O TempName
rep     movsb
        pop     es
        mov     [D di],'mcr.'
        mov     [B di+4],0

        mov     dx,O TempName
        mov     ax,3d00h
        int     21h
        jc      @@end
        mov     bx,ax
        mov     ah,3fh
        mov     dx,O FileBuffer
        mov     cx,496
        int     21h
        jc      @@end
        mov     ah,3eh
        int     21h
        jc      @@end
;file is in buffer now
        mov     bp,[Temp2]
        cmp     [Temp],0
        jz      @@FirstTeam
        xor     bp,bp
@@FirstTeam:
        add     bp,[Temp1]
@@3:    movzx   edi,[Temp3]
        shl     edi,4
        add     edi,[RoboStart]
        mov     al,[B Temp]
        mov     [fs:edi+0fh],al

        movzx   esi,[Temp3]
        shl     esi,9
        add     esi,[DNAStart]
        mov     [B fs:esi],8    ;init IP
        mov     [B fs:esi+1],0
        mov     [D fs:esi+2],0
        mov     [D fs:esi+6],0
        mov     [W fs:esi+10],0
        mov     [W fs:esi+14],0
        add     esi,16
        mov     di,O FileBuffer
        mov     cl,496/4
@@4:    mov     eax,[di]
        mov     [fs:esi],eax
        add     esi,4
        add     di,4
        dec     cl
        jnz     @@4

        inc     [Temp3]
        dec     bp
        jnz     @@3

        inc     [Temp]
        mov     ax,[Temp]
        cmp     al,[NrTeams]
        jb      @@2

        mov     [CommandCounter],0
        mov     [MutNum],0
        mov     [ActRobot],0
        call    CopyRegsToVar

        jmp     CloseWin

@@end:  ret
ENDP

PROC    NrRobotsUp
        mov     ax,[NrRobots]
        inc     ax
        cmp     ax,2048
        jne     @@1
        dec     ax
@@1:    mov     [NrRobots],ax
        mov     si,O NNrRobots
        call    ReDrawObject
        ret
ENDP

PROC    NrRobotsDn
        mov     ax,[NrRobots]
        dec     ax
        cmp     ax,15
        jne     @@1
        inc     al
@@1:    mov     [NrRobots],ax
        mov     si,O NNrRobots
        call    ReDrawObject
        ret
ENDP

PROC    MutTimesUp
        mov     al,[MutationTimes]
        inc     al
        test    al,al
        jne     @@1
        dec     al
@@1:    mov     [MutationTimes],al
        mov     [MCounter],0
        mov     si,O NMutTimes
        call    ReDrawObject
        ret
ENDP

PROC    MutTimesDn
        mov     al,[MutationTimes]
        dec     al
        cmp     al,255
        jne     @@1
        inc     al
@@1:    mov     [MutationTimes],al
        mov     [MCounter],0
        mov     si,O NMutTimes
        call    ReDrawObject
        ret
ENDP

PROC    OpenInfo
        mov     [D Team0Nr],0
        mov     [D Team2Nr],0
        mov     [D Team4Nr],0
        mov     bp,[RobotNum]
        mov     esi,[RoboStart]
        add     esi,0fh
@@1:    movzx   bx,[fs:esi]
        shl     bx,1
        inc     [W bx+Team0Nr]
        add     esi,16
        dec     bp
        jnz     @@1
        mov     [ActWindow],4
        call    ChangeActWindow
        ret
ENDP

start:  mov     ax,Data
        mov     ds,ax

        xor     ax,ax
        int     33h
        inc     ax
        jz      @@ok1
        Print   NoMouse
        jmp     @@end
@@ok1:
        mov     [MinReq],1024
        call    InitFlat
        cmp     [FlatInst],0
        jz      @@end

        xor     ax,ax
        mov     fs,ax

        mov     [RobotNum],256
        mov     ebx,[FlatPos]
        push    es
        call    StartRevolution
        pop     es

        call    InitGUI
        call    CopyRegsToVar
        call    RunGUI

        call    DeInitFlat
        mov     ax,3h
        int     10h
@@end:  mov     ax,4c00h
        int     21h
ENDS

SEGMENT IData   PUBLIC

CommandCounter  DD      0
RefreshRate     DW      8
ActRobot        DW      0

MainWin         Window  {ONext=O WinEnd,OX=0,OY=0,OWidth=640,OHeight=480,OInside=O TTitle}

TTitle          TextField {ONext=O BEnd,OX=0,OY=0,OText=O TTitleTXT}
TTitleTXT       DB      'R-Evolution - geschrieben von Denis Kovacs und Christoph Groth in 100% Assembler',0
BEnd            Button  {OCall=O OpenEnd,ONext=O BVirInfo,OX=470,OY=450,OWidth=170,OHeight=30,OText=O BEndTXT}
BEndTXT         DB      'Beenden',0

BVirInfo        Button  {OCall=O OpenVirInfo,ONext=O BTeams,OX=290,OY=370,OWidth=170,OHeight=30,OText=O BVirInfoTXT}
BVirInfoTXT     DB      'Viren-Infos',0
BTeams          Button  {OCall=O OpenTeams,ONext=O BInfo,OX=290,OY=410,OWidth=170,OHeight=30,OText=O BTeamsTXT}
BTeamsTXT       DB      'Team-Einstellungen',0
BInfo           Button  {OCall=O OpenInfo,ONext=O BRunR,OX=290,OY=450,OWidth=170,OHeight=30,OText=O BInfoTXT}
BInfoTXT        DB      'Team-Statistik',0
BRunR           Button  {OCall=O RunREvolution,ONext=O BSingleR,OX=470,OY=370,OWidth=170,OHeight=30,OText=O BRunRTXT}
BRunRTXT        DB      'Start',0
BSingleR        Button  {OCall=O SingleRun,ONext=O NComm,OX=470,OY=410,OWidth=170,OHeight=30,ORepeat=1,OText=O BSingleRTXT}
BSingleRTXT     DB      'Einzelschritt',0
NComm           Number  {ONext=O NMutNum,OX=300,OY=28,OWidth=300,OLength=2,OVar=O CommandCounter,OText=O NCommTXT}
NCommTXT        DB      'abgearbeitete Befehle:',0
NMutNum         Number  {ONext=O FRobots,OX=300,OY=50,OWidth=300,OLength=2,OVar=O MutNum,OText=O NMutNumTXT}
NMutNumTXT      DB      'Mutationen:',0
FRobots         Frame   {ONext=O PRobots,OX=16-5,OY=32-5,OWidth=256+9,OHeight=256+9}
PRobots         Picture {ONext=O NIP,OX=16,OY=32,OWidth=256,OHeight=256,OCall=O ChooseRobot,ORefresh=O DrawRobots}

NIP             Number  {ONext=O NR1,OX=300,OY=72,OWidth=50,OLength=0,OVar=O RegIP,OText=O NIPTXT}
NIPTXT          DB      'IP=',0
NR1             Number  {ONext=O NR2,OX=300,OY=88,OWidth=50,OLength=0,OVar=O RegR1,OText=O NR1TXT}
NR1TXT          DB      'R1=',0
NR2             Number  {ONext=O NR3,OX=300,OY=104,OWidth=50,OLength=0,OVar=O RegR2,OText=O NR2TXT}
NR2TXT          DB      'R2=',0
NR3             Number  {ONext=O NR4,OX=300,OY=120,OWidth=50,OLength=0,OVar=O RegR3,OText=O NR3TXT}
NR3TXT          DB      'R3=',0
NR4             Number  {ONext=O NR5,OX=380,OY=72,OWidth=50,OLength=0,OVar=O RegR4,OText=O NR4TXT}
NR4TXT          DB      'R4=',0
NR5             Number  {ONext=O NR6,OX=380,OY=88,OWidth=50,OLength=0,OVar=O RegR5,OText=O NR5TXT}
NR5TXT          DB      'R5=',0
NR6             Number  {ONext=O NR7,OX=380,OY=104,OWidth=50,OLength=0,OVar=O RegR6,OText=O NR6TXT}
NR6TXT          DB      'R6=',0
NR7             Number  {ONext=O NR8,OX=380,OY=120,OWidth=50,OLength=0,OVar=O RegR7,OText=O NR7TXT}
NR7TXT          DB      'R7=',0
NR8             Number  {ONext=O NR9,OX=460,OY=72,OWidth=50,OLength=0,OVar=O RegR8,OText=O NR8TXT}
NR8TXT          DB      'R8=',0
NR9             Number  {ONext=O NEA,OX=460,OY=88,OWidth=50,OLength=0,OVar=O RegR9,OText=O NR9TXT}
NR9TXT          DB      'R9=',0
NEA             Number  {ONext=O NCA,OX=460,OY=104,OWidth=50,OLength=0,OVar=O RegEA,OText=O NEATXT}
NEATXT          DB      'EA=',0
NCA             Number  {ONext=O NRA,OX=460,OY=120,OWidth=50,OLength=0,OVar=O RegCA,OText=O NCATXT}
NCATXT          DB      'CA=',0
NRA             Number  {ONext=O NRS,OX=540,OY=72,OWidth=50,OLength=0,OVar=O RegRA,OText=O NRATXT}
NRATXT          DB      'RA=',0
NRS             Number  {ONext=O NCF,OX=540,OY=88,OWidth=50,OLength=0,OVar=O RegRS,OText=O NRSTXT}
NRSTXT          DB      'RS=',0
NCF             Number  {ONext=O NZF,OX=540,OY=104,OWidth=50,OLength=0,OVar=O RegCF,OText=O NCFTXT}
NCFTXT          DB      'CF=',0
NZF             Number  {ONext=O NXPos,OX=540,OY=120,OWidth=50,OLength=0,OVar=O RegZF,OText=O NZFTXT}
NZFTXT          DB      'ZF=',0

NXPos           Number  {ONext=O NYPos,OX=300,OY=142,OWidth=130,OLength=1,OVar=O RobXPos,OText=O NXPosTXT}
NXPosTXT        DB      'X-Position=',0
NYPos           Number  {ONext=O NSV,OX=460,OY=142,OWidth=130,OLength=1,OVar=O RobYPos,OText=O NYPosTXT}
NYPosTXT        DB      'Y-Position=',0

NSV             Number  {ONext=O NSD,OX=300,OY=164,OWidth=130,OLength=0,OVar=O SV,OText=O NSVTXT}
NSVTXT          DB      'Viren-Status=',0
NSD             Number  {ONext=O NActRob,OX=460,OY=164,OWidth=130,OLength=0,OVar=O SD,OText=O NSDTXT}
NSDTXT          DB      'Schutzschild=',0

BUpTXT          DB      24,0
BDnTXT          DB      25,0
NActRob         Number  {ONext=O BActRobUp,OX=300,OY=186,OWidth=230,OLength=1,OText=O NActRobTXT,OVar=O ActRobot}
NActRobTXT      DB      'aktueller Roboter:',0
BActRobUp       Button  {OCall=O ActRobUp,ONext=O BActRobDn,OX=540,OY=185,OWidth=30,OHeight=18,ORepeat=1,OText=O BUpTXT}
BActRobDn       Button  {OCall=O ActRobDn,ONext=O BRS,OX=575,OY=185,OWidth=30,OHeight=18,ORepeat=1,OText=O BDnTXT}

BRS             Button  {OCall=O RobSave,ONext=O IRS,OX=290,OY=214,OWidth=160,OHeight=24,OText=O BRSTXT}
BRSTXT          DB      'Roboter speichern',0
IRS             InputField {ONext=O BRL,OX=460,OY=214,OWidth=180,OHeight=24,OMaxSize=20,OText=O RobSaveName}
BRL             Button  {OCall=O RobLoad,ONext=O IRL,OX=290,OY=244,OWidth=160,OHeight=24,OText=O BRLTXT}
BRLTXT          DB      'Roboter laden',0
IRL             InputField {ONext=O BSS,OX=460,OY=244,OWidth=180,OHeight=24,OMaxSize=20,OText=O RobLoadName}

BSS             Button  {OCall=O SShotSave,ONext=O ISS,OX=290,OY=274,OWidth=160,OHeight=24,OText=O BSSTXT}
BSSTXT          DB      'Snapshot speichern',0
ISS             InputField {ONext=O BSL,OX=460,OY=274,OWidth=180,OHeight=24,OMaxSize=20,OText=O SShotSaveName}
BSL             Button  {OCall=O SShotLoad,ONext=O ISL,OX=290,OY=304,OWidth=160,OHeight=24,OText=O BSLTXT}
BSLTXT          DB      'Snapshot laden',0
ISL             InputField {ONext=O NMutTimes,OX=460,OY=304,OWidth=180,OHeight=24,OMaxSize=20,OText=O SShotLoadName}

NMutTimes       Number  {ONext=O BMutTimesUP,OX=0,OY=299,OWidth=200,OLength=0,OText=O NMutTimesTXT,OVar=O MutationTimes}
NMutTimesTXT    DB      'Mutations-HÑufigkeit:',0
BMutTimesUp     Button  {OCall=O MutTimesUp,ONext=O BMutTimesDn,OX=210,OY=298,OWidth=30,OHeight=18,ORepeat=1,OText=O BUpTXT}
BMutTimesDn     Button  {OCall=O MutTimesDn,ONext=O NRefrR,OX=245,OY=298,OWidth=30,OHeight=18,ORepeat=1,OText=O BDnTXT}

NRefrR          Number  {ONext=O BRefrRUP,OX=0,OY=323,OWidth=200,OLength=1,OText=O NRefrRTXT,OVar=O RefreshRate}
NRefrRTXT       DB      'Feld-Refreshrate:',0
BRefrRUp        Button  {OCall=O RefrRUp,ONext=O BRefrRDn,OX=210,OY=322,OWidth=30,OHeight=18,ORepeat=1,OText=O BUpTXT}
BRefrRDn        Button  {OCall=O RefrRDn,ONext=O CHex,OX=245,OY=322,OWidth=30,OHeight=18,ORepeat=1,OText=O BDnTXT}

CHex            CheckBox {ONext=O CGrid,OX=0,OY=346,OWidth=176,OCall=O CloseWin,OText=O CHexTXT,OVar=O Hex}
CHexTXT         DB      'hexadezimale Zahlen',0
CGrid           CheckBox {ONext=O CZoom,OCall=DrawRobots,OX=0,OY=372,OWidth=72,OText=O CGridTXT,OVar=O Grid}
CGridTXT        DB      'Gitter',0
CZoom           CheckBox {ONext=O CBlank,OX=0,OY=398,OWidth=120,OCall=O DrawRobots,OText=O CZoomTXT,OVar=O Zoom}
CZoomTXT        DB      'Vergrî·erung',0
CBlank          CheckBox {ONext=0,OX=0,OY=424,OWidth=144,OText=O CBlankTXT,OVar=O Blank}
CBlankTXT       DB      'Bild-Ausblenden',0

WinEnd          Window  {ONext=O WinVirInfo,OX=100,OY=180,OWidth=440,OHeight=120,OInside=O TEnd}
TEnd            TextField {ONext=O BYeah,OX=64,OY=20,OText=O TEndTXT}
TEndTXT         DB      'Mîchtest du R-Evolution wirklich beenden?',0
BYeah           Button  {OCall=O Adios,ONext=O BNo,OX=10,OY=80,OWidth=200,OHeight=30,OText=O BYeahTXT}
BYeahTXT        DB      'Traurig, aber wahr...',0
BNo             Button  {OCall=O CloseWin,ONext=0,OX=230,OY=80,OWidth=200,OHeight=30,OText=O BNoTXT}
BNoTXT          DB      'Wie kommst Du darauf?!',0

WinVirInfo      Window  {ONext=WinTeams,OX=80,OY=28,OWidth=480,OHeight=424,OInside=O BVirInfoClose}
BVirInfoClose   Button  {OCall=O CloseWin,ONext=O _BSingleR,OX=320,OY=384,OWidth=150,OHeight=30,OText=O BVirInfoCloseTXT}
BVirInfoCloseTXT DB     'Schlie·en',0
_BSingleR       Button  {OCall=O _SingleRun,ONext=O _NIP,OX=10,OY=384,OWidth=150,ORepeat=1,OHeight=30,OText=O BSingleRTXT}

_NIP            Number  {ONext=O _NR1,OX=10,OY=50+242,OWidth=50,OLength=0,OVar=O RegIP,OText=O NIPTXT}
_NR1            Number  {ONext=O _NR2,OX=10,OY=66+242,OWidth=50,OLength=0,OVar=O RegR1,OText=O NR1TXT}
_NR2            Number  {ONext=O _NR3,OX=10,OY=82+242,OWidth=50,OLength=0,OVar=O RegR2,OText=O NR2TXT}
_NR3            Number  {ONext=O _NR4,OX=10,OY=98+242,OWidth=50,OLength=0,OVar=O RegR3,OText=O NR3TXT}
_NR4            Number  {ONext=O _NR5,OX=90,OY=50+242,OWidth=50,OLength=0,OVar=O RegR4,OText=O NR4TXT}
_NR5            Number  {ONext=O _NR6,OX=90,OY=66+242,OWidth=50,OLength=0,OVar=O RegR5,OText=O NR5TXT}
_NR6            Number  {ONext=O _NR7,OX=90,OY=82+242,OWidth=50,OLength=0,OVar=O RegR6,OText=O NR6TXT}
_NR7            Number  {ONext=O _NR8,OX=90,OY=98+242,OWidth=50,OLength=0,OVar=O RegR7,OText=O NR7TXT}
_NR8            Number  {ONext=O _NR9,OX=170,OY=50+242,OWidth=50,OLength=0,OVar=O RegR8,OText=O NR8TXT}
_NR9            Number  {ONext=O _NEA,OX=170,OY=66+242,OWidth=50,OLength=0,OVar=O RegR9,OText=O NR9TXT}
_NEA            Number  {ONext=O _NCA,OX=170,OY=82+242,OWidth=50,OLength=0,OVar=O RegEA,OText=O NEATXT}
_NCA            Number  {ONext=O _NRA,OX=170,OY=98+242,OWidth=50,OLength=0,OVar=O RegCA,OText=O NCATXT}
_NRA            Number  {ONext=O _NRS,OX=250,OY=50+242,OWidth=50,OLength=0,OVar=O RegRA,OText=O NRATXT}
_NRS            Number  {ONext=O _NCF,OX=250,OY=66+242,OWidth=50,OLength=0,OVar=O RegRS,OText=O NRSTXT}
_NCF            Number  {ONext=O _NZF,OX=250,OY=82+242,OWidth=50,OLength=0,OVar=O RegCF,OText=O NCFTXT}
_NZF            Number  {ONext=O _NXPos,OX=250,OY=98+242,OWidth=50,OLength=0,OVar=O RegZF,OText=O NZFTXT}

_NXPos          Number  {ONext=O _NYPos,OX=320,OY=50+242,OWidth=130,OLength=1,OVar=O RobXPos,OText=O NXPosTXT}
_NYPos          Number  {ONext=O _NComm,OX=320,OY=66+242,OWidth=130,OLength=1,OVar=O RobYPos,OText=O NYPosTXT}
_NComm          Number  {ONext=O _NMutNum,OX=320,OY=82+242,OWidth=150,OLength=2,OVar=O CommandCounter,OText=O _NCommTXT}
_NCommTXT       DB      'Befehle:',0
_NMutNum        Number  {ONext=O _NActRob,OX=320,OY=98+242,OWidth=150,OLength=2,OVar=O MutNum,OText=O _NMutNumTXT}
_NMutNumTXT     DB      'Mutationen:',0

_NActRob        Number  {ONext=O _BActRobUp,OX=10,OY=362,OWidth=230,OLength=1,OText=O NActRobTXT,OVar=O ActRobot}
_BActRobUp      Button  {OCall=O _ActRobUp,ONext=O _BActRobDn,OX=250,OY=361,OWidth=30,OHeight=18,ORepeat=1,OText=O BUpTXT}
_BActRobDn      Button  {OCall=O _ActRobDn,ONext=O TXCoord,OX=285,OY=361,OWidth=30,OHeight=18,ORepeat=1,OText=O BDnTXT}

TXCoord         TextField {ONext=O TYCoord,OX=10,OY=10,OText=O TXCoordTXT}
TXCoordTXT      DB      'X-Coord',0
TYCoord         TextField {ONext=O TIncFl,OX=74,OY=10,OText=O TYCoordTXT}
TYCoordTXT      DB      'Y-Coord',0
TIncFl          TextField {ONext=O TID,OX=138,OY=10,OText=O TIncFlTXT}
TIncFlTXT       DB      'IncFlag',0
TID             TextField {ONext=O TIncX,OX=202,OY=10,OText=O TIDTXT}
TIDTXT          DB      'ID-Byte',0
TIncX           TextField {ONext=O TIncY,OX=266,OY=10,OText=O TIncXTXT}
TIncXTXT        DB      'IncX',0
TIncY           TextField {ONext=O TNextVir,OX=330,OY=10,OText=O TIncYTXT}
TIncYTXT        DB      'IncY',0
TNextVir        TextField {ONext=O VirInfos,OX=394,OY=10,OText=O TNextVirTXT}
TNextVirTXT     DB      'NextVir',0

I=0
LABEL   VirInfos        BYTE
REPT    16
LOCAL   N1,N2,N3,N4,N5,N6,N7,N8
N1      Number  {ONext=O N2,OX=10,OY=30+I*16,OWidth=56,OLength=1,OVar=O VirInfo+I*16+2}
N2      Number  {ONext=O N3,OX=74,OY=30+I*16,OWidth=56,OLength=1,OVar=O VirInfo+I*16+6}
N3      Number  {ONext=O N4,OX=138,OY=30+I*16,OWidth=56,OLength=0,OVar=O VirInfo+I*16+8}
N4      Number  {ONext=O N5,OX=202,OY=30+I*16,OWidth=56,OLength=0,OVar=O VirInfo+I*16+9}
N5      Number  {ONext=O N6,OX=266,OY=30+I*16,OWidth=56,OLength=1,OVar=O VirInfo+I*16+10}
N6      Number  {ONext=O N7,OX=330,OY=30+I*16,OWidth=56,OLength=1,OVar=O VirInfo+I*16+12}
IF      I LT 15
N7      Number  {ONext=O N8,OX=394,OY=30+I*16,OWidth=56,OLength=1,OVar=O VirInfo+I*16+14}
ELSE
N7      Number  {ONext=0,OX=394,OY=30+I*16,OWidth=56,OLength=1,OVar=O VirInfo+I*16+14}
ENDIF
LABEL   N8      BYTE
I=I+1
ENDM

WinTeams        Window  {ONext=O WinInfo,OX=120,OY=112,OWidth=400,OHeight=256,OInside=O BTeamsClose}
BTeamsClose     Button  {OCall=O CloseWin,ONext=O BTeamsOk,OX=240,OY=216,OWidth=150,OHeight=30,OText=O BTeamsCloseTXT}
BTeamsCloseTXT  DB      'Abbrechen',0
BTeamsOk        Button  {OCall=O TeamsOk,ONext=O NNrTeams,OX=10,OY=216,OWidth=150,OHeight=30,OText=O BTeamsOkTXT}
BTeamsOkTXT     DB      'Akzeptieren',0
NNrTeams        Number  {ONext=O BNrTeamsUp,OX=10,OY=10,OWidth=80,OLength=0,OText=O NNrTeamsTXT,OVar=O NrTeams}
NNrTeamsTXT     DB      'Teams:',0
BNrTeamsUp      Button  {OCall=O NrTeamsUp,ONext=O BNrTeamsDn,OX=100,OY=9,OWidth=30,OHeight=18,OText=O BUpTXT}
BNrTeamsDn      Button  {OCall=O NrTeamsDn,ONext=O NNrRobots,OX=135,OY=9,OWidth=30,OHeight=18,OText=O BDnTXT}
NNrRobots       Number  {ONext=O BNrRobotsUp,OX=200,OY=10,OWidth=115,OLength=1,OText=O NNrRobotsTXT,OVar=O NrRobots}
NNrRobotsTXT    DB      'Roboter:',0
BNrRobotsUp     Button  {OCall=O NrRobotsUp,ONext=O BNrRobotsDn,OX=325,OY=9,OWidth=30,OHeight=18,ORepeat=1,OText=O BUpTXT}
BNrRobotsDn     Button  {OCall=O NrRobotsDn,ONext=O TTeam0,OX=360,OY=9,OWidth=30,OHeight=18,ORepeat=1,OText=O BDnTXT}
TTeam0          TextField {ONext=O ITeam0,OX=10,OY=40,OText=O TTeam0TXT}
TTeam0TXT       DB      '0) rotes Team:',0
ITeam0          InputField {ONext=O TTeam1,OX=210,OY=36,OWidth=180,OHeight=24,OMaxSize=20,OText=O Team0Name}
TTeam1          TextField {ONext=O ITeam1,OX=10,OY=70,OText=O TTeam1TXT}
TTeam1TXT       DB      '1) blaues Team:',0
ITeam1          InputField {ONext=O TTeam2,OX=210,OY=66,OWidth=180,OHeight=24,OMaxSize=20,OText=O Team1Name}
TTeam2          TextField {ONext=O ITeam2,OX=10,OY=100,OText=O TTeam2TXT}
TTeam2TXT       DB      '2) gelbes Team:',0
ITeam2          InputField {ONext=O TTeam3,OX=210,OY=96,OWidth=180,OHeight=24,OMaxSize=20,OText=O Team2Name}
TTeam3          TextField {ONext=O ITeam3,OX=10,OY=130,OText=O TTeam3TXT}
TTeam3TXT       DB      '3) blaugrÅnes Team:',0
ITeam3          InputField {ONext=O TTeam4,OX=210,OY=126,OWidth=180,OHeight=24,OMaxSize=20,OText=O Team3Name}
TTeam4          TextField {ONext=O ITeam4,OX=10,OY=160,OText=O TTeam4TXT}
TTeam4TXT       DB      '4) violettes Team:',0
ITeam4          InputField {ONext=O TTeam5,OX=210,OY=156,OWidth=180,OHeight=24,OMaxSize=20,OText=O Team4Name}
TTeam5          TextField {ONext=O ITeam5,OX=10,OY=190,OText=O TTeam5TXT}
TTeam5TXT       DB      '5) dunkelgrÅnes Team:',0
ITeam5          InputField {ONext=0,OX=210,OY=186,OWidth=180,OHeight=24,OMaxSize=20,OText=O Team5Name}

WinInfo Window  {ONext=0,OX=160,OY=120,OWidth=320,OHeight=240,OInside=O BInfoClose}
BInfoClose      Button  {OCall=O CloseWin,ONext=O NTeam0,OX=85,OY=200,OWidth=150,OHeight=30,OText=O BInfoCloseTXT}
BInfoCloseTXT   DB      'Schlie·en',0
NTeam0          Number  {ONext=NTeam1,OX=20,OY=20,OWidth=280,OLength=1,OText=O TTeam0TXT,OVar=Team0Nr}
NTeam1          Number  {ONext=NTeam2,OX=20,OY=36,OWidth=280,OLength=1,OText=O TTeam1TXT,OVar=Team1Nr}
NTeam2          Number  {ONext=NTeam3,OX=20,OY=52,OWidth=280,OLength=1,OText=O TTeam2TXT,OVar=Team2Nr}
NTeam3          Number  {ONext=NTeam4,OX=20,OY=68,OWidth=280,OLength=1,OText=O TTeam3TXT,OVar=Team3Nr}
NTeam4          Number  {ONext=NTeam5,OX=20,OY=84,OWidth=280,OLength=1,OText=O TTeam4TXT,OVar=Team4Nr}
NTeam5          Number  {ONext=0,OX=20,OY=100,OWidth=280,OLength=1,OText=O TTeam5TXT,OVar=Team5Nr}

Zoom            DB      0
Grid            DB      0
Blank           DB      0
NrTeams         DB      1

NoMouse         DB      'no mouse driver installed',0dh,0ah,'$'
RobSaveName     DB      0,19 DUP (?)
RobLoadName     DB      0,19 DUP (?)
SShotSaveName   DB      0,19 DUP (?)
SShotLoadName   DB      0,19 DUP (?)
Team0Name       DB      0,19 DUP (?)
Team1Name       DB      0,19 DUP (?)
Team2Name       DB      0,19 DUP (?)
Team3Name       DB      0,19 DUP (?)
Team4Name       DB      0,19 DUP (?)
Team5Name       DB      0,19 DUP (?)

No      EQU     0
_Const  EQU     1
RegConst4 EQU   2
RegConst8 EQU   2+128
RegX1   EQU     3
RegX2   EQU     4
RegX3   EQU     5

LABEL   Commands BYTE
        DB      No        ,3,'nop   '

        DB      _Const    ,5,'firev '
        DB      RegX1     ,5,'firev '
        DB      _Const    ,5,'firea '
        DB      RegX1     ,5,'firea '
        DB      RegX1     ,5,'getsv '
        DB      RegX1     ,5,'getsd '
        DB      No        ,6,'setdir'

REPT    8
        DB      No        ,3,'nop   '
ENDM

REPT    16
        DB      RegConst8 ,3,'mov   '
ENDM
REPT    16
        DB      RegConst8 ,3,'add   '
ENDM
REPT    16
        DB      RegConst8 ,3,'sub   '
ENDM
REPT    16
        DB      RegConst8 ,3,'and   '
ENDM
REPT    16
        DB      RegConst8 ,2,'or    '
ENDM
REPT    16
        DB      RegConst8 ,3,'xor   '
ENDM
REPT    16
        DB      RegConst8 ,4,'test  '
ENDM
REPT    16
        DB      RegConst8 ,3,'cmp   '
ENDM

        DB      RegX2     ,3,'mov   '
        DB      RegX2     ,3,'add   '
        DB      RegX2     ,3,'sub   '
        DB      RegX2     ,4,'xchg  '
        DB      RegX1     ,3,'inc   '
        DB      RegX1     ,3,'dec   '
        DB      RegConst4 ,3,'shl   '
        DB      RegConst4 ,3,'shr   '
        DB      RegConst4 ,3,'rol   '
        DB      RegConst4 ,3,'ror   '
        DB      RegX1     ,3,'neg   '
        DB      RegX2     ,3,'and   '
        DB      RegX2     ,2,'or    '
        DB      RegX2     ,3,'xor   '
        DB      RegX2     ,4,'test  '
        DB      RegX2     ,3,'cmp   '

REPT    16
        DB      RegX3     ,5,'scanr '
ENDM
REPT    16
        DB      RegX3     ,5,'scanv '
ENDM

REPT    48
        DB      No        ,3,'nop   '
ENDM

        DB      _Const    ,3,'jmp   '
        DB      _Const    ,2,'jz    '
        DB      _Const    ,3,'jnz   '
        DB      _Const    ,2,'ja    '
        DB      _Const    ,2,'jb    '
        DB      _Const    ,3,'jae   '
        DB      _Const    ,3,'jbe   '

REPT    9
        DB      No        ,3,'nop   '
ENDM

Registers DW    'pi','1r','2r','3r','4r','5r','6r','7r','8r','9r','ae','ac','ar','sr','fc','fz'

ENDS

SEGMENT UData   PUBLIC
Team0Nr DW      ?
Team1Nr DW      ?
Team2Nr DW      ?
Team3Nr DW      ?
Team4Nr DW      ?
Team5Nr DW      ?
RefreshCounter DW ?
RobXPos DW      ?
RobYPos DW      ?
DrawRobX DW     ?
DrawRobY DW     ?
NrRobots DW     ?       ;temporary number of robots
Temp    DW      ?
Temp1   DW      ?
Temp2   DW      ?
Temp3   DW      ?
RegIP   DB      ?
RegR1   DB      ?
RegR2   DB      ?
RegR3   DB      ?
RegR4   DB      ?
RegR5   DB      ?
RegR6   DB      ?
RegR7   DB      ?
RegR8   DB      ?
RegR9   DB      ?
RegEA   DB      ?
RegCA   DB      ?
RegRA   DB      ?
RegRS   DB      ?
RegCF   DB      ?
RegZF   DB      ?
SV      DB      ?
SD      DB      ?
VirInfo DB      256 DUP (?)
TempName DB     128 DUP (?)
FileBuffer DB   8192 DUP (?)
ENDS

SEGMENT SSeg    STACK
        DB      08000h DUP(?)
ENDS

END     start