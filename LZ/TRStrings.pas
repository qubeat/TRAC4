unit TRStrings;

{$IFDEF FPC}
  {$MODE Delphi}
  {$IFDEF WINDOWS}
   {$DEFINE MSWINDOWS}
  {$ENDIF}
{$ENDIF}

interface

uses

  SysUtils,
  {$IFDEF MSWINDOWS}
  Windows;
  {$ELSE}
  cwstring,lazutf8,
  LCLProc,LConvEncoding;
  {$ENDIF}



type

  tConv = (tcOEM,tcANSI,tcUTF8);

  TConvToString = function(const s: string): string;
  TConvToTRString = function(const s: string): WideString;
  TConvTRString = function(const ws : WideString): string;
var
  ConvToTR8String : TConvToString = nil;
  ConvToTRString : TConvToTRString = nil;
  ConvTR8String : TConvToString = nil;
  ConvTRString : TConvTRString = nil;

  CurConv : tConv;


  function AnsiToTR8(const s: string): string;
  function OEMToTR8(const s: string): string;

  function TR8ToAnsi(const s: string): string;
  function TR8ToOEM(const s: string): string;

  function TR8toTR(const s: string): WideString;
  function TRtoTR8(const ws : WideString): string;

  function AnsiToTR(const s: string): WideString;
  function OEMToTR(const s: string): WideString;

  function TRtoANSI(const ws : WideString): string;
  function TRtoOEM(const ws : WideString): string;


  procedure SetConv(ct : tConv);

implementation

 {$IFDEF MSWINDOWS}
 function OEMtoWin(const s: string): string;
 var
  Buf : array[0..$FFFF] of AnsiChar;
 begin
  StrPCopy(Buf,s);
  OEMToANSI(Buf,Buf);
  Result := string(buf);
 end;

 function WinToOEM(const s: string): string;
 var
  Buf : array[0..$FFFF] of AnsiChar;
 begin
  StrPCopy(Buf,s);
  ANSIToOEM(Buf,Buf);
  Result := string(buf);
 end;

 function OEMToTR8(const s: string): string;
 begin
  Result := AnsiToUTF8(OEMtoWin(s));
 end;

 function TR8ToOEM(const s: string): string;
 begin
  Result := WinToOEM(UTF8ToAnsi(s));
 end;

 function TR8toTR(const s: string): WideString;
 begin
  Result := UTF8Decode(s);
 end;

 function TRtoTR8(const ws : WideString): string;
 begin
  Result := UTF8Encode(ws);
 end;
 {$ELSE}

 function OEMToTR8(const s: string): string;
 begin
  Result := ConsoleToUTF8(s);
 end;

 function TR8ToOEM(const s: string): string;
 begin
  Result := UTF8ToConsole(s);
 end;

 function TR8toTR(const s: string): WideString;
 begin
  Result := UTF8ToUTF16(s);
 end;

 function TRtoTR8(const ws : WideString): string;
 begin
  Result := UTF16ToUTF8(ws);
 end;
  {$ENDIF}

  function AnsiToTR8(const s: string): string;
  begin
   Result := AnsiToUTF8(s);
  end;


  function TR8ToAnsi(const s: string): string;
  begin
   Result := UTF8ToAnsi(s);
  end;



 function AnsiToTR(const s: string): WideString;
 begin
  Result := TR8toTR(AnsiToTR8(s));
 end;

 function OEMToTR(const s: string): WideString;
 begin
  Result := TR8toTR(OEMToTR8(s));
 end;

 function TRtoANSI(const ws : WideString): string;
 begin
  Result := TR8ToANSI(TRtoTR8(ws));
 end;

 function TRtoOEM(const ws : WideString): string;
 begin
  Result := TR8ToOEM(UTF8Encode(ws));
 end;



 function NoConv(const s: string): string;
 begin
  Result := s;
 end;


 procedure SetConv(ct : tConv);
 begin
  CurConv := ct;
  case ct of
   tcOEM :
    begin
     ConvToTR8String := @OEMtoTR8;
     ConvToTRString := @OEMtoTR;
     ConvTR8String := @TR8toOEM;
     ConvTRString := @TRtoOEM;
    end;
   tcANSI :
    begin
     ConvToTR8String := @ANSItoTR8;
     ConvToTRString := @ANSItoTR;
     ConvTR8String := @TR8toANSI;
     ConvTRString := @TRtoANSI;
    end;
   tcUTF8 :
    begin
     ConvToTR8String := @NoConv;
     ConvToTRString := @TR8toTR;
     ConvTR8String := @NoConv;
     ConvTRString := @TRtoTR8;
    end;
   end;

 end;


end.
