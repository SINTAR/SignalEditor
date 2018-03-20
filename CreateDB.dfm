object CreateDBForm: TCreateDBForm
  Left = 194
  Top = 117
  Width = 294
  Height = 411
  Caption = #1057#1086#1079#1076#1072#1090#1100
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
  object lblBDName: TLabel
    Left = 8
    Top = 16
    Width = 91
    Height = 13
    Caption = #1048#1084#1103' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
  end
  object lblParentFolder: TLabel
    Left = 8
    Top = 48
    Width = 105
    Height = 13
    Caption = #1056#1086#1076#1080#1090#1077#1083#1100#1089#1082#1072#1103' '#1087#1072#1087#1082#1072
  end
  object pnlFolderTree: TPanel
    Left = 0
    Top = 64
    Width = 278
    Height = 249
    Caption = 'pnlFolderTree'
    TabOrder = 0
    object tvSelectPath: TShellTreeView
      Left = 1
      Top = 1
      Width = 276
      Height = 247
      ObjectTypes = [otFolders]
      Root = 'rfDesktop'
      UseShellImages = True
      Align = alClient
      AutoRefresh = False
      HideSelection = False
      Indent = 19
      ParentColor = False
      RightClickSelect = True
      ShowRoot = False
      TabOrder = 0
    end
  end
  object btnCreate: TButton
    Left = 48
    Top = 328
    Width = 75
    Height = 25
    Caption = #1054#1082
    TabOrder = 1
    OnClick = btnCreateClick
  end
  object btnCancel: TButton
    Left = 144
    Top = 328
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object edtBDName: TEdit
    Left = 112
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 3
  end
end
