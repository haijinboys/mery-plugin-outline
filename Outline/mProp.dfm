object PropForm: TPropForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #12450#12454#12488#12521#12452#12531
  ClientHeight = 297
  ClientWidth = 449
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
  object BarPosLabel: TLabel
    Left = 8
    Top = 8
    Width = 72
    Height = 13
    Caption = #12496#12540#12398#20301#32622'(&P):'
    FocusControl = BarPosComboBox
  end
  object IndentTypeLabel: TLabel
    Left = 8
    Top = 104
    Width = 44
    Height = 13
    Caption = #12479#12452#12503'(&T):'
    FocusControl = IndentTypeComboBox
  end
  object LevelLabel1: TLabel
    Left = 152
    Top = 28
    Width = 10
    Height = 13
    Caption = '&1:'
    FocusControl = MatchEdit1
  end
  object LevelLabel2: TLabel
    Left = 152
    Top = 52
    Width = 10
    Height = 13
    Caption = '&2:'
    FocusControl = MatchEdit2
  end
  object LevelLabel3: TLabel
    Left = 152
    Top = 76
    Width = 10
    Height = 13
    Caption = '&3:'
    FocusControl = MatchEdit3
  end
  object LevelLabel4: TLabel
    Left = 152
    Top = 100
    Width = 10
    Height = 13
    Caption = '&4:'
    FocusControl = MatchEdit4
  end
  object LevelLabel5: TLabel
    Left = 152
    Top = 124
    Width = 10
    Height = 13
    Caption = '&5:'
    FocusControl = MatchEdit5
  end
  object LevelLabel6: TLabel
    Left = 152
    Top = 148
    Width = 10
    Height = 13
    Caption = '&6:'
    FocusControl = MatchEdit6
  end
  object LevelLabel7: TLabel
    Left = 152
    Top = 172
    Width = 10
    Height = 13
    Caption = '&7:'
    FocusControl = MatchEdit7
  end
  object LevelLabel8: TLabel
    Left = 152
    Top = 196
    Width = 10
    Height = 13
    Caption = '&8:'
    FocusControl = MatchEdit8
  end
  object ViewLevelLabel: TLabel
    Left = 8
    Top = 152
    Width = 72
    Height = 13
    Caption = #26368#22823#12524#12505#12523'(&A):'
    FocusControl = ViewLevelComboBox
  end
  object DefaultLevelLabel: TLabel
    Left = 8
    Top = 200
    Width = 72
    Height = 13
    Caption = #26082#23450#12524#12505#12523'(&D):'
    FocusControl = DefaultLevelComboBox
  end
  object ModeLabel: TLabel
    Left = 8
    Top = 56
    Width = 72
    Height = 13
    Caption = #32232#38598#12514#12540#12489'(&M):'
    FocusControl = ModeComboBox
  end
  object Bevel: TBevel
    Left = 0
    Top = 256
    Width = 449
    Height = 9
    Shape = bsTopLine
  end
  object MatchLabel: TLabel
    Left = 168
    Top = 8
    Width = 76
    Height = 13
    Caption = #26908#32034'/'#27491#35215#34920#29694
  end
  object ReplaceLabel: TLabel
    Left = 320
    Top = 8
    Width = 24
    Height = 13
    Caption = #32622#25563
  end
  object BarPosComboBox: TComboBox
    Left = 8
    Top = 24
    Width = 129
    Height = 21
    Style = csDropDownList
    TabOrder = 0
    Items.Strings = (
      #24038
      #19978
      #21491
      #19979)
  end
  object IndentTypeComboBox: TComboBox
    Left = 8
    Top = 120
    Width = 129
    Height = 21
    Style = csDropDownList
    TabOrder = 2
    OnChange = IndentTypeComboBoxChange
    Items.Strings = (
      #31354#30333#12398#25968
      #25324#24359' { } '#12398#25968
      #25324#24359' [ ] '#12398#25968
      #12459#12473#12479#12512
      #12459#12473#12479#12512' ('#38283#22987#12392#32066#20102')')
  end
  object MatchEdit1: TEdit
    Left = 168
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 5
  end
  object RegExCheckBox1: TCheckBox
    Left = 296
    Top = 24
    Width = 17
    Height = 17
    TabOrder = 6
  end
  object MatchEdit2: TEdit
    Left = 168
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 8
  end
  object RegExCheckBox2: TCheckBox
    Left = 296
    Top = 48
    Width = 17
    Height = 17
    TabOrder = 9
  end
  object MatchEdit3: TEdit
    Left = 168
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 11
  end
  object RegExCheckBox3: TCheckBox
    Left = 296
    Top = 72
    Width = 17
    Height = 17
    TabOrder = 12
  end
  object MatchEdit4: TEdit
    Left = 168
    Top = 96
    Width = 121
    Height = 21
    TabOrder = 14
  end
  object RegExCheckBox4: TCheckBox
    Left = 296
    Top = 96
    Width = 17
    Height = 17
    TabOrder = 15
  end
  object MatchEdit5: TEdit
    Left = 168
    Top = 120
    Width = 121
    Height = 21
    TabOrder = 17
  end
  object RegExCheckBox5: TCheckBox
    Left = 296
    Top = 120
    Width = 17
    Height = 17
    TabOrder = 18
  end
  object MatchEdit6: TEdit
    Left = 168
    Top = 144
    Width = 121
    Height = 21
    TabOrder = 20
  end
  object RegExCheckBox6: TCheckBox
    Left = 296
    Top = 144
    Width = 17
    Height = 17
    TabOrder = 21
  end
  object MatchEdit7: TEdit
    Left = 168
    Top = 168
    Width = 121
    Height = 21
    TabOrder = 23
  end
  object RegExCheckBox7: TCheckBox
    Left = 296
    Top = 168
    Width = 17
    Height = 17
    TabOrder = 24
  end
  object MatchEdit8: TEdit
    Left = 168
    Top = 192
    Width = 121
    Height = 21
    TabOrder = 26
  end
  object RegExCheckBox8: TCheckBox
    Left = 296
    Top = 192
    Width = 17
    Height = 17
    TabOrder = 27
  end
  object OKButton: TButton
    Left = 272
    Top = 264
    Width = 81
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 30
  end
  object CancelButton: TButton
    Left = 360
    Top = 264
    Width = 81
    Height = 25
    Cancel = True
    Caption = #12461#12515#12531#12475#12523
    ModalResult = 2
    TabOrder = 31
  end
  object ViewLevelComboBox: TComboBox
    Left = 8
    Top = 168
    Width = 129
    Height = 21
    Style = csDropDownList
    TabOrder = 3
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8')
  end
  object DefaultLevelComboBox: TComboBox
    Left = 8
    Top = 216
    Width = 129
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    Items.Strings = (
      #12377#12409#12390#32302#23567
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      #12377#12409#12390#23637#38283)
  end
  object ModeComboBox: TComboBox
    Left = 8
    Top = 72
    Width = 129
    Height = 21
    Style = csDropDownList
    DropDownCount = 32
    TabOrder = 1
    OnChange = ModeComboBoxChange
  end
  object ResetButton: TButton
    Left = 360
    Top = 224
    Width = 81
    Height = 25
    Caption = #12522#12475#12483#12488'(&R)'
    TabOrder = 29
    OnClick = ResetButtonClick
  end
  object ReplaceEdit1: TEdit
    Left = 320
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 7
  end
  object ReplaceEdit2: TEdit
    Left = 320
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 10
  end
  object ReplaceEdit3: TEdit
    Left = 320
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 13
  end
  object ReplaceEdit4: TEdit
    Left = 320
    Top = 96
    Width = 121
    Height = 21
    TabOrder = 16
  end
  object ReplaceEdit5: TEdit
    Left = 320
    Top = 120
    Width = 121
    Height = 21
    TabOrder = 19
  end
  object ReplaceEdit6: TEdit
    Left = 320
    Top = 144
    Width = 121
    Height = 21
    TabOrder = 22
  end
  object ReplaceEdit7: TEdit
    Left = 320
    Top = 168
    Width = 121
    Height = 21
    TabOrder = 25
  end
  object ReplaceEdit8: TEdit
    Left = 320
    Top = 192
    Width = 121
    Height = 21
    TabOrder = 28
  end
end
