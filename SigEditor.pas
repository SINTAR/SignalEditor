unit SigEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBSQL, IBDatabase, DB, DBLogDlg, StdCtrls, Grids, Base,
  IBCustomDataSet, IBQuery, Menus, fcTreeView, ComCtrls, ToolWin, ImgList, IniFiles,
  ExtCtrls, fcCombo, fctreecombo;

type
  TSigEditorForm = class(TForm)
    pnlSelectType: TPanel;
    pnlSigEditor: TPanel;
    spl1: TSplitter;
    TVSigTypes: TfcTreeView;
    tlbSigEditor: TToolBar;
    SGSigTable: TStringGrid;
    btnAddSignal: TToolButton;
    btnDelSignal: TToolButton;
    SGSigPropsTable: TStringGrid;
    pnlProps: TPanel;
    spl2: TSplitter;
    lblSignalsCount: TLabel;
    lblPropsCount: TLabel;
    cbbTypeSelect: TComboBox;
    btnSaveTable: TToolButton;
    cbbPropsChange: TComboBox;
    cbbPropsTablePropsChange: TComboBox;
    fcTreeValsCmb: TfcTreeCombo;
    fcTreeValsCmbPropsTable: TfcTreeCombo;
    procedure FormCreate(Sender: TObject);
    procedure TVSigTypesClick(Sender: TObject);
    procedure SGSigTableDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure SGSigTableSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cbbTypeSelectChange(Sender: TObject);
    procedure btnAddSignalClick(Sender: TObject);
    procedure SGSigTableSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure btnSaveTableClick(Sender: TObject);
    procedure SGSigPropsTableSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure btnDelSignalClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TVSigTypesChange(TreeView: TfcCustomTreeView;
      Node: TfcTreeNode);
    procedure SGSigPropsTableSetEditText(Sender: TObject; ACol,
      ARow: Integer; const Value: String);
    procedure cbbPropsChangeChange(Sender: TObject);
    procedure cbbPropsTablePropsChangeChange(Sender: TObject);
    procedure SGSigPropsTableEnter(Sender: TObject);
    procedure SGSigTableEnter(Sender: TObject);
    procedure fcTreeValsCmbChange(Sender: TObject);
    procedure fcTreeValsCmbPropsTableChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SigEditorForm: TSigEditorForm;
  TableHeader,DeleteList: TStringList; //список полей и список для удаления, которые заполняются в TSigType.ShowSignalFields
  SigDeleteCheck,SigNodeCheck,FormShowCheck: boolean; //чтобы не вызывало лишнего в onSelectCell при удалении


implementation

uses TpsEditor,Editor;

{$R *.dfm}

procedure TSigEditorForm.FormCreate(Sender: TObject);
begin
  PreviousIndex := -1;
  SigDeleteCheck := False;
  SigNodeCheck := False;
end;

procedure TSigEditorForm.TVSigTypesClick(Sender: TObject);
var
  i,FillStartCol,CheckCol: integer;
  myRect: TGridRect;
begin
  SigNodeCheck := True;
  pnlProps.Visible := False;
  cbbTypeSelect.Visible := False;
  cbbPropsChange.Visible := False;
  fcTreeValsCmb.Visible := False;
  btnDelSignal.Enabled := False;
  if CheckSignals then begin
    if SGSigTable.Cells[1,0] = 'Имя типа' then
      CheckCol := 2
    else
      CheckCol := 1;
    if ((TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SignalExists(SGSigTable.Cells[CheckCol,SGSigTable.Row]) and (SGSigTable.Row = SGSigTable.RowCount-1)) and (TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigType.Signals.Count < SGSigTable.RowCount-1)) then begin
      MessageDlg('Сигнал с таким именем уже существует!',mtWarning,[mbOK],0);
      btnDelSignalClick(Sender);
    end
    else begin
      if CurType.NotEmptyListCheck then
        MessageDlg('Заполните необходимые поля!',mtWarning,[mbOK],0)
      else if TSignal(SGSigTable.Objects[0,SGSigTable.Row])<> nil then begin
        if TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigID = 0 then
          TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SaveNewSignal
        else begin
          TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Name := TypeEditor.GetCurName;
          TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Info := TypeEditor.GetCurInfo;
          TSignal(SGSigTable.Objects[0,SGSigTable.Row]).FIelds := TypeEditor.GetCurSignalFields;
        end;
      end;
      TypeEditor.SaveSignals;
    end;
  end;
  for i:=0 to SGSigTable.RowCount-1 do
    SGSigTable.Rows[i].Clear;
  SGSigTable.RowCount := 2;
  SGSigTable.RowHeights[1] := 0;
  SGSigPropsTable.RowHeights[1] := 0;
  SGSigTable.Cells[0,0] := '№';
  TableHeader := TStringList.Create;
  DeleteList := TStringList.Create;
  if CurType.Children.Count > 0 then begin
    SGSigTable.ColCount := 3;
    SGSigTable.ColWidths[2] := 0;
    FillStartCol := 2;
    CurType.ShowSigTableFields(FillStartCol);
    for i:=0 to DeleteList.Count-1 do
      TableHeader.Delete(TableHeader.IndexOf(DeleteList[i]));
    SGSigTable.ColCount := TableHeader.Count+2;
    for i:=0 to TableHeader.Count-1 do
      SGSigTable.Cells[i+2,0] := TableHeader[i];
    SGSigTable.Cells[1,0] := 'Имя типа';
  end else begin
    SGSigTable.ColCount := 2;
    SGSigTable.ColWidths[1] := 0;
    FillStartCol := 1;
    CurType.ShowSigTableFields(FillStartCol);
    for i:=0 to DeleteList.Count-1 do
      TableHeader.Delete(TableHeader.IndexOf(DeleteList[i]));
    if TableHeader.Count > 0 then
      SGSigTable.ColCount := TableHeader.Count+1;
    for i:=0 to TableHeader.Count-1 do
      SGSigTable.Cells[i+1,0] := TableHeader[i];
  end;
  CurType.ShowSignals(FillStartCol);
  if SGSigTable.RowHeights[1] > 0 then
    lblSignalsCount.Caption := 'Сигналы: '+IntToStr(SGSigTable.RowCount-1)
  else
    lblSignalsCount.Caption := 'Сигналы: 0';
  if SGSigPropsTable.RowHeights[1] > 0 then
    lblPropsCount.Caption := 'Свойства: '+IntToStr(SGSigPropsTable.RowCount-1)
  else
    lblPropsCount.Caption := 'Свойства: 0';
  TpsEditorForm.SetColWidth(SGSigTable);
  TpsEditorForm.SetColWidth(SGSigPropsTable);
  if TVSigTypes.Selected.HasChildren then begin
    with myRect do begin
      Left := 2;
      Top := 1;
      Right := 2;
      Bottom := 1;
    end;
  end else begin
    with myRect do begin
      Left := 1;
      Top := 1;
      Right := 1;
      Bottom := 1;
    end;
  end;
  SGSigTable.Selection := myRect;
  SigNodeCheck := False;
end;

procedure TSigEditorForm.SGSigTableDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  s: string; //текст в ячейке
begin
  with Sender as TStringGrid do begin
    s := ' ' + Cells[acol,arow]; //' ' для того, чтобы текст не сильно прижимался к левому краю
    if ((Cells[1,0] = 'Имя типа') and (ACol=1)) then
      Canvas.Brush.Color := clBtnFace;
    canvas.FillRect (rect);
    if ((ACol=0) or ((Cells[1,0] = 'Имя типа') and (ACol=1)) or (ARow=0)) then
      Canvas.Font.Style := [fsBold];
    //перерисовываем ячейку, здесь же можно изменить цвет
    DrawText(canvas.handle,pchar(s),-1,Rect,DT_SINGLELINE OR DT_VCENTER );
    //например ВЕРТИКАЛЬНО_ПО_ЦЕНТРУ + ГОРИЗОНТАЛЬНО_ПО_ЦЕНТРУ(OR DT_CENTER)
  end;
end;

procedure TSigEditorForm.FormShow(Sender: TObject);
var
  PropsTableHeader: TStringList;
  i: integer;
begin
  FormShowCheck := True;
  if TypeEditor <> nil then
    TypeEditor.Free;
  TypeEditor := TTypeEditor.Create;
  TypeEditor.Load;
  TypeEditor.LoadArchive;
  TSigType(TypeEditor.Types[0]).Load;
  TypeEditor.LoadUniqFields;
  TVSigTypes.Items.Clear;
  TVSigTypes.Items.AddObject(TVSigTypes.Selected,'Все типы',TSigType(TypeEditor.Types[0]));
  //TVSigTypes.Selected := TVSigTypes.Items.FindNode('Все типы',False);
  TSigType(TypeEditor.Types[0]).TreeNode := TVSigTypes.Items.FindNode('Все типы',False);
  TSigType(TypeEditor.Types[0]).ShowChildren(TVSigTypes);
  SGSigTable.RowHeights[1] := 0;
  for i:=0 to SGSigTable.RowCount-1 do
    SGSigTable.Rows[i].Clear;
  SGSigTable.RowCount := 2;
   for i:=0 to TypeEditor.Types.Count-1 do
    if TSigType(TypeEditor.Types[i]).CheckTableExist then
      TSigType(TypeEditor.Types[i]).LoadSignals;
  SGSigTable.ColCount := 3;
  SGSigTable.ColWidths[2] := 0;
  TableHeader := TStringList.Create;
  DeleteList := TStringList.Create;
  TSigType(TypeEditor.Types[0]).ShowSigTableFields(2);
  for i:=0 to DeleteList.Count-1 do
    TableHeader.Delete(TableHeader.IndexOf(DeleteList[i]));
  SGSigTable.ColCount := TableHeader.Count+2;
  for i:=0 to TableHeader.Count-1 do
    SGSigTable.Cells[i+2,0] := TableHeader[i];
  SGSigTable.Cells[1,0] := 'Имя типа';
  TSigType(TypeEditor.Types[0]).ShowSignals(2);
  PropsTableHeader := TStringList.Create;
  PropsTableHeader.CommaText := 'Свойство,Значение';
  SGSigPropsTable.Rows[0].CommaText := PropsTableHeader.CommaText;
  SGSigTable.Cells[0,0] := '№';
  TpsEditorForm.SetColWidth(SGSigTable);
  TpsEditorForm.SetColWidth(SGSigPropsTable);
  if SGSigTable.RowCount > 2 then
    lblSignalsCount.Caption := 'Сигналы:' +IntToStr(SGSigTable.RowCount-1)
  else
    lblSignalsCount.Caption := 'Сигналы:0';
  if SGSigPropsTable.RowCount > 2 then
    lblPropsCount.Caption := 'Свойства:' +IntToStr(SGSigPropsTable.RowCount-1)
  else
    lblPropsCount.Caption := 'Свойства:0';
  if SGSigTable.Objects[0,1] <>  nil then begin
    TypeEditor.GetCurTypeForSignals(1).ShowSigPropsTableFields;
    TypeEditor.GetCurTypeForSignals(1).ShowSigPropsTableSignals(1);
  end;
  SGSigTable.Visible := False; //без этого вылазит белая полоса( FormShow -> редактируем значение -> Confirm -> открываем форму по новой
  SGSigTable.Visible := True; //она пропадает даже после Alt+Tab. Причину выяснить не удалось. 15.07.2016г.
  CheckSignals := False;
  DeleteCheck := False;
  FormShowCheck := False;
end;

procedure TSigEditorForm.SGSigTableSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  R: TRect;
  i,j,CheckCol: integer;
begin
  pnlProps.Visible := False;
  cbbTypeSelect.Visible := False;
  cbbPropsChange.Visible := False;
  fcTreeValsCmb.Visible := False;
  btnDelSignal.Enabled := True;
  TpsEditorForm.SetColWidth(SGSigTable);
  TpsEditorForm.SetColWidth(SGSigPropsTable);
  SGSigTable.Options := SGSigTable.Options+[goEditing];
  if ((SGSigTable.Cells[1,0] = 'Имя типа') and (ACol=1)) then
    SGSigTable.Options := SGSigTable.Options-[goEditing];
  if ((SGSigTable.Cells[0,ARow] <> '') and (TVSigTypes.Selected.HasChildren)) then
    if ((ACol=1) and (TSignal(SGSigTable.Objects[0,ARow]).SigType = nil)) then begin //тип возможно менять только для сигналов, которые еще даже не внесены в объектную модель, а не только в БД.
      cbbTypeSelect.Items.Clear;
      CurType.cbbSelectTypeFill;                                                     //Потому как, даже если сигнал существует только в объектной модели, то у него уже есть сформированный список Fields, значения в котором изменять проблематично и нецелесообразно
      R := SGSigTable.CellRect(ACol, ARow);
      R.Left := R.Left + SGSigTable.Left;
      R.Right := R.Right + SGSigTable.Left;
      R.Top := R.Top + SGSigTable.Top;
      R.Bottom := R.Bottom + SGSigTable.Top;
      cbbTypeSelect.Left := R.Left + 1;
      cbbTypeSelect.Top := R.Top + 1;
      cbbTypeSelect.Width := (R.Right + 1) - R.Left;
      cbbTypeSelect.Height := (R.Bottom + 1) - R.Top;
      cbbTypeSelect.Visible := True;
      cbbTypeSelect.SetFocus;
    end;
  if ((not SigDeleteCheck) and (not SigNodeCheck) and (not FormShowCheck)) then
    if TSignal(SGSigTable.Objects[0,ARow]).SigType <> nil then begin
      with TSignal(SGSigTable.Objects[0,ARow]) do begin
        for i:=0 to SigType.Props.Count-1 do
          if ((TSigField(SigType.Props[i]).Header = SGSigTable.Cells[ACol,0]) and (TSigField(SigType.Props[i]).Values.Count > 0)) then begin
            if not TSigField(SigType.Props[i]).IsTree then begin
              cbbPropsChange.Items.Clear;
              for j:=0 to TSigField(SigType.Props[i]).Values.Count-1 do
                cbbPropsChange.Items.Add(TSigField(SigType.Props[i]).Values[j]);
              SGSigTable.Options := SGSigTable.Options-[goEditing];
              R := SGSigTable.CellRect(ACol, ARow);
              R.Left := R.Left + SGSigTable.Left;
              R.Right := R.Right + SGSigTable.Left;
              R.Top := R.Top + SGSigTable.Top;
              R.Bottom := R.Bottom + SGSigTable.Top;
              cbbPropsChange.Left := R.Left + 1;
              cbbPropsChange.Top := R.Top + 1;
              cbbPropsChange.Width := (R.Right + 1) - R.Left;
              cbbPropsChange.Height := (R.Bottom + 1) - R.Top;
              cbbPropsChange.Visible := True;
              cbbPropsChange.SetFocus;
            end
            else begin
              fcTreeValsCmb.Items.Clear;
              TSigField(SigType.Props[i]).FillTreeValsCmb(fcTreeValsCmb);
              SGSigTable.Options := SGSigTable.Options-[goEditing];
              R := SGSigTable.CellRect(ACol, ARow);
              R.Left := R.Left + SGSigTable.Left;
              R.Right := R.Right + SGSigTable.Left;
              R.Top := R.Top + SGSigTable.Top;
              R.Bottom := R.Bottom + SGSigTable.Top;
              fcTreeValsCmb.Left := R.Left + 1;
              fcTreeValsCmb.Top := R.Top + 1;
              fcTreeValsCmb.Width := (R.Right + 1) - R.Left;
              fcTreeValsCmb.Height := (R.Bottom + 1) - R.Top;
              fcTreeValsCmb.Visible := True;
              fcTreeValsCmb.SetFocus;
            end;
          end;
      end;
    end;
  if not FormShowCheck then
    if ((TVSigTypes.Selected.HasChildren) and (SGSigTable.Cells[1,SGSigTable.Row]='') and (ACol > 1) and (not SigDeleteCheck) and (not SigNodeCheck)) then begin
      MessageDlg('Задайте тип',mtWarning,[mbOK],0);
      Exit;
    end;
  if not FormShowCheck then
    if ((SGSigTable.Row <> ARow) and (not SigDeleteCheck) and (not SigNodeCheck)) then begin
      if SGSigTable.Cells[1,0] = 'Имя типа' then
        CheckCol := 2
      else
        CheckCol := 1;
      if ((TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SignalExists(SGSigTable.Cells[CheckCol,SGSigTable.Row]) and (SGSigTable.Row = SGSigTable.RowCount-1))and (TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigType.Signals.Count < SGSigTable.RowCount-1)) then begin
        MessageDlg('Сигнал с таким именем уже существует!',mtWarning,[mbOK],0);
        btnDelSignalClick(Sender);
      end
      else begin
        if ((TypeEditor.GetCurTypeForSignals(SGSigTable.Row).NotEmptyListCheck) and (SGSigTable.RowHeights[1] > 0)) then
          MessageDlg('Заполните необходимые поля!',mtWarning,[mbOK],0)
        else begin
          if TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigID = 0 then
            TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SaveNewSignal
          else begin
            TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Name := TypeEditor.GetCurName;
            TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Info := TypeEditor.GetCurInfo;
            TSignal(SGSigTable.Objects[0,SGSigTable.Row]).FIelds := TypeEditor.GetCurSignalFields;
          end;
        end;
      end;
      for i:=0 to SGSigPropsTable.RowCount-1 do
        SGSigPropsTable.Rows[i].Clear;
      SGSigPropsTable.RowCount := 2;
    end;
  if ((SGSigTable.Cells[1,0] = 'Имя типа') and (SGSigTable.Cells[1,ARow] <> '')) then begin //этот кусок выводит вновь выбранный сигнал и его поля. Поэтому должен проводится под конец
    TypeEditor.GetCurTypeForSignals(ARow).ShowSigPropsTableFields;
    TypeEditor.GetCurTypeForSignals(ARow).ShowSigPropsTableSignals(ARow);
  end;
end;

procedure TSigEditorForm.cbbTypeSelectChange(Sender: TObject);
begin
  if SGSigTable.Col = 1 then begin
    SGSigTable.Cells[SGSigTable.Col, SGSigTable.Row] := cbbTypeSelect.Items[cbbTypeSelect.ItemIndex];
    TypeEditor.GetCurTypeForSignals(SGSigTable.Row).ShowSigPropsTableFields;
    TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigType := TypeEditor.GetCurTypeForSignals(SGSigTable.Row);
    cbbTypeSelect.Visible := False;
    cbbTypeSelect.ClearSelection;
    SGSigTable.SetFocus;
  end;
end;

procedure TSigEditorForm.btnAddSignalClick(Sender: TObject);
begin
  with SGSigTable do begin
    if RowHeights[1] > 0 then
      if ((TypeEditor.GetCurTypeForSignals(Row) = nil) or CurType.NotEmptyListCheck) then
        MessageDlg('Заполните обязательные поля!',mtWarning,[mbOK],0)
      else begin
        RowCount := RowCount+1;
        Cells[0,RowCount-1] := IntToStr(RowCount-1);
        Objects[0,RowCount-1] := TSignal.CreateNew;
        if Cells[1,0] <> 'Имя типа' then
          TSignal(Objects[0,RowCount-1]).SigType := CurType;
      end
    else begin
      RowHeights[1] := DefaultRowHeight;
      Cells[0,RowCount-1] := IntToStr(RowCount-1);
      SGSigTable.Objects[0,RowCount-1] := TSignal.CreateNew;
      if Cells[1,0] <> 'Имя типа' then
          TSignal(Objects[0,RowCount-1]).SigType := CurType;
    end;
    lblSignalsCount.Caption := 'Сигналы:' +IntToStr(RowCount-1);
  end;
end;

procedure TSigEditorForm.SGSigTableSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
begin
  CheckSignals := True;
  btnSaveTable.Enabled := True;
end;

procedure TSigEditorForm.btnSaveTableClick(Sender: TObject);
var
  CheckCol: integer;
begin
  TypeEditor.GetCurTypeForSignals(SGSigTable.Row);
  if SGSigTable.Cells[1,0] = 'Имя типа' then
    CheckCol := 2
  else
    CheckCol := 1;
  if ((TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SignalExists(SGSigTable.Cells[CheckCol,SGSigTable.Row]) and (SGSigTable.Row = SGSigTable.RowCount-1) and (TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigType.Signals.Count < SGSigTable.RowCount-1))) then begin
    MessageDlg('Сигнал с таким именем уже существует!',mtWarning,[mbOK],0);
    SigEditorForm.btnDelSignalClick(Sender);
  end
  else begin
    if ((CurType.NotEmptyListCheck) and (SGSigTable.RowHeights[1] > 0)) then
      MessageDlg('Заполните необходимые поля!',mtWarning,[mbOK],0)
    else begin
      if TSignal(SGSigTable.Objects[0,SGSigTable.Row]) <> nil then
        if TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigID = 0 then
          TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SaveNewSignal
        else begin
          TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Name := TypeEditor.GetCurName;
          TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Info := TypeEditor.GetCurInfo;
          TSignal(SGSigTable.Objects[0,SGSigTable.Row]).FIelds := TypeEditor.GetCurSignalFields;
        end;
    end;
  end;
  btnSaveTable.Enabled := False;
  CheckSignals := False;
  EditorForm.ibtrnsctn1.CommitRetaining;
end;

procedure TSigEditorForm.SGSigPropsTableSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
  var
    R: TRect;
    i,j: integer;
begin
  SGSigPropsTable.Options := SGSigPropsTable.Options+[goEditing];
  TpsEditorForm.SetColWidth(SGSigTable);
  TpsEditorForm.SetColWidth(SGSigPropsTable);
  if TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigType <> nil then begin
    with TSignal(SGSigTable.Objects[0,SGSigTable.Row]) do begin
      for i:=0 to SigType.Props.Count-1 do
        if ((TSigField(SigType.Props[i]).Header = SGSigPropsTable.Cells[0,ARow]) and (TSigField(SigType.Props[i]).Values.Count > 0)) then begin
          if not TSigField(SigType.Props[i]).IsTree then begin
            cbbPropsTablePropsChange.Items.Clear;
            for j:=0 to TSigField(SigType.Props[i]).Values.Count-1 do
              cbbPropsTablePropsChange.Items.Add(TSigField(SigType.Props[i]).Values[j]);
            SGSigPropsTable.Options := SGSigPropsTable.Options-[goEditing];
            R := SGSigPropsTable.CellRect(ACol, ARow);
            R.Left := R.Left + SGSigPropsTable.Left;
            R.Right := R.Right + SGSigPropsTable.Left;
            R.Top := R.Top + SGSigPropsTable.Top;
            R.Bottom := R.Bottom + SGSigPropsTable.Top;
            cbbPropsTablePropsChange.Left := R.Left + 1;
            cbbPropsTablePropsChange.Top := R.Top + 1;
            cbbPropsTablePropsChange.Width := (R.Right + 1) - R.Left;
            cbbPropsTablePropsChange.Height := (R.Bottom + 1) - R.Top;
            cbbPropsTablePropsChange.Visible := True;
            cbbPropsTablePropsChange.SetFocus;
          end
          else begin
            fcTreeValsCmbPropsTable.Items.Clear;
            TSigField(SigType.Props[i]).FillTreeValsCmb(fcTreeValsCmbPropsTable);
            SGSigPropsTable.Options := SGSigPropsTable.Options-[goEditing];
            R := SGSigPropsTable.CellRect(ACol, ARow);
            R.Left := R.Left + SGSigPropsTable.Left;
            R.Right := R.Right + SGSigPropsTable.Left;
            R.Top := R.Top + SGSigPropsTable.Top;
            R.Bottom := R.Bottom + SGSigPropsTable.Top;
            fcTreeValsCmbPropsTable.Left := R.Left + 1;
            fcTreeValsCmbPropsTable.Top := R.Top + 1;
            fcTreeValsCmbPropsTable.Width := (R.Right + 1) - R.Left;
            fcTreeValsCmbPropsTable.Height := (R.Bottom + 1) - R.Top;
            fcTreeValsCmbPropsTable.Visible := True;
            fcTreeValsCmbPropsTable.SetFocus;
          end;
        end;
    end;
  end;
  btnDelSignal.Enabled := True;
end;

procedure TSigEditorForm.btnDelSignalClick(Sender: TObject);
var
  i: integer;
begin
  SigDeleteCheck := True;
  TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Delete;
  SGSigTable.Rows[SGSigTable.Row].Clear;
  if SGSigTable.RowCount = 2 then begin
    SGSigTable.RowHeights[1] := 0;
    for i:=1 to SGSigPropsTable.RowCount-1 do
      SGSigPropsTable.Rows[i].Clear;
    SGSigPropsTable.RowCount := 2;
    SGSigPropsTable.RowHeights[1] := 0;
    btnDelSignal.Enabled := False;
  end
  else
    TpsEditorForm.DeleteRow(SGSigTable,SGSigTable.Row);
  for i:=1 to SGSigTable.RowCount-1 do
    SGSigTable.Cells[0,i] := IntToStr(i);
  if SGSigTable.RowHeights[1] = 0 then
    lblSignalsCount.Caption := 'Сигналы: 0'
  else
    lblSignalsCount.Caption := 'Сигналы:' +IntToStr(SGSigTable.RowCount-1);
  CheckSignals := True;
  SigDeleteCheck := False;
end;

procedure TSigEditorForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if CheckSignals then begin
    if TypeEditor.GetCurTypeForSignals(SGSigTable.Row).NotEmptyListCheck then
      MessageDlg('Заполните необходимые поля!',mtWarning,[mbOK],0)
    else begin
      if TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SigType = nil then
        TSignal(SGSigTable.Objects[0,SGSigTable.Row]).SaveNewSignal
      else begin
        TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Name := TypeEditor.GetCurName;
        TSignal(SGSigTable.Objects[0,SGSigTable.Row]).Info := TypeEditor.GetCurInfo;
        TSignal(SGSigTable.Objects[0,SGSigTable.Row]).FIelds := TypeEditor.GetCurSignalFields;
      end;
      TypeEditor.SaveSignals;
    end;

  end;
end;

procedure TSigEditorForm.TVSigTypesChange(TreeView: TfcCustomTreeView;
  Node: TfcTreeNode);
begin
  if TVSigTypes.Selected.Data <> nil then
    CurType := TSigType(TVSigTypes.Selected.Data);
end;

procedure TSigEditorForm.SGSigPropsTableSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
begin
  btnSaveTable.Enabled := True;
  CheckSignals := True;
end;

procedure TSigEditorForm.cbbPropsChangeChange(Sender: TObject);
begin
  SGSigTable.Cells[SGSigTable.Col, SGSigTable.Row] := cbbPropsChange.Items[cbbPropsChange.ItemIndex];
  cbbPropsChange.Visible := False;
  cbbPropsChange.ClearSelection;
  SGSigTable.SetFocus;
  CheckSignals := True;
end;

procedure TSigEditorForm.cbbPropsTablePropsChangeChange(Sender: TObject);
begin
  SGSigPropsTable.Cells[SGSigPropsTable.Col, SGSigPropsTable.Row] := cbbPropsTablePropsChange.Items[cbbPropsTablePropsChange.ItemIndex];
  cbbPropsTablePropsChange.Visible := False;
  cbbPropsTablePropsChange.ClearSelection;
  SGSigPropsTable.SetFocus;
end;

procedure TSigEditorForm.SGSigPropsTableEnter(Sender: TObject);
begin
  TpsEditorForm.SetColWidth(SGSigTable);
  TpsEditorForm.SetColWidth(SGSigPropsTable);
end;



procedure TSigEditorForm.SGSigTableEnter(Sender: TObject);
begin
  TpsEditorForm.SetColWidth(SGSigTable);
  TpsEditorForm.SetColWidth(SGSigPropsTable);
end;


procedure TSigEditorForm.fcTreeValsCmbChange(Sender: TObject);
var
  i: Integer;
begin
  if not fcTreeValsCmb.SelectedNode.HasChildren then begin
    SGSigTable.Cells[SGSigTable.Col, SGSigTable.Row] := fcTreeValsCmb.SelectedNode.Text;
    fcTreeValsCmb.Visible := False;
    fcTreeValsCmb.ClearSelection;
    SGSigTable.SetFocus;
    CheckSignals := True;
  end;
end;

procedure TSigEditorForm.fcTreeValsCmbPropsTableChange(Sender: TObject);
begin
  if not fcTreeValsCmbPropsTable.SelectedNode.HasChildren then begin
    SGSigPropsTable.Cells[SGSigPropsTable.Col, SGSigPropsTable.Row] := fcTreeValsCmbPropsTable.SelectedNode.Text;
    fcTreeValsCmbPropsTable.Visible := False;
    fcTreeValsCmbPropsTable.ClearSelection;
    SGSigPropsTable.SetFocus;
    CheckSignals := True;
  end;
end;

end.
