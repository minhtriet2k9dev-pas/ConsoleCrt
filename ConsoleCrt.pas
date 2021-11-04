unit ConsoleCrt;

(*

This unit only work with:
  +Os      : Windows
  +Compiler: Delphi

Language that written in: Delphi (RAD studio)
  +Version: SYdney 10.4

Hope you enjoy <3

*)

interface

uses
  System.SysUtils,
  WinAPI.Windows;

//This is constant color code
const
  MedGray=0;
  LightRed=1;
  LightGreen=2;
  LightBlue=3;
  Yellow=4;
  Purple=5;
  Aqua=6;
  Gray=7;
  Green=8;
  Blue=9;
  Red=10;
  DarkYellow=11;
  DarkPurple=12;
  DarkAqua=13;
  White=14;
  Default=15;
  Black=16;

procedure WaitAnyKeyPressed(const TextMessage: string = ''); overload; inline;
procedure WaitAnyKeyPressed(TimeDelay: Cardinal; const TextMessage: string = ''); overload; inline;
procedure WaitForKeyPressed(KeyCode: Word; const TextMessage: string = ''); overload; inline;
procedure WaitForKeyPressed(KeyCode: Word; TimeDelay: Cardinal; const TextMessage: string = ''); overload;
procedure TextCl(Code:Byte);
procedure TextBk(Code:Byte);
procedure GotoXY(x,y: Integer);
function WhereY: Integer;
function WhereX: Integer;
function MaxTermiSize:TCoord;
procedure Cls(OptionalCharFill:Char=' ');
function TermiSize:_COORD;
procedure ResetCl;

implementation

type
  TTimer = record
    Started: TLargeInteger;
    Frequency: Cardinal;
  end;

var
  IsElapsed: function(const Timer: TTimer; Interval: Cardinal): Boolean;
  StartTimer: procedure(var Timer: TTimer);
  Buffer: _Console_Screen_Buffer_Info;
  hStdOut:THandle;
  ConOut: THandle;
  BufInfo: TConsoleScreenBufferInfo;

procedure ResetCl;
begin
  TextCl(Default);
end;

procedure TextCl(Code:Byte);
begin
  case Code of
    0: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE);
    1: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_INTENSITY);
    2: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    3: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    4: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY);
    5: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    6: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    7: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_INTENSITY);
    8: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_GREEN);
    9: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_BLUE);
    10: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED);
    11: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_RED);
    12: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_BLUE or FOREGROUND_RED);
    13: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_BLUE);
    14: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    15: SetConsoleTextAttribute(ConOut, BufInfo.wAttributes);
    16:
      begin
        { this is optional so u cant uncomment this }
        //raise Exception.Create('COLOR CODE FOR BLACK CANNOT APPLIED HERE [0..15], ALL THE COLOR WILL AUTO RESET TO DEFAULT');
        ResetCl;
      end
    else
      begin
        { this is optional so u cant uncomment this }
        //raise Exception.Create('COLOR CODE OVER THE RANGE [0..15], ALL THE COLOR WILL AUTO RESET TO DEFAULT');
        ResetCl;
      end;
  end;
end;

procedure TextBk(Code:Byte);
begin
  case Code of
    0: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE);
    1: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_RED or BACKGROUND_INTENSITY);
    2: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_GREEN or BACKGROUND_INTENSITY);
    3: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_BLUE or BACKGROUND_INTENSITY);
    4: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_GREEN or BACKGROUND_RED or BACKGROUND_INTENSITY);
    5: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_RED or BACKGROUND_BLUE or BACKGROUND_INTENSITY);
    6: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_GREEN or BACKGROUND_BLUE or BACKGROUND_INTENSITY);
    7: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), BACKGROUND_INTENSITY);
    8: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), BACKGROUND_GREEN);
    9: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), BACKGROUND_BLUE);
    10: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), BACKGROUND_RED);
    11: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_GREEN or BACKGROUND_RED);
    12: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_BLUE or BACKGROUND_RED);
    13: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),BACKGROUND_GREEN or BACKGROUND_BLUE);
    14: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    15: SetConsoleTextAttribute(ConOut, BufInfo.wAttributes);
    16: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),0);
    else
      begin
        { this is optional so u cant uncomment this }
        //raise Exception.Create('COLOR CODE OVER THE RANGE [0..15], ALL THE COLOR WILL AUTO RESET TO DEFAULT  ');
        ResetCl;
      end;
  end;
end;

function MaxTermiSize:TCoord;
var
  Con: THandle;
begin
  Con := GetStdHandle(STD_OUTPUT_HANDLE);
  Exit(GetLargestConsoleWindowSize(Con));
end;

function WhereX: Integer;
begin
  hStdOut:= GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleScreenBufferInfo(hStdOut,Buffer);
  //
  Result:=Buffer.dwCursorPosition.X;
end;

function WhereY: Integer;
begin
  hStdOut:= GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleScreenBufferInfo(hStdOut,Buffer);
  //
  Result:=Buffer.dwCursorPosition.Y;
end;

procedure GotoXY(x,y: Integer);
var
  CursorCoord: _COORD;
begin
  CursorCoord.x := x;
  CursorCoord.y := y;
  hStdOut:= GetStdHandle(STD_OUTPUT_HANDLE);

  SetConsoleCursorPosition(hStdOut, CursorCoord);
end;

procedure WaitAnyKeyPressed(const TextMessage: string);
begin
  WaitForKeyPressed(0, 0, TextMessage)
end;

procedure WaitAnyKeyPressed(TimeDelay: Cardinal; const TextMessage: string);
begin
  WaitForKeyPressed(0, TimeDelay, TextMessage)
end;

procedure WaitForKeyPressed(KeyCode: Word; const TextMessage: string);
begin
  WaitForKeyPressed(KeyCode, 0, TextMessage)
end;

function TermiSize:_COORD;
var
  csbi: TConsoleScreenBufferInfo;
  StdOut:THandle;
begin
  stdout := GetStdHandle(STD_OUTPUT_HANDLE);
  Win32Check(GetConsoleScreenBufferInfo(stdout, csbi));
  Exit(csbi.dwSize);
end;

procedure WaitForKeyPressed(KeyCode: Word; TimeDelay: Cardinal; const TextMessage: string);
var
  Handle: THandle;
  Buffer: TInputRecord;
  Counter: Cardinal;
  Timer: TTimer;
begin
  Handle := GetStdHandle(STD_INPUT_HANDLE);
  if Handle = 0 then
    RaiseLastOSError;
  if not (TextMessage = '') then
    Write(TextMessage);
  if not (TimeDelay = 0) then
    StartTimer(Timer);
  while True do
    begin
      Sleep(0);
      if not GetNumberOfConsoleInputEvents(Handle, Counter) then
        RaiseLastOSError;
      if not (Counter = 0) then
        begin
          if not ReadConsoleInput(Handle, Buffer, 1, Counter) then
            RaiseLastOSError;
          if (Buffer.EventType = KEY_EVENT) and Buffer.Event.KeyEvent.bKeyDown then
            if (KeyCode = 0) or (KeyCode = Buffer.Event.KeyEvent.wVirtualKeyCode) then
              Break
        end;
      if not (TimeDelay = 0) and IsElapsed(Timer, TimeDelay) then
        Break
    end
end;

function HardwareIsElapsed(const Timer: TTimer; Interval: Cardinal): Boolean;
var
  Passed: TLargeInteger;
begin
  QueryPerformanceCounter(Passed);
  Result := (Passed - Timer.Started) div Timer.Frequency > Interval
end;

procedure HardwareStartTimer(var Timer: TTimer);
var
  Frequency: TLargeInteger;
begin
  QueryPerformanceCounter(Timer.Started);
  QueryPerformanceFrequency(Frequency);
  Timer.Frequency := Frequency div 1000
end;

function SoftwareIsElapsed(const Timer: TTimer; Interval: Cardinal): Boolean;
begin
  Result := (GetCurrentTime - Cardinal(Timer.Started)) > Interval
end;

procedure SoftwareStartTimer(var Timer: TTimer);
begin
  PCardinal(@Timer.Started)^ := GetCurrentTime
end;

procedure Cls(OptionalCharFill:Char=' ');
var
  stdout: THandle;
  csbi: TConsoleScreenBufferInfo;
  ConsoleSize: DWORD;
  NumWritten: DWORD;
  Origin: TCoord;
begin
  stdout := GetStdHandle(STD_OUTPUT_HANDLE);
  Win32Check(stdout<>INVALID_HANDLE_VALUE);
  Win32Check(GetConsoleScreenBufferInfo(stdout, csbi));
  ConsoleSize := csbi.dwSize.X * csbi.dwSize.Y;
  Origin.X := 0;
  Origin.Y := 0;
  Win32Check(FillConsoleOutputCharacter(stdout, OptionalCharFill, ConsoleSize, Origin,
    NumWritten));
  Win32Check(FillConsoleOutputAttribute(stdout, csbi.wAttributes, ConsoleSize, Origin,
    NumWritten));
  Win32Check(SetConsoleCursorPosition(stdout, Origin));
end;

initialization

  if QueryPerformanceCounter(PLargeInteger(@@IsElapsed)^) and QueryPerformanceFrequency(PLargeInteger(@@IsElapsed)^) then
  begin
    StartTimer := HardwareStartTimer;
    IsElapsed := HardwareIsElapsed
  end else
  begin
    StartTimer := SoftwareStartTimer;
    IsElapsed := SoftwareIsElapsed
  end;

  //begin init variables
  ConOut := TTextRec(Output).Handle;
  GetConsoleScreenBufferInfo(ConOut, BufInfo);

end.
