{$A-,R+}
{$APPTYPE CONSOLE}

program TRAC4LZ;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
  UTRAC4LZ,TRStrings,
  SysUtils;

var
 TT : TTRAC;
 procedure HelloWorld(TT : TTRAC);
 var
  i : integer;
  s : TRString;
 begin
  TT.WrTrace('Hello World',true,0);
  writeln('NumPar: ',TT.NumPars);
  s := '';
  for i:=1 to TT.NumPars do
  begin
   TT.Par(i,s);
   writeln(s)
  end;
  TT.RetStFun(s);
 end;
begin

 NumGE := false;

 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetConv(tcOEM);
  {$ELSE}
   SetConv(tcUTF8);
  {$ENDIF}
{$ENDIF}

 TT := TTRAC.Create;
 with TT do
 begin
  IniTRAC(defLenChain,defLenCF);
  InsFunTRAC('hello',HelloWorld);
  PREND:=false;
  repeat
    EvalTRAC('#(ps,#(rs))')
  until PREND;
  FinTRAC;
  Free;
 end;
end.
