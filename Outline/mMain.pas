// -----------------------------------------------------------------------------
// アウトライン
//
// Copyright (c) Kuro. All Rights Reserved.
// e-mail: info@haijin-boys.com
// www:    https://www.haijin-boys.com/
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
  StringBuffer, mPerMonitorDpi;

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

  TDefaultLevel = (dlCollapse, dlLevel2, dlLevel3, dlLevel4, dlLevel5, dlLevel6,
    dlLevel7, dlExpand);

  TTextSize = (tsSmallest, tsSmaller, tsMedium, tsLarger, tsLargest);

  TProp = class(TPersistent)
  private
    { Private 宣言 }
    FCaption: string;
    FIndentType: Integer;
    FViewLevel: Integer;
    FDefaultLevel: TDefaultLevel;
  public
    { Public 宣言 }
    Match: array [0 .. MaxDepth - 1] of string;
    Replace: array [0 .. MaxDepth - 1] of string;
    RegEx: array [0 .. MaxDepth - 1] of Boolean;
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure Reset;
    property Caption: string read FCaption write FCaption;
    property IndentType: Integer read FIndentType write FIndentType;
    property ViewLevel: Integer read FViewLevel write FViewLevel;
    property DefaultLevel: TDefaultLevel read FDefaultLevel write FDefaultLevel;
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
    FIndex: Integer;
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
    function GetItem(Index: Integer): TPropItem;
    procedure SetItem(Index: Integer; Value: TPropItem);
  public
    { Public 宣言 }
    constructor Create;
    function Add: TPropItem;
    function GetEnumerator: TPropItemsEnumerator;
    function IndexOf(Item: TPropItem): Integer;
    property Items[Index: Integer]: TPropItem read GetItem write SetItem; default;
  end;

  TOutlineItem = class
  private
    { Private 宣言 }
    FNode: TTreeNode;
    FLineNum: Integer;
    FLevel: Integer;
    FLineStr: string;
  public
    { Public 宣言 }
    constructor Create(ALineNum: Integer; ALevel: Integer; ALineStr: string);
    property Node: TTreeNode read FNode write FNode;
    property LineNum: Integer read FLineNum write FLineNum;
    property Level: Integer read FLevel write FLevel;
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

  TMainForm = class(TScaledForm)
    PopupMenu: TPopupMenu;
    CopyMenuItem: TMenuItem;
    CopyAllMenuItem: TMenuItem;
    N1: TMenuItem;
    GoMenuItem: TMenuItem;
    SelectMenuItem: TMenuItem;
    N2: TMenuItem;
    MoveUpMenuItem: TMenuItem;
    MoveDownMenuItem: TMenuItem;
    N3: TMenuItem;
    CollapseAllMenuItem: TMenuItem;
    Level2MenuItem: TMenuItem;
    Level3MenuItem: TMenuItem;
    Level4MenuItem: TMenuItem;
    Level5MenuItem: TMenuItem;
    Level6MenuItem: TMenuItem;
    Level7MenuItem: TMenuItem;
    ExpandAllMenuItem: TMenuItem;
    N4: TMenuItem;
    TextSizeMenuItem: TMenuItem;
    N5: TMenuItem;
    TextSizeLargestMenuItem: TMenuItem;
    TextSizeLargerMenuItem: TMenuItem;
    TextSizeMediumMenuItem: TMenuItem;
    TextSizeSmallerMenuItem: TMenuItem;
    TextSizeSmallestMenuItem: TMenuItem;
    PropPopupMenuItem: TMenuItem;
    Timer: TTimer;
    TreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PopupMenuPopup(Sender: TObject);
    procedure CopyMenuItemClick(Sender: TObject);
    procedure CopyAllMenuItemClick(Sender: TObject);
    procedure GoMenuItemClick(Sender: TObject);
    procedure SelectMenuItemClick(Sender: TObject);
    procedure MoveUpMenuItemClick(Sender: TObject);
    procedure MoveDownMenuItemClick(Sender: TObject);
    procedure CollapseAllMenuItemClick(Sender: TObject);
    procedure Level2MenuItemClick(Sender: TObject);
    procedure ExpandAllMenuItemClick(Sender: TObject);
    procedure TextSizeLargestMenuItemClick(Sender: TObject);
    procedure PropPopupMenuItemClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TreeViewClick(Sender: TObject);
    procedure TreeViewDblClick(Sender: TObject);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeViewEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure TreeViewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private 宣言 }
    FEditor: THandle;
    FBarPos: Integer;
    FFontName: string;
    FFontSize: Integer;
    FTextSize: TTextSize;
    FProp: TProp;
    FStringBuffer: TStringBuffer;
    FList: TOutlineList;
    FPoint: TPoint;
    FNode: TTreeNode;
    FDropTarget: TTreeNode;
    FAfter: Boolean;
    FUpdateOutline: Boolean;
    FUpdateTreeSel: Boolean;
    FWorkFlag: Integer;
    FWorkThread: THandle;
    FAbortThread: Boolean;
    FQueEvent: THandle;
    FMutex: THandle;
    procedure ReadIni(Prop: TProp; const Mode: string); overload;
    procedure WriteIni(Prop: TProp); overload;
    procedure EraseSection;
    function Find(ALine: PChar; AFind: PChar; ARegEx: Boolean): PChar;
    function LineMatched(ALine: PChar; ABegin: PChar; ARegExBegin: Boolean; AEnd: PChar; ARegExEnd: Boolean): Integer;
    function Matched(ALine, AFind: PChar; ARegEx: Boolean; AStripPrefix: Boolean; AReplace: PChar): Boolean;
    function CalcIndent(ALine: PChar; ALevel: Integer; var ApplyBefore: Boolean; var CustomBarLevel: Integer): Integer;
    function CalcOutlineCustom(ALine: PChar; AStripPrefix: Boolean): Integer;
    function GetCurrentLine: Integer;
    procedure UpdateTreeViewAll;
    procedure UpdateTreeViewString;
    procedure OutlineSelected(Node: TTreeNode; FocusView, Select: Boolean);
    procedure MoveNode(Node, Destination: TTreeNode; After: Boolean);
    procedure TreeMoveSub(Node: TTreeNode; Down: Boolean);
  public
    { Public 宣言 }
    procedure ReadIni; overload;
    procedure WriteIni; overload;
    procedure ResetThread;
    procedure OutlineAll;
    procedure UpdateTreeViewSel;
    procedure TreeCopy(Node: TTreeNode);
    procedure TreeMove(Node: TTreeNode; Down: Boolean);
    procedure SetFont;
    procedure SetScale(const Value: Integer);
    function SetProperties: Boolean;
    property BarPos: Integer read FBarPos write FBarPos;
    property UpdateOutline: Boolean read FUpdateOutline write FUpdateOutline;
    property UpdateTreeSel: Boolean read FUpdateTreeSel write FUpdateTreeSel;
    property Editor: THandle read FEditor write FEditor;
    property WorkHandle: THandle read FWorkThread write FWorkThread;
    property WorkFlag: Integer read FWorkFlag write FWorkFlag;
    property AbortThread: Boolean read FAbortThread write FAbortThread;
    property QueEvent: THandle read FQueEvent write FQueEvent;
    property Mutex: THandle read FMutex write FMutex;
  end;

var
  MainForm: TMainForm;
  FPropItems: TPropItems;

implementation

uses
{$IF CompilerVersion > 22.9}
  System.Types, System.StrUtils, System.Math, System.IniFiles, Winapi.CommCtrl,
  Vcl.Clipbrd,
{$ELSE}
  Types, StrUtils, Math, IniFiles, CommCtrl, Clipbrd,
{$IFEND}
  mCommon, mPlugin, mProp;

{$R *.dfm}


function WaitMessageLoop(Count: LongWord; var Handles: THandle;
  Milliseconds: DWORD): Integer;
var
  Quit: Boolean;
  ExitCode: Integer;
  WaitResult: DWORD;
  Msg: TMsg;
begin
  Quit := False;
  ExitCode := 0;
  repeat
    while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
    begin
      case Msg.message of
        WM_QUIT:
          begin
            Quit := True;
            ExitCode := Integer(Msg.wParam);
            Break;
          end;
        WM_MOUSEMOVE:
          ;
        WM_LBUTTONDOWN:
          ;
      else
        DispatchMessage(Msg);
      end;
    end;
    WaitResult := MsgWaitForMultipleObjects(Count, Handles, False, Milliseconds, QS_ALLINPUT);
  until WaitResult <> WAIT_OBJECT_0 + 1;
  if Quit then
    PostQuitMessage(ExitCode);
  Result := Integer(WaitResult - WAIT_OBJECT_0);
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
      Self.FDefaultLevel := DefaultLevel;
      Self.Match := Match;
      Self.Replace := Replace;
      Self.RegEx := RegEx;
    end
  else
    inherited;
end;

procedure TProp.Reset;
var
  I: Integer;
begin
  for I := 0 to MaxDepth - 1 do
  begin
    Match[I] := StringOfChar('.', I + 1);
    Replace[I] := '';
    RegEx[I] := False;
  end;
  FIndentType := IndentSpaces;
  FViewLevel := 8;
  FDefaultLevel := dlCollapse;
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
  Result := TPropItem(inherited Add);
end;

constructor TPropItems.Create;
begin
  inherited Create(TPropItem);
end;

function TPropItems.GetEnumerator: TPropItemsEnumerator;
begin
  Result := TPropItemsEnumerator.Create(Self);
end;

function TPropItems.GetItem(Index: Integer): TPropItem;
begin
  Result := TPropItem(inherited GetItem(Index));
end;

function TPropItems.IndexOf(Item: TPropItem): Integer;
begin
  for Result := 0 to Count - 1 do
    if Items[Result] = Item then
      Exit;
  Result := -1;
end;

procedure TPropItems.SetItem(Index: Integer; Value: TPropItem);
begin
  inherited SetItem(Index, Value);
end;

{ TOutlineItem }

constructor TOutlineItem.Create(ALineNum: Integer; ALevel: Integer;
  ALineStr: string);
  function TrimLine(const ALine: string): string;
  var
    I, Len: Integer;
  begin
    Result := Trim(ALine);
    Len := Length(Result);
    I := 1;
    while I <= Len do
    begin
      if Result[I] = #09 then
        Result[I] := ' ';
      Inc(I);
    end;
  end;

begin
  FNode := nil;
  FLineNum := ALineNum;
  FLevel := ALevel;
  FLineStr := TrimLine(ALineStr);
end;

{ TOutlineList }

destructor TOutlineList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TOutlineList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited;
end;

function TOutlineList.Get(Index: Integer): TOutlineItem;
begin
  Result := TOutlineItem(inherited Get(Index));
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  TScaledForm.DefaultFont.Assign(Font);
  FEditor := ParentWindow;
  FFontName := '';
  FFontSize := 0;
  FTextSize := tsMedium;
  FProp := TProp.Create;
  FStringBuffer := TStringBuffer.Create(0);
  FList := TOutlineList.Create;
  FPoint := Point(-1, -1);
  FNode := nil;
  FDropTarget := nil;
  FAfter := False;
  FUpdateOutline := False;
  FUpdateTreeSel := False;
  FWorkFlag := 0;
  FQueEvent := CreateEvent(nil, True, False, nil);
  FMutex := CreateMutex(nil, False, nil);
  ReadIni;
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

procedure TMainForm.PopupMenuPopup(Sender: TObject);
begin
  with TreeView do
  begin
    CopyMenuItem.Enabled := Selected <> nil;
    CopyAllMenuItem.Enabled := Items.Count > 0;
    GoMenuItem.Enabled := Selected <> nil;
    SelectMenuItem.Enabled := Selected <> nil;
    MoveDownMenuItem.Enabled := Selected <> nil;
    MoveUpMenuItem.Enabled := Selected <> nil;
  end;
  TextSizeLargestMenuItem.Checked := False;
  TextSizeLargerMenuItem.Checked := False;
  TextSizeMediumMenuItem.Checked := False;
  TextSizeSmallerMenuItem.Checked := False;
  TextSizeSmallestMenuItem.Checked := False;
  case FTextSize of
    tsLargest:
      TextSizeLargestMenuItem.Checked := True;
    tsLarger:
      TextSizeLargerMenuItem.Checked := True;
    tsSmaller:
      TextSizeSmallerMenuItem.Checked := True;
    tsSmallest:
      TextSizeSmallestMenuItem.Checked := True;
  else
    TextSizeMediumMenuItem.Checked := True;
  end;
end;

procedure TMainForm.CopyMenuItemClick(Sender: TObject);
begin
  TreeCopy(TreeView.Selected);
end;

procedure TMainForm.CopyAllMenuItemClick(Sender: TObject);
var
  LList: TStringList;
  LNode: TTreeNode;
begin
  LList := TStringList.Create;
  try
    with TreeView, Items do
    begin
      LNode := GetFirstNode;
      while LNode <> nil do
      begin
        LList.Add(DupeString(#09, LNode.Level) + LNode.Text);
        LNode := LNode.GetNext;
      end;
    end;
    Clipboard.AsText := LList.Text;
  finally
    LList.Free;
  end;
end;

procedure TMainForm.GoMenuItemClick(Sender: TObject);
begin
  OutlineSelected(TreeView.Selected, True, False);
end;

procedure TMainForm.SelectMenuItemClick(Sender: TObject);
begin
  OutlineSelected(TreeView.Selected, True, True);
end;

procedure TMainForm.MoveUpMenuItemClick(Sender: TObject);
begin
  TreeMove(TreeView.Selected, False);
end;

procedure TMainForm.MoveDownMenuItemClick(Sender: TObject);
begin
  TreeMove(TreeView.Selected, True);
end;

procedure TMainForm.CollapseAllMenuItemClick(Sender: TObject);
begin
  if WaitMessageLoop(1, FMutex, INFINITE) <> 0 then
    Exit;
  with TreeView, Items do
  begin
    BeginUpdate;
    try
      FullCollapse;
    finally
      EndUpdate;
    end;
  end;
  ReleaseMutex(FMutex);
end;

procedure TMainForm.Level2MenuItemClick(Sender: TObject);
var
  LLevel: Integer;
  LNode: TTreeNode;
begin
  if WaitMessageLoop(1, FMutex, INFINITE) <> 0 then
    Exit;
  LLevel := (Sender as TMenuItem).Tag;
  with TreeView, Items do
  begin
    BeginUpdate;
    try
      LNode := GetFirstNode;
      while LNode <> nil do
      begin
        if LNode.Level < LLevel then
          LNode.Expand(False)
        else
          LNode.Collapse(False);
        LNode := LNode.GetNext;
      end;
    finally
      EndUpdate;
    end;
  end;
  ReleaseMutex(FMutex);
end;

procedure TMainForm.ExpandAllMenuItemClick(Sender: TObject);
begin
  if WaitMessageLoop(1, FMutex, INFINITE) <> 0 then
    Exit;
  with TreeView, Items do
  begin
    BeginUpdate;
    try
      FullExpand;
    finally
      EndUpdate;
    end;
  end;
  ReleaseMutex(FMutex);
end;

procedure TMainForm.TextSizeLargestMenuItemClick(Sender: TObject);
begin
  if Sender = TextSizeLargestMenuItem then
    FTextSize := tsLargest
  else if Sender = TextSizeLargerMenuItem then
    FTextSize := tsLarger
  else if Sender = TextSizeSmallerMenuItem then
    FTextSize := tsSmaller
  else if Sender = TextSizeSmallestMenuItem then
    FTextSize := tsSmallest
  else
    FTextSize := tsMedium;
  SetFont;
end;

procedure TMainForm.PropPopupMenuItemClick(Sender: TObject);
begin
  SetProperties;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
var
  P: TPoint;
begin
  with TreeView do
  begin
    if not Dragging then
    begin
      Timer.Enabled := False;
      Exit;
    end;
    P := ScreenToClient(Mouse.CursorPos);
    if P.Y < 0 then
      Perform(WM_VSCROLL, SB_LINEUP, 0)
    else
      if P.Y > ClientHeight then
      Perform(WM_VSCROLL, SB_LINEDOWN, 0)
    else
      Timer.Enabled := False;
  end;
end;

procedure TMainForm.TreeViewClick(Sender: TObject);
var
  LNode: TTreeNode;
begin
  LNode := TreeView.GetNodeAt(FPoint.X, FPoint.Y);
  if LNode <> nil then
    OutlineSelected(LNode, False, False);
end;

procedure TMainForm.TreeViewDblClick(Sender: TObject);
var
  LNode: TTreeNode;
begin
  LNode := TreeView.GetNodeAt(FPoint.X, FPoint.Y);
  if LNode <> nil then
    OutlineSelected(LNode, True, False);
end;

procedure TMainForm.TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if FDropTarget <> nil then
    MoveNode(FNode, FDropTarget, FAfter);
end;

procedure TMainForm.TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  H: Integer;
  R: TRect;
begin
  with TreeView do
  begin
    Accept := Sender = Source;
    if Accept then
    begin
      H := TreeView_GetItemHeight(Handle);
      FAfter := False;
      FDropTarget := GetNodeAt(X, Y);
      if FDropTarget <> nil then
      begin
        R := FDropTarget.DisplayRect(False);
        if (Y > R.Top + H div 2) and (FDropTarget.getFirstChild = nil) then
          FAfter := True;
      end
      else
      begin
        FDropTarget := GetNodeAt(X, Y - H);
        if FDropTarget <> nil then
          FAfter := True;
      end;
      if FDropTarget <> nil then
        TreeView_SetInsertMark(Handle, Integer(FDropTarget.ItemId), FAfter);
      Timer.Enabled := True;
    end;
  end;
end;

procedure TMainForm.TreeViewEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  Timer.Enabled := False;
  TreeView_SetInsertMark((Sender as TTreeView).Handle, 0, False);
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
var
  LNode: TTreeNode;
  LTests: THitTests;
begin
  LTests := TreeView.GetHitTestInfoAt(X, Y);
  if not(htOnItem in LTests) then
  begin
    FPoint := Point(-1, -1);
    Exit;
  end;
  FPoint := Point(X, Y);
  with TreeView do
    case Button of
      mbLeft:
        begin
          FNode := GetNodeAt(X, Y);
          if FNode <> nil then
            BeginDrag(False);
        end;
      mbRight:
        begin
          LNode := GetNodeAt(X, Y);
          if LNode <> nil then
            Selected := LNode;
        end;
    end;
end;

procedure TMainForm.ReadIni(Prop: TProp; const Mode: string);
var
  S: string;
  I: Integer;
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
          DefaultLevel := TDefaultLevel(ReadInteger(Format('Outline\%s', [Caption]), 'DefaultLevel', Integer(DefaultLevel)));
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
  I: Integer;
begin
  if not GetIniFileName(S) then
    Exit;
  with TMemIniFile.Create(S, TEncoding.UTF8) do
    try
      with Prop do
      begin
        WriteInteger(Format('Outline\%s', [Caption]), 'IndentType', IndentType);
        WriteInteger(Format('Outline\%s', [Caption]), 'ViewLevel', ViewLevel);
        WriteInteger(Format('Outline\%s', [Caption]), 'DefaultLevel', Integer(DefaultLevel));
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
  I: Integer;
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
  LStart, LEnd, LNext: PChar;
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
    LStart := nil;
    LEnd := nil;
    LNext := nil;
    FindRegexInfo.cbSize := SizeOf(FindRegexInfo);
    FindRegexInfo.nFlags := FLAG_FIND_MATCH_CASE;
    FindRegexInfo.pszRegEx := PChar(AFind);
    FindRegexInfo.pszText := ALine;
    FindRegexInfo.ppszStart := @LStart;
    FindRegexInfo.ppszEnd := @LEnd;
    FindRegexInfo.ppszNext := @LNext;
    if Editor_FindRegEx(FEditor, @FindRegexInfo) then
      Result := FindRegexInfo.ppszNext^
    else
      Result := nil;
    Exit;
  end
  else
  begin
    LStart := StrPos(ALine, AFind);
    if LStart <> nil then
    begin
      Result := LStart + StrLen(AFind);
      Exit;
    end;
  end;
  Result := nil;
end;

function TMainForm.LineMatched(ALine, ABegin: PChar; ARegExBegin: Boolean;
  AEnd: PChar; ARegExEnd: Boolean): Integer;
var
  P: PChar;
  LLevel: Integer;
begin
  P := ALine;
  LLevel := 0;
  if ALine^ = #0 then
  begin
    if ABegin^ = #0 then
      Inc(LLevel);
    if AEnd^ = #0 then
      Dec(LLevel);
    Result := LLevel;
    Exit;
  end;
  while P^ <> #0 do
  begin
    P := Find(P, ABegin, ARegExBegin);
    if P = nil then
      Break;
    Inc(LLevel);
  end;
  P := ALine;
  while P^ <> #0 do
  begin
    P := Find(P, AEnd, ARegExEnd);
    if P = nil then
      Break;
    Dec(LLevel);
  end;
  Result := LLevel;
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
  LineLen, FindLen, ReplaceLen: Integer;
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

function TMainForm.CalcIndent(ALine: PChar; ALevel: Integer;
  var ApplyBefore: Boolean; var CustomBarLevel: Integer): Integer;
var
  P, Temp: PChar;
  BeginChar, EndChar: Char;
  Tested: Boolean;
  Ret: Integer;
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
  AStripPrefix: Boolean): Integer;
var
  I: Integer;
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

function TMainForm.GetCurrentLine: Integer;
var
  P: TPoint;
begin
  Editor_GetCaretPos(FEditor, POS_LOGICAL, @P);
  Result := P.Y;
end;

procedure TMainForm.OutlineSelected(Node: TTreeNode; FocusView, Select: Boolean);
var
  I, J, LOutline: Integer;
  LLevel: Integer;
  LPos, LPosBottom: TPoint;
begin
  if Node = nil then
    Exit;
  LOutline := Node.StateIndex;
  if not InRange(LOutline, 0, FList.Count - 1) then
    Exit;
  LPos.X := 0;
  LPos.Y := FList[LOutline].LineNum;
  Editor_SetCaretPos(FEditor, POS_LOGICAL, @LPos);
  if FocusView then
    Editor_ExecCommand(FEditor, MEID_WINDOW_ACTIVE_PANE);
  if Select then
  begin
    LPosBottom.X := 0;
    I := LOutline;
    if Node.HasChildren then
    begin
      LLevel := FList[LOutline].Level;
      for J := Succ(LOutline) to FList.Count - 1 do
      begin
        if FList[J].Level > LLevel then
          I := J
        else
          Break;
      end;
    end;
    if I < FList.Count - 1 then
      LPosBottom.Y := FList[Succ(I)].LineNum
    else
      LPosBottom.Y := Editor_GetLines(FEditor, POS_LOGICAL) - 1;
    Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPosBottom, False);
    Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPos, True);
  end;
  Editor_GetCaretPos(FEditor, POS_VIEW, @LPos);
  Editor_SetScrollPos(FEditor, @LPos);
end;

procedure TMainForm.MoveNode(Node, Destination: TTreeNode; After: Boolean);
  function GetNextCluster(Value: TTreeNode): TTreeNode;
  var
    NextNode: TTreeNode;
  begin
    repeat
      NextNode := Value.getNextSibling;
      if NextNode <> nil then
      begin
        Result := NextNode;
        Exit;
      end;
      Value := Value.Parent;
    until Value = nil;
    Result := nil;
  end;

var
  NodeTop, NodeBottom, LineTop, LineBottom, Line: Integer;
  NextNode: TTreeNode;
  LOutline: Integer;
  LPos: TPoint;
  LSize: Cardinal;
  LBuf: array of Char;
begin
  if (Node = nil) or (Destination = nil) or (Node = Destination) then
    Exit;
  NodeTop := Node.StateIndex;
  if not InRange(NodeTop, 0, FList.Count - 1) then
    Exit;
  LineTop := FList[NodeTop].LineNum;
  NextNode := GetNextCluster(Node);
  if NextNode <> nil then
  begin
    NodeBottom := NextNode.StateIndex;
    if not InRange(NodeBottom, 0, FList.Count - 1) then
      Exit;
    LineBottom := FList[NodeBottom].LineNum;
  end
  else
  begin
    LPos.X := MaxInt;
    LPos.Y := MaxInt;
    Editor_SetCaretPos(FEditor, POS_VIEW, @LPos);
    Editor_GetCaretPos(FEditor, POS_LOGICAL, @LPos);
    LineBottom := LPos.Y;
    if LPos.X > 0 then
    begin
      Editor_InsertString(FEditor, PChar(string(#10)));
      Inc(LineBottom);
    end;
  end;
  TreeView.Items.Delete(Node);
  LOutline := Destination.StateIndex;
  if not InRange(LOutline, 0, FList.Count - 1) then
    Exit;
  if After then
  begin
    NextNode := Destination.GetLastChild;
    if NextNode <> nil then
    begin
      LOutline := NextNode.StateIndex;
      if not InRange(LOutline, 0, FList.Count - 1) then
        Exit;
    end;
    Inc(LOutline);
    if LOutline < FList.Count then
      Line := FList[LOutline].LineNum
    else
    begin
      LPos.X := MaxInt;
      LPos.Y := MaxInt;
      Editor_SetCaretPos(FEditor, POS_VIEW, @LPos);
      Editor_GetCaretPos(FEditor, POS_LOGICAL, @LPos);
      Line := LPos.Y;
      if LPos.X > 0 then
      begin
        Editor_InsertString(FEditor, PChar(string(#10)));
        Inc(Line);
      end;
    end;
  end
  else
    Line := FList[LOutline].LineNum;
  Editor_Redraw(FEditor, False);
  try
    LPos.X := 0;
    LPos.Y := LineBottom;
    Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPos, False);
    LPos.Y := LineTop;
    Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPos, True);
    LSize := Editor_GetSelText(FEditor, 0, nil);
    SetLength(LBuf, LSize);
    if Length(LBuf) > 0 then
    begin
      Editor_GetSelText(FEditor, LSize, PChar(LBuf));
      if Line < LineTop then
        Editor_ExecCommand(FEditor, MEID_EDIT_DELETE);
      LPos.Y := Line;
      Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPos, False);
      Editor_InsertString(FEditor, PChar(LBuf));
      if Line < LineTop then
        Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPos, False)
      else
      begin
        LPos.Y := LineBottom;
        Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPos, False);
        LPos.Y := LineTop;
        Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPos, True);
        Editor_ExecCommand(FEditor, MEID_EDIT_DELETE);
        LPos.Y := Line - (LineBottom - LineTop);
        Editor_SetCaretPosEx(FEditor, POS_LOGICAL, @LPos, False);
      end;
    end;
  finally
    Editor_Redraw(FEditor, True);
  end;
  FList.Clear;
  FUpdateOutline := True;
end;

procedure TMainForm.TreeMoveSub(Node: TTreeNode; Down: Boolean);
var
  LNode: TTreeNode;
  After: Boolean;
begin
  After := False;
  if Down then
  begin
    TreeView_Expand(TreeView.Handle, Node.ItemId, TVE_COLLAPSE);
    LNode := Node.GetNextVisible;
    if LNode = nil then
      Exit;
    After := True;
  end
  else
  begin
    LNode := Node.GetPrevVisible;
    if LNode = nil then
      Exit;
  end;
  MoveNode(Node, LNode, After);
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
      with TScaledForm.DefaultFont do
        if ValueExists('MainForm', 'FontName') then
        begin
          Name := ReadString('MainForm', 'FontName', Name);
          Size := ReadInteger('MainForm', 'FontSize', Size);
        end
        else if CheckWin32Version(6, 2) then
          Assign(Screen.IconFont);
      FFontName := ReadString('Outline', 'FontName', FFontName);
      FFontSize := ReadInteger('Outline', 'FontSize', FFontSize);
      FTextSize := TTextSize(ReadInteger('Outline', 'TextSize', Integer(FTextSize)));
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
        WriteInteger('Outline', 'TextSize', Integer(FTextSize));
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
  I, J: Integer;
  ParentItem: array [0 .. MaxDepth] of TTreeNode;
  LNode: TTreeNode;
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
        LNode := TreeView.Items.GetNode(Item.Node.ItemId);
        if LNode <> nil then
          LNode.Text := Item.LineStr;
      end
      else
      begin
        if ParentItem[Item.Level - 1] = nil then
          LNode := TreeView.Items.AddChild(nil, Item.LineStr)
        else
          LNode := TreeView.Items.AddChild(ParentItem[Item.Level - 1], Item.LineStr);
        with LNode do
        begin
          StateIndex := I;
          if Parent <> nil then
            case FProp.DefaultLevel of
              dlCollapse:
                ;
              dlLevel2 .. dlLevel7:
                begin
                  if Parent.Level < Integer(FProp.DefaultLevel) then
                    Parent.Expand(False)
                  else
                    Parent.Collapse(False);
                end;
            else
              Parent.Expand(False);
            end;
        end;
        Item.Node := LNode;
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
  I, Len: Integer;
  LList: TOutlineList;
  Text: array [0 .. MaxLineLength - 1] of Char;
  LineInfo: TGetLineInfo;
  OldLine, EmptyLine: Integer;
  Level, NewLevel: Integer;
  ApplyBefore: Boolean;
  CustomBarLevel: Integer;
  Line, Temp: Integer;
  UpdateAll: Boolean;
  FirstUpdate: Integer;
  Src, Dest: Integer;
  LNode: TTreeNode;
  LItem: TOutlineItem;
begin
  LList := TOutlineList.Create;
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
            if (not ApplyBefore) and (Integer(LineInfo.yLine) > 0) and (OldLine <> Integer(LineInfo.yLine) - 1) then
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
            LList.Add(TOutlineItem.Create(Line, Min(NewLevel, MaxDepth), Text));
            OldLine := Line;
          end;
        end;
      end
      else if CustomBarLevel > 0 then
      begin
        if CustomBarLevel <= FProp.ViewLevel then
          LList.Add(TOutlineItem.Create(LineInfo.yLine, Min(CustomBarLevel, MaxDepth), Text));
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
      for I := 0 to Min(FList.Count, LList.Count) - 1 do
      begin
        if FAbortThread then
          Exit;
        if FList[I].Level <> LList[I].Level then
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
            LNode := FList[I].Node.GetNext;
            if LNode = nil then
              Break;
            LNode.Delete;
          end;
          if FList[I].Node <> nil then
            FList[I].Node.Delete;
          Break;
        end;
      end;
    end;
    Src := 0;
    Dest := 0;
    for I := 0 to Min(FirstUpdate, LList.Count) - 1 do
    begin
      with FList[I] do
      begin
        LineNum := LList[I].LineNum;
        Level := LList[I].Level;
        LineStr := LList[I].LineStr;
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
        LNode := FList[Dest].Node.GetNext;
        if LNode = nil then
          Break;
        LNode.Delete;
      end;
      if FList[Dest].Node <> nil then
        FList[Dest].Node.Delete;
      for I := FList.Count - 1 downto Dest do
      begin
        LItem := FList[I];
        FList.Remove(LItem);
        LItem.Free;
      end;
    end;
    if InRange(Src, 0, LList.Count - 1) then
    begin
      for I := Src to LList.Count - 1 do
      begin
        if not UpdateAll then
          UpdateAll := True;
        with LList[I] do
        begin
          LItem := TOutlineItem.Create(LineNum, Level, LineStr);
          LItem.Node := Node;
        end;
        FList.Add(LItem);
      end;
    end;
    if FAbortThread then
      Exit;
    if UpdateAll then
      UpdateTreeViewAll
    else
      UpdateTreeViewString;
  finally
    LList.Free;
  end;
end;

procedure TMainForm.UpdateTreeViewSel;
var
  I: Integer;
  CurrentLine: Integer;
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

procedure TMainForm.TreeCopy(Node: TTreeNode);
begin
  if Node = nil then
    Node := TreeView.Selected;
  if Node <> nil then
    Clipboard.AsText := Node.Text;
end;

procedure TMainForm.TreeMove(Node: TTreeNode; Down: Boolean);
begin
  if WaitMessageLoop(1, FMutex, INFINITE) <> 0 then
    Exit;
  if Node = nil then
    Node := TreeView.Selected;
  if Node <> nil then
    TreeMoveSub(Node, Down);
  ReleaseMutex(FMutex);
end;

procedure TMainForm.SetFont;
var
  LName: array [0 .. 255] of Char;
  LSize: Integer;
  LFore, LBack: TColor;
begin
  Editor_Info(FEditor, MI_GET_FONT_NAME, LPARAM(@LName));
  LSize := Editor_Info(FEditor, MI_GET_FONT_SIZE, 0);
  LFore := TColor(Editor_Info(FEditor, MI_GET_TEXT_COLOR, COLOR_GENERAL));
  LBack := TColor(Editor_Info(FEditor, MI_GET_BACK_COLOR, COLOR_GENERAL));
  if Editor_Info(FEditor, MI_GET_INVERT_COLOR, 0) = 1 then
  begin
    LFore := GetInvertColor(LFore);
    LBack := GetInvertColor(LBack);
  end;
  with TreeView do
  begin
    with Font do
    begin
      Name := IfThen(FFontName <> '', FFontName, LName);
      Size := IfThen(FFontSize <> 0, FFontSize, LSize);
      Height := MulDiv(Height, Self.PixelsPerInch, 96);
      case FTextSize of
        tsLargest:
          Size := Round(Size * 1.5);
        tsLarger:
          Size := Round(Size * 1.25);
        tsSmaller:
          Size := Round(Size * 0.75);
        tsSmallest:
          Size := Round(Size * 0.5);
      end;
      Color := LFore;
    end;
    Color := LBack;
  end;
end;

procedure TMainForm.SetScale(const Value: Integer);
var
  P: Integer;
begin
  P := PixelsPerInch;
  PixelsPerInch := Value;
  with Font do
    Height := MulDiv(Height, Self.PixelsPerInch, P);
  SetFont;
end;

procedure TMainForm.UpdateTreeViewString;
var
  I: Integer;
  LNode: TTreeNode;
begin
  for I := 0 to FList.Count - 1 do
    if FList[I].Node <> nil then
    begin
      LNode := TreeView.Items.GetNode(FList[I].Node.ItemId);
      if LNode <> nil then
        LNode.Text := FList[I].LineStr;
    end;
  UpdateTreeViewSel;
end;

function TMainForm.SetProperties: Boolean;
var
  S, P: PChar;
  Len: Cardinal;
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
