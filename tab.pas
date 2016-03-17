var t:text;
    r,s,c,last:real;
    b:word;
    dw:longint;

Function D2H(dez:longint):String;Var G1,M:LongInt;Hx:String;
Const W:Array[0..15] of char = '0123456789ABCDEF';
Begin
  hx:='';
  For G1:= 1 to 4 Do Begin
     Hx:=w[dez and 15]+Hx;
     dez:=dez shr 4;
  End;
  D2H:=Hx;
End;

begin
 asm
  mov al,255
  inc al
 end;
 assign(t,'TAB2.ASM');ReWrite(t);
 last:=(sin(0)/cos(0))*256;
 for b:=1 to 256 do begin
  s:= sin(b*1.40625*Pi/180);
  c:= cos(b*1.40625*Pi/180);
  If (b=64) or (b=192) then begin
    dw:=round(abs($7F00-last)/2);
    last:=$7F00;
    Writeln(t,'0'+D2H(dw),'h,');
  end else begin
   r:= (s / c) * 256;
   dw:= round(abs(r-last)/2);
   last:=r;
   Writeln(t,'0'+D2H(dw+1),'h,');
  end;
 End;
 close(t);

 Assign(t,'TAB3.aSM');REWRITE(t);
 for b:=1 to 256 do begin
  Write(t,D2H(b)+'h,'); if b and -16 = b then writeln(t);
 end;
 close(t);





end.




