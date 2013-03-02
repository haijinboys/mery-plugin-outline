object MainForm: TMainForm
  Left = 0
  Top = 0
  ActiveControl = TreeView
  BorderStyle = bsNone
  Caption = 'MainForm'
  ClientHeight = 338
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TreeView: TTreeView
    Left = 0
    Top = 0
    Width = 651
    Height = 338
    Align = alClient
    HideSelection = False
    Indent = 19
    PopupMenu = PopupMenu
    ReadOnly = True
    RightClickSelect = True
    TabOrder = 0
    OnClick = TreeViewClick
    OnDblClick = TreeViewDblClick
    OnKeyUp = TreeViewKeyUp
    OnMouseDown = TreeViewMouseDown
  end
  object PopupMenu: TPopupMenu
    AutoHotkeys = maManual
    Left = 8
    Top = 8
    object GoMenuItem: TMenuItem
      Caption = #31227#21205'(&G)'
      OnClick = GoMenuItemClick
    end
    object SelectMenuItem: TMenuItem
      Caption = #36984#25246'(&S)'
      OnClick = SelectMenuItemClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object CollapseAllMenuItem: TMenuItem
      Caption = #12377#12409#12390#32302#23567'(&C)'
      OnClick = CollapseAllMenuItemClick
    end
    object ExpandAllMenuItem: TMenuItem
      Caption = #12377#12409#12390#23637#38283'(&E)'
      OnClick = ExpandAllMenuItemClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object PropPopupMenuItem: TMenuItem
      Caption = #12503#12525#12497#12486#12451'(&P)'
      OnClick = PropPopupMenuItemClick
    end
  end
end
