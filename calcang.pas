
const winkel:real=250;
      DeltaX:real=20;
var r,c,s,w:real;

begin
 w:=winkel*1.40625;
 s:=sin(w*pi/180);
 c:=cos(w*pi/180);
 r:=DeltaX*(s/c);
 Writeln('DeltaY: ',r);

end.

