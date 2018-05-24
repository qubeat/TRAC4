{$A-,R+}
{$APPTYPE CONSOLE}

program TRAC4Z;
uses
  {SysUtils,}
  UTRAC4Z;

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
  Destroy; //Free;
 end;
end.
