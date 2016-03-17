;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
; First Attempt of Robot-Evolution        < Kernel 1.o >      Syrius/ALPiNE  ;
;                                                                            ;
; JMPIndex: Jump-Index-Table ( 512B )                                        ;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;


JMPIndex DW @NOP     ;00h
DW @FIRECONST        ;01h
DW @FIREREG          ;02h
DW @FIRECONST        ;03h
DW @FIREREG          ;04h
DW @GETSV            ;05h
DW @GETSD            ;06h
DW @SETDIR           ;07h
DW 8 DUP (@NOP)      ;08h - 0Fh

DW @JMP              ;10h        ; Same as jump
DW 15 DUP (@MOV_IMM) ;11h

DW @ADD_IP           ;20h
DW 13 DUP (@ADD_IMM) ;21h
DW 02 DUP (@NOP)     ;2Eh - 2Fh  ; CF + ZF

DW @SUB_IP           ;30h
DW 13 DUP (@SUB_IMM) ;31h
DW 02 DUP (@NOP)     ;3Eh - 3Fh  ; CF + ZF

DW @NOP              ;40h = Nonsens
DW 13 DUP (@AND_IMM) ;41h
DW 02 DUP (@NOP)     ;4Eh - 4Fh  ; CF + ZF

DW @NOP              ;50h = Nonsens
DW 13 DUP (@OR_IMM)  ;51h
DW 02 DUP (@NOP)     ;5Eh - 5Fh

DW @NOP              ;60h = Nonsens
DW 13 DUP (@XOR_IMM) ;61h
DW 02 DUP (@NOP)     ;6Eh - 6Fh

DW @NOP              ;70h = Nonsens
DW 13 DUP (@TST_IMM) ;71h
DW 02 DUP (@NOP)

DW @NOP              ;80h = Nonsens
DW 13 DUP (@CMP_IMM) ;81h
DW 02 DUP (@NOP)

DW @MOV            ;90h
DW @ADD            ;91h
DW @SUB            ;92h
DW @XCH            ;93h
DW @INC            ;94h
DW @DEC            ;95h
DW @SHL            ;96h
DW @SHR            ;97h
DW @ROL            ;98h
DW @ROR            ;99h
DW @NEG            ;9Ah
DW @AND            ;9Bh
DW @OR             ;9Ch
DW @XOR            ;9Dh
DW @TST            ;9Eh
DW @CMP            ;9Fh


DW 16 DUP (@SCANROB)   ;A0h-AFh
DW 16 DUP (@SCANVIRUS) ;B0h-BFh
DW 48 DUP (@NOP)       ;C0h-EFh

DW @JMP            ;F0h
DW @JMP_ZF1        ;F1h
DW @JMP_ZF0        ;F2h
DW @JMP_ZF0CF0     ;F3h
DW @JMP_CF1        ;F4h
DW @JMP_CF0        ;F5h
DW @JMP_CF1ZF1     ;F6h
DW 10 dup (@NOP)   ;F7h-FFh

