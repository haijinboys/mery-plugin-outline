// -----------------------------------------------------------------------------
// アウトライン
//
// Copyright (c) Kuro. All Rights Reserved.
// e-mail: info@haijin-boys.com
// www:    http://www.haijin-boys.com/
// -----------------------------------------------------------------------------

unit mMain;

interface

uses
{$IF CompilerVersion > 22.9}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
{$ELSE}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ComCtrls, ExtCtrls,
{$IFEND}
  StringBuffer;

const
  MaxLineLength = 2000;
  MaxDepth = 8;
  WorkOutlineAll = 1;
  WorkTreeSel = 2;
  IndentSpaces = 0;
  IndentBraces = 1;
  IndentBrackets = 2;
  IndentCustom = 3;
  IndentCustomBeginEnd = 4;

type
  TMatch = array [0 .. MaxDepth - 1] of string;
  TReplace = array [0 .. MaxDepth - 1] of string;
  TRegEx = array [0 .. MaxDepth - 1] of Boolean;

  TProp = class(TPersistent)
  private
    { Private 宣言 }
    FCaption: string;
    FIndentType: NativeInt;
    FViewLevel: NativeInt;
  public
    { Public 宣言 }
    Match: array [0 .. MaxDepth - 1] of string;
    Replace: array [0 .. MaxDepth - 1] of string;
    RegEx: array [0 .. MaxDepth - 1] of Boolean;
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure Reset;
    property Caption: string read FCaption write FCaption;
    property IndentType: NativeInt read FIndentType write FIndentType;
    property ViewLevel: NativeInt read FViewLevel write FViewLevel;
  end;

  TPropItem = class(TCollectionItem)
  private
    { Private 宣言 }
    FProp: TProp;
  protected
    { Protected 宣言 }
    function GetDisplayName: string; override;
  public
    { Public 宣言 }
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    { Published 宣言 }
    property Prop: TProp read FProp write FProp;
  end;

  TPropItems = class;

  TPropItemsEnumerator = class
  private
    { Private 宣言 }
    FIndex: NativeInt;
    FCollection: TPropItems;
  public
    { Public 宣言 }
    constructor Create(ACollection: TPropItems);
    function GetCurrent: TPropItem;
    function MoveNext: Boolean;
    property Current: TPropItem read GetCurrent;
  end;

  TPropItems = class(TCollection)
  private
    { Private 宣言 }
    function GetItem(Index: NativeInt): TPropItem;
    procedure SetItem(Index: NativeInt; Value: TPropItem);
  public
    { Public 宣言 }
    constructor Create;
    function Add: TPropItem;
    function GetEnumerator: TPropItemsEnumerator;
    function IndexOf(Item: TPropItem): NativeInt;
    property Items[Index: NativeInt]: TPropItem read GetItem write SetItem; default;
  end;

  TOutlineItem = class
  private
    { Private 宣言 }
    FNode: TTreeNode;
    FLineNum: NativeInt;
    FLevel: NativeInt;
    FLineStr: string;
  public
    { Public 宣言 }
    constructor Create(ALineNum, ALevel: NativeInt; ALineStr: string);
    property Node: TTreeNode read FNode write FNode;
    property LineNum: NativeInt read FLineNum write FLineNum;
    property Level: NativeInt read FLevel write FLevel;
    property LineStr: string read FLineStr write FLineStr;
  end;

  TOutlineList = class(TList)
  private
    { Private 宣言 }
    function Get(Index: Integer): TOutlineItem; inline;
  public
    { Public 宣言 }
    destructor Destroy; override;
    procedure Clear; override;
    property Items[Index: Integer]: TOutlineItem read Get; default;
  end;

  TMainForm = class(TForm)
    PopupMenu: TPopupMenu;
    GoMenuItem: TMenuItem;
    SelectMenuItem: TMenuItem;
    N1: TMenuItem;
    CollapseAllMenuItem: TMenuItem;
    ExpandAllMenuItem: TMenuItem;
    N2: TMenuItem;
    PropPopupMenuItem: TMenuItem;
    TreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GoMenuItemClick(Sender: TObject);
    procedure SelectMenuItemClick(Sender: TObject);
    procedure CollapseAllMenuItemClick(Sender: TObject);
    procedure ExpandAllMenuItemClick(Sender: TObject);
    procedure PropPopupMenuItemClick(Sender: TObject);
    procedure TreeViewClick(Sender: TObject);
    procedure TreeViewDblClick(Sender: TObject);
    procedure TreeViewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private 宣言 }
    FEditor: THandle;
    FBarPos: NativeInt;
    FFontNameSub: string;
    FFontSizeSub: NativeInt;
    FProp: TProp;
    FStringBuffer: TStringBuffer;
    FList: TOutlineList;
    FUpdateOutline: Boolean;
    FUpdateTreeSel: Boolean;
    FWorkFlag: NativeInt;
    FWorkThread: THandle;
    FAbortThread: Boolean;
    FQueEvent: THandle;
    FMutex: THandle;
    FPoint: TPoint;
    procedure ReadIni(Prop: TProp; const Mode: string); overload;
    procedure WriteIni(Prop: TProp); overload;
    procedure EraseSection;
    function Find(ALine: PChar; AFind: PChar; ARegEx: Boolean): PChar;
    function LineMatched(ALine: PChar; ABegin: PChar; ARegExBegin: Boolean; AEnd: PChar; ARegExEnd: Boolean): NativeInt;
    function Matched(ALine, AFind: PChar; ARegEx: Boolean; AStripPrefix: Boolean; AReplace: PChar): Boolean;
    function CalcIndent(ALine: PChar; ALevel: NativeInt; var ApplyBefore: Boolean; var CustomBarLevel: NativeInt): NativeInt;
    function CalcOutlineCustom(ALine: PChar; AStripPrefix: Boolean): NativeInt;
    function GetCurrentLine: NativeInt;
    procedure UpdateTreeViewAll;
    procedure UpdateTreeViewString;
    procedure OutlineSelected(Node: TTreeNode; FocusView, Select: Boolean);
  public
    { Public 宣言 }
    procedure ReadIni; overload;
    procedure WriteIni; overload;
    procedure ResetThread;
    procedure OutlineAll;
    procedure UpdateTreeViewSel;
    procedure SetTreeColor;
    function SetProperties: Boolean;
    property BarPos: NativeInt read FBarPos write FBarPos;
    property UpdateOutline: Boolean read FUpdateOutline write FUpdateOutline;
    property UpdateTreeSel: Boolean read FUpdateTreeSel write FUpdateTreeSel;
    property Editor: THandle read FEditor write FEditor;
    property WorkHandle: THandle read FWorkThread write FWorkThread;
    property WorkFlag: NativeInt read FWorkFlag write FWorkFlag;
    property AbortThread: Boolean read FAbortThread write FAbortThread;
    property QueEvent: THandle read FQueEvent write FQueEvent;
    property Mutex: THandle read FMutex write FMutex;
  end;

var
  MainForm: TMainForm;
  FFontName: string;
  FFontSize: NativeInt;
  FPropItems: TPropItems;

implementation

uses
{$IF CompilerVersion > 22.9}
  System.Types, System.StrUtils, System.Math, System.IniFiles,
{$ELSE}
  Types, StrUtils, Math, IniFiles,
{$IFEND}
  mCommon, mPlugin, mProp;

{$R *.dfm}


function WaitMessageLoop(Count: LongWord; var Handles: THandle;
  Milliseconds: DWORD): NativeInt;
var
  Quit: Boolean;
  ExitCode: NativeInt;
  WaitResult: DWORD;
  Msg: TMsg;
begin
  Quit := False;
  ExitCode := 0;
  WaitResult := 0;
  repeat
    while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
    begin
      if Msg.message = WM_QUIT then
      begin
        Quit := True;
        ExitCode := NativeInt(Msg.wParam);
        Break;
      end
      else
        DispatchMessage(Msg);
      WaitResult := MsgWaitForMultipleObjects(Count, Handles, False, Milliseconds, QS_ALLINPUT);
    end;
  until WaitResult = WAIT_OBJECT_0;
  if Quit then
    PostQuitMessage(ExitCode);
  Result := NativeInt(WaitResult - WAIT_OBJECT_0);
end;

function TrimLine(Line: PChar): string;
var
  P: PChar;
  Len: NativeInt;
begin
  P := Line;
  while (P^ = ' ') or (P^ = #09) do
    Inc(P);
  if P <> Line then
  begin
    Len := StrLen(P);
    StrMove(Line, P, Len + 1);
  end;
  P := Line;
  while True do
  begin
    P := StrScan(P, #09);
    if P = nil then
      Break;
    P^ := ' ';
    Inc(P);
  end;
end;

{ TProp }

constructor TProp.Create;
begin
  Reset;
end;

procedure TProp.Assign(Source: TPersistent);
begin
  if Source is TProp then
    with TProp(Source) do
    begin
      Self.FCaption := Caption;
      Self.FIndentType := IndentType;
      Self.FViewLevel := ViewLevel;
      Self.Match := Match;
      Self.Replace := Replace;
      Self.RegEx := RegEx;
    end
  else
    inherited;
end;

procedure TProp.Reset;
var
  I: NativeInt;
begin
  for I := 0 to MaxDepth - 1 do
  begin
    Match[I] := StringOfChar('.', I + 1);
    Replace[I] := '';
    RegEx[I] := False;
  end;
  FIndentType := IndentSpaces;
  FViewLevel := 8;
  if SameText(FCaption, 'Bat') then
    //
  else if SameText(FCaption, 'C#') then
  begin
    IndentType := IndentBraces;
    ViewLevel := 1;
  end
  else if SameText(FCaption, 'C++') then
  begin
    IndentType := IndentBraces;
    ViewLevel := 1;
  end
  else if SameText(FCaption, 'ColdFusion') then
    //
  else if SameText(FCaption, 'CSS') then
    //
  else if SameText(FCaption, 'Delphi') then
    //
  else if SameText(FCaption, 'HSP') then
    //
  else if SameText(FCaption, 'HTML') then
    //
  else if SameText(FCaption, 'INI') then
    //
  else if SameText(FCaption, 'Java') then
  begin
    IndentType := IndentBraces;
    ViewLevel := 1;
  end
  else if SameText(FCaption, 'JavaScript') then
  begin
    IndentType := IndentBraces;
    ViewLevel := 1;
  end
  else if SameText(FCaption, 'JSP') then
    //
  else if SameText(FCaption, 'Perl') then
    //
  else if SameText(FCaption, 'PHP') then
    //
  else if SameText(FCaption, 'PowerShell') then
    //
  else if SameText(FCaption, 'Python') then
    //
  else if SameText(FCaption, 'Ruby') then
    //
  else if SameText(FCaption, 'SQL') then
    //
  else if SameText(FCaption, 'TeX') then
  begin
    IndentType := IndentCustomBeginEnd;
    Match[0] := '\begin';
    Match[1] := '\end';
  end
  else if SameText(FCaption, 'Text') then
    //
  else if SameText(FCaption, 'UWSC') then
    //
  else if SameText(FCaption, 'VBScript') then
    //
  else if SameText(FCaption, 'VisualBasic') then
    //
  else if SameText(FCaption, 'Windows Script') then
    //
  else if SameText(FCaption, 'x86 Assembler') then
    //
  else if SameText(FCaption, 'XML') then
  begin
    IndentType := IndentCustomBeginEnd;
    Match[0] := '<[^/?].*?[^/]>';
    Match[1] := '</.*?>';
    RegEx[0] := True;
    RegEx[1] := True;
  end
  else
      ;
end;

{ TPropItem }

constructor TPropItem.Create(Collection: TCollection);
begin
  inherited;
  FProp := TProp.Create;
end;

destructor TPropItem.Destroy;
begin
  FProp.Free;
  inherited;
end;

procedure TPropItem.Assign(Source: TPersistent);
begin
  if Source is TPropItem then
    with TPropItem(Source) do
    begin
      Self.FProp.Assign(Prop);
    end
  else
    inherited;
end;

function TPropItem.GetDisplayName: string;
begin
  Result := FProp.Caption;
end;

{ TPropItemsEnumerator }

constructor TPropItemsEnumerator.Create(ACollection: TPropItems);
begin
  inherited Create;
  FIndex := -1;
  FCollection := ACollection;
end;

function TPropItemsEnumerator.GetCurrent: TPropItem;
begin
  Result := FCollection[FIndex];
end;

function TPropItemsEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FCollection.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TPropItems }

function TPropItems.Add: TPropItem;
begin
  Result := TPropItem( inherited Add);
end;

constructor TPropItems.Create;
begin
  inherited Create(TPropItem);
end;

function TPropItems.GetEnumerator: TPropItemsEnumerator;
begin
  Result := TPropItemsEnumerator.Create(Self);
end;

function TPropItems.GetItem(Index: NativeInt): TPropItem;
begin
  Result := TPropItem( inherited GetItem(Index));
end;

function TPropItems.IndexOf(Item: TPropItem): NativeInt;
begin
  for Result := 0 to Count - 1 do
    if Items[Result] = Item then
      Exit;
  Result := -1;
end;

procedure TPropItems.SetItem(Index: NativeInt; Value: TPropItem);
begin
  inherited SetItem(Index, Value);
end;

{ TOutlineItem }

constructor TOutlineItem.Create(ALineNum, ALevel: NativeInt; ALineStr: string);
begin
  FNode := nil;
  FLineNum := ALineNum;
  FLevel := ALevel;
  FLineStr := ALineStr;
  if Length(FLineStr) > 0 then
    TrimLine(@FLineStr[1]);
end;

{ TOutlineList }

destructor TOutlineList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TOutlineList.Clear;
var
  I: NativeInt;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited;
end;

function TOutlineList.Get(Index: Integer): TOutlineItem;
begin
  Result := TOutlineItem( inherited Get(Index));
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  if Win32MajorVersion < 6 then
    with Font do
    begin
      Name := 'Tahoma';
      Size := 8;
    end;
  FEditor := ParentWindow;
  FFontNameSub := '';
  FFontSizeSub := 0;
  FProp := TProp.Create;
  FStringBuffer := TStringBuffer.Create(0);
  FList := TOutlineList.Create;
  FUpdateOutline := False;
  FUpdateTreeSel := False;
  FWorkFlag := 0;
  FQueEvent := CreateEvent(nil, True, False, nil);
  FMutex := CreateMutex(nil, False, nil);
  FPoint.X := -1;
  FPoint.Y := -1;
  ReadIni;
  with Font do
  begin
    ChangeScale(FFontSize, Size);
    Name := FFontName;
    Size := FFontSize;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ResetThread;
  if FQueEvent > 0 then
  begin
    CloseHandle(FQueEvent);
    FQueEvent := 0;
  end;
  if FMutex > 0 then
  begin
    CloseHandle(FMutex);
    FMutex := 0;
  end;
  WriteIni;
  if Assigned(FStringBuffer) then
    FreeAndNil(FStringBuffer);
  if Assigned(FList) then
    FreeAndNil(FList);
  if Assigned(FProp) then
    FreeAndNil(FProp);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  //
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //
end;

procedure TMainForm.GoMenuItemClick(Sender: TObject);
var
  ANode: TTreeNode;
begin
  ANode := TreeView.GetNodeAt(FPoint.X, FPoint.Y);
  if ANode = TreeView.Selected then
    OutlineSelected(TreeView.Selected, True, False);
end;

procedure TMainForm.SelectMenuItemClick(Sender: TObject);
var
  ANode: TTreeNode;
begin
  ANode := TreeView.GetNodeAt(FPoint.X, FPoint.Y);
  if ANode = TreeView.Selected then
    OutlineSelected(TreeView.Selected, True, True);
end;

procedure TMainForm.CollapseAllMenuItemClick(Sender: TObject);
begin
  if WaitMessageLoop(1, FMutex, INFINITE) <> 0 then
    Exit;
  TreeView.FullCollapse;
  ReleaseMutex(FMutex);
end;

procedure TMainForm.ExpandAllMenuItemClick(Sender: TObject);
begin
  if WaitMessageLoop(1, FMutex, INFINITE) <> 0 then
    Exit;
  TreeView.FullExpand;
  ReleaseMutex(FMutex);
end;

procedure TMainForm.PropPopupMenuItemClick(Sender: TObject);
begin
  SetProperties;
end;

procedure TMainForm.TreeViewClick(Sender: TObject);
var
  ANode: TTreeNode;
begin
  ANode := TreeView.GetNodeAt(FPoint.X, FPoint.Y);
  if ANode = TreeView.Selected then
    OutlineSelected(TreeView.Selected, False, False);
end;

procedure TMainForm.TreeViewDblClick(Sender: TObject);
var
  ANode: TTreeNode;
begin
  ANode := TreeView.GetNodeAt(FPoint.X, FPoint.Y);
  if ANode = TreeView.Selected then
    OutlineSelected(TreeView.Selected, True, False);
end;

procedure TMainForm.TreeViewKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    OutlineSelected(TreeView.Selected, True, False);
    Key := 0;
  end;
end;

procedure TMainForm.TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FPoint.X := X;
  FPoint.Y := Y;
  with TreeView do
    if (Button = mbRight) and (GetNodeAt(X, Y) <> nil) then
      Selected := GetNodeAt(X, Y);
end;

procedure TMainForm.ReadIni(Prop: TProp; const Mode: string);
var
  S: string;
  I: NativeInt;
begin
  Prop.Caption := Mode;
  if not GetIniFileName(S) then
    Exit;
  with TMemIniFile.Create(S, TEncoding.UTF8) do
    try
      with Prop do
      begin
        if SectionExists(Format('Outline\%s', [Caption])) then
        begin
          IndentType := ReadInteger(Format('Outline\%s', [Caption]), 'IndentType', IndentType);
          ViewLevel := ReadInteger(Format('Outline\%s', [Caption]), 'ViewLevel', ViewLevel);
          for I := 0 to MaxDepth - 1 do
          begin
            Match[I] := ReadString(Format('Outline\%s', [Caption]), Format('Match%d', [I]), Match[I]);
            RegEx[I] := ReadBool(Format('Outline\%s', [Caption]), Format('RegEx%d', [I]), RegEx[I]);
            Replace[I] := ReadString(Format('Outline\%s', [Caption]), Format('Replace%d', [I]), Replace[I]);
          end;
        end
        else
          Reset;
      end;
    finally
      Free;
    end;
end;

procedure TMainForm.WriteIni(Prop: TProp);
var
  S: string;
  I: NativeInt;
begin
  if not GetIniFileName(S) then
    Exit;
  with TMemIniFile.Create(S, TEncoding.UTF8) do
    try
      with Prop do
      begin
        WriteInteger(Format('Outline\%s', [Caption]), 'IndentType', IndentType);
        WriteInteger(Format('Outline\%s', [Caption]), 'ViewLevel', ViewLevel);
        for I := 0 to MaxDepth - 1 do
        begin
          WriteString(Format('Outline\%s', [Caption]), Format('Match%d', [I]), Match[I]);
          WriteBool(Format('Outline\%s', [Caption]), Format('RegEx%d', [I]), RegEx[I]);
          WriteString(Format('Outline\%s', [Caption]), Format('Replace%d', [I]), Replace[I]);
        end;
        UpdateFile;
      end;
    finally
      Free;
    end;
end;

procedure TMainForm.EraseSection;
var
  S: string;
  I: NativeInt;
  Sections: TStrings;
begin
  if FIniFailed or (not GetIniFileName(S)) then
    Exit;
  try
    with TMemIniFile.Create(S, TEncoding.UTF8) do
      try
        Sections := TStringList.Create;
        try
          ReadSections(Sections);
          for I := 0 to Sections.Count - 1 do
            if Pos('Outline\', Sections[I]) = 1 then
              EraseSection(Sections[I]);
        finally
          Sections.Free;
        end;
        UpdateFile;
      finally
        Free;
      end;
  except
    FIniFailed := True;
  end;
end;

function TMainForm.Find(ALine, AFind: PChar; ARegEx: Boolean): PChar;
var
  FindRegexInfo: TFindRegExInfo;
  AStart, AEnd, ANext: PChar;
begin
  if AFind^ = #0 then
  begin
    if ALine^ = #0 then
    begin
      Result := ALine + 1;
      Exit;
    end;
    Result := nil;
    Exit;
  end;
  if ARegEx then
  begin
    AStart := nil;
    AEnd := nil;
    ANext := nil;
    FindRegexInfo.cbSize := SizeOf(FindRegexInfo);
    FindRegexInfo.nFlags := FLAG_FIND_MATCH_CASE;
    FindRegexInfo.pszRegEx := PChar(AFind);
    FindRegexInfo.pszText := ALine;
    FindRegexInfo.ppszStart := @AStart;
    FindRegexInfo.ppszEnd := @AEnd;
    FindRegexInfo.ppszNext := @ANext;
    if Editor_FindRegEx(FEditor, @FindRegexInfo) then
      Result := FindRegexInfo.ppszNext^
    else
      Result := nil;
    Exit;
  end
  else
  begin
    AStart := StrPos(ALine, AFind);
    if AStart <> nil then
    begin
      Result := AStart + StrLen(AFind);
      Exit;
    end;
  end;
  Result := nil;
end;

function TMainForm.LineMatched(ALine, ABegin: PChar; ARegExBegin: Boolean;
  AEnd: PChar; ARegExEnd: Boolean): NativeInt;
var
  P: PChar;
  ALevel: NativeInt;
begin
  P := ALine;
  ALevel := 0;
  if ALine^ = #0 then
  begin
    if ABegin^ = #0 then
      Inc(ALevel);
    if AEnd^ = #0 then
      Dec(ALevel);
    Result := ALevel;
    Exit;
  end;
  while P^ <> #0 do
  begin
    P := Find(P, ABegin, ARegExBegin);
    if P = nil then
      Break;
    Inc(ALevel);
  end;
  P := ALine;
  while P^ <> #0 do
  begin
    P := Find(P, AEnd, ARegExEnd);
    if P = nil then
      Break;
    Dec(ALevel);
  end;
  Result := ALevel;
end;

function TMainForm.Matched(ALine, AFind: PChar; ARegEx, AStripPrefix: Boolean;
  AReplace: PChar): Boolean;
  function StrCompEx(First, Last: PChar): Boolean;
  begin
    while First^ = Last^ do
    begin
      Inc(First);
      Inc(Last);
      if Last^ = #0 then
      begin
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;

var
  MatchRegexInfo: TMatchRegexInfo;
  LineLen, FindLen, ReplaceLen: NativeInt;
begin
  if ARegEx then
  begin
    FillChar(MatchRegexInfo, SizeOf(TMatchRegexInfo), #0);
    MatchRegexInfo.cbSize := SizeOf(TMatchRegexInfo);
    MatchRegexInfo.nFlags := FLAG_FIND_MATCH_CASE;
    MatchRegexInfo.pszRegEx := PChar(AFind);
    MatchRegexInfo.pszText := ALine;
    if AStripPrefix and (AReplace <> nil) and (AReplace^ <> #0) then
    begin
      MatchRegexInfo.pszReplace := AReplace;
      MatchRegexInfo.pszResult := ALine;
      MatchRegexInfo.cchResult := MaxLineLength;
    end;
    Result := Editor_MatchRegex(FEditor, @MatchRegexInfo);
    Exit;
  end
  else if StrCompEx(ALine, AFind) then
  begin
    if AStripPrefix then
    begin
      LineLen := StrLen(ALine);
      FindLen := StrLen(AFind);
      ReplaceLen := StrLen(AReplace);
      FStringBuffer.Clear;
      FStringBuffer.Append(ALine);
      FStringBuffer.Remove(0, FindLen);
      FStringBuffer.Insert(0, AReplace, ReplaceLen);
      StrLCopy(ALine, FStringBuffer.ToPointer(0), LineLen);
    end;
    Result := True;
    Exit;
  end;
  Result := False;
end;

function TMainForm.CalcIndent(ALine: PChar; ALevel: NativeInt;
  var ApplyBefore: Boolean; var CustomBarLevel: NativeInt): NativeInt;
var
  P, Temp: PChar;
  BeginChar, EndChar: Char;
  Tested: Boolean;
  Ret: NativeInt;
begin
  ApplyBefore := False;
  CustomBarLevel := 0;
  P := ALine;
  if FProp.IndentType = IndentSpaces then
  begin
    if ALine[0] <> #0 then
    begin
      ALevel := 0;
      while (P^ = #09) or (P^ = #$0020) do
      begin
        Inc(ALevel);
        Inc(P);
      end;
    end;
  end
  else if (FProp.IndentType = IndentBraces) or (FProp.IndentType = IndentBrackets) then
  begin
    if FProp.IndentType = IndentBraces then
    begin
      BeginChar := '{';
      EndChar := '}';
    end
    else
    begin
      BeginChar := '[';
      EndChar := ']';
    end;
    ApplyBefore := True;
    Tested := False;
    while P^ <> #0 do
    begin
      if P^ = '/' then
      begin
        if (P + 1)^ = '/' then
          Break;
      end
      else if P^ = BeginChar then
      begin
        if not Tested then
        begin
          Tested := True;
          ApplyBefore := False;
          Temp := ALine;
          while Temp <> P do
          begin
            if (Temp^ <> ' ') and (Temp^ <> #09) then
            begin
              ApplyBefore := True;
              Break;
            end;
            Inc(Temp);
          end;
        end;
        Inc(ALevel);
      end
      else if P^ = EndChar then
        Dec(ALevel);
      Inc(P);
    end;
    if ALevel < 0 then
      ALevel := 0;
  end
  else if FProp.IndentType = IndentCustom then
  begin
    CustomBarLevel := CalcOutlineCustom(ALine, True);
    if CustomBarLevel <> 0 then
      ALevel := CustomBarLevel;
    ApplyBefore := True;
  end
  else if FProp.IndentType = IndentCustomBeginEnd then
  begin
    ApplyBefore := True;
    Ret := LineMatched(ALine,
      PChar(FProp.Match[0]), FProp.RegEx[0],
      PChar(FProp.Match[1]), FProp.RegEx[1]);
    Inc(ALevel, Ret);
    if ALevel < 0 then
      ALevel := 0;
  end;
  Result := ALevel;
end;

function TMainForm.CalcOutlineCustom(ALine: PChar;
  AStripPrefix: Boolean): NativeInt;
var
  I: NativeInt;
begin
  for I := MaxDepth - 1 downto 0 do
  begin
    if FProp.Match[I] <> '' then
    begin
      if Matched(ALine, PChar(FProp.Match[I]), FProp.RegEx[I], AStripPrefix, PChar(FProp.Replace[I])) then
      begin
        Result := I + 1;
        Exit;
      end;
    end;
  end;
  Result := 0;
end;

function TMainForm.GetCurrentLine: NativeInt;
var
  P: TPoint;
begin
  Editor_GetCaretPos(FEditor, POS_LOGICAL, @P);
  Result := P.Y;
end;

procedure TMainForm.OutlineSelected(Node: TTreeNode; FocusView, Select: Boolean);
var
  I, P, AOutline, ALevel: NativeInt;
  APos, APosBottom: TPoint;
begin
  if Node = nil then
    Exit;
  AOutline := Node.StateIndex;
  if not InRange(AOutline, 0, FList.Count - 1) then
    Exit;
  APos.X := 0;
  APos.Y := FList[AOutline].LineNum;
  Editor_Redraw(FEditor, False);
  try
    Editor_SetCaretPos(FEditor, POS_LOGICAL, @APos);
    if FocusView then
      Editor_ExecCommand(FEditor, MEID_WINDOW_ACTIVE_PANE);
    if Select then
    begin
      APosBottom.X := 0;
      I := AOutline;
      if Node.HasChildren then
      begin
        ALevel := FList[AOutline].Level;
        for P := Succ(AOutline) to FList.Count - 1 do
        begin
          if FList[P].Level > ALevel then
            I := P
          else
            Break;
        end;
      end;
      if I < FList.Count - 1 then
        APosBottom.Y := FList[Succ(I)].LineNum
      else
        APosBottom.Y := Editor_GetLines(FEditor, POS_LOGICAL) - 1;
      Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @APosBottom, False);
      Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @APos, True);
    end;
    Editor_GetCaretPos(FEditor, POS_VIEW, @APos);
    Editor_SetScrollPos(FEditor, @APos);
  finally
    Editor_Redraw(FEditor, True);
  end;
end;

procedure TMainForm.ReadIni;
var
  S: string;
  Mode: array [0 .. MAX_MODE_NAME - 1] of Char;
begin
  if not GetIniFileName(S) then
    Exit;
  with TMemIniFile.Create(S, TEncoding.UTF8) do
    try
      FFontName := ReadString('MainForm', 'FontName', Font.Name);
      FFontSize := ReadInteger('MainForm', 'FontSize', Font.Size);
      FFontNameSub := ReadString('Outline', 'FontName', FFontNameSub);
      FFontSizeSub := ReadInteger('Outline', 'FontSize', FFontSizeSub);
    finally
      Free;
    end;
  Mode[0] := #0;
  Editor_GetMode(Editor, @Mode);
  if Mode[0] <> #0 then
    ReadIni(FProp, Mode);
end;

procedure TMainForm.WriteIni;
var
  S: string;
begin
  if FIniFailed or (not GetIniFileName(S)) then
    Exit;
  try
    with TMemIniFile.Create(S, TEncoding.UTF8) do
      try
        WriteInteger('Outline', 'CustomBarPos', FBarPos);
        UpdateFile;
      finally
        Free;
      end;
  except
    FIniFailed := True;
  end;
end;

procedure TMainForm.ResetThread;
begin
  if FWorkThread > 0 then
  begin
    FAbortThread := True;
    SetEvent(FQueEvent);
    SetThreadPriority(FWorkThread, THREAD_PRIORITY_ABOVE_NORMAL);
    WaitMessageLoop(1, FWorkThread, INFINITE);
    CloseHandle(FWorkThread);
    FWorkThread := 0;
    with TreeView.Items do
    begin
      BeginUpdate;
      try
        Clear;
      finally
        EndUpdate;
      end;
    end;
    FList.Clear;
    FAbortThread := False;
  end;
end;

procedure TMainForm.UpdateTreeViewAll;
var
  I, J: NativeInt;
  ParentItem: array [0 .. MaxDepth] of TTreeNode;
  ANode: TTreeNode;
  Item: TOutlineItem;
begin
  TreeView.Items.BeginUpdate;
  try
    for I := 0 to High(ParentItem) do
      ParentItem[I] := nil;
    for I := 0 to FList.Count - 1 do
    begin
      if FAbortThread then
        Exit;
      Item := FList[I];
      if Item.Node <> nil then
      begin
        ANode := TreeView.Items.GetNode(Item.Node.ItemId);
        if ANode <> nil then
          ANode.Text := Item.LineStr;
      end
      else
      begin
        if ParentItem[Item.Level - 1] = nil then
          ANode := TreeView.Items.AddChild(nil, Item.LineStr)
        else
          ANode := TreeView.Items.AddChild(ParentItem[Item.Level - 1], Item.LineStr);
        ANode.StateIndex := I;
        Item.Node := ANode;
      end;
      for J := Item.Level to MaxDepth do
        ParentItem[J] := Item.Node;
    end;
    TreeView.Selected := TreeView.Items.GetFirstNode;
  finally
    TreeView.Items.EndUpdate;
    UpdateTreeViewSel;
  end;
end;

procedure TMainForm.OutlineAll;
var
  I, Len: NativeInt;
  AList: TOutlineList;
  Text: array [0 .. MaxLineLength - 1] of Char;
  LineInfo: TGetLineInfo;
  OldLine, EmptyLine: NativeInt;
  Level, NewLevel: NativeInt;
  ApplyBefore: Boolean;
  CustomBarLevel: NativeInt;
  Line, Temp: NativeInt;
  UpdateAll: Boolean;
  FirstUpdate: NativeInt;
  Src, Dest: NativeInt;
  ANode: TTreeNode;
  AItem: TOutlineItem;
begin
  AList := TOutlineList.Create;
  try
    Len := Editor_GetLines(FEditor, POS_LOGICAL);
    OldLine := -1;
    EmptyLine := -1;
    Level := 0;
    LineInfo.flags := FLAG_LOGICAL;
    LineInfo.cch := Length(Text);
    for I := 0 to Len - 1 do
    begin
      if FAbortThread then
        Break;
      LineInfo.yLine := I;
      Text[0] := #0;
      Editor_GetLine(FEditor, @LineInfo, Text);
      CustomBarLevel := 0;
      NewLevel := CalcIndent(Text, Level, ApplyBefore, CustomBarLevel);
      if NewLevel < 0 then
        NewLevel := 0;
      if (Text[0] = #0) and (EmptyLine = -1) then
        EmptyLine := LineInfo.yLine;
      if (FProp.IndentType = IndentSpaces) or (FProp.IndentType = IndentBraces) or (FProp.IndentType = IndentBrackets) or (FProp.IndentType = IndentCustomBeginEnd) then
      begin
        if NewLevel <= FProp.ViewLevel then
        begin
          if (NewLevel > Level) and (NewLevel > 0) then
          begin
            if (not ApplyBefore) and (NativeInt(LineInfo.yLine) > 0) and (OldLine <> NativeInt(LineInfo.yLine) - 1) then
            begin
              if (EmptyLine <> -1) and (EmptyLine > 0) and (Text[0] <> #0) then
                Line := EmptyLine - 1
              else
                Line := LineInfo.yLine - 1;
              Text[0] := #0;
              Temp := LineInfo.yLine;
              LineInfo.yLine := Line;
              Editor_GetLine(FEditor, @LineInfo, Text);
              LineInfo.yLine := Temp;
            end
            else
              Line := LineInfo.yLine;
            AList.Add(TOutlineItem.Create(Line, Min(NewLevel, MaxDepth), Text));
            OldLine := Line;
          end;
        end;
      end
      else if CustomBarLevel > 0 then
      begin
        if CustomBarLevel <= FProp.ViewLevel then
          AList.Add(TOutlineItem.Create(LineInfo.yLine, Min(CustomBarLevel, MaxDepth), Text));
      end;
      Level := NewLevel;
      if Text[0] <> #0 then
        EmptyLine := -1;
    end;
    if FAbortThread then
      Exit;
    UpdateAll := False;
    FirstUpdate := FList.Count;
    if FList.Count = 0 then
    begin
      FirstUpdate := -1;
      UpdateAll := True;
      with TreeView.Items do
      begin
        BeginUpdate;
        try
          Clear;
        finally
          EndUpdate;
        end;
      end;
    end
    else
    begin
      for I := 0 to Min(FList.Count, AList.Count) - 1 do
      begin
        if FAbortThread then
          Exit;
        if FList[I].Level <> AList[I].Level then
        begin
          if not UpdateAll then
          begin
            FirstUpdate := I;
            UpdateAll := True;
          end;
        end;
        if UpdateAll then
        begin
          while True do
          begin
            if FList[I].Node = nil then
              Break;
            ANode := FList[I].Node.GetNext;
            if ANode = nil then
              Break;
            ANode.Delete;
          end;
          if FList[I].Node <> nil then
            FList[I].Node.Delete;
          Break;
        end;
      end;
    end;
    Src := 0;
    Dest := 0;
    for I := 0 to Min(FirstUpdate, AList.Count) - 1 do
    begin
      with FList[I] do
      begin
        LineNum := AList[I].LineNum;
        Level := AList[I].Level;
        LineStr := AList[I].LineStr;
      end;
      Inc(Src);
      Inc(Dest);
    end;
    if InRange(Dest, 0, FList.Count - 1) then
    begin
      if not UpdateAll then
        UpdateAll := True;
      while True do
      begin
        if FList[Dest].Node = nil then
          Break;
        ANode := FList[Dest].Node.GetNext;
        if ANode = nil then
          Break;
        ANode.Delete;
      end;
      if FList[Dest].Node <> nil then
        FList[Dest].Node.Delete;
      for I := FList.Count - 1 downto Dest do
      begin
        AItem := FList[I];
        FList.Remove(AItem);
        AItem.Free;
      end;
    end;
    if InRange(Src, 0, AList.Count - 1) then
    begin
      for I := Src to AList.Count - 1 do
      begin
        if not UpdateAll then
          UpdateAll := True;
        with AList[I] do
        begin
          AItem := TOutlineItem.Create(LineNum, Level, LineStr);
          AItem.Node := Node;
        end;
        FList.Add(AItem);
      end;
    end;
    if FAbortThread then
      Exit;
    if UpdateAll then
      UpdateTreeViewAll
    else
      UpdateTreeViewString;
  finally
    AList.Free;
  end;
end;

procedure TMainForm.UpdateTreeViewSel;
var
  I: NativeInt;
  CurrentLine: NativeInt;
begin
  if FList.Count = 0 then
    Exit;
  CurrentLine := GetCurrentLine;
  I := 0;
  while I < FList.Count do
  begin
    if CurrentLine = FList[I].LineNum then
      Break
    else if FList[I].LineNum > CurrentLine then
    begin
      Dec(I);
      Break;
    end;
    Inc(I);
  end;
  if I < 0 then
    I := 0;
  if I > FList.Count - 1 then
    I := FList.Count - 1;
  if FList[I].Node <> nil then
    FList[I].Node.Selected := True;
end;

procedure TMainForm.SetTreeColor;
var
  AName: array [0 .. 255] of Char;
  ASize: NativeInt;
  AFore, ABack: TColor;
begin
  Editor_Info(FEditor, MI_GET_FONT_NAME, LPARAM(@AName));
  ASize := Editor_Info(FEditor, MI_GET_FONT_SIZE, 0);
  AFore := TColor(Editor_Info(FEditor, MI_GET_TEXT_COLOR, COLOR_GENERAL));
  ABack := TColor(Editor_Info(FEditor, MI_GET_BACK_COLOR, COLOR_GENERAL));
  with TreeView do
  begin
    with Font do
    begin
      Name := IfThen(FFontNameSub <> '', FFontNameSub, AName);
      Size := IfThen(FFontSizeSub <> 0, FFontSizeSub, ASize);
      Color := AFore;
    end;
    Color := ABack;
  end;
end;

procedure TMainForm.UpdateTreeViewString;
var
  I: NativeInt;
  ANode: TTreeNode;
begin
  for I := 0 to FList.Count - 1 do
    if FList[I].Node <> nil then
    begin
      ANode := TreeView.Items.GetNode(FList[I].Node.ItemId);
      if ANode <> nil then
        ANode.Text := FList[I].LineStr;
    end;
end;

function TMainForm.SetProperties: Boolean;
var
  S, P: PChar;
  Len: NativeInt;
  Item: TPropItem;
  Items: TPropItems;
begin
  Result := False;
  Items := TPropItems.Create;
  try
    Len := Editor_EnumMode(FEditor, nil, 0);
    S := StrAlloc(Len);
    try
      Editor_EnumMode(FEditor, S, Len);
      P := S;
      while P^ <> #0 do
      begin
        with Items.Add do
          ReadIni(Prop, P);
        Inc(P, StrLen(P) + 1);
      end;
    finally
      StrDispose(S);
    end;
    if Prop(Self, FBarPos, Items, FProp) then
    begin
      EraseSection;
      for Item in Items do
        WriteIni(Item.Prop);
      WriteIni;
      ReadIni;
      FUpdateOutline := True;
      Result := True;
    end;
  finally
    FreeAndNil(Items);
  end;
end;

end.
