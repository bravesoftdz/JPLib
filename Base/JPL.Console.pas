﻿unit JPL.Console;

{
  Jacek Pazera
  http://www.pazera-software.com
  Last mod: 2018.03.18

  =================================================================

  MSDN
    https://docs.microsoft.com/en-us/windows/console/using-the-high-level-input-and-output-functions
    https://docs.microsoft.com/en-us/windows/console/getconsolescreenbufferinfo
    https://docs.microsoft.com/en-us/windows/console/setconsoletextattribute
    https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
    https://msdn.microsoft.com/en-us/library/windows/desktop/aa364960      <-- GetFileType

  Rudy Velthuis
    http://rvelthuis.de/programs/console.html
    https://github.com/rvelthuis/Consoles

  https://en.wikipedia.org/wiki/ANSI_escape_code
  Colors: https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

  https://stackoverflow.com/questions/2616906/how-do-i-output-coloured-text-to-a-linux-terminal
  https://stackoverflow.com/questions/287871/print-in-terminal-with-colors

  https://stackoverflow.com/questions/1312922/detect-if-stdin-is-a-terminal-or-pipe



  =====================================================================

  ANSI color codes:

  ESC[<ATTRIBUTE>;<TEXT_COLOR>;<BACKGROUND_COLOR>m some text ESC[<RESET_ATTRIBUTE>m
  eg. ESC[0;31;36m red text on cyan background ESC[0m default colors
  ESC = #27
  CSI = #27[      (CSI - Control Sequence Introducer)


  ATTRIBUTES

    0 - default
    1 - bold or increased intensity
    2 - dim (decreased intensity)
    3 - italic
    4 - underline
    5 - slow blink
    6 - rapid blink
    7 - inverse foreground and background colors
    8 - hidden
    9 - crossed-out
    10 - primary (default) font
    11-19 - alternative font
    20 - fraktur
    21 - bold or double underline
    22 - normal color or intensity
    23 - not italic, not fraktur

  COLORS

    Foreground      Background (Fg + 10)
    30  black           40
    31  red             41
    32  green           42
    33  yellow          43
    34  blue            44
    35  magenta         45
    36  cyan            46
    37  white           47

    90  bright black    100
    91  bright red      101
    92  bright green    102
    93  bright yellow   103
    94  bright blue     104
    95  bright magenta  105
    96  bright cyan     106
    97  bright white    107

}

{$IFDEF FPC}
  {$mode objfpc}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}




interface

uses
  SysUtils,
  {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  {$IFDEF UNIX} BaseUnix, {$ENDIF}
  JPL.Strings;



const

  {$IFDEF DCC}
  ENABLE_VIRTUAL_TERMINAL_PROCESSING = $0004;
  {$ENDIF}

  // Console application exit codes
  CON_EXIT_CODE_OK = 0;
  CON_EXIT_CODE_ERROR = 1;
  CON_EXIT_CODE_SYNTAX_ERROR = 2; // invalid options
  CON_EXIT_CODE_USER = 20;


  ESC_CHAR = Char(27);
  AEC_START = ESC_CHAR + '[';   // AEC - Ansi Escape Code
  CSI = AEC_START;
  AEC_RESET = ESC_CHAR + '[0m';


  CON_COLOR_NONE = 200;

  {$IFDEF MSWINDOWS}
  CON_COLOR_RED_DARK = 4;
  CON_COLOR_RED_LIGHT = 12;
  CON_COLOR_GREEN_DARK = 2;
  CON_COLOR_GREEN_LIGHT = 10;
  CON_COLOR_BLUE_DARK = 1;
  CON_COLOR_BLUE_LIGHT = 9;

  CON_COLOR_BLACK = 0;
  CON_COLOR_BLACK_DARK = CON_COLOR_BLACK;
  CON_COLOR_BLACK_LIGHT = 8;

  CON_COLOR_WHITE = 15;
  CON_COLOR_WHITE_DARK = 7;
  CON_COLOR_WHITE_LIGHT = CON_COLOR_WHITE;

  // WHITE, WHITE_LIGHT, WHITE_DARK - taki mały absurd, trochę jak "koło, koło kwadratowe, koło trójkątne"

  CON_COLOR_GRAY_DARK = CON_COLOR_BLACK_LIGHT;
  CON_COLOR_GRAY_LIGHT = CON_COLOR_WHITE_DARK;

  CON_COLOR_CYAN_DARK = 3;
  CON_COLOR_CYAN_LIGHT = 11;

  CON_COLOR_MAGENTA_DARK = 5;
  CON_COLOR_MAGENTA_LIGHT = 13;

  CON_COLOR_YELLOW_DARK = 6;
  CON_COLOR_YELLOW_LIGHT = 14;

  {$ELSE} // Linux

  CCL_DELTA = 60;     // foreground: light color - dark color
  CCL_FB_DELTA = 10;  // background color - foreground color

  // Foreground colors
  CON_COLOR_RED_DARK_FG = 31;
  CON_COLOR_RED_LIGHT_FG = CON_COLOR_RED_DARK_FG + CCL_DELTA;
  CON_COLOR_GREEN_DARK_FG = 32;
  CON_COLOR_GREEN_LIGHT_FG = CON_COLOR_GREEN_DARK_FG + CCL_DELTA;
  CON_COLOR_BLUE_DARK_FG = 34;
  CON_COLOR_BLUE_LIGHT_FG = CON_COLOR_BLUE_DARK_FG + CCL_DELTA;

  CON_COLOR_BLACK_FG = 30;
  CON_COLOR_BLACK_DARK_FG = CON_COLOR_BLACK_FG;
  CON_COLOR_BLACK_LIGHT_FG = CON_COLOR_BLACK_DARK_FG + CCL_DELTA;

  CON_COLOR_WHITE_DARK_FG = 37;
  CON_COLOR_WHITE_LIGHT_FG = CON_COLOR_WHITE_DARK_FG + CCL_DELTA;
  CON_COLOR_WHITE_FG = CON_COLOR_WHITE_LIGHT_FG;

  CON_COLOR_CYAN_DARK_FG = 36;
  CON_COLOR_CYAN_LIGHT_FG = CON_COLOR_CYAN_DARK_FG + CCL_DELTA;

  CON_COLOR_MAGENTA_DARK_FG = 35;
  CON_COLOR_MAGENTA_LIGHT_FG = CON_COLOR_MAGENTA_DARK_FG + CCL_DELTA;

  CON_COLOR_YELLOW_DARK_FG = 33;
  CON_COLOR_YELLOW_LIGHT_FG = CON_COLOR_YELLOW_DARK_FG + CCL_DELTA;

  // Background colors
  CON_COLOR_RED_DARK_BG = CON_COLOR_RED_DARK_FG + CCL_FB_DELTA;
  CON_COLOR_RED_LIGHT_BG = CON_COLOR_RED_LIGHT_FG + CCL_FB_DELTA;
  CON_COLOR_GREEN_DARK_BG = CON_COLOR_GREEN_DARK_FG + CCL_FB_DELTA;
  CON_COLOR_GREEN_LIGHT_BG = CON_COLOR_GREEN_LIGHT_FG + CCL_FB_DELTA;
  CON_COLOR_BLUE_DARK_BG = CON_COLOR_BLUE_DARK_FG + CCL_FB_DELTA;
  CON_COLOR_BLUE_LIGHT_BG = CON_COLOR_BLUE_LIGHT_FG + CCL_FB_DELTA;

  CON_COLOR_BLACK_BG = CON_COLOR_BLACK_DARK_FG + CCL_FB_DELTA;
  CON_COLOR_BLACK_DARK_BG = CON_COLOR_BLACK_BG;
  CON_COLOR_BLACK_LIGHT_BG = CON_COLOR_BLACK_LIGHT_FG + CCL_FB_DELTA;

  CON_COLOR_WHITE_DARK_BG = CON_COLOR_WHITE_DARK_FG + CCL_FB_DELTA;
  CON_COLOR_WHITE_LIGHT_BG = CON_COLOR_WHITE_LIGHT_FG + CCL_FB_DELTA;
  CON_COLOR_WHITE_BG = CON_COLOR_WHITE_LIGHT_BG;

  CON_COLOR_CYAN_DARK_BG = CON_COLOR_CYAN_DARK_FG + CCL_FB_DELTA;
  CON_COLOR_CYAN_LIGHT_BG = CON_COLOR_CYAN_LIGHT_FG + CCL_FB_DELTA;

  CON_COLOR_MAGENTA_DARK_BG = CON_COLOR_MAGENTA_DARK_FG + CCL_FB_DELTA;
  CON_COLOR_MAGENTA_LIGHT_BG = CON_COLOR_MAGENTA_LIGHT_FG + CCL_FB_DELTA;

  CON_COLOR_YELLOW_DARK_BG = CON_COLOR_YELLOW_DARK_FG + CCL_FB_DELTA;
  CON_COLOR_YELLOW_LIGHT_BG = CON_COLOR_YELLOW_LIGHT_FG + CCL_FB_DELTA;

  {$ENDIF}

type

  TConsoleColors = record
    Text: Byte;
    Background: Byte;
  end;

  TConsoleColorEx = record
    Text: string;
    NormalColors: TConsoleColors;
    IsError: Boolean;
    ErrorColors: TConsoleColors;
    HighlightedColors: TConsoleColors;
    HighlightedText: string;
    CaseSensitive: Boolean;
    procedure Clear;
  end;


  TConsole = record
  private
    {$IFDEF MSWINDOWS}
    class var FOutputCodePage: UINT;
    class var FOriginalOutputCodePage: UINT;
    class function GetOutputCodePage: UINT; static;
    class procedure SetOutputCodePage(AValue: UINT); static;
    {$ENDIF}

    class function GetTextCodePage: Cardinal; static;
    class procedure SetTextCodePage(AValue: Cardinal); static;
  public

    {$region '     colors       '}


    const clNone = CON_COLOR_NONE;

    {$IFDEF MSWINDOWS}

    const clBlackText = CON_COLOR_BLACK;
    const clWhiteText = CON_COLOR_WHITE;
    const clBlackBg = clBlackText;
    const clWhiteBg = clWhiteText;

    // foreground light colors
    const clLightBlackText = CON_COLOR_BLACK_LIGHT;
    const clLightWhiteText = CON_COLOR_WHITE;
    const clLightRedText = CON_COLOR_RED_LIGHT;
    const clLightGreenText = CON_COLOR_GREEN_LIGHT;
    const clLightBlueText = CON_COLOR_BLUE_LIGHT;
    const clLightCyanText = CON_COLOR_CYAN_LIGHT;
    const clLightMagentaText = CON_COLOR_MAGENTA_LIGHT;
    const clLightYellowText = CON_COLOR_YELLOW_LIGHT;

    // foreground dark colors
    const clDarkBlackText = CON_COLOR_BLACK;
    const clDarkWhiteText = CON_COLOR_WHITE_DARK;
    const clDarkRedText = CON_COLOR_RED_DARK;
    const clDarkGreenText = CON_COLOR_GREEN_DARK;
    const clDarkBlueText = CON_COLOR_BLUE_DARK;
    const clDarkCyanText = CON_COLOR_CYAN_DARK;
    const clDarkMagentaText = CON_COLOR_MAGENTA_DARK;
    const clDarkYellowText = CON_COLOR_YELLOW_DARK;

    // background colors = foreground colors
    const clLightBlackBg = clLightBlackText;
    const clLightWhiteBg = clLightWhiteText;
    const clLightRedBg = clLightRedText;
    const clLightGreenBg = clLightGreenText;
    const clLightBlueBg = clLightBlueText;
    const clLightCyanBg = clLightCyanText;
    const clLightMagentaBg = clLightMagentaText;
    const clLightYellowBg = clLightYellowText;
    const clDarkBlackBg = clBlackText;
    const clDarkWhiteBg = clDarkWhiteText;
    const clDarkRedBg = clDarkRedText;
    const clDarkGreenBg = clDarkGreenText;
    const clDarkBlueBg = clDarkBlueText;
    const clDarkCyanBg = clDarkCyanText;
    const clDarkMagentaBg = clDarkMagentaText;
    const clDarkYellowBg = clDarkYellowText;

    {$ELSE}

    const clBlackText = CON_COLOR_BLACK_FG;
    const clWhiteText = CON_COLOR_WHITE_FG;
    const clBlackBg = CON_COLOR_BLACK_BG;
    const clWhiteBg = CON_COLOR_WHITE_BG;

    // foreground light colors
    const clLightBlackText = CON_COLOR_BLACK_LIGHT_FG;
    const clLightWhiteText = clWhiteText;
    const clLightRedText = CON_COLOR_RED_LIGHT_FG;
    const clLightGreenText = CON_COLOR_GREEN_LIGHT_FG;
    const clLightBlueText = CON_COLOR_BLUE_LIGHT_FG;
    const clLightCyanText = CON_COLOR_CYAN_LIGHT_FG;
    const clLightMagentaText = CON_COLOR_MAGENTA_LIGHT_FG;
    const clLightYellowText = CON_COLOR_YELLOW_LIGHT_FG;

    // foreground dark colors
    const clDarkBlackText = CON_COLOR_BLACK_DARK_FG;
    const clDarkWhiteText = CON_COLOR_WHITE_DARK_FG;
    const clDarkRedText = CON_COLOR_RED_DARK_FG;
    const clDarkGreenText = CON_COLOR_GREEN_DARK_FG;
    const clDarkBlueText = CON_COLOR_BLUE_DARK_FG;
    const clDarkCyanText = CON_COLOR_CYAN_DARK_FG;
    const clDarkMagentaText = CON_COLOR_MAGENTA_DARK_FG;
    const clDarkYellowText = CON_COLOR_YELLOW_DARK_FG;

    // background light colors
    const clLightBlackBg = CON_COLOR_BLACK_LIGHT_BG;
    const clLightWhiteBg = CON_COLOR_WHITE_BG;
    const clLightRedBg = CON_COLOR_RED_LIGHT_BG;
    const clLightGreenBg = CON_COLOR_GREEN_LIGHT_BG;
    const clLightBlueBg = CON_COLOR_BLUE_LIGHT_BG;
    const clLightCyanBg = CON_COLOR_CYAN_LIGHT_BG;
    const clLightMagentaBg = CON_COLOR_MAGENTA_LIGHT_BG;
    const clLightYellowBg = CON_COLOR_YELLOW_LIGHT_BG;

    // background dark colors
    const clDarkBlackBg = CON_COLOR_BLACK_DARK_BG;
    const clDarkWhiteBg = CON_COLOR_WHITE_DARK_BG;
    const clDarkRedBg = CON_COLOR_RED_DARK_BG;
    const clDarkGreenBg = CON_COLOR_GREEN_DARK_BG;
    const clDarkBlueBg = CON_COLOR_BLUE_DARK_BG;
    const clDarkCyanBg = CON_COLOR_CYAN_DARK_BG;
    const clDarkMagentaBg = CON_COLOR_MAGENTA_DARK_BG;
    const clDarkYellowBg = CON_COLOR_YELLOW_DARK_BG;

    {$ENDIF}

    const clLightGrayText = clDarkWhiteText;
    const clDarkGrayText = clLightBlackText;
    const clLightGrayBg = clLightGrayText;
    const clDarkGrayBg = clDarkGrayText;
    {$endregion colors}

    class procedure ResetColors; static;
    class procedure ResetColorsAEC; static;

    class procedure SetTextColor(const Color: Byte); static;
    class procedure SetBackgroundColor(const Color: Byte); static;
    class procedure SetColors(const TextColor, BgColor: Byte); static;

    class procedure SetRgbTextColor(const R, G, B: Byte); static;
    class procedure SetRgbBackgroundColor(const R, G, B: Byte); static;

    class procedure WriteColoredText(const s: string; const TextColor, BgColor: Byte); overload; static;
    class procedure WriteColoredText(const s: string; const cc: TConsoleColors); overload; static;
    class procedure WriteColoredTextLine(const s: string; const TextColor: Byte; BgColor: Byte = CON_COLOR_NONE); overload; static;
    class procedure WriteColoredTextLine(const s: string; const cc: TConsoleColors); overload; static;
    class procedure WriteColoredTextEx(const cce: TConsoleColorEx); static;
    class procedure WriteColoredTextLineEx(const cce: TConsoleColorEx); static;
    class procedure WriteTaggedText(s: string); static;
    class procedure WriteTaggedTextLine(s: string); static;

    class procedure Init; static;

    {$IFDEF MSWINDOWS}
    class function RestoreOriginalOutputCodePage: Boolean; static;
    class property OriginalOutputCodePage: UINT read FOriginalOutputCodePage;
    class property OutputCodePage: UINT read GetOutputCodePage write SetOutputCodePage;
    {$ENDIF}
    class property TextCodePage: Cardinal read GetTextCodePage write SetTextCodePage;
  end;


procedure ConInit;
{$IFDEF MSWINDOWS}
function ConOK: Boolean;
function ConGetCurrentTextAttr: WORD;
procedure ConSetTextAttrs(const Attrs: WORD);

// To use ANSI Escape Codes on Windows, ENABLE_VIRTUAL_TERMINAL_PROCESSING must be set in the console mode.
function ConSetVirtualTerminalProcessing(const Enable: Boolean): Boolean;
{$ENDIF}

function ConCanUseAEC: Boolean; // AEC - ANSI Escape Codes

procedure ConSetTextColor(const Color: Byte);
procedure ConSetBackgroundColor(const Color: Byte);
procedure ConSetColors(const TextColor, BgColor: Byte);

// RGB colors: Windows 10 Anniversary Update or newer
procedure ConSetRgbTextColor(const R, G, B: Byte);
procedure ConSetRgbBackgroundColor(const R, G, B: Byte);

procedure ConResetColors;
//procedure ConRestoreOriginalColors;
procedure ConResetColorsAEC;

procedure ConWriteAnsiEscapeCode(const Attr, TextColor, BgColor: Byte);

procedure ConWriteColoredText(const s: string; const TextColor, BgColor: Byte); overload;
procedure ConWriteColoredText(const s: string; const cc: TConsoleColors); overload;
procedure ConWriteColoredTextLine(const s: string; const cc: TConsoleColors); overload;
procedure ConWriteColoredTextLine(const s: string; const TextColor: Byte; BgColor: Byte = CON_COLOR_NONE); overload;

procedure ConWriteColoredTextEx(const cce: TConsoleColorEx);
procedure ConWriteColoredTextLineEx(const cce: TConsoleColorEx);

procedure ConGetColorsFromStr(const sColors: string; out TextColor, BgColor: Byte);
function ConColorToStr(const Color: Byte; AddFgBgSuffix: Boolean = False): string;

procedure ConWriteTaggedText(s: string);
procedure ConWriteTaggedTextLine(s: string);

procedure ConTestStandardColors;
procedure ConTestRgbColors;

{$IFDEF MSWINDOWS}
// If True, we can use ANSI Escape Codes. If False, we should use plain text only.
// Character device: console, terminal, printer
// Non-character device: file (redirection with ">"), pipe ...
function OutputIsCharacterDevice: Boolean;
{$ELSE}
// Jeśli wyjście (Output) jest "urządzeniem znakowym" (character device), oznacza to z reguły, że mamy do
// czynienia z terminalem lub drukarką, i można stosować kolory (sekwencje ANSI). W przeciwnym razie najprawdopodobniej
// mamy do czynienia z potokiem lub przekierowaniem wyjścia do pliku i wówczas nie można stosować kodów ANSI! (no chyba, że
// program/urządzenie odbierające dane akceptuje kody ANSI).
function OutputIsCharacterDevice(ResultIfStatFailed: Boolean = True): Boolean;
function OutputIsNamedPipe(ResultIfStatFailed: Boolean = True): Boolean;
function OutputIsRegularFile(ResultIfStatFailed: Boolean = True): Boolean;
{$ENDIF}

var

  ConOutputIsCharacterDevice: Boolean;

  // Forces the use of ANSI Escape Codes, even if the output is not a character device.
  ConForceAEC: Boolean;

  {$IFDEF MSWINDOWS}
  ConStdOut: THandle;
  ConCurrentTextAttrs: WORD;
  ConOriginalTextAttrs: WORD;
  ConInitialized: Boolean = False;
  ConVirtualTerminalProcessingEnabled: Boolean;
  {$ENDIF}


implementation


function ConCanUseAEC: Boolean;
begin
  Result := ConOutputIsCharacterDevice or ConForceAEC;
end;

{$IFDEF MSWINDOWS}
function ConGetCurrentTextAttr: WORD;
begin
  Result := ConCurrentTextAttrs;
end;

procedure ConSetTextAttrs(const Attrs: WORD);
begin
  if not ConOK then Exit;
  SetConsoleTextAttribute(ConStdOut, Attrs);
end;

function ConSetVirtualTerminalProcessing(const Enable: Boolean): Boolean;
var
  dwMode: DWORD;
begin
  Result := False;
  if not ConOK then Exit;
  if not GetConsoleMode(ConStdOut, dwMode) then Exit;
  if Enable then dwMode := dwMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING
  else dwMode := dwMode and (not ENABLE_VIRTUAL_TERMINAL_PROCESSING);
  Result := SetConsoleMode(ConStdOut, dwMode);
  ConVirtualTerminalProcessingEnabled := Result and Enable;
end;
{$ENDIF}


procedure ConSetTextColor(const Color: Byte);
begin
  {$IFDEF MSWINDOWS}
  if not ConOK then Exit;
  ConCurrentTextAttrs := (ConCurrentTextAttrs and $F0) or (Color and $0F);
  SetConsoleTextAttribute(ConStdOut, ConCurrentTextAttrs);
  {$ELSE}
  if ConCanUseAEC then Write(CSI, Color, 'm');
  {$ENDIF}
end;

procedure ConSetBackgroundColor(const Color: Byte);
begin
  {$IFDEF MSWINDOWS}
  ConCurrentTextAttrs := (ConCurrentTextAttrs and $0F) or Word((Color shl 4) and $F0);
  SetConsoleTextAttribute(ConStdOut, ConCurrentTextAttrs);
  {$ELSE}
  if ConCanUseAEC then Write(CSI, Color, 'm');
  {$ENDIF}
end;

procedure ConSetColors(const TextColor, BgColor: Byte);
begin
  {$IFDEF MSWINDOWS}
  if not ConOK then Exit;
  ConCurrentTextAttrs := (ConCurrentTextAttrs and $F0) or (TextColor and $0F);
  ConCurrentTextAttrs := (ConCurrentTextAttrs and $0F) or Word((BgColor shl 4) and $F0);
  SetConsoleTextAttribute(ConStdOut, ConCurrentTextAttrs);
  {$ELSE}
  if ConCanUseAEC then Write(CSI, 0, ';', TextColor, ';', BgColor, 'm');
  {$ENDIF}
end;

procedure ConSetRgbTextColor(const R, G, B: Byte);
begin
  if not ConCanUseAEC then Exit;
  {$IFDEF MSWINDOWS}
  if not ConOK then Exit;
  if not ConVirtualTerminalProcessingEnabled then
    if not ConSetVirtualTerminalProcessing(True) then Exit;
  {$ENDIF}
  Write(CSI, '38;2;', R, ';', G, ';', B, 'm');
end;

procedure ConSetRgbBackgroundColor(const R, G, B: Byte);
begin
  if not ConCanUseAEC then Exit;
  {$IFDEF MSWINDOWS}
  if not ConOK then Exit;
  if not ConVirtualTerminalProcessingEnabled then
    if not ConSetVirtualTerminalProcessing(True) then Exit;
  {$ENDIF}
  Write(CSI, '48;2;', R, ';', G, ';', B, 'm');
end;

procedure ConResetColors;
begin
  {$IFDEF MSWINDOWS}
  if not ConOK then Exit;
  ConSetTextAttrs(ConOriginalTextAttrs);
  ConCurrentTextAttrs := ConOriginalTextAttrs;
  {$ELSE}
  if ConCanUseAEC then Write(AEC_RESET);
  {$ENDIF}
end;


procedure ConResetColorsAEC;
begin
  if not ConCanUseAEC then Exit;
  //if not ConOK then Exit;
  Write(AEC_RESET);
end;

procedure ConWriteAnsiEscapeCode(const Attr, TextColor, BgColor: Byte);
begin
  if not ConCanUseAEC then Exit;
  Write(CSI, Attr, ';', TextColor, ';', BgColor, 'm');
end;

procedure ConWriteColoredText(const s: string; const TextColor, BgColor: Byte);
begin
  if TextColor <> CON_COLOR_NONE then ConSetTextColor(TextColor);
  if BgColor <> CON_COLOR_NONE then ConSetBackgroundColor(BgColor);
  Write(s);
  ConResetColors;
end;

procedure ConWriteColoredText(const s: string; const cc: TConsoleColors);
begin
  ConWriteColoredText(s, cc.Text, cc.Background);
end;

procedure ConWriteColoredTextLine(const s: string; const TextColor: Byte; BgColor: Byte);
begin
  ConWriteColoredText(s, TextColor, BgColor);
  Writeln;
end;

procedure ConWriteColoredTextLine(const s: string; const cc: TConsoleColors);
begin
  ConWriteColoredTextLine(s, cc.Text, cc.Background);
end;



{$region '                  ConWriteColoredTextEx                         '}
procedure ConWriteColoredTextEx(const cce: TConsoleColorEx);
var
  TextColor, BgColor: Byte;
  xp, xlen: integer;
  s, sn, sh: string;
begin

  if cce.Text = '' then Exit;

  if cce.IsError then
  begin
    TextColor := cce.ErrorColors.Text;
    BgColor := cce.ErrorColors.Background;
  end
  else
  begin
    TextColor := cce.NormalColors.Text;
    BgColor := cce.NormalColors.Background;
  end;

  s := cce.Text;
  sh := cce.HighlightedText;
  xlen := Length(sh);
  xp := PosCS(sh, s, cce.CaseSensitive);

  if (xlen = 0) or (xp = 0) then ConWriteColoredText(s, TextColor, BgColor)
  else
    while True do
    begin
      xp := PosCS(sh, s, cce.CaseSensitive);

      if xp > 0 then
      begin

        sn := Copy(s, 1, xp - 1);

        if sn <> '' then
        begin
          if TextColor <> CON_COLOR_NONE then ConSetTextColor(TextColor);
          if BgColor <> CON_COLOR_NONE then ConSetBackgroundColor(BgColor);
          Write(sn);
          ConResetColors;
        end;

        if cce.HighlightedColors.Text <> CON_COLOR_NONE then ConSetTextColor(cce.HighlightedColors.Text);
        if cce.HighlightedColors.Background <> CON_COLOR_NONE then ConSetBackgroundColor(cce.HighlightedColors.Background);
        if not cce.CaseSensitive then Write( Copy(s, xp, xlen) ) else Write(sh);
        ConResetColors;

        s := Copy(s, xp + xlen, Length(s));
      end
      else
      begin
        if TextColor <> CON_COLOR_NONE then ConSetTextColor(TextColor);
        if BgColor <> CON_COLOR_NONE then ConSetBackgroundColor(BgColor);
        Write(s);
        Break;
      end;

    end; // while

  ConResetColors;

end;

procedure ConWriteColoredTextLineEx(const cce: TConsoleColorEx);
begin
  ConWriteColoredTextEx(cce);
  Writeln;
end;
{$endregion ConWriteColoredTextEx}

{$region '                  ConGetColorsFromStr                           '}
procedure ConGetColorsFromStr(const sColors: string; out TextColor, BgColor: Byte);
var
  x: integer;
  sTextColor, sBgColor: string;
begin
  TextColor := CON_COLOR_NONE;
  BgColor := CON_COLOR_NONE;

  x := Pos(',', sColors);
  if x > 0 then
  begin
    sTextColor := Copy(sColors, 1, x - 1);
    sBgColor := Copy(sColors, x + 1, Length(sColors));
  end
  else
  begin
    sTextColor := sColors;
    sBgColor := '';
  end;

  sTextColor := RemoveAll(sTextColor, ' BG');
  sTextColor := RemoveAll(sTextColor, ' FG');
  sTextColor := RemoveChars(sTextColor, ['_', ' ', '-']);

  sBgColor := RemoveAll(sBgColor, ' BG');
  sBgColor := RemoveAll(sBgColor, ' FG');
  sBgColor := RemoveChars(sBgColor, ['_', ' ', '-']);

  sTextColor := TrimUp(sTextColor);
  sBgColor := TrimUp(sBgColor);


  if sTextColor <> '' then
    if (sTextColor = 'RED') or (sTextColor = 'LIGHTRED') then TextColor := TConsole.clLightRedText
    else if (sTextColor = 'DARKRED') then TextColor := TConsole.clDarkRedText

    else if (sTextColor = 'GREEN') or (sTextColor = 'LIGHTGREEN') then TextColor := TConsole.clLightGreenText
    else if (sTextColor = 'DARKGREEN') then TextColor := TConsole.clDarkGreenText

    else if (sTextColor = 'BLUE') or (sTextColor = 'LIGHTBLUE') then TextColor := TConsole.clLightBlueText
    else if (sTextColor = 'DARKBLUE') then TextColor := TConsole.clDarkBlueText

    else if (sTextColor = 'BLACK') or (sTextColor = 'DARKBLACK') then TextColor := TConsole.clBlackText
    else if (sTextColor = 'WHITE') or (sTextColor = 'LIGHTWHITE') then TextColor := TConsole.clWhiteText

    else if (sTextColor = 'GRAY') or (sTextColor = 'LIGHTGRAY') or (sTextColor = 'DARKWHITE') then TextColor := TConsole.clDarkWhiteText
    else if (sTextColor = 'DARKGRAY') or (sTextColor = 'LIGHTBLACK') then TextColor := TConsole.clLightBlackText

    else if (sTextColor = 'CYAN') or (sTextColor = 'LIGHTCYAN') then TextColor := TConsole.clLightCyanText
    else if (sTextColor = 'DARKCYAN') then TextColor := TConsole.clDarkCyanText

    else if (sTextColor = 'MAGENTA') or (sTextColor = 'LIGHTMAGENTA') then TextColor := TConsole.clLightMagentaText
    else if (sTextColor = 'DARKMAGENTA') then TextColor := TConsole.clDarkMagentaText

    else if (sTextColor = 'YELLOW') or (sTextColor = 'LIGHTYELLOW') then TextColor := TConsole.clLightYellowText
    else if (sTextColor = 'DARKYELLOW') then TextColor := TConsole.clDarkYellowText
    ;

  if sBgColor <> '' then
    if (sBgColor = 'RED') or (sBgColor = 'LIGHTRED') then BgColor := TConsole.clLightRedBg
    else if (sBgColor = 'DARKRED') then BgColor := TConsole.clDarkRedBg

    else if (sBgColor = 'GREEN') or (sBgColor = 'LIGHTGREEN') then BgColor := TConsole.clLightGreenBg
    else if (sBgColor = 'DARKGREEN') then BgColor := TConsole.clDarkGreenBg

    else if (sBgColor = 'BLUE') or (sBgColor = 'LIGHTBLUE') then BgColor := TConsole.clLightBlueBg
    else if (sBgColor = 'DARKBLUE') then BgColor := TConsole.clDarkBlueBg

    else if (sBgColor = 'BLACK') or (sBgColor = 'DARKBLACK') then BgColor := TConsole.clBlackBg
    else if (sBgColor = 'WHITE') or (sBgColor = 'LIGHTWHITE') then BgColor := TConsole.clWhiteBg

    else if (sBgColor = 'GRAY') or (sBgColor = 'LIGHTGRAY') or (sBgColor = 'DARKWHITE') then BgColor := TConsole.clDarkWhiteBg
    else if (sBgColor = 'DARKGRAY') or (sBgColor = 'LIGHTBLACK') then BgColor := TConsole.clLightBlackBg

    else if (sBgColor = 'CYAN') or (sBgColor = 'LIGHTCYAN') then BgColor := TConsole.clLightCyanBg
    else if (sBgColor = 'DARKCYAN') then BgColor := TConsole.clDarkCyanBg

    else if (sBgColor = 'MAGENTA') or (sBgColor = 'LIGHTMAGENTA') then BgColor := TConsole.clLightMagentaBg
    else if (sBgColor = 'DARKMAGENTA') then BgColor := TConsole.clDarkMagentaBg

    else if (sBgColor = 'YELLOW') or (sBgColor = 'LIGHTYELLOW') then BgColor := TConsole.clLightYellowBg
    else if (sBgColor = 'DARKYELLOW') then BgColor := TConsole.clDarkYellowBg
    ;

end;
{$endregion ConGetColorsFromStr}

{$region '                  ConColorToStr                                 '}
function ConColorToStr(const Color: Byte; AddFgBgSuffix: Boolean = False): string;
{$IFDEF UNIX}
var
  s_FG, s_BG: string;
begin
  s_FG := '';
  s_BG := '';
  if AddFgBgSuffix then
  begin
    s_FG := ' - FG';
    s_BG := ' - BG';
  end;
{$ELSE}
begin
{$ENDIF}
  {$IFDEF MSWINDOWS}
  case Color of
    // background colors = foreground (text) colors
    TConsole.clDarkRedText: Result := 'Dark Red';
    TConsole.clLightRedText: Result := 'Light Red';

    TConsole.clDarkGreenText: Result := 'Dark Green';
    TConsole.clLightGreenText: Result := 'Light Green';

    TConsole.clDarkBlueText: Result := 'Dark Blue';
    TConsole.clLightBlueText: Result := 'Light Blue';

    TConsole.clBlackText: Result := 'Black';
    TConsole.clLightBlackText: Result := 'Light Black (Dark Gray)';

    TConsole.clDarkWhiteText: Result := 'Dark White (Light Gray)';
    TConsole.clWhiteText: Result := 'White';

    TConsole.clDarkCyanText: Result := 'Dark Cyan';
    TConsole.clLightCyanText: Result := 'Light Cyan';

    TConsole.clDarkMagentaText: Result := 'Dark Magenta';
    TConsole.clLightMagentaText: Result := 'Light Magenta';

    TConsole.clDarkYellowText: Result := 'Dark Yellow';
    TConsole.clLightYellowText: Result := 'Light Yellow';
  else
    Result := 'UNKNOWN color';
  end;
  {$ELSE}
  case Color of
    TConsole.clDarkRedText: Result := 'Dark Red' + s_FG;
    TConsole.clLightRedText: Result := 'Light Red' + s_FG;
    TConsole.clDarkRedBg: Result := 'Dark Red' + s_BG;
    TConsole.clLightRedBg: Result := 'Light Red' + s_BG;

    TConsole.clDarkGreenText: Result := 'Dark Green' + s_FG;
    TConsole.clLightGreenText: Result := 'Light Green' + S_FG;
    TConsole.clDarkGreenBg: Result := 'Dark Green' + s_BG;
    TConsole.clLightGreenBg: Result := 'Light Green' + s_BG;

    TConsole.clDarkBlueText: Result := 'Dark Blue' + s_FG;
    TConsole.clLightBlueText: Result := 'Light Blue' + s_FG;
    TConsole.clDarkBlueBg: Result := 'Dark Blue' + s_BG;
    TConsole.clLightBlueBg: Result := 'Light Blue' + s_BG;

    TConsole.clDarkBlackText: Result := 'Black' + s_FG;
    TConsole.clLightBlackText: Result := 'Light Black' + s_FG;
    TConsole.clBlackBg: Result := 'Black' + s_BG;
    TConsole.clLightBlackBg: Result := 'Light Black' + s_BG;

    TConsole.clDarkWhiteText: Result := 'Dark White' + s_FG;
    TConsole.clWhiteText: Result := 'White' + s_FG;
    TConsole.clDarkWhiteBg: Result := 'Dark White' + s_BG;
    TConsole.clWhiteBg: Result := 'White' + s_BG;

    TConsole.clDarkCyanText: Result := 'Dark Cyan' + S_FG;
    TConsole.clLightCyanText: Result := 'Light Cyan' + s_FG;
    TConsole.clDarkCyanBg: Result := 'Dark Cyan' + s_BG;
    TConsole.clLightCyanBg: Result := 'Light Cyan' + s_BG;

    TConsole.clDarkMagentaText: Result := 'Dark Magenta' + s_FG;
    TConsole.clLightMagentaText: Result := 'Light Magenta' + s_FG;
    TConsole.clDarkMagentaBg: Result := 'Dark Magenta' + s_BG;
    TConsole.clLightMagentaBg: Result := 'Light Magenta' + s_BG;

    TConsole.clDarkYellowText: Result := 'Dark Yellow' + s_FG;
    TConsole.clLightYellowText: Result := 'Light Yellow' + s_FG;
    TConsole.clDarkYellowBg: Result := 'Dark Yellow' + s_BG;
    TConsole.clLightYellowBg: Result := 'Light Yellow' + s_BG;
  else
    Result := 'UNKNOWN color';
  end;
  {$ENDIF}
end;
{$endregion ConColorToStr}

{$region '                  ConWriteTaggedText & Line                     '}
procedure ConWriteTaggedText(s: string);
var
  x, xpe: integer;
  sColor, sn, sInTag: string;
  TextColor, BgColor: Byte;
begin

  x := Pos('<color=', s);
  if x <= 0 then
  begin
    Write(s);
    Exit;
  end;

  while x > 0 do
  begin

    x := Pos('<color=', s);

    if x = 0 then
    begin
      Write(s);
      Break;
    end;

    sn := Copy(s, 1, x - 1);
    if sn <> '' then Write(sn);

    s := Copy(s, x + Length('<color='), Length(s));

    xpe := Pos('>', s);

    if xpe > 0 then
    begin
      sColor := Copy(s, 1, xpe - 1);
      ConGetColorsFromStr(sColor, TextColor, BgColor);
      s := Copy(s, xpe + 1, Length(s));

      xpe := Pos('</color>', s);

      if xpe > 0 then
      begin
        sInTag := Copy(s, 1, xpe - 1);
        if TextColor <> CON_COLOR_NONE then ConSetTextColor(TextColor);
        if BgColor <> CON_COLOR_NONE then ConSetBackgroundColor(BgColor);
        Write(sInTag);
        ConResetColors;

        s := Copy(s, xpe + Length('</color>'), Length(s));
      end;
    end

    else

    begin
      Write(s);
      Break; // niedomknięty znacznik
    end;

  end; // while

  ConResetColors;

end;

procedure ConWriteTaggedTextLine(s: string);
begin
  ConWriteTaggedText(s);
  Writeln;
end;
{$endregion ConWriteTaggedText & Line}

{$region '                  ConTestStandardColors                         '}
procedure ConTestStandardColors;
var
  cc: TConsoleColors;
  i, xpad: integer;
  s: string;
  {$IFDEF MSWINDOWS}
  bAttr: WORD;
  {$ENDIF}
begin
  xpad := 36;

  {$IFDEF MSWINDOWS}
  if not ConOK then Exit;
  bAttr := ConGetCurrentTextAttr;
  try
    ConResetColors;
    Writeln('------------------------- FOREGROUND COLORS -------------------------');

    for i := 0 to 7 do
    begin
      cc.Text := Byte(i);
      cc.Background := TConsole.clWhiteBg;
      s := PadRight('[' + IntToStr(cc.Text) + '] ' + ConColorToStr(cc.Text), xpad);
      ConWriteColoredText(s, cc);

      cc.Background := TConsole.clNone;
      cc.Text := cc.Text + 8;
      s := PadRight('[' + IntToStr(cc.Text) + '] ' + ConColorToStr(cc.Text), xpad);
      ConWriteColoredText(s, cc);

      Writeln;
    end;

    Writeln('------------------------- BACKGROUND COLORS -------------------------');

    for i := 0 to 7 do
    begin
      cc.Background := Byte(i);
      cc.Text := cc.Background + 8;
      s := PadRight('[' + IntToStr(cc.Background) + '] ' + ConColorToStr(cc.Background), xpad);
      ConWriteColoredText(s, cc);

      cc.Text := cc.Background;
      cc.Background := cc.Background + 8;
      s := PadRight('[' + IntToStr(cc.Background) + '] ' + ConColorToStr(cc.Background), xpad);
      ConWriteColoredText(s, cc);

      Writeln;
    end;

  finally
    ConSetTextAttrs(bAttr);
  end;

  {$ELSE}

  ConResetColors;

  Writeln('------------------------- FOREGROUND COLORS -------------------------');
  for i := 30 to 37 do
  begin

    cc.Text := Byte(i);
    cc.Background := TConsole.clWhiteBg;
    s := PadRight(' [' + IntToStr(cc.Text) + '] ' + ConColorToStr(cc.Text, True), xpad, ' ');
    ConWriteColoredText(s, cc);

    cc.Text := i + 60;
    if cc.Text = TConsole.clLightBlackText then cc.Background := TConsole.clBlackBg
    else cc.Background := TConsole.clNone;
    s := PadRight(' [' + IntToStr(cc.Text) + '] ' + ConColorToStr(cc.Text, True), xpad, ' ');
    ConWriteColoredText(s, cc);

    Writeln;
  end;


  ConResetColors;


  Writeln('------------------------- BACKGROUND COLORS -------------------------');
  for i := 40 to 47 do
  begin

    cc.Background := Byte(i);
    cc.Text := cc.Background + 50;
    s := PadRight(' [' + IntToStr(cc.Background) + '] ' + ConColorToStr(cc.Background, True), xpad, ' ');
    ConWriteColoredText(s, cc);

    cc.Background := i + 60;
    cc.Text := cc.Background - 70;
    s := PadRight(' [' + IntToStr(cc.Background) + '] ' + ConColorToStr(cc.Background, True), xpad, ' ');
    ConWriteColoredText(s, cc);

    Writeln;
  end;

  ConResetColors;
  {$ENDIF}
end;
{$endregion ConTestStandardColors}

{$region '                  ConTestRgbColors                              '}
procedure ConTestRgbColors;
var
  i: integer;
  s: string;
begin
  //if not ConCanUseAEC then Exit;

  // This procedure can be used to check if the console/terminal supports the ANSI Escape Codes.

  Writeln('Black & White    RGB(x, x, x)');
  Writeln('x = ');
  for i := 0 to 255 do
  begin
    s := Pad(IntToStr(i), 4, ' ');
    ConSetRgbBackgroundColor(i, i, i);
    ConSetRgbTextColor(255 - i, 255 - i, 255 - i);
    Write(s);
    if (i + 1) mod 32 = 0 then
    begin
      ConResetColorsAEC;
      Writeln;
    end;
  end;

  Writeln;
  Writeln('Red    RGB(x, 0, 0)');
  Writeln('x = ');
  for i := 0 to 255 do
  begin
    s := Pad(IntToStr(i), 4, ' ');
    ConSetRgbBackgroundColor(i, 0, 0);
    ConSetRgbTextColor(255 - i, 0, 0);
    Write(s);
    if (i + 1) mod 32 = 0 then
    begin
      ConResetColorsAEC;
      Writeln;
    end;
  end;

  Writeln;
  Writeln('Green    RGB(0, x, 0)');
  Writeln('x = ');
  for i := 0 to 255 do
  begin
    s := Pad(IntToStr(i), 4, ' ');
    ConSetRgbBackgroundColor(0, i, 0);
    ConSetRgbTextColor(0, 255 - i, 0);
    Write(s);
    if (i + 1) mod 32 = 0 then
    begin
      ConResetColorsAEC;
      Writeln;
    end;
  end;

  Writeln;
  Writeln('Blue    RGB(0, 0, x)');
  Writeln('x = ');
  for i := 0 to 255 do
  begin
    s := Pad(IntToStr(i), 4, ' ');
    ConSetRgbBackgroundColor(0, 0, i);
    ConSetRgbTextColor(0, 0, 255 - i);
    Write(s);
    if (i + 1) mod 32 = 0 then
    begin
      ConResetColorsAEC;
      Writeln;
    end;
  end;

  Writeln;
  Writeln('Cyan    RGB(0, x, x)');
  Writeln('x = ');
  for i := 0 to 255 do
  begin
    s := Pad(IntToStr(i), 4, ' ');
    ConSetRgbBackgroundColor(0, i, i);
    ConSetRgbTextColor(0, 255 - i, 255 - i);
    Write(s);
    if (i + 1) mod 32 = 0 then
    begin
      ConResetColorsAEC;
      Writeln;
    end;
  end;

  Writeln;
  Writeln('Magenta    RGB(x, 0, x)');
  Writeln('x = ');
  for i := 0 to 255 do
  begin
    s := Pad(IntToStr(i), 4, ' ');
    ConSetRgbBackgroundColor(i, 0, i);
    ConSetRgbTextColor(255 - i, 0, 255 - i);
    Write(s);
    if (i + 1) mod 32 = 0 then
    begin
      ConResetColorsAEC;
      Writeln;
    end;
  end;

  Writeln;
  Writeln('Yellow    RGB(x, x, 0)');
  Writeln('x = ');
  for i := 0 to 255 do
  begin
    s := Pad(IntToStr(i), 4, ' ');
    ConSetRgbBackgroundColor(i, i, 0);
    ConSetRgbTextColor(255 - i, 255 - i, 0);
    Write(s);
    if (i + 1) mod 32 = 0 then
    begin
      ConResetColorsAEC;
      Writeln;
    end;
  end;

  ConResetColorsAEC;
end;
{$endregion ConTestRgbColors}



{$region ' ---------------------------------- TConsole --------------------------------------- '}

{$IFDEF MSWINDOWS}
class procedure TConsole.SetOutputCodePage(AValue: UINT);
begin
  if FOutputCodePage = AValue then Exit;
  SetConsoleOutputCP(AValue);
  FOutputCodePage := GetConsoleOutputCP;
end;

class function TConsole.GetOutputCodePage: Cardinal; {$IFDEF FPC}static;{$ENDIF}
begin
  Result := GetConsoleOutputCP;
end;

class function TConsole.RestoreOriginalOutputCodePage: Boolean;
begin
  if GetConsoleOutputCP = FOriginalOutputCodePage then Exit(True);
  if not SetConsoleOutputCP(FOriginalOutputCodePage) then Exit(False);
  Result := GetConsoleOutputCP = FOriginalOutputCodePage;
end;
{$ENDIF}

class procedure TConsole.SetTextCodePage(AValue: Cardinal); {$IFDEF FPC}static;{$ENDIF}
begin
  System.SetTextCodePage(Output, AValue);
end;

class function TConsole.GetTextCodePage: Cardinal;
begin
  Result := System.GetTextCodePage(Output);
end;


class procedure TConsole.ResetColors;
begin
  ConResetColors;
end;

class procedure TConsole.ResetColorsAEC;
begin
  ConResetColorsAEC
end;

class procedure TConsole.SetTextColor(const Color: Byte);
begin
  ConSetTextColor(Color);
end;

class procedure TConsole.SetBackgroundColor(const Color: Byte);
begin
  ConSetBackgroundColor(Color);
end;

class procedure TConsole.SetColors(const TextColor, BgColor: Byte);
begin
  ConSetColors(TextColor, BgColor);
end;

class procedure TConsole.SetRgbTextColor(const R, G, B: Byte);
begin
  ConSetRgbTextColor(R, G, B);
end;

class procedure TConsole.SetRgbBackgroundColor(const R, G, B: Byte);
begin
  ConSetRgbBackgroundColor(R, G, B);
end;

class procedure TConsole.WriteColoredText(const s: string; const TextColor, BgColor: Byte);
begin
  ConWriteColoredText(s, TextColor, BgColor);
end;

class procedure TConsole.WriteColoredText(const s: string; const cc: TConsoleColors);
begin
  ConWriteColoredText(s, cc);
end;

class procedure TConsole.WriteColoredTextLine(const s: string; const TextColor: Byte; BgColor: Byte);
begin
  ConWriteColoredTextLine(s, TextColor, BgColor);
end;

class procedure TConsole.WriteColoredTextLine(const s: string; const cc: TConsoleColors);
begin
  ConWriteColoredTextLine(s, cc);
end;

class procedure TConsole.WriteColoredTextEx(const cce: TConsoleColorEx);
begin
  ConWriteColoredTextEx(cce);
end;

class procedure TConsole.WriteColoredTextLineEx(const cce: TConsoleColorEx);
begin
  ConWriteColoredTextLineEx(cce);
end;

class procedure TConsole.WriteTaggedText(s: string);
begin
  ConWriteTaggedText(s);
end;

class procedure TConsole.WriteTaggedTextLine(s: string);
begin
  ConWriteTaggedTextLine(s);
end;

class procedure TConsole.Init;
begin
  {$IFDEF MSWINDOWS}
  FOriginalOutputCodePage := GetConsoleOutputCP;
  {$ENDIF}
end;

{$endregion TConsole}


procedure TConsoleColorEx.Clear;
begin
  Text := '';
  NormalColors.Text := CON_COLOR_NONE;
  NormalColors.Background := CON_COLOR_NONE;
  ErrorColors.Text := CON_COLOR_NONE;
  ErrorColors.Background := CON_COLOR_NONE;
  IsError := False;
  HighlightedColors.Text := CON_COLOR_NONE;
  HighlightedColors.Background := CON_COLOR_NONE;
  HighlightedText := '';
  CaseSensitive := True;
end;


{$IFDEF MSWINDOWS}
function OutputIsCharacterDevice: Boolean;
begin
  if not ConOK then Exit(True);

  // GetFileType - min. OS: Windows XP | Windows Server 2003
  Result := GetFileType(ConStdOut) = FILE_TYPE_CHAR;
end;
{$ELSE}
function OutputIsCharacterDevice(ResultIfStatFailed: Boolean): Boolean;
var
  st: BaseUnix.stat;
begin
  if FpFStat(Output, st) then Result := fpS_ISCHR(st.st_mode)
  else Result := ResultIfStatFailed;
end;

function OutputIsNamedPipe(ResultIfStatFailed: Boolean): Boolean;
var
  st: BaseUnix.stat;
begin
  if FpFStat(Output, st) then Result := fpS_ISFIFO(st.st_mode)
  else Result := ResultIfStatFailed;
end;

function OutputIsRegularFile(ResultIfStatFailed: Boolean): Boolean;
var
  st: BaseUnix.stat;
begin
  if FpFStat(Output, st) then Result := fpS_ISREG(st.st_mode)
  else Result := ResultIfStatFailed;
end;
{$ENDIF}


{$IFDEF MSWINDOWS}
function ConOK: Boolean;
begin
  Result := ConInitialized;
end;
{$ENDIF}


procedure ConInit;
{$IFDEF MSWINDOWS}
var
  csbi: TConsoleScreenBufferInfo;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  ConInitialized := False;

  ConStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if ConStdOut = INVALID_HANDLE_VALUE then Exit;

  FillChar(csbi, SizeOf(csbi), 0);
  if not GetConsoleScreenBufferInfo(ConStdOut, csbi) then Exit;

  ConInitialized := True;
  ConOriginalTextAttrs := csbi.wAttributes;
  ConCurrentTextAttrs := ConOriginalTextAttrs;
  {$ENDIF}

  ConOutputIsCharacterDevice := OutputIsCharacterDevice;
end;




initialization

  ConInit;
  TConsole.Init;

end.
