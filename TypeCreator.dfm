object TypeCreateForm: TTypeCreateForm
  Left = 288
  Top = 295
  Width = 310
  Height = 285
  Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1090#1080#1087#1072' '#1089#1080#1075#1085#1072#1083#1086#1074
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 16
    Top = 64
    Width = 98
    Height = 13
    Caption = #1048#1084#1103' '#1090#1080#1087#1072' '#1089#1080#1075#1085#1072#1083#1086#1074
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lbl2: TLabel
    Left = 11
    Top = 96
    Width = 103
    Height = 13
    Caption = #1058#1080#1087' '#1076#1072#1085#1085#1099#1093' '#1089#1080#1075#1085#1072#1083#1072
  end
  object lbl3: TLabel
    Left = 18
    Top = 128
    Width = 96
    Height = 13
    Caption = #1058#1080#1087' '#1087#1086#1083#1103' '#1079#1085#1072#1095#1077#1085#1080#1103
  end
  object lbl4: TLabel
    Left = 8
    Top = 16
    Width = 3
    Height = 13
  end
  object lbl5: TLabel
    Left = 46
    Top = 160
    Width = 68
    Height = 13
    Caption = #1058#1080#1087' '#1074#1077#1088#1096#1080#1085#1099
  end
  object edtTypeName: TEdit
    Left = 128
    Top = 56
    Width = 145
    Height = 21
    TabOrder = 0
  end
  object btnEditType: TButton
    Left = 32
    Top = 200
    Width = 75
    Height = 25
    Caption = 'O'#1082
    TabOrder = 1
    OnClick = btnEditTypeClick
  end
  object btnCancel: TButton
    Left = 184
    Top = 200
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object edtSignalDataType: TEdit
    Left = 128
    Top = 88
    Width = 145
    Height = 21
    TabOrder = 3
  end
  object cbbSignalValueType: TComboBox
    Left = 128
    Top = 120
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
  end
  object cbbNodeTypeChange: TComboBox
    Left = 128
    Top = 152
    Width = 145
    Height = 21
    Hint = 
      #1051#1080#1089#1090#1086#1074#1086#1081' '#1090#1080#1087' '#1085#1077' '#1084#1086#1078#1077#1090' '#1080#1084#1077#1090#1100' '#1087#1086#1090#1086#1084#1082#1086#1074';'#13#10#1053#1077#1083#1080#1089#1090#1086#1074#1086#1081' '#1090#1080#1087' '#1085#1077' '#1084#1086#1078#1077#1090' '#1080 +
      #1084#1077#1090#1100' '#1087#1086#1083#1077#1081
    Style = csDropDownList
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    Items.Strings = (
      #1051#1080#1089#1090#1086#1074#1086#1081
      #1053#1077#1083#1080#1089#1090#1086#1074#1086#1081)
  end
end
