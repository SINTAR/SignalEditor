object SelArrchFieldForm: TSelArrchFieldForm
  Left = 534
  Top = 338
  Width = 323
  Height = 131
  Caption = #1042#1099#1073#1086#1088' '#1087#1086#1083#1103' '#1080#1079' '#1072#1088#1093#1080#1074#1072
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
    Left = 24
    Top = 32
    Width = 49
    Height = 13
    Caption = #1048#1084#1103' '#1087#1086#1083#1103
  end
  object cbbSelArchField: TComboBox
    Left = 88
    Top = 24
    Width = 209
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbbSelArchFieldChange
  end
  object btnOk: TButton
    Left = 139
    Top = 56
    Width = 75
    Height = 25
    Caption = #1054#1050
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 222
    Top = 56
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
