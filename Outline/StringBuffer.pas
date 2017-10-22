unit StringBuffer;

interface

uses
{$IF CompilerVersion > 22.9}
  System.SysUtils;
{$ELSE}
  SysUtils;
{$IFEND}


type
  TStringBuffer = class
  private
    { Private éŒ¾ }
    FChars: string;
    FLength: Integer;
    function Get(Index: Integer): Char;
    function GetCapacity: Integer;
    procedure Put(Index: Integer; const C: Char);
  public
    { Public éŒ¾ }
    constructor Create(Size: Integer);
    destructor Destroy; override;
    procedure Append(const S: string); overload;
    procedure Append(P: PChar; ALen: Integer); overload;
    procedure Clear;
    function GetString(Start, Len: Integer): string; overLoad;
    function GetString: string; overload;
    procedure Insert(Index: Integer; const S: string; ALen: Integer);
    procedure Remove(Index, Len: Integer);
    function ToPointer(Index: Integer): PChar;
    property Capacity: Integer read GetCapacity;
    property Chars[Index: Integer]: Char read Get write Put; default;
    property StringLength: Integer read FLength;
  end;

implementation

uses
{$IF CompilerVersion > 22.9}
  System.Math;
{$ELSE}
  Math;
{$IFEND}

{ TStringBuffer }

constructor TStringBuffer.Create(Size: Integer);
begin
  if Size < 2 then
    Size := 2;
  SetLength(FChars, Size);
  FChars[1] := #0;
  FLength := 0;
end;

destructor TStringBuffer.Destroy;
begin
  SetLength(FChars, 0);
  inherited;
end;

procedure TStringBuffer.Append(const S: string);
var
  I: Integer;
  Len: Integer;
  PS, PD: NativeUInt;
begin
  Len := Length(S);
  I := Length(FChars);
  while FLength + Len + 1 > I do
    Inc(I, I);
  if I > Length(FChars) then
    SetLength(FChars, I);
  PS := NativeUInt(PChar(S));
  PD := NativeUInt(PChar(FChars)) + NativeUInt(FLength) * 2;
  Move(Pointer(PS)^, Pointer(PD)^, Len * 2);
  Inc(FLength, Len);
  FChars[FLength + 1] := #0;
end;

procedure TStringBuffer.Append(P: PChar; ALen: Integer);
var
  I: Integer;
  PS, PD: NativeUInt;
begin
  I := Length(FChars);
  while FLength + ALen + 1 > I do
    Inc(I, I);
  if I > Length(FChars) then
    SetLength(FChars, I);
  PS := NativeUInt(P);
  PD := NativeUInt(PChar(FChars)) + NativeUInt(FLength) * 2;
  Move(Pointer(PS)^, Pointer(PD)^, ALen * 2);
  Inc(FLength, ALen);
  FChars[FLength + 1] := #0;
end;

procedure TStringBuffer.Clear;
begin
  FLength := 0;
  FChars[1] := #0;
end;

function TStringBuffer.Get(Index: Integer): Char;
begin
  Result := FChars[Index + 1];
end;

function TStringBuffer.GetCapacity: Integer;
begin
  Result := Length(FChars);
end;

function TStringBuffer.GetString(Start, Len: Integer): string;
var
  PS, PD: NativeUInt;
begin
  SetLength(Result, Len);
  PS := NativeUInt(PChar(FChars)) + NativeUInt(Start) * 2;
  PD := NativeUInt(PChar(Result));
  Move(Pointer(PS)^, Pointer(PD)^, Len * 2);
end;

function TStringBuffer.GetString: string;
var
  PS, PD: NativeUInt;
begin
  SetLength(Result, FLength);
  PS := NativeUInt(PChar(FChars));
  PD := NativeUInt(PChar(Result));
  Move(Pointer(PS)^, Pointer(PD)^, (FLength) * 2);
end;

procedure TStringBuffer.Insert(Index: Integer; const S: string; ALen: Integer);
type
  StrRec = packed record
{$IF defined(CPUX64)}
    _Padding: LongInt;
{$IFEND}
    codePage: Word;
    elemSize: Word;
    refCnt: Longint;
    length: Longint;
  end;
var
  I, MaxSize: Integer;
  PS, PD: NativeUInt;
begin
  MaxSize := (MaxInt - SizeOf(StrRec)) div SizeOf(WideChar) - 1;
  if FLength + ALen > MaxSize then
    OutOfMemoryError;
  I := Length(FChars);
  while FLength + ALen + 1 > I do
    Inc(I, I);
  if I > Length(FChars) then
    SetLength(FChars, Min(I, MaxSize));
  PS := NativeUInt(PChar(FChars)) + NativeUInt(Index) * 2;
  PD := PS + NativeUInt(ALen) * 2;
  Move(Pointer(PS)^, Pointer(PD)^, (FLength - Index + 1) * 2);
  PD := PS;
  PS := NativeUInt(PChar(S));
  Move(Pointer(PS)^, Pointer(PD)^, ALen * 2);
  Inc(FLength, ALen);
end;

procedure TStringBuffer.Put(Index: Integer; const C: Char);
begin
  FChars[Index + 1] := C;
end;

procedure TStringBuffer.Remove(Index, Len: Integer);
var
  PS, PD: NativeUInt;
begin
  PD := NativeUInt(PChar(FChars)) + NativeUInt(Index) * 2;
  PS := PD + NativeUInt(Len) * 2;
  Move(Pointer(PS)^, Pointer(PD)^, (FLength - Len - Index + 1) * 2);
  Dec(FLength, Len);
end;

function TStringBuffer.ToPointer(Index: Integer): PChar;
begin
  Result := PChar(FChars) + Index;
end;

end.
