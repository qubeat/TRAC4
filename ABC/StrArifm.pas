unit StrArifm;

interface

type
 TFloat = Double;

 function StrBinOP(op : char; var A,B,Res : String) : Boolean;
 function StrCmp3(var A,B : String; var EQ3 : Integer) : Boolean;


implementation

{uses
 SysUtils;}

function StrBinOp(op : char; var A,B,Res : String) : Boolean;
var
 fA,fB,fRes : TFloat;
begin
 StrBinOp := true;
 try
  fA := StrToFloat(A);
  fB := StrToFloat(B);
  case op of
   '*' : fRes := fA*fB;
   '+' : fRes := fA+fB;
   '-' : fRes := fA-fB;
   '/' : fRes := fA/fB;
  end;
  Res := Format('%g',[fRes])
 except
  StrBinOp := false;
 end;
end;

function StrCmp3(var A,B : String; var EQ3 : Integer) : Boolean;
var
 fA,fB : TFloat;
begin
 StrCmp3 := true;
 try
  fA := StrToFloat(A);
  fB := StrToFloat(B);
  if fA = fB then EQ3 := 0
   else if fA > fB then EQ3 := 1 else EQ3 := -1
 except
  StrCmp3 := false;
 end;
end;

begin
  //DecimalSeparator := '.';
end.
