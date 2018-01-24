{$A-,R+}

program trac4laz;

{$IFDEF FPC}
  {$MODE Delphi}
{$ELSE}
 {$APPTYPE CONSOLE}
{$ENDIF}

uses
  UTRAC4LZ,TRStrings,
  SysUtils;

var
 TT : TTRAC;
 procedure Params(TT : TTRAC);
 var
  i : integer;
  s : TRString;
 begin
  s := '('+ExtractFileName(ParamStr(0))+')';
  for i:=1 to ParamCount do
   s := s+',('+ParamStr(i)+')';
  //TT.WrTrace(s);
  TT.DAFS; {Clear stack}
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
  InsFunTRAC('params',Params,True,False);
  PREND:=false;
  if ParamCount > 0 then
   if FileExists(ParamStr(1)) then
     EvalTRAC('#(lf,'+ParamStr(1)+')');
  while not PREND do
    EvalTRAC('#(ps,#(rs))');
  FinTRAC;
  Free;
 end;
end.
