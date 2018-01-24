unit UTRAC4LZ;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
  uses SysUtils, Classes,
   {$IFDEF FPC}
      lazutf8classes,
   {$ENDIF}
    TRStrings;

var
 NumGE : boolean = true;

const
  defLenChain=1024*1024;
{* size of memory for "chains" (strings) *}

  defLenCF=1024*1024;
{* length of call function stack *}

{  LENC0=32; }

type

  letter = integer;
  letters = array of letter;

  TRChar = WideChar;
  TRString = WideString;

  CHAIN = record
    enc : integer; {* end of neutral chain *}
    oac : integer;  {* origin of active chain *}
    end;
             {*  enc- Y      Y -oac  *}
{* <    neutral   chain......active   chain  > *}
{  Alpha = array[1..32] of char; }
  Alpha = TRString;
  MarkType = (BgArg,BgNeuFun,BgActFun,EndFun);
  MarC = record
    tym : MarkType; {* type of mark *}
    adm : integer; end; {* address of mark in chain *}
  Bill=^BiList;
  BiList=record
   Lett : integer;
   Prev,Next : Bill;  end;
{* TRAC form header *}

  TFormT = class
    pack : boolean;
    AdPtr : integer;
    adr2,RTofFormT : Bill;
    ForMem : letters;
    constructor Create;
    destructor Destroy; override;
  end;

  {$IFDEF FPC}
  TListFormT = class(TStringListUTF8)
  {$ELSE}
  TListFormT = class(TStringList)
  {$ENDIF}
  public
    destructor Destroy; override;
  end;

 TTRAC = class;

 FlagProcTRAC = (fptClearStack,fptOverride,fptFormT);

 ProcTRAC = procedure(TT : TTRAC);
 TProcTRAC = class
  flags : set of FlagProcTRAC;
  t_proc : ProcTRAC;
 end;

 TTRAC = class
  private
   LenChain,LenCF : Longint;
   ChMem : letters;
   MainChain : CHAIN;
   stc : array {[0..LenCF]} of MarC; {* stack with marks *}
   pstc : integer; {* pointer to mark's stack *}
   pfbg : integer; {* pointer to function beg. *}
   MetaChar : letter;{* meta character *}
   OPNFO,OPNFI,DEBUG,trace: boolean;
   FO,FI: text;
   EOL:TRChar;
   s0 : Alpha; {array[1..LENC0] of TRChar;}
   ListForms : TListFormT;
   ListFun : TStringList;

   procedure SubstShort(var s: Alpha; N1,N2: integer);
   procedure MovSCP(var s: letter);
   procedure marcc(m:MarkType);
   procedure ShStr(N1,N2,N: integer);
   procedure WrChL0(ch: letter; var B: Bill);
   procedure Tear(var B,BE: Bill);
   procedure Merge(var B,BE: Bill);
   procedure WrChL(ch: letter; var B: Bill);
   procedure WrChLB(ch: letter; var B: Bill);
   procedure WrLsSt(var N:integer; B:Bill; k:boolean);
   procedure WrStSt(var N:integer; St:Alpha; k:boolean);
   procedure DelList(var B:Bill);


   function APar(N: integer):integer;
   procedure ActPar(k: integer);
   procedure RetFun(var BE,EN: Bill);


   function Natur(N1,N2: integer):integer;
   procedure NmRot(N: integer; var B: Bill);
   procedure WrNum(N: integer; var B: Bill);
   function Compar(var Mem1,Mem2 : letters; N1,N2,m1,m2: integer):boolean;
   function Compar3(var Mem1,Mem2 : letters; N1,N2,m1,m2: integer):integer;
   function Compar3a(var Mem1,Mem2 : letters; N1,N2,m1,m2: integer):integer;

   function InsFormT(var f : TFormT; const s: Alpha) : boolean;
   function FindFormT(var f : TFormT; const s: Alpha) : boolean;
   procedure DelFormT(const s: Alpha);


   procedure UnpackFormT(var f: TFormT);
   procedure PackFormT(var f: TFormT);
   procedure StList(var B:Bill; N,k: integer);
   procedure DelCh;
   procedure FiDel(N1,N2: integer; var B: Bill);
   procedure RSsF(N1,N2:integer);
   procedure WrFParLs(N: integer; var B: Bill);


   procedure Search(var Mem1,Mem2 : letters; I1,J1,I2,e2 : integer;
                    var J2 : integer);

   procedure add(B1,B2: Bill);
   procedure sub(B1,B2: Bill);
   function LenLis(B: Bill):integer;
   function Compar1(B1,B2: Bill):integer;
   function Compar2(B1,B2: Bill):integer;
   procedure Mul1(B1: Bill;var B: Bill;N: integer);
   procedure Digs(var B: Bill;var S: integer;
                        N: integer);
   procedure Del0(var B: Bill);
   procedure TwNum(var a1,B1,a2,B2: Bill;
                        var S1,S2: integer);
   procedure ad(SO: integer);
   procedure Mul(B1,a2 : Bill; var sa,sb: Bill);
   procedure Dvd(a1,a2: Bill;var a: Bill);

   procedure FillFun;

   procedure CallForm(var f : TFormT; shft : Integer);

   procedure CallFun;

   function StoTRString(const AStr : String) : TRString; virtual;
   function TRtoString(const ATRStr : TRString) : String; virtual;


public
   PREND,Unicode : boolean;
   constructor Create;
   destructor Destroy; override;

   procedure IniTRAC(aLenChain,aLenCF : Longint);

   procedure FinTRAC;
   procedure RunTRAC(aLenChain : Longint = defLenChain;
                     aLenCF : Longint = defLenCF);
   procedure AlgTRAC;
   procedure EvalTRAC(Instr : TRString);

   procedure DAFS; { made public 2k17 }
   function NumPars : Integer;
   procedure Par(N: integer; var s: Alpha);
   procedure RetStFun(var St : Alpha);

   procedure InsFunTRAC(FunName : TRString;
     Fun : ProcTRAC; Update : Boolean = True;
     ClearStack : Boolean = True {2k17} );

   procedure WrDebug(Msg : TRString); virtual;
   procedure WrTrace(Msg : TRString; IsEol : Boolean = False;
    info : integer = 1); virtual;

   procedure WriteTRAC(Str : TRString;
    IsEol : Boolean = False); virtual;

   procedure ReadlnTRAC; virtual;
   procedure ReadTRAC(var Ch : TRChar); virtual;

end;

implementation
{***************************************}
{*     interpreter of TRAC language    *}
{***************************************}

uses
  WideStrArifm;

 {* *}
{**************************************}
 function I2S(I : Integer) : String;
 begin
  Str(I,Result);
 end;
{**************************************}
 function B2S(b : Boolean) : String;
 begin
  If b then B2S := 'TRUE' else B2S := 'FALSE'
 end;

{**************************************}
 function ltr(I : Integer) : letter;
{ integer to letter 2k5}
 begin
  ltr := letter(I);
 end;
{**************************************}
 function iord(lt : letter) : Integer;
{ letter to integer 2k5}
 begin
  iord := Integer(lt);
 end;
 {**************************************}
 function ch8l(lt : letter) : AnsiChar;
{ letter to TRChar 2k5/13A}
 begin
  if lt < 256 then ch8l := AnsiChar(lt)
  else ch8l := #0;
 end;
{**************************************}
 function chl(lt : letter) : TRChar;
{ letter to TRChar 2k13}
 begin
  if lt < $10000 then chl := TRChar(lt)
  else chl := #0;
 end;
{**************************************}
 function lch(ch : TRChar) : letter;
{ TRChar to letter 2k5}
 begin
  lch := ltr(ord(ch))
 end;
 {**************************************}
 function wchl(lt : letter) : WideChar;
{ letter to unicode 2k13}
 begin
  if lt < $10000 then wchl := WideChar(lt)
  else wchl := #0;
 end;
{**************************************}
 function lwch(wch : WideChar) : letter;
{ WideChar to letter 2k15}
 begin
  lwch := letter(wch)
 end;
{**************************************}
 function mch(ch : letter) : Integer;
{ letter to mark, 2k5}
 begin
  mch := -1-iord(ch)
 end;
{**************************************}
 function mrc(I : Integer) : Integer;
{ mark from letter/integer, 2k5}
 begin
  mrc := -1-I
 end;
{**************************************}
 function cmp3(A,B : Integer) : Integer;
 begin
  if A = B then cmp3 := 0
  else if A > B then cmp3 := 1
                else cmp3 := -1;
 end;

 {Class TTRAC}

{**************************************}
  procedure TTRAC.SubstShort(var s: Alpha; N1,N2: integer);
  var I: integer;
   begin s:='';
    for I:=N1 to N1+N2-1 do
     s := s + chl(ChMem[I])
   end;
{**************************************}
  procedure TTRAC.MovSCP(var s: letter);
{* to move scanning pointer *}
{* of chain to one character, read it *}
  begin if DEBUG then
    WrDebug('movscp('+chl(ChMem[MainChain.oac])+') '+
     I2S(MainChain.enc)+' '+I2S(MainChain.oac));
   s:=ChMem[MainChain.oac]; MainChain.oac:=MainChain.oac+1;
   MainChain.enc:=MainChain.enc+1; ChMem[MainChain.enc]:=s
  end;
{**************************************}
  procedure TTRAC.marcc(m:MarkType);
{* mark character in chain *}
  begin if DEBUG then WrDebug('marcc , pstc='+I2S(pstc));
   stc[pstc].tym:=m;
   stc[pstc].adm:=MainChain.enc;
   pstc:=pstc+1
  end;
{***************************************}
  procedure TTRAC.ShStr(N1,N2,N: integer);
   var I: integer;
   begin if DEBUG then  WrDebug('shift of TRString('+
      I2S(N1)+','+I2S(N2)+','+I2S(N)+')');
    if N<>0 then
    if N<0 then
    for I:=N1 to N2 do ChMem[I+N]:=ChMem[I]
           else
    for I:=N2 downto N1 do ChMem[I+N]:=ChMem[I]
   end;
{***************************************}
  procedure TTRAC.WrChL0(ch: letter; var B: Bill);
{* write letter in cyclic list *}
  var BN: Bill;
  begin if DEBUG then WrDebug('wrchl0('+chl(ch)+')');
   if B=nil then begin new(B); B^.Prev:=B; B^.Next:=B end
    else begin new(BN); B^.Prev^.Next:=BN;BN^.Prev:=B^.Prev;
     B^.Prev:=BN; BN^.Next:=B end;
   B^.Prev^.Lett:=iord(ch)
  end;
{***************************************}
  procedure TTRAC.Tear(var B,BE: Bill);
  begin if DEBUG then WrDebug('tear chains');
   if B = nil then BE := nil else begin  {!2k5}
    B^.Prev^.Next:=nil; BE:=B^.Prev; B^.Prev:=nil end
  end;
{***************************************}
  procedure TTRAC.Merge(var B,BE: Bill);
  begin if DEBUG then WrDebug('merge chains');
   if BE <> nil then BE^.Next:=B; if BE <> nil then B^.Prev:=BE {!2k5}
  end;
{***************************************}
  procedure TTRAC.WrChL(ch: letter; var B: Bill);
{* write letter to list *}
  var BN: Bill;
  begin if DEBUG then WrDebug('wrchl('+chl(ch)+')'); new(BN);
   BN^.Lett:=iord(ch); BN^.Prev:=B;
   if B<>nil then begin BN^.Next:=B^.Next; B^.Next:=BN;
              if BN^.Next<>nil then BN^.Next^.Prev:=BN end {!2k5}
             else BN^.Next:=nil;
   B:=BN
  end;
{***************************************}
  procedure TTRAC.WrChLB(ch: letter; var B: Bill);
{* write letter to list before B *}
  var BN: Bill;
  begin if DEBUG then WrDebug('wrchlb('+chl(ch)+')'); new(BN);
   BN^.Lett:=iord(ch); BN^.Next:=B;
   if B<>nil then begin BN^.Prev:=B^.Prev; B^.Prev:=BN; B^.Prev:=BN;
               if BN^.Prev<>nil then BN^.Prev^.Next:=BN end {!2k5}
             else BN^.Prev:=nil;
   B:=BN
  end;
{***************************************}
  procedure TTRAC.WrLsSt(var N:integer; B:Bill; k:boolean);
{* write list -B- in TRString -S- with origin N *}
{* if k=TRUE to right, if k=FALSE to left  *}
  begin if DEBUG then WrDebug('wrlsst '+I2S(N)+' '+B2S(k));
   if k then while B<>nil do
   begin N:=N+1; ChMem[N]:=ltr(B^.Lett);
    B:=B^.Next end
        else while B<>nil do
   begin N:=N-1; ChMem[N]:=ltr(B^.Lett);
    B:=B^.Prev end
  end;
{***************************************}
  procedure TTRAC.WrStSt(var N:integer; St:Alpha; k:boolean);
{* write list -St- in TRString -S- with origin N *}
{* if k=TRUE to right, if k=FALSE to left  *}
  var
   I,N0 : integer;
  begin if DEBUG then WrDebug('wrstst '+I2S(N)+' '+B2S(k));
   if k then
    begin N0 := N; N := N+Length(St) end
   else
    begin N := N-Length(St); N0 := N-1 end;
   for I:= 1 to Length(St) do
    ChMem[N0+I] := lch(St[I]);
  end;
{***************************************}
  procedure TTRAC.DelList(var B:Bill);
{* delete list *}
  var BN:Bill;
  begin if DEBUG then WrDebug('dellist');
  if B<>nil then if B^.Prev=nil then
   repeat BN:=B^.Next; dispose(B); B:=BN
   until B=nil
  end;
{***************************************}
  procedure TTRAC.DAFS;
{* delete arguments of function from stack *}
  begin if DEBUG then WrDebug('dafs'+I2S(pstc)+' '+I2S(pfbg)); pstc:=pfbg;
   if stc[pfbg].tym=BgNeuFun then MainChain.enc:=stc[pfbg].adm-3
                             else MainChain.enc:=stc[pfbg].adm-2
  end;
{***************************************}
  procedure TTRAC.Par(N: integer; var s: Alpha);
{* read N-th argument and write in form's name *}
{* 0-th argument-name of function *}
  var N1,N2: integer;
  begin if pfbg+N > pstc-2
   then s:=''
   else begin N1:=stc[pfbg+N].adm+1; N2:=stc[pfbg+N+1].adm-N1;
    if N2>0 then SubstShort(s,N1,N2)
    else s:=''
   end; if DEBUG then WrDebug('par'+I2S(N)+' '+s)
  end;
{***************************************}
  function TTRAC.NumPars : Integer;
  begin
   NumPars := pstc-pfbg-2;
  end;
{***************************************}
  function TTRAC.APar(N: integer):integer;
{* address of N-th argument *}
{* 0-th argument-name of function *}
  var a: integer;
  begin if pfbg+N > pstc-2 then a:=stc[pstc-1].adm
   else a:=stc[pfbg+N].adm;
   if DEBUG then WrDebug('apar '+I2S(N)+' '+I2S(a));
   APar:=a
  end;
{***************************************}
  procedure TTRAC.ActPar(k: integer);
  var J: integer;
  begin if DEBUG then WrDebug('actpar');
   if (pfbg+k+1<pstc) then
   for J:=stc[pfbg+k+1].adm-1 downto stc[pfbg+k].adm+1 do
   begin MainChain.oac:=MainChain.oac-1; ChMem[MainChain.oac]:=ChMem[J] end;
   DAFS;
  end;
{***************************************}
  procedure TTRAC.RetFun(var BE,EN: Bill);
{* writing value of function to chain from list *}
  begin
   if stc[pfbg].tym=BgNeuFun then WrLsSt(MainChain.enc,BE,true)
                             else WrLsSt(MainChain.oac,EN,false);
   DelList(BE)
  end;
{***************************************}
  procedure TTRAC.RetStFun(var St : Alpha);
{* writing value of function to chain from TRString *}
  begin
   if stc[pfbg].tym=BgNeuFun then WrStSt(MainChain.enc,St,true)
                             else WrStSt(MainChain.oac,St,false);
  end;
{***************************************}
  function TTRAC.Natur(N1,N2: integer):integer;
  var I,k,N,L,e : integer; ch: AnsiChar; {A}
  begin N:=0; k:=1; e:=10;
   if ch8l(ChMem[N1])='-' then k:=-1;
   if ch8l(ChMem[N1]) in ['-','+'] then N1:=N1+1;
   if ch8l(ChMem[N2])='O' then e:=8 else
   if ch8l(ChMem[N2])='B' then e:=2 else
   if ch8l(ChMem[N2])='H' then e:=16;
   for I:=N1 to N2 do begin ch:=ch8l(ChMem[I]);
    if ch in ['0'..'9']
    then L:=ord(ch)-ord('0')
    else if ch in ['A'..'F']
     then L:=ord(ch)-ord('A')+10 else L:=100;
     if L<e then N:=e*N+L end;
   if k<0 then N:=-N; Natur:=N
  end;
{***************************************}
  procedure TTRAC.NmRot(N: integer; var B: Bill);
{* write number in cyclic list *}
  var I,k: integer;
  begin  k:=-1;
   if N<0 then N:=-N else k:=1;
   if N=0 then WrChL0(lch('0'),B) else
   begin while N<>0 do
    begin I:=N mod 10; N:=N div 10;
     WrChL0(ltr(I+ord('0')),B); B:=B^.Prev end;
    if k<0 then begin WrChL0(lch('-'),B); B:=B^.Prev end
   end
  end;
 {***************************************}
  procedure TTRAC.WrNum(N: integer; var B: Bill);
{* write number in usual list *}
  var I: integer;
      BE : Bill;
  begin
   if N<0 then begin N:=-N; WrChL(lch('-'),B) end;
   I:=N mod 10; N:=N div 10;
   WrChL(ltr(I+ord('0')),B);
   BE := B;
   while N<>0 do
    begin I:=N mod 10; N:=N div 10;
     WrChLB(ltr(I+ord('0')),B); B:=B^.Prev end;
   B := BE;
  end;
{***************************************}
  function TTRAC.Compar(var Mem1,Mem2 : letters; N1,N2,m1,m2: integer):boolean;
  var EQU: boolean; I,J: integer;
  begin if N1-N2=m1-m2 then
   begin EQU:=true; I:=N1; J:=m1;
    while (I<=N2) and EQU do
    begin EQU:=(iord(Mem1[I])=iord(Mem2[J])); I:=I+1; J:=J+1 end;
   end else EQU:=false;
   if DEBUG then WrDebug('compar'+I2S(N1)+' '+I2S(N2)+' '+
                     I2S(m1)+' '+I2S(m2)+' '+B2S(EQU));
   Compar:=EQU
  end;
{***************************************}
  function TTRAC.Compar3(var Mem1,Mem2 : letters; N1,N2,m1,m2: integer):integer;
 {* -1,0,+1 TRString comparison 2k5 *}
  var EQU3: integer; I,J: integer;
  begin if N1-N2=m1-m2 then
   begin EQU3:=0; I:=N1; J:=m1;
    while (I<=N2) and (EQU3=0) do
    begin EQU3:=Cmp3(iord(Mem1[I]),iord(Mem2[J])); I:=I+1; J:=J+1 end;
   end else EQU3:=Cmp3(N2-N1,m2-m1);
   if DEBUG then WrDebug('compar3'+I2S(N1)+' '+I2S(N2)+' '+
                     I2S(m1)+' '+I2S(m2)+' '+I2S(EQU3));
   Compar3:=EQU3
  end;
{***************************************}
  function TTRAC.Compar3a(var Mem1,Mem2 : letters; N1,N2,m1,m2: integer):integer;
 {* -1,0,+1 alphabetic comparison 2k5 *}
  var EQU3: integer; I,J: integer;
  begin
   EQU3:=0; I:=N1; J:=m1;
   while (I<=N2) and (J<=m2) and (EQU3=0) do
    begin EQU3:=Cmp3(iord(Mem1[I]),iord(Mem2[J])); I:=I+1; J:=J+1 end;
   if EQU3=0 then EQU3 := Cmp3(N2-N1,m2-m1);
   if DEBUG then WrDebug('compar3a'+I2S(N1)+' '+I2S(N2)+' '+
                     I2S(m1)+' '+I2S(m2)+' '+I2S(EQU3));
   Compar3a:=EQU3
  end;

{***************************************}

  function TTRAC.InsFormT(var f : TFormT; const s: Alpha) : boolean;
   var
    Idx : Integer;
    found : boolean;
    tp : TProcTRAC;
    str : string;
   begin
    str := TRtoString(s);
    found := ListForms.Find(str,Idx);
    InsFormT := found;
    if found then {* t-form already exists *}
     f := TFormT(ListForms.Objects[Idx])
    else
    begin
     f := TFormT.Create;
     ListForms.InsertItem(Idx,str,f);
     found := ListFun.Find(str,Idx);
     if found then
     begin
      tp := TProcTRAC(ListFun.Objects[Idx]);
      with tp do
       flags := flags+[fptFormT]
     end;
    end;
   end;

{***************************************}

   function TTRAC.FindFormT(var f : TFormT; const s: Alpha) : boolean;
   var
    Idx : Integer;
    found : boolean;
    str : string;
   begin
    str := TRtoString(s);
    found := ListForms.Find(str,Idx);
    FindFormT := found;
    if found then
      f := TFormT(ListForms.Objects[Idx])
   end;

{***************************************}

   procedure TTRAC.DelFormT(const s: Alpha);
   var
    f : TFormT;
    Idx : Integer;
    found : boolean;
    tp : TProcTRAC;
    str : string;
   begin
    str := TRtoString(s);
    found := ListForms.Find(str,Idx);
    if found then
    begin
     f := TFormT(ListForms.Objects[Idx]);
     f.Free;
     ListForms.Delete(Idx);
     found := ListFun.Find(str,Idx);
     if found then
     begin
      tp := TProcTRAC(ListFun.Objects[Idx]);
      with tp do
       flags := flags-[fptFormT]
     end;
    end;
   end;


{***************************************}
  procedure TTRAC.UnpackFormT(var f: TFormT);
   var I,L : integer;
       L1,L2: Bill;
   begin if DEBUG then WrDebug('unpack t-form');
    if f.pack then
    begin
     L:=f.AdPtr; f.pack:=false;
     L1:=nil; if DEBUG then WrDebug('ptr:'+I2S(L));
     for I:=0 to Length(f.ForMem)-1 do begin L:=L-1; new(L2);L2^.Next:=nil;
      L2^.Lett:=iord(f.ForMem[I]);
      if L=0 then f.RTofFormT:=L2;
      L2^.Prev:=L1; if I=0 then f.adr2:=L2
                            else L1^.Next:=L2; L1:=L2
     end {* FOR *};
    end
   end;
{***************************************}
  procedure TTRAC.PackFormT(var f: TFormT);
   var I,L : integer;
       L1,L2: Bill;
   begin if DEBUG then WrDebug('pack t-form');
    if not f.pack then
    begin L:=0;
     L1:=f.adr2;
     repeat
      L:=L+1; L1:=L1^.Next;
     until L1=nil;
     I := L+1;
     if Length(f.ForMem) <> L then SetLength(f.ForMem,L);
     L := 0;
     L1:=f.adr2;
     repeat f.ForMem[L]:=ltr(L1^.Lett);
      L:=L+1; if f.RTofFormT=L1 then I:=L;
      L2:=L1^.Next; dispose(L1);
      L1:=L2;
     until L1=nil;
     f.pack:=true;
     f.AdPtr:=I; if DEBUG then WrDebug('ptr='+I2S(I));
    end
   end;
{***************************************}
  procedure TTRAC.StList(var B:Bill; N,k: integer);
   var I: integer;
{* write S-->B from N to k *}
   begin if DEBUG then WrDebug('TRString-list');
    for I:=N to k do
    WrChL(ChMem[I],B);
   end;
{***************************************}
  procedure TTRAC.DelCh;
   begin if DEBUG then WrDebug('delete character');
   if MainChain.enc>0 then MainChain.enc:=MainChain.enc-1
    else WrTrace('overflow: before origin of chain',true,2)
   end;
{***************************************}
  procedure TTRAC.FiDel(N1,N2: integer; var B: Bill);
{* find in form (after pointer) segment S[N1..N2] and delete it *}
  var B1,B2: Bill; J: integer;
      EQU : boolean;
  begin if DEBUG then WrDebug('fidel '+I2S(N1)+' '+I2S(N2));
   B1:=B; EQU:=false;
   if N1<=N2 then while ((B1<>nil) and (not EQU)) do
   begin EQU:=false; B2:=B1; J:=N1; if B2^.Lett=iord(ChMem[N1]) then
    begin EQU:=true; while ((J<>N2) and EQU) do
     begin B2:=B2^.Next; J:=J+1;
      if B2=nil then EQU:=false else
                 if B2^.Lett<>iord(ChMem[J]) then EQU:=false
     end
    end; if DEBUG then WrDebug(chl(ltr(B1^.Lett)));
   if not EQU then B1:=B1^.Next
   end; if EQU then begin B:=B1;
    if B2^.Next<>nil then B2^.Next^.Prev:=B;
    B^.Next:=B2^.Next; if DEBUG then WrDebug('found');
    while B<>B2 do
    begin B1:=B2^.Prev; dispose(B2); B2:=B1 end;
   end else B:=nil
  end;
{***************************************}
  procedure TTRAC.RSsF(N1,N2:integer);
{* return substring as value of function *}
  begin
   if N2>=N1 then
   if stc[pfbg].tym=BgNeuFun then
   begin ShStr(N1,N2,MainChain.enc-N1+1);
    MainChain.enc:=MainChain.enc-N1+1+N2 end else
   begin ShStr(N1,N2,MainChain.oac-N2-1);
    MainChain.oac:=MainChain.oac-N2-1+N1 end
  end;
{***************************************}
  procedure TTRAC.WrFParLs(N: integer; var B: Bill);
{* write parametr of function in list *}
  begin if DEBUG then WrDebug('wrfparls'+I2S(N));
   if (pfbg+N+1<pstc) then
   StList(B,stc[pfbg+N].adm+1,stc[pfbg+N+1].adm-1)
  end;
{***************************************}
{**         TRAC functions            **}
{***************************************}
  procedure  t_rs(TT : TTRAC);
{  (rc) rs, read TRString  }
  var ch: TRChar;
      BB,BE: Bill;
  begin
  with TT do
  begin BB:=nil; BE:=nil;
   WriteTRAC(chl(MetaChar));
   ReadTRAC(ch); if ch<>chl(MetaChar) then {* !!!! *}
   begin WrChL(lch(ch),BB); BE:=BB; ReadTRAC(ch);
    while ch<>chl(MetaChar) do
    begin WrChL(lch(ch),BE);
     if eoln then begin ch:=EOL; ReadlnTRAC; WriteTRAC('/') end
             else ReadTRAC(ch)
    end;
    ReadlnTRAC;
   end; DAFS; RetFun(BB,BE)
  end;
  end;
{***************************************}
  procedure  t_rc(TT : TTRAC);
{  rc, read character  2k5  }
  var ch: TRChar;
      BB,BE: Bill;
  begin
  with TT do
  begin BB:=nil; BE:=nil;
   ReadTRAC(ch);
   WrChL(lch(ch),BB); BE:=BB;
   DAFS; RetFun(BB,BE)
  end;
  end;
{***************************************}
  procedure  t_ps(TT : TTRAC);
{  (pc) ps, print TRString  }
  var I:integer; ch: letter;
  begin
  with TT do
  begin
   for I:=stc[pfbg+1].adm+1 to stc[pfbg+2].adm-1 do
   begin ch:=ChMem[I]; if iord(ch)=10
    then WriteTRAC('',True) else WriteTRAC(chl(ch)) end;
   DAFS; WriteTRAC('',True)
  end;
  end;

{***************************************}
   procedure  t_ds(TT : TTRAC);
{  (oc) ds, define TRString  }
   var f: TFormT; I,I0,L: integer;
     s: Alpha;
   begin
   with TT do
   begin
    Par(1,s);
    InsFormT(f,s);
    I0 := APar(2)+1;
    L := APar(3)-I0;
    with f do
    begin
     if L <> Length(ForMem) then SetLength(ForMem,L);
     for I := 0 to L-1 do
     ForMem[I] := ChMem[I+I0];
     pack := true;
     AdPtr := 1;
     adr2 := nil;
     RTofFormT := nil;
    end;
   DAFS;
   end;
   end;
{***************************************}
  procedure  t_ss(TT : TTRAC);
{  (sc) ss, segment TRString  }
  var f: TFormT; s: Alpha; I: integer;
  begin
  with TT do
  begin
    Par(1,s);
    if FindFormT(f,s) then
    begin UnpackFormT(f);
     for I:=1 to pstc-pfbg-3 do
     begin f.RTofFormT:=f.adr2;
      while f.RTofFormT<>nil do
      begin FiDel(stc[pfbg+I+1].adm+1,stc[pfbg+I+2].adm-1,f.RTofFormT);
       if f.RTofFormT<>nil then {* segment mark *}
          f.RTofFormT.Lett:=mrc(I);
      end;
    end;
     PackFormT(f);
     DAFS; f.AdPtr:=1
    end
   end;
   end;

  procedure TTRAC.CallForm(var f : TFormT; shft : Integer);
  var I: integer;
      ch: letter;
      B,B1: Bill;
   begin
    if (Length(f.ForMem)>0) then begin
     new(B); B^.Prev:=nil; B^.Next:=nil; B1:=B;
     for I:=0 to Length(f.ForMem)-1 do
     begin ch:=f.ForMem[I];
      if mch(ch)>=0 then WrFParLs(mch(ch)+shft,B) else WrChL(ch,B)
     end; DAFS; B1:=B1^.Next; dispose(B1^.Prev); B1^.Prev:=nil;
     RetFun(B1,B)
    end else DAFS
   end;


{***************************************}
   procedure  t_cl(TT : TTRAC; N: integer);
{  (wc) cl, call TRString  }
   var f: TFormT;
       s: Alpha;
   begin
   with TT do
   begin
    Par(N,s);
    if FindFormT(f,s) then CallForm(f,N)
    else DAFS
   end;
   end;
{***************************************}
  procedure TTRAC.Search(var Mem1,Mem2 : letters; I1,J1,I2,e2 : integer;
                 var J2 : integer);
  begin J2:=I2+J1-I1;
   while (J2<=e2) and (not Compar(Mem1,Mem2,I1,J1,I2,J2))
   do begin I2:=I2+1; J2:=J2+1 end;
   if DEBUG then WrDebug('search'+I2S(I1)+' '+I2S(J1)+' '+
                      I2S(I2)+' ('+I2S(e2)+')'+I2S(J2));
  end;
{***************************************}
  procedure  t_te(TT : TTRAC);
{  (ob) te, template -> list  }
  const
   NSEG = 4096;
  var f : TFormT; s : Alpha;
  m,k,I1,I2,J1,J2,e1,e2 : integer;
  B1,B2 : Bill; SG: array [1..NSEG,1..2] of integer;
    function OrdSeg(N,L1,L2 : integer):boolean;
  {* ordered writing of segments *}
    begin
    with TT do
    begin if DEBUG then WrDebug('ordseg'+I2S(N)+' '+I2S(L1)+' '+I2S(L2));
     if m<N then m:=N;
     if SG[N,1]=0 then begin SG[N,1]:=L1;
      SG[N,2]:=L2; OrdSeg:=true end
     else OrdSeg:=Compar(ChMem,ChMem,L1,L2,SG[N,1],SG[N,2])
    end;
    end;
    procedure Wrt21(var B:Bill);
    var I,J : integer;
    begin
    with TT do
    begin B:=nil;
     for I:=1 to m do
     begin WrChL0(lch('('),B);
      if SG[I,1]>0 then
       for J:=SG[I,1] to SG[I,2] do
       WrChL0(ChMem[J],B);
      WrChL0(lch(')'),B); if I<m then WrChL0(lch(','),B)
     end
    end;
    end;
  begin
  with TT do
  begin
   for m:=1 to NSEG do SG[m,1]:=0; m:=0;
   Par(1,s);
   if FindFormT(f,s) then
   begin
     I2:=APar(2)+1; e2:=APar(3)-1;
     I1:=f.AdPtr-1;
     e1:=Length(f.ForMem)-1; J1:=I1; J2:=I2;
     while (mch(f.ForMem[J1])<0) and (J1<=e1)
     do J1:=J1+1;
     if J1>e1 then begin k:=-1; J2:=e2 end else
      begin k:=mch(f.ForMem[J1]); J2:=I2+J1-I1-1 end;
       if J1>I1 then if Compar(f.ForMem,ChMem,I1,J1-1,I2,J2) then
       begin I1:=J1; I2:=J2+1 end else k:=0;
     if k>0 then
      repeat J1:=J1+1; if J1>e1 then J2:=e2 else
       begin while (mch(f.ForMem[J1])<0) and (J1<=e1)
        do J1:=J1+1;
        Search(f.ForMem,ChMem,I1+1,J1-1,I2,e2,J2) end;
       if J2>e2 then k:=0 else
       if not OrdSeg(k,I2,J2-J1+I1+1) then k:=0 else
       if J1>e1 then           {*  ^ length of marker *}
       if J2=e2 then k:=-1 else k:=0
       else begin k:=mch(f.ForMem[J1]);
        I1:=J1; I2:=J2+1 end;
      until (J2>=e2) or (k<=0);
     if k<>0 then begin DAFS;
      Wrt21(B1); Tear(B1,B2);
      RetFun(B1,B2) end else ActPar(3)
   end else ActPar(3)
  end;
  end;
{***************************************}
  procedure  t_cc(TT : TTRAC);
{  (wl) cc, call letter  }
   var f: TFormT; s: Alpha; J: integer;
    B: Bill;
   begin
   with TT do
   begin
    Par(1,s);
    if FindFormT(f,s) then begin
     J:=f.AdPtr-1;
     while (mch(f.ForMem[J])>=0) and (J<=Length(f.ForMem)-1) do J:=J+1;
     if J<=Length(f.ForMem)-1 then begin B:=nil;
      WrChL(f.ForMem[J],B); DAFS; RetFun(B,B); J:=J+1;
      end else ActPar(2);
     f.AdPtr:=J+1;
    end else DAFS
   end;
   end;
{***************************************}
   procedure  t_cn(TT : TTRAC);
{  (wn) cn, call n chars  }
   var f:TFormT; s:Alpha; ch:letter;
       I,J: integer; B,BE:Bill;
   begin
   with TT do
   begin
    Par(1,s);
    if FindFormT(f,s) then
    begin
     B:=nil;
     J:=f.AdPtr-1;
     I:=Natur(APar(2)+1,APar(3)-1);
     if I>=0 then begin {* "extras" *}
      while I>0 do
      if J>Length(f.ForMem)-1 then I:=-1
      else begin ch:=f.ForMem[J];
       J:=J+1; if mch(ch)<0 then
       begin WrChL0(ch,B); I:=I-1 end
      end
     end
             else begin I:=-I;
      while I>0 do
      if J<=0 then I:=-1
      else begin J:=J-1; ch:=f.ForMem[J];
       if mch(ch)<0 then
       begin WrChL0(ch,B); B:=B^.Prev; I:=I-1 end
      end
     end;
     Tear(B,BE);
     if I=0 then begin
      f.AdPtr:=J+1;
      DAFS; RetFun(B,BE) end
            else ActPar(3);
     DelList(B) end else DAFS
    end;
   end;
{***************************************}
  procedure  t_in(TT : TTRAC);
{  (ps) in, initial  }
   var f: TFormT; N1,N2,J : integer; s: Alpha;
   B,BE: Bill; ch: letter;
   begin
   with TT do
   begin
    Par(1,s);
    if FindFormT(f,s) then
    begin
     N1:=APar(2)+1; N2:=APar(3)-1;
     J:=f.AdPtr-1; B:=nil;
     while (not Compar(ChMem,f.ForMem,N1,N2,J,J-N1+N2))
     and (J<=Length(f.ForMem)-1) do
     begin ch:=f.ForMem[J];
      if (mch(ch)<0) then WrChL0(ch,B); J:=J+1 end;
     if B<>nil then Tear(B,BE);
     if J<=Length(f.ForMem)-1 then begin DAFS;
      if B<>nil then RetFun(B,BE); J:=J-N1+N2+1;
      f.AdPtr:=J+1 end
     else begin DelList(B); ActPar(3) end
    end else DAFS
   end;
   end;
{***************************************}
  procedure  t_ln(TT : TTRAC);
{  (si) ln, list names  }
   var {f: TFormT;} B,BE: Bill;
       s : TRString;
       I,J: integer;
   begin
   with TT do
   begin B:=nil;
    for I := 0 to ListForms.Count-1 do
    begin if I <> 0 then
     for J:=APar(1)+1 to APar(2)-1 do
      WrChL0(ChMem[J],B);
     s := StoTRString(ListForms.Strings[I]);
     for J:=1 to Length(s) do
     WrChL0(lch(s[J]),B);
     WrChL0(lch(EOL),B);
    end;
    DAFS; Tear(B,BE); RetFun(B,BE)
   end;
   end;
{***************************************}
  procedure  t_cs(TT : TTRAC);
{  (ws) cs, call segment  }
  var f: TFormT; s: Alpha; I,J,k: integer;
      B,BE: Bill; ch: letter;
  begin
  with TT do
  begin
   Par(1,s); B:=nil;
   if FindFormT(f,s) then
   begin
    J:=f.AdPtr-1;
    if J>Length(f.ForMem)-1 then ActPar(2) else
    begin if DEBUG then WrDebug('before ptr='+I2S(f.AdPtr));
     ch:=f.ForMem[J]; k:=pstc-pfbg-4; if k<0  then k:=0;
     while (J<=Length(f.ForMem)-1) and (mch(ch)<=k) do
     begin if (mch(ch)>=0) then
      for I:=APar(mch(ch)+2)+1 to APar(mch(ch)+3)-1 do
      WrChL0(f.ForMem[I],B) else WrChL0(ch,B);
      J:=J+1; ch:=f.ForMem[J] end;
     if J<=Length(f.ForMem)-1 then J:=J+1;
     Tear(B,BE); DAFS; f.AdPtr:=J+1;
     if DEBUG then WrDebug('after ptr='+I2S(f.AdPtr));
     RetFun(B,BE)
    end
   end else DAFS
  end;
  end;
{***************************************}
   procedure  TTRAC.add(B1,B2: Bill);
   var pre,S: integer;
   begin if DEBUG then WrDebug('add'); pre:=0;
    while B1<>nil do
    begin if B2=nil then S:=0
     else begin S:=B2^.Lett-ord('0');
      B2:=B2^.Prev end;
     S:=S+B1^.Lett+pre; pre:=1;
     if S>ord('9') then S:=S-10 else pre:=0;
     B1^.Lett:=S; B1:=B1^.Prev
    end
   end;
{***************************************}
   procedure  TTRAC.sub(B1,B2: Bill);
   var pre,S: integer;
   begin if DEBUG then WrDebug('sub'); pre:=0;
    while B1<>nil do
    begin if B2=nil then S:=0
     else begin S:=B2^.Lett-ord('0');
      B2:=B2^.Prev end;
     S:=B1^.Lett-S-pre; pre:=1;
     if S<ord('0') then S:=S+10 else pre:=0;
     B1^.Lett:=S; B1:=B1^.Prev
    end
   end;
{***************************************}
   function  TTRAC.LenLis(B: Bill):integer;
{* list length *}
   var S: integer;
   begin S:=0;
    while B<>nil do
    begin B:=B^.Next; S:=S+1 end;
    LenLis:=S
   end;
{***************************************}
   function  TTRAC.Compar1(B1,B2: Bill):integer;
{* "alphabetic" comparison *}
   var S: integer;
   begin S:=2; if DEBUG then WrDebug('compar1');
    repeat if B1=nil then if B2=nil then S:=0
                                    else S:=-1
                     else if B2=nil then S:=1
     else if B1^.Lett>B2^.Lett then S:=1
     else if B1^.Lett<B2^.Lett then S:=-1
     else begin B1:=B1^.Next; B2:=B2^.Next end
    until S<>2;
    Compar1:=S
   end;
{***************************************}
   function  TTRAC.Compar2(B1,B2: Bill):integer;
{* "arithmetic" comparison *}
   var s1,s2,S: integer;
   begin if DEBUG then WrDebug('compar2');
    s1:=LenLis(B1); s2:=LenLis(B2);
    if s1>s2 then S:=1 else
    if s1<s2 then S:=-1 else
    S:=Compar1(B1,B2);
    Compar2:=S
   end;
{***************************************}
   procedure  TTRAC.Mul1(B1: Bill;var B: Bill;N: integer);
{* multiplication on digit in list *}
   var pre,S: integer;
   begin if DEBUG then WrDebug('mul1 '+I2S(N));
    pre:=0; while B1<>nil do
    begin S:=(B1^.Lett-ord('0'))*N+pre;
     pre:=S div 10; S:=S mod 10 ;
     B1:=B1^.Prev; S:=S+ord('0');
     WrChL0(ltr(S),B); B:=B^.Prev
    end; if pre<>0 then begin
     WrChL0(ltr(pre+ord('0')),B); B:=B^.Prev end
   end;
{***************************************}
   procedure  TTRAC.Digs(var B: Bill;var S: integer;
                        N: integer);
{* list of digits *}
   var I: integer; ch: letter;
   begin if DEBUG then WrDebug('digs '+I2S(N));
    I:=APar(N+1)-1; B:=nil; S:=1;
    repeat ch:=ChMem[I];
     if ch8l(ch) in ['0'..'9'] then
      begin WrChL0(ch,B); B:=B^.Prev;
       I:=I-1 end;
    until not (ch8l(ch) in ['0'..'9']);
    if chl(ch)='-' then S:=-1
   end;
{***************************************}
   procedure  TTRAC.Del0(var B: Bill);
{* delete zeros *}
   begin if DEBUG then WrDebug('del0');
   if B <> nil then {!2k5}
    while (B^.Lett=ord('0'))
           and (B^.Next<>nil) do
    begin B:=B^.Next; dispose(B^.Prev);
     B^.Prev:=nil end
   end;
{***************************************}
   procedure  TTRAC.TwNum(var a1,B1,a2,B2: Bill;
                        var S1,S2: integer);
{* two numbers *}
   begin if DEBUG then WrDebug('TwNum');
    a1:=nil; a2:=nil;
    Digs(a1,S1,1); Digs(a2,S2,2);
    Tear(a1,B1); Tear(a2,B2);
    Del0(a1); Del0(a2);
   end;
{***************************************}
  procedure  t_gen(TT : TTRAC);
{  (br) ge, >= (numerical)  }
  var S1,S2,N,N1,N2: integer; a1,a2,B1,B2: Bill;
   begin
   with TT do
   begin TwNum(a1,B1,a2,B2,S1,S2);
    if S1<>S2 then N:=(7+S2) div 2 else
    if (Compar2(a1,a2)*S1)=-1 then N:=4 else N:=3;
    N1:=APar(N)+1; N2:=APar(N+1)-1; DAFS; RSsF(N1,N2);
    DelList(a1); DelList(a2)
  end;
  end;
{***************************************}
  procedure  t_ges(TT : TTRAC);
{  ! ge, >=, TRString 2k5}
  var N,N1,N2: integer;
  begin
  with TT do
  begin
   if Compar3(ChMem,ChMem,APar(1)+1,APar(2)-1,APar(2)+1,APar(3)-1) >= 0
   then N:=3  else N:=4; N1:=APar(N)+1; N2:=APar(N+1)-1;
   DAFS; RSsF(N1,N2);
  end;
  end;

{***************************************}
  procedure  t_ge(TT : TTRAC);
  begin
   if NumGE then t_gen(TT) else t_ges(TT)
  end;
{***************************************}
  procedure  t_gr(TT : TTRAC); {2k5}
{  gr, >   }
  var S1,S2,N,N1,N2: integer; a1,a2,B1,B2: Bill;
   begin
   with TT do
   begin TwNum(a1,B1,a2,B2,S1,S2);
    if S1<>S2 then N:=(7+S2) div 2 else
    if (Compar2(a1,a2)*S1)= 1 then N:=3 else N:=4;
    N1:=APar(N)+1; N2:=APar(N+1)-1; DAFS; RSsF(N1,N2);
    DelList(a1); DelList(a2)
   end;
   end;
{***************************************}
   procedure  TTRAC.ad(SO: integer);
{* plus / minus *}
   var S1,S2 : integer; a,a1,a2,B1,B2: Bill;
   begin if DEBUG then WrDebug('ad '+I2S(SO));
    TwNum(a1,B1,a2,B2,S1,S2); S2:=S1*S2*SO;
    if Compar2(a1,a2)=-1 then begin
     a:=a1; a1:=a2; a2:=a; S1:=S1*S2;
     a:=B1; B1:=B2; B2:=a end;
    WrChLB(lch('0'),a1);
    if S2=1 then add(B1,B2) else sub(B1,B2);
    Del0(a1); if (S1=-1) and (a1^.Lett<>iord(lch('0')))
              then WrChLB(lch('-'),a1);
    DAFS; DelList(a2); RetFun(a1,B1)
   end;
{***************************************}
   procedure  TTRAC.Mul(B1,a2 : Bill; var sa,sb: Bill);
   var am,bm: Bill; N: integer;
   begin if DEBUG then WrDebug('mul');
    sa:=nil; am:=nil;
    Mul1(B1,sa,a2^.Lett-ord('0'));
    Tear(sa,sb); a2:=a2^.Next;
    while a2<>nil do
    begin N:=a2^.Lett-ord('0');
     WrChL(lch('0'),sb); if N<>0 then
     begin Mul1(B1,am,N); Tear(am,bm);
      WrChLB(lch('0'),sa); add(sb,bm); DelList(am); Del0(sa)
     end; a2:=a2^.Next
    end;
   end;
{***************************************}
   procedure  TTRAC.Dvd(a1,a2: Bill;var a: Bill);
   var B1,B2: Bill;
   begin if DEBUG then WrDebug('dvd');
    B1:=a1; B2:=a2; a:=nil; WrChL0(lch('0'),a);
    while B2^.Next<>nil do
    begin B2:=B2^.Next; B1:=B1^.Next end;
    while B1<>nil do
     if a1^.Lett=ord('0') then
     begin a1:=a1^.Next; B1:=B1^.Next;
      WrChL0(lch('0'),a) end  else begin
       if Compar1(a1,a2)<0 then begin B1:=B1^.Next;
                                 WrChL0(lch('0'),a);
        if B1<>nil then begin
         while a1^.Lett<>ord('0') do begin sub(B1,B2);
         a^.Prev^.Lett:=a^.Prev^.Lett+1 end;
         a1:=a1^.Next end end;
       if B1<>nil then
       while Compar1(a1,a2)<>-1 do begin sub(B1,B2);
       a^.Prev^.Lett:=a^.Prev^.Lett+1 end
     end; a:=a^.Prev {* delete last 0 *}
    end;
{***************************************}
   procedure  t_ad(TT : TTRAC);
{  (sl) ad, add  }
   begin TT.ad(1) end;
{***************************************}
   procedure  t_su(TT : TTRAC);
{  (rz) su, subtract  }
   begin TT.ad(-1) end;
{***************************************}
   procedure  t_ml(TT : TTRAC);
{  (um) ml, multiply  }
   var a1,B1,a2,B2,a,B: Bill; S1,S2: integer;
   begin
   with TT do
   begin
    TwNum(a1,B1,a2,B2,S1,S2);a:=nil;B:=nil;
    if (a1^.Lett<>ord('0')) and (a2^.Lett<>ord('0'))
    then begin Mul(B1,a2,a,B);
     if S1*S2=-1 then WrChLB(lch('-'),a) end
    else begin WrChL(lch('0'),a); B:=a end;
    DAFS; DelList(a1); DelList(a2); RetFun(a,B)
   end;
   end;
{***************************************}
   procedure  t_dv(TT : TTRAC);
{  (dl) dv, divide  }
   var a1,B1,a2,B2,a,B: Bill; S1,S2: integer;
   begin
   with TT do
   begin
    TwNum(a1,B1,a2,B2,S1,S2);a:=nil;B:=nil;
    if a2^.Lett=ord('0') then ActPar(3) else
    begin
     if a2^.Lett<>ord('0')
      then begin Dvd(a1,a2,a);
       Tear(a,B); Del0(a);
       if S1*S2=-1 then WrChLB(lch('-'),a) end
      else begin WrChL(lch('0'),a); B:=a end;
      DAFS; RetFun(a,B)
    end;
    DelList(a1); DelList(a2)
   end;
   end;
{***************************************}
  procedure  t_cr(TT : TTRAC);
{  (pu) cr ?, call restore  }
  var f: TFormT; s: Alpha;
  begin
  with TT do
  begin
   Par(1,s); 
   if FindFormT(f,s) then
   begin
    f.AdPtr:=1; DAFS end
   else ActPar(2)
  end;
  end;
{***************************************}
  procedure  t_cm(TT : TTRAC);
{  (im) cm, change meta  }
  begin
  with TT do
  begin
   MetaChar:=ChMem[APar(1)+1]; DAFS
  end;
  end;
{***************************************}
  procedure  t_dd(TT : TTRAC);
{  (uo) dd, delete definition  }
  var s: Alpha; J: integer;
  begin
  with TT do
  begin
   for J:=1 to pstc-2-pfbg do begin
    Par(J,s);
    DelFormT(s);
   end;
   DAFS
  end;
  end;
{***************************************}
  procedure  t_eq(TT : TTRAC);
{  ! (rw) eq, equal  }
  var N,N1,N2: integer;
  begin
  with TT do
  begin
   if Compar(ChMem,ChMem,APar(1)+1,APar(2)-1,APar(2)+1,APar(3)-1)
   then N:=3  else N:=4; N1:=APar(N)+1; N2:=APar(N+1)-1;
   DAFS; RSsF(N1,N2);
  end;
  end;
{***************************************}
   procedure  t_oo(TT : TTRAC);
{  + (wy) oo, output file  }
   var NM : Alpha; J,LEN:integer;
   begin
   with TT do
   begin
    if OPNFO then close(FO) else OPNFO:=true;
    NM := '';
    for J:=APar(1)+1 to APar(2)-1 do
      NM:= NM + chl(ChMem[J]);
     LEN:=Natur(APar(2)+1,APar(3)-1);
     assign(FO,NM);
     if LEN <> 0 then
     begin
      {$I-} APPEND(FO); {$I+}
      if IORESULT = 2 {not found} then rewrite(FO)
    end
    else rewrite(FO);
    DAFS
   end;
   end;
{***************************************}
   procedure  t_oi(TT : TTRAC);
{  + (ww) oi, input file  }
   var NM : Alpha; J,LEN:integer;
        B1,B2: Bill;
   begin
   with TT do
   begin
    if OPNFI then close(FI) else OPNFI:=true;
    NM:='';
    for J:=APar(1)+1 to APar(2)-1 do
      NM:= NM + chl(ChMem[J]);
    assign(FI,NM);
    {$I-} reset(FI); {$I+}
    if IORESULT = 0 then LEN:=1 else begin LEN:=-1; OPNFI:=false end;
    B1:=nil; NmRot(LEN,B1); Tear(B1,B2);
   DAFS; RetFun(B1,B2)
   end;
   end;
{***************************************}
   procedure  t_lf(TT : TTRAC);
{  lf, load file, 2k5  }
   var
    BB,BE: Bill; ch: TRChar;
    FL : Text;  NM : Alpha; OK : Boolean;
   begin
   with TT do
   begin
    Par(1,NM);
    assign(FL,NM);
    {$I-} reset(FL); {$I+}
    OK := (IORESULT = 0);
    BB:=nil;
    if OK then
    begin
     while not eof(FL) do
     begin
      repeat read(FL,ch); WrChL0(lch(ch),BB)
      until eoln(FL); readln(FL);
      WrChL0(lch(EOL),BB)
     end;
     DAFS; Tear(BB,BE); RetFun(BB,BE);
     Close(FL);
    end
    else ActPar(2)
   end;
   end;
{***************************************}
   procedure  t_rf(TT : TTRAC);
{  (~f) rf, read line from file  }
   var BB,BE: Bill; ch: TRChar;
   begin
   with TT do
   begin BB:=nil;
    if OPNFI {!2k5} and (not eof(FI)) then
    begin repeat read(FI,ch); WrChL0(lch(ch),BB)
     until eoln(FI); readln(FI);
     DAFS; Tear(BB,BE); RetFun(BB,BE)
    end else ActPar(1)
   end;
   end;
{***************************************}
   procedure  t_wf(TT : TTRAC);
{  (zf) wf, write file  }
   var I: integer; ch: letter;
   begin
   with TT do
   begin
    if OPNFO then begin {!2k5}
     for I:=APar(1)+1 to APar(2)-1 do
     begin ch:=ChMem[I]; if chl(ch)=EOL then writeln(FO)
                         else write(FO,chl(ch)) end;
    writeln(FO) end;
    DAFS
   end;
   end;
{***************************************}
  procedure  t_cp(TT : TTRAC);
{  + (sp) cp, compare after ptr   }
  var k,N1,N2,m1,m2: integer; s:Alpha; f: TFormT;
  begin
  with TT do
  begin
   Par(1,s);
   if FindFormT(f,s) then
   begin
    N1:=f.AdPtr-1;
    m1:=APar(2)+1; m2:=APar(3)-1; N2:=N1-m1+m2;
    k:=4; if N2<=Length(f.ForMem)-1 then
    if Compar(ChMem,f.ForMem,m1,m2,N1,N2) then
    begin f.AdPtr:=f.AdPtr-N1+N2+1; k:=3 end;
    N1:=APar(k)+1; N2:=APar(k+1)-1; DAFS;
    RSsF(N1,N2)
   end else DAFS
   end;
   end;
{***************************************}
  procedure  t_ch(TT : TTRAC);
{  (sn) ch  }
  var B: Bill;
  begin
  with TT do
  begin
   B:=nil; if pfbg+2<pstc then
   begin WrChL(ltr(Natur(APar(1)+1,APar(2)-1)),B);
    DAFS; RetFun(B,B) end
   else DAFS
  end;
  end;
{***************************************}
  procedure  t_ac(TT : TTRAC);
{  ! (as) ac, ascii code  }
  var B1,B2: Bill; N: integer;
  begin
  with TT do
  begin
   B1:=nil; N:=iord(ChMem[APar(1)+1]);
   NmRot(N,B1); Tear(B1,B2);
   DAFS; RetFun(B1,B2)
  end;
  end;
{***************************************}
  procedure  t_ll(TT : TTRAC);
{  (ke) ll, list length  }
  var B1,B2: Bill; N: integer;
  begin
  with TT do
  begin
   B1:=nil; N:=pstc-pfbg-2;
    NmRot(N,B1); Tear(B1,B2);
    DAFS; RetFun(B1,B2)
  end;
  end;
{***************************************}
  procedure  t_hl(TT : TTRAC);
{  (gs) hl, head of list  }
  var B,BE: Bill; I: integer;
  begin
  with TT do
  begin
   B:=nil;
   for I:=APar(1)+1 to APar(2)-1 do WrChL0(ChMem[I],B);
   DAFS;
   if B<>nil then begin Tear(B,BE); RetFun(B,BE) end;
  end;
  end;
{***************************************}
  procedure  t_en(TT : TTRAC);
{  (es) en, element of list  }
  var B,BE: Bill; I,N: integer;
  begin
  with TT do
  begin
   B:=nil; N:=Natur(APar(1)+1,APar(2)-1);
   if N<0 then N:=pstc-pfbg-2+N; N:=N+1;
   if N>0 then
   for I:=APar(N)+1 to APar(N+1)-1 do WrChL0(ChMem[I],B);
   DAFS;
   if B<>nil then begin Tear(B,BE); RetFun(B,BE) end;
  end;
  end;
{***************************************}
  procedure  t_tl(TT : TTRAC);
{  (hs) tl, tail of list  }
  var B,BE: Bill; I,J : integer;
  begin
  with TT do
  begin
   B:=nil;
   for J:=2 to pstc-pfbg-2 do
   begin if J<>2 then WrChL0(lch(','),B); WrChL0(lch('('),B);
    for I:=APar(J)+1 to APar(J+1)-1 do WrChL0(ChMem[I],B);
    WrChL0(lch(')'),B) end;
   DAFS;
   if B<>nil then begin Tear(B,BE); RetFun(B,BE) end;
  end;
  end;
{***************************************}
  procedure  t_bel(TT : TTRAC;t: integer);
  {bl/el begining or end of list}
  var B,BE: Bill; I,J,k,L,N: integer;
  begin
  with TT do
  begin
   B:=nil; N:=Natur(APar(1)+1,APar(2)-1);
   if t=0 then if N>0 then begin k:=2; L:=N+1;
                     if L>pstc-pfbg-2 then L:=pstc-pfbg-2 end
               else begin L:=pstc-pfbg-2; k:=L+N+1;
                if k<2 then k:=2 end
          else if N>0 then begin k:=N+2; L:=pstc-pfbg-2 end
               else begin k:=2; L:=pstc-pfbg-2+N end;
   for J:=k to L do
   begin if J<>k then WrChL0(lch(','),B); WrChL0(lch('('),B);
    for I:=APar(J)+1 to APar(J+1)-1 do WrChL0(ChMem[I],B);
    WrChL0(lch(')'),B) end;
   DAFS;
   if B<>nil then begin Tear(B,BE); RetFun(B,BE) end;
  end;
  end;
{***************************************}
   procedure  t_pf(TT : TTRAC); {2k5}
{  pf, print form  }
   var f: TFormT; I : integer;
       s: Alpha; ch: letter;
       found : boolean;
       B,B1: Bill;
   begin
   with TT do
   begin
    Par(1,s); found := FindFormT(f,s);
    if found and (Length(f.ForMem)>0) then begin
     new(B); B^.Prev:=nil; B^.Next:=nil; B1:=B;
     for I:=0 to Length(f.ForMem)-1 do
     begin ch:=f.ForMem[I];
      if (mch(ch)>=0) then
      begin WrChL(lch('\'),B);
       WrNum(mch(ch),B);
       WrChL(lch('\'),B) end
      else begin if chl(ch) = '\' then WrChL(lch('\'),B);
            WrChL(ch,B) end;
      if I=f.AdPtr-2 then begin
       WrChL(lch('\'),B); WrChL(lch('^'),B) end;
     end; DAFS; B1:=B1^.Next; dispose(B1^.Prev); B1^.Prev:=nil;
     RetFun(B1,B)
    end else DAFS
   end;
   end;
{***************************************}
  procedure  t_arif(TT : TTRAC); {2k5}
{  *,+,-,/ float arithmetics  }
  var
   A,B,C,Res : Alpha;
  begin
  with TT do
  begin
   Par(0,C); Par(1,A); Par(2,B);
   if StrBinOp(C[1],A,B,Res) then
   begin
    DAFS; RetStFun(Res);
   end
   else ActPar(3);
  end;
  end;
{***************************************}
  procedure  t_cmpf(TT : TTRAC); {2k5}
{  <,=,> float comparisom  }
  var
   A,B,C : Alpha;
   EQ3,N,N1,N2 : integer;
  begin
  with TT do
  begin
   Par(0,C); Par(1,A); Par(2,B);
   if StrCmp3(A,B,EQ3) then
   begin
    if ((C='>') and (EQ3=1))
     or ((C='=') and (EQ3=0))
     or ((C='<') and (EQ3=-1))
    then N := 3 else N:=4;
    N1:=APar(N)+1; N2:=APar(N+1)-1; DAFS; RSsF(N1,N2);
   end
   else ActPar(5);
  end;
  end;
  {***************************************}
  procedure t_cl1(TT : TTRAC);
  begin
   t_cl(TT,1)
  end;

  {***************************************}
  procedure t_bel0(TT : TTRAC);
  begin
   t_bel(TT,0)
  end;

  {***************************************}
  procedure t_bel1(TT : TTRAC);
  begin
   t_bel(TT,1)
  end;

 {***************************************}
  procedure t_tn(TT : TTRAC);
  begin
  with TT do
  begin trace:=true; DAFS end;
  end;

 {***************************************}
  procedure t_tf(TT : TTRAC);
  begin
  with TT do
  begin trace:=false; DAFS end;
  end;

 {***************************************}
  procedure t_hlp(TT : TTRAC);
  begin
  with TT do
  begin DAFS;
    WrTrace('rs ps ds ss cl cr cm ad su ml dv cs rc',true,0);
    WrTrace('cc cn in eq ge gr dd ln ch ac no hl tl',true,0);
    WrTrace('ll en bl el te cp oo oi rf wf st tn tf pf lf',true,0)
  end;
  end;
{***************************************}
  procedure t_deb(TT : TTRAC);
  begin
  with TT do
  begin DEBUG:=not DEBUG; DAFS end;
  end;

 {***************************************}
  procedure t_nop(TT : TTRAC);
  begin
   TT.DAFS
  end;

  {***************************************}
  procedure t_st(TT : TTRAC);
  begin
   TT.PREND := true;
  end;

{***************************************}
  procedure TTRAC.FillFun;
  const
   nfun = 50;
   funlist : array[0..nfun-1] of
    record
     n : TRString;
     p : ProcTRAC;
    end =
    ((n : 'rs'; p : t_rs),
     (n : 'ps'; p : t_ps),
     (n : 'ds'; p : t_ds),
     (n : 'ss'; p : t_ss),
     (n : 'cl'; p : t_cl1),
     (n : 'cr'; p : t_cr),
     (n : 'cm'; p : t_cm),
     {(n : 'rs'; p : t_rs),}
     (n : 'ad'; p : t_ad),
     (n : 'su'; p : t_su),
     (n : 'ml'; p : t_ml),
     (n : 'dv'; p : t_dv),
     (n : 'cs'; p : t_cs),
     (n : 'cc'; p : t_cc),
     (n : 'cn'; p : t_cn),
     (n : 'in'; p : t_in),
     (n : 'eq'; p : t_eq),
     (n : 'ge'; p : t_ge),
     (n : 'gr'; p : t_gr),
     (n : 'dd'; p : t_dd),
     (n : 'ln'; p : t_ln),
     (n : 'ch'; p : t_ch),
     (n : 'ac'; p : t_ac),
     (n : 'no'; p : t_nop),
     (n : 'hl'; p : t_hl),
     (n : 'tl'; p : t_tl),
     (n : 'll'; p : t_ll),
     (n : 'en'; p : t_en),
     (n : 'bl'; p : t_bel0),
     (n : 'el'; p : t_bel1),
     (n : 'te'; p : t_te),
     (n : 'cp'; p : t_cp),
     (n : 'oi'; p : t_oi),
     (n : 'oo'; p : t_oo),
     (n : 'lf'; p : t_lf),
     (n : 'rf'; p : t_rf),
     (n : 'wf'; p : t_wf),
     (n : 'pf'; p : t_pf),
     (n : 'rc'; p : t_rc),
     (n : 'st'; p : t_st),
     (n : 'tn'; p : t_tn),
     (n : 'tf'; p : t_tf),
     (n : '*'; p : t_arif),
     (n : '+'; p : t_arif),
     (n : '-'; p : t_arif),
     (n : '/'; p : t_arif),
     (n : '<'; p : t_cmpf),
     (n : '='; p : t_cmpf),
     (n : '>'; p : t_cmpf),
     (n : '?'; p : t_hlp),
     (n : 'DEBUG'; p : t_deb)
     );
  var
   i : integer;
   tp : TProcTRAC;
  begin
   for i := 0 to nfun-1 do
   with funlist[i] do
   begin
    tp := TProcTRAC.Create;
    tp.flags := [];
    tp.t_proc := p;
    ListFun.AddObject(n,tp)
   end;
  end;

  procedure TTRAC.InsFunTRAC(FunName : TRString;
   Fun : ProcTRAC; Update,ClearStack : Boolean);
  var
   Idx : integer;
   tp : TProcTRAC;
   SFunName : String;
  begin
   SFunName := TRtoString(FunName);
   if ListFun.Find(SFunName,Idx) then
    if Update then
    begin
     tp := TProcTRAC(ListFun.Objects[Idx]);
     if ClearStack then
      tp.flags := tp.flags + [fptClearStack]
     else
      tp.flags := tp.flags - [fptClearStack];
     tp.flags := tp.flags + [fptOverride];
     tp.t_proc := Fun
    end
    else Exit
   else
   begin
    tp := TProcTRAC.Create;
    if ClearStack then
     tp.flags := [fptClearStack]
    else
     tp.flags := [];
    tp.t_proc := Fun;
    ListFun.AddObject(SFunName,tp);
   end
  end;

{***************************************}
  procedure TTRAC.CallFun;
  var N1,N2,I,nas,Idx : integer;
      imfu : Alpha;
      tp : TProcTRAC;
  begin if DEBUG then WrDebug('callfun');
   marcc(EndFun); {* mark last argument *}
   nas:=MainChain.oac; pfbg:=pstc-2;
   while (pfbg > 0) and
      not (stc[pfbg].tym in [BgActFun,BgNeuFun])
      do pfbg:=pfbg-1;
   if pfbg<=0 then WrTrace('no origin of function',true,2)
   else begin
    N1:=stc[pfbg].adm+1; N2:=stc[pfbg+1].adm-N1;
    SubstShort(imfu,N1,N2);
    if trace then
    begin if stc[pfbg].tym=BgNeuFun then WrTrace('#'); WrTrace('#(');
     for N1:=pfbg to pstc-2 do begin
      if N1<>pfbg then WrTrace(chl(MetaChar));
      for I:=stc[N1].adm+1 to stc[N1+1].adm-1 do
      WrTrace(chl(ChMem[I])) end; WrTrace(')',true) end;
     if ListFun.Find(TRtoString(imfu),Idx) then
     begin
      tp := TProcTRAC(ListFun.Objects[Idx]);
      tp.t_proc(Self);
      if fptClearStack in tp.flags then DAFS
     end
     else t_cl(Self,0);
    if trace then begin
     if nas=MainChain.oac then begin WrTrace('<-'+chl(MetaChar));
      if stc[pfbg].tym=BgNeuFun then N1:=stc[pfbg].adm-2
                                else N1:=stc[pfbg].adm-1;
      N2:=MainChain.enc end  else begin WrTrace('->'+chl(MetaChar));
      N1:=MainChain.oac; N2:=nas-1 end;
     for I:=N1 to N2 do WrTrace(chl(ChMem[I])); WrTrace('',true) end
   end
  end;
  {***************************************}
  procedure TTRAC.AlgTRAC;
  begin
    PREND:=false;
    repeat
     EvalTRAC(s0)
    until PREND
  end;
  {***************************************}
   procedure TTRAC.IniTRAC(aLenChain,aLenCF : Longint);
   begin
    LenChain := aLenChain;
    LenCF := aLenCF;
    SetLength(ChMem,LenChain+1);
    SetLength(stc,LenCF);
    MetaChar:=lch(''''); trace:=false; DEBUG:=false;
    OPNFO:=false; OPNFI:=false;
    EOL:=chr(10); {* *}
    s0:='#(ps,#(rs))';
    FillFun;

   end;
   {***************************************}
   procedure TTRAC.FinTRAC;
   begin
     if OPNFO then close(FO);
     if OPNFI then close(FI);
   end;
   {***************************************}
   procedure TTRAC.EvalTRAC(Instr : TRString);
   var ch: letter; EXI: boolean;
   I,br: integer {* brackets nesting *};
   begin
   try
    MainChain.enc:=0; MainChain.oac:=LenChain-Length(Instr);
    pstc:=1; EXI:=false;
    for I:=MainChain.oac to LenChain-1 do
     ChMem[I]:=lch(Instr[I-MainChain.oac+1]);
    repeat MovSCP(ch);
      while chl(ch)='#' do
      begin MovSCP(ch); if chl(ch)='(' then
       begin marcc(BgActFun); MovSCP(ch) end
       else if chl(ch)='#' then
       begin MovSCP(ch); if chl(ch)='(' then
        begin marcc(BgNeuFun); MovSCP(ch) end
       end
      end;
      if chl(ch)=EOL then DelCh
      else if chl(ch)='(' then begin DelCh; EXI:=false; br:=1;
       repeat MovSCP(ch);
       if chl(ch)='(' then br:=br+1 else
       if chl(ch)=')' then br:=br-1;
       if MainChain.oac>=LenChain then EXI:=true
       until (br=0) or (EXI); DelCh end
      else if chl(ch)=',' then marcc(BgArg)
      else if chl(ch)=')' then CallFun;
      if MainChain.oac>=LenChain then EXI:=true;
     until EXI;
    except on E: Exception do
     WrTrace('Exception:'+E.Message,true,2)
    end {try}
   end;
   {***************************************}
   procedure TTRAC.RunTRAC(aLenChain : Longint = defLenChain;
                            aLenCF : longint = defLenCF);
   begin
     IniTRAC(aLenChain,aLenCF);
     WrTrace('Processor TRAC 4LZ (MACAR 2K5/13/17)',True,0);
     AlgTRAC;
     WrTrace('Stop the processor.',True,0);
     FinTRAC;
   end;
   {**************************************}
   procedure TTRAC.WrDebug(Msg : TRString);
   begin
    writeln(ConvTRString(Msg));
   end;
  {**************************************}
   procedure TTRAC.WrTrace(Msg : TRString; IsEol : Boolean; info : integer);
   begin
    write(ConvTRString(Msg));
    if IsEol then writeln
   end;
   {**************************************}
   procedure TTRAC.WriteTRAC(Str : TRString; IsEol : Boolean = False);
   begin
    write(ConvTRString(Str));
    if IsEol then writeln
   end;
  {**************************************}
   procedure TTRAC.ReadlnTRAC;
   begin
    Readln;
   end;
  {**************************************}
   procedure TTRAC.ReadTRAC(var Ch : TRChar);
   var
    TRS : TRString;
    S : string;
    i,n : integer;
    ch8 : AnsiChar;  {A}
   begin
    Read(ch8);
    S := ch8;
    if CurConv = tcUTF8 then
    begin
     if ch8 < #128 then n:=1
     else
      if ch8 < #224 then n:=2
      else n := 3;
     for i:=2 to n do
     begin
      Read(ch8);
      S := S+ch8;
     end;
    end;
    TRS := ConvToTRString(S);
    Ch := TRS[1]
   end;
   {**************************************}
   constructor TTRAC.Create;
   begin
    inherited Create;
    LenChain := 0;
    LenCF := 0;
    SetLength(ChMem,0);
    SetLength(stc,0);
    MainChain.enc := 0;
    MainChain.oac := 0;
    pstc := 0;
    pfbg := 0;
    MetaChar := 0;

    OPNFO := False;
    OPNFI := False;
    PREND := False;
    DEBUG := False;
    trace := False;
    Unicode := False;
    EOL := chr(10);
    s0 := '';
    ListForms := TLIstFormT.Create;
    ListForms.Sorted := true;
    ListForms.CaseSensitive := true;
    ListFun := TStringList.Create;
    ListFun.Sorted := true;
    ListFun.CaseSensitive := true;
    if @ConvToTRString = nil
     then SetConv(tcANSI)
   end;
   {**************************************}
   destructor TTRAC.Destroy;
   var
    i : integer;
   begin
    if ChMem <> nil then
     SetLength(ChMem,0);
    if stc <> nil then
     SetLength(stc,0);
    s0 := '';

    ListForms.Free;
    with ListFun do
    begin
     for i:=0 to Count-1 do
      Objects[I].Free;
     Free;
    end;

    inherited Destroy;
   end;
   {**************************************}
   function TTRAC.StoTRString(const AStr : String) : TRString;
   begin
    Result := TR8toTR(AStr);
   end;
   {**************************************}
   function TTRAC.TRtoString(const ATRStr : TRString) : String;
   begin
    Result := TRtoTR8(ATRStr);
   end;
  {**************************************}

 { TListForm}

   destructor TListFormT.Destroy;
   var
    i : Integer;
   begin
    for i := 0 to Count-1 do
     TFormT(Objects[i]).Free;
    inherited Destroy
   end;

 {TFormT}

   constructor TFormT.Create;
   begin
    inherited Create;
    pack := false;
    AdPtr := 0;
    adr2 := nil;
    RTofFormT := nil;
    SetLength(ForMem,0);
   end;

   destructor TFormT.Destroy;
   begin
     SetLength(ForMem,0);
     inherited Destroy
   end;

end.
