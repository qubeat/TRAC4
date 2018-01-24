unit WideStrArifm;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}



interface

type
 TFloat = Extended;

 function StrBinOP(op : WideChar; var A,B,Res : WideString) : Boolean;
 function StrCmp3(var A,B : WideString; var EQ3 : Integer) : Boolean;


implementation

uses
 SysUtils;

function StrBinOp(op : WideChar; var A,B,Res : WideString) : Boolean;
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

function StrCmp3(var A,B : WideString; var EQ3 : Integer) : Boolean;
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
  {$IFDEF FPC}
   DefaultFormatSettings.DecimalSeparator := '.';
  {$ELSE}
  {$IF CompilerVersion > 21}
   FormatSettings.DecimalSeparator := '.';
  {$ELSE}
   DecimalSeparator := '.';
  {$IFEND}
  {$ENDIF}
end.

