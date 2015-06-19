unit StringBuffer;

interface

type
  TStringBuffer = class
  private
    { Private êÈåæ }
    FChars: string;
    FLength: NativeInt;
    function Get(Index: NativeInt): Char;
    function GetCapacity: NativeInt;
    procedure Put(Index: NativeInt; const C: Char);
  public
    { Public êÈåæ }
    constructor Create(Size: NativeInt);
    destructor Destroy; override;
    procedure Append(const S: string); overload;
    procedure Append(P: PChar; ALen: NativeInt); overload;
    procedure Clear;
    function GetString(Start, Len: NativeInt): string; overLoad;
    function GetString: string; overload;
    procedure Insert(Index: NativeInt; const S: string; ALen: NativeInt);
    procedure Remove(Index, Len: NativeInt);
    function ToPointer(Index: NativeInt): PChar;
    property Capacity: NativeInt read GetCapacity;
    property Chars[Index: NativeInt]: Char read Get write Put; default;
    property StringLength: NativeInt read FLength;
  end;

implementation

{ TStringBuffer }

constructor TStringBuffer.Create(Size: NativeInt);
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
  I: NativeInt;
  Len: NativeInt;
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

procedure TStringBuffer.Append(P: PChar; ALen: NativeInt);
var
  I: NativeInt;
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

function TStringBuffer.Get(Index: NativeInt): Char;
begin
  Result := FChars[Index + 1];
end;

function TStringBuffer.GetCapacity: NativeInt;
begin
  Result := Length(FChars);
end;

function TStringBuffer.GetString(Start, Len: NativeInt): string;
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

procedure TStringBuffer.Insert(Index: NativeInt; const S: string; ALen: NativeInt);
var
  I: NativeInt;
  PS, PD: NativeUInt;
begin
  I := Length(FChars);
  while FLength + Alen + 1 > I do
    Inc(I, I);
  if I > Length(FChars) then
    SetLength(FChars, I);
  PS := NativeUInt(PChar(FChars)) + NativeUInt(Index) * 2;
  PD := PS + NativeUInt(Alen) * 2;
  Move(Pointer(PS)^, Pointer(PD)^, (FLength - Index + 1) * 2);
  PD := PS;
  PS := NativeUInt(PChar(S));
  Move(Pointer(PS)^, Pointer(PD)^, Alen * 2);
  Inc(FLength, Alen);
end;

procedure TStringBuffer.Put(Index: NativeInt; const C: Char);
begin
  FChars[Index + 1] := C;
end;

procedure TStringBuffer.Remove(Index, Len: NativeInt);
var
  PS, PD: NativeUInt;
begin
  PD := NativeUInt(PChar(FChars)) + NativeUInt(Index) * 2;
  PS := PD + NativeUInt(Len) * 2;
  Move(Pointer(PS)^, Pointer(PD)^, (FLength - Len - Index + 1) * 2);
  Dec(FLength, Len);
end;

function TStringBuffer.ToPointer(Index: NativeInt): PChar;
begin
  Result := PChar(FChars) + Index;
end;

end.
