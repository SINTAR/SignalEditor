object SigEditorForm: TSigEditorForm
  Left = 500
  Top = 154
  Width = 1032
  Height = 771
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1089#1080#1075#1085#1072#1083#1086#1074
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 129
    Top = 0
    Height = 732
  end
  object spl2: TSplitter
    Left = 737
    Top = 0
    Width = 1
    Height = 732
  end
  object pnlSelectType: TPanel
    Left = 0
    Top = 0
    Width = 129
    Height = 732
    Align = alLeft
    TabOrder = 0
    object TVSigTypes: TfcTreeView
      Left = 1
      Top = 1
      Width = 127
      Height = 730
      Align = alClient
      AutoExpand = True
      Indent = 19
      MultiSelectAttributes.AutoUnselect = False
      Options = [tvoExpandOnDblClk, tvoExpandButtons3D, tvoShowButtons, tvoShowLines, tvoShowRoot, tvoToolTips]
      Items.StreamVersion = 1
      Items.Data = {00000000}
      TabOrder = 0
      OnChange = TVSigTypesChange
      OnClick = TVSigTypesClick
    end
  end
  object pnlSigEditor: TPanel
    Left = 132
    Top = 0
    Width = 605
    Height = 732
    Align = alLeft
    TabOrder = 1
    object lblSignalsCount: TLabel
      Left = 160
      Top = 32
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object tlbSigEditor: TToolBar
      Left = 1
      Top = 1
      Width = 603
      Height = 24
      AutoSize = True
      Caption = 'tlbSigEditor'
      Flat = True
      Images = TpsEditorForm.il1
      TabOrder = 0
      object btnAddSignal: TToolButton
        Left = 0
        Top = 0
        Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1080#1075#1085#1072#1083
        Caption = 'btnAddSignal'
        ImageIndex = 0
        ParentShowHint = False
        ShowHint = True
        OnClick = btnAddSignalClick
      end
      object btnDelSignal: TToolButton
        Left = 23
        Top = 0
        Hint = #1059#1076#1072#1083#1080#1090#1100' '#1089#1080#1075#1085#1072#1083
        Caption = 'btnDelSignal'
        Enabled = False
        ImageIndex = 1
        ParentShowHint = False
        ShowHint = True
        OnClick = btnDelSignalClick
      end
      object btnSaveTable: TToolButton
        Left = 46
        Top = 0
        Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1090#1072#1073#1083#1080#1094#1091
        Enabled = False
        ImageIndex = 2
        ParentShowHint = False
        ShowHint = True
        OnClick = btnSaveTableClick
      end
    end
    object SGSigTable: TStringGrid
      Left = 1
      Top = 70
      Width = 603
      Height = 661
      Align = alBottom
      ColCount = 2
      RowCount = 2
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnDrawCell = SGSigTableDrawCell
      OnEnter = SGSigTableEnter
      OnSelectCell = SGSigTableSelectCell
      OnSetEditText = SGSigTableSetEditText
      ColWidths = (
        64
        64)
    end
    object cbbTypeSelect: TComboBox
      Left = 192
      Top = 376
      Width = 145
      Height = 26
      Style = csOwnerDrawFixed
      ItemHeight = 20
      TabOrder = 2
      Visible = False
      OnChange = cbbTypeSelectChange
    end
    object cbbPropsChange: TComboBox
      Left = 72
      Top = 312
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 3
      Visible = False
      OnChange = cbbPropsChangeChange
    end
    object fcTreeValsCmb: TfcTreeCombo
      Left = 240
      Top = 264
      Width = 121
      Height = 21
      ButtonStyle = cbsDownArrow
      DropDownCount = 8
      Items.StreamVersion = 1
      Items.Data = {00000000}
      Options = []
      ReadOnly = False
      ShowMatchText = True
      Sorted = False
      Style = csDropDown
      TabOrder = 4
      TreeOptions = [tvoExpandButtons3D, tvoHideSelection, tvoShowButtons, tvoShowLines, tvoShowRoot, tvoToolTips]
      Visible = False
      OnChange = fcTreeValsCmbChange
    end
  end
  object pnlProps: TPanel
    Left = 738
    Top = 0
    Width = 278
    Height = 732
    Align = alClient
    Caption = 'pnlProps'
    TabOrder = 2
    Visible = False
    object lblPropsCount: TLabel
      Left = 80
      Top = 40
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object SGSigPropsTable: TStringGrid
      Left = 1
      Top = 70
      Width = 276
      Height = 661
      Align = alBottom
      ColCount = 2
      DefaultColWidth = 100
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      TabOrder = 0
      OnEnter = SGSigPropsTableEnter
      OnSelectCell = SGSigPropsTableSelectCell
      OnSetEditText = SGSigPropsTableSetEditText
      ColWidths = (
        100
        168)
    end
    object cbbPropsTablePropsChange: TComboBox
      Left = 146
      Top = 296
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Visible = False
      OnChange = cbbPropsTablePropsChangeChange
    end
    object fcTreeValsCmbPropsTable: TfcTreeCombo
      Left = 80
      Top = 344
      Width = 121
      Height = 21
      ButtonStyle = cbsDownArrow
      DropDownCount = 8
      Items.StreamVersion = 1
      Items.Data = {00000000}
      Options = [icoExpanded]
      ReadOnly = False
      ShowMatchText = True
      Sorted = False
      Style = csDropDown
      TabOrder = 2
      TreeOptions = [tvoExpandButtons3D, tvoHideSelection, tvoShowButtons, tvoShowLines, tvoShowRoot, tvoToolTips]
      Visible = False
      OnChange = fcTreeValsCmbPropsTableChange
    end
  end
end
