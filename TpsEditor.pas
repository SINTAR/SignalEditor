unit TpsEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBSQL, IBDatabase, DB, DBLogDlg, StdCtrls, Grids, Base,
  IBCustomDataSet, IBQuery, Menus, fcTreeView, ComCtrls, ToolWin, ImgList, IniFiles,
  ExtCtrls;

type
  TTpsEditorForm = class(TForm)
    SGPropsTable: TStringGrid;
    cbbFieldTypeChange: TComboBox;
    cbbEmptyFieldChange: TComboBox;
    pmChangeValuesType: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    fctrvw1: TfcTreeView;
    tlb1: TToolBar;
    btnCreateNode: TToolButton;
    btnDelNode: TToolButton;
    il1: TImageList;
    btnAddProperty: TToolButton;
    btnDelProperty: TToolButton;
    btnSaveTable: TToolButton;
    btn1: TToolButton;
    btnAddFieldToArchive: TToolButton;
    btnDelFieldFromArchive: TToolButton;
    btnSelFieldFromArchive: TToolButton;
    tlb2: TToolBar;
    pnlTypes: TPanel;
    pnlFields: TPanel;
    spl1: TSplitter;
    btnSaveTypes: TToolButton;
    
    procedure SGPropsTableSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cbbFieldTypeChangeChange(Sender: TObject);
    procedure cbbEmptyFieldChangeChange(Sender: TObject);
    procedure SGPropsTableMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCreateNodeClick(Sender: TObject);
    procedure btnDelNodeClick(Sender: TObject);
    procedure fctrvw1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure fctrvw1DblClick(TreeView: TfcCustomTreeView;
      Node: TfcTreeNode; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure btnAddPropertyClick(Sender: TObject);
    procedure btnDelPropertyClick(Sender: TObject);
    procedure btnSaveTableClick(Sender: TObject);
    procedure SetColWidth(SG: TStringGrid);
    function CheckLength: Boolean;
    procedure btnSelFieldFromArchiveClick(Sender: TObject);
    procedure btnAddFieldToArchiveClick(Sender: TObject);
    procedure btnDelFieldFromArchiveClick(Sender: TObject);
    procedure SGPropsTableSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure btnSaveTypesClick(Sender: TObject);
    procedure fctrvw1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure fctrvw1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure N1Click(Sender: TObject);
    procedure SGPropsTableDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SGPropsTableEnter(Sender: TObject);

  private
    { Private declarations }
  public
    procedure DeleteRow (Grid: TStringGrid; IncRow: Integer);
  end;

  TMyGrid = class(TCustomGrid)

  end;

var
  TpsEditorForm: TTpsEditorForm;
  TableHeader,SignalValueTypes,FieldDataTypes: TStringList;
  PreviousIndex: integer;
  RowCheck,DeleteCheck,NodeCheck: Boolean;

implementation

uses TypeCreator,FieldValuesList,SelArchField,DelArchFields,Editor;

{$R *.dfm}


procedure TTpsEditorForm.DeleteRow(Grid: TStringGrid; IncRow: Integer);
begin
  if (Grid.Row = 0) or ((Grid.RowHeights[1] = 0) and
  (Grid.RowCount = 2))  then
    ShowMessage('Строка не выбрана!')
  else begin
    if (Grid.RowHeights[1] = SGPropsTable.DefaultRowHeight) and (Grid.RowCount = 2) then begin
      Grid.Rows[1].Clear;
      Grid.RowHeights[1] := 0;
    end
    else begin
      Grid.Rows[Grid.Row].Clear;
      SGPropsTable.Col := 2;
      Grid.Row := 1;
      TMyGrid(Grid).DeleteRow(IncRow);
    end;
  end;
end;

procedure TTpsEditorForm.SGPropsTableSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  R: TRect;
  i,buttonSelected: Integer;
  FieldsList: TStringList;
  CheckFieldExists: Boolean;
begin
  CheckFieldExists := True;
  SetColWidth(SGPropsTable);
  if not fctrvw1.Selected.HasChildren then
    SGPropsTable.Options := SGPropsTable.Options+[goEditing];
  btnAddFieldToArchive.Enabled := True;
  cbbFieldTypeChange.Visible := False;
  cbbEmptyFieldChange.Visible := False;
  if ((ACol = 4) and (ARow <> 0) and not DeleteCheck and not NodeCheck and not (fctrvw1.Selected.HasChildren)) then begin
    R := SGPropsTable.CellRect(ACol, ARow);
    R.Left := R.Left + SGPropsTable.Left;
    R.Right := R.Right + SGPropsTable.Left;
    R.Top := R.Top + SGPropsTable.Top;
    R.Bottom := R.Bottom + SGPropsTable.Top;
    cbbFieldTypeChange.Left := R.Left + 1;
    cbbFieldTypeChange.Top := R.Top + 1;
    cbbFieldTypeChange.Width := (R.Right + 1) - R.Left;
    cbbFieldTypeChange.Height := (R.Bottom + 1) - R.Top;
    cbbFieldTypeChange.Visible := True;
    cbbFieldTypeChange.SetFocus;
  end else
  if ACol =7 then
    for i:=0 to CurType.Props.Count-1 do
      CheckFieldExists := CheckFieldExists and (TSigField(CurType.Props[i]).Name <> SGPropsTable.Cells[2,ARow]);
  if ((not CheckFieldExists) or ((SGPropsTable.Cells[4,ARow] <> 'string') and (ACol=5))) then     //нельзя редактировать длину у нечисловых типов данных
    SGPropsTable.Options := SGPropsTable.Options-[goEditing];
  if ((ACol=7) and (ARow <>0) and not DeleteCheck and not NodeCheck and not (fctrvw1.Selected.HasChildren) and CheckFieldExists) then begin
    R := SGPropsTable.CellRect(ACol, ARow);
    R.Left := R.Left + SGPropsTable.Left;
    R.Right := R.Right + SGPropsTable.Left;
    R.Top := R.Top + SGPropsTable.Top;
    R.Bottom := R.Bottom + SGPropsTable.Top;
    cbbEmptyFieldChange.Left := R.Left + 1;
    cbbEmptyFieldChange.Top := R.Top + 1;
    cbbEmptyFieldChange.Width := (R.Right + 1) - R.Left;
    cbbEmptyFieldChange.Height := (R.Bottom + 1) - R.Top;
    cbbEmptyFieldChange.Visible := True;
    cbbEmptyFieldChange.SetFocus;
  end;
  CanSelect := True;
  if ((ARow <> SGPropsTable.Row) and (DeleteCheck = False) and (NodeCheck = False) and not(fctrvw1.Selected.HasChildren) and (TypeEditor.GetFieldList.Count>0)) then begin
    if not CheckLength then begin
      if ((SGPropsTable.Row > 0) and not((SGPropsTable.Row > CurType.Props.Count) and (CurType.CheckFieldExists(SGPropsTable.Cells[2,SGPropsTable.Row])))) then
        TypeEditor.CheckFieldInUniqList(SGPropsTable.Cells[2,SGPropsTable.Row]);
      if ((SGPropsTable.Row > CurType.Props.Count) and (CurType.CheckFieldExists(SGPropsTable.Cells[2,SGPropsTable.Row]))) then begin
        MessageDlg('Поле с таким именем уже существует!',mtWarning,[mbOK],0);
        btnDelPropertyClick(Sender);
      end
      else begin
        if TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).SigType = nil then
          TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).SaveNewField(TypeEditor.GetFieldList)
        else begin
          TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Number := StrToInt(SGPropsTable.Cells[0,SGPropsTable.Row]);
          TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Name := SGPropsTable.Cells[2,SGPropsTable.Row];
          TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Header := SGPropsTable.Cells[3,SGPropsTable.Row];
          TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).FieldType := SGPropsTable.Cells[4,SGPropsTable.Row];
          TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Length := StrToInt(SGPropsTable.Cells[5,SGPropsTable.Row]);
          if ((SGPropsTable.Cells[6,SGPropsTable.Row] <> '') and (SGPropsTable.Cells[6,SGPropsTable.Row] <> '(...)')) then begin
            if not Assigned(CreateValuesList) then
              CreateValuesList := TStringList.Create;
            CreateValuesList.Clear;
            CreateValuesList.Add(SGPropsTable.Cells[6,SGPropsTable.Row]);
            TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Values.Assign(CreateValuesList);
          end;
          TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Empty := SGPropsTable.Cells[7,SGPropsTable.Row] <> 'Не пусто';
        end;
      end;
      if not Assigned(CreateValuesList) then
        CreateValuesList := TStringList.Create;
      if CurType.Props.Count >= ARow then
        CreateValuesList.Assign(TSigField(CurType.Props[ARow-1]).Values) //необходимо для того, чтобы на входе в новое поле CreateValuesList получал значение Values выбираемого типа.
      else
        CreateValuesList.Clear;
    end;
  end;
  if ((SGPropsTable.Row = -1) and (CurType.Children.Count=0)) then begin
    if not Assigned(CreateValuesList) then
      CreateValuesList := TStringList.Create;
    CreateValuesList.Assign(TSigField(CurType.Props[ARow-1]).Values); //если выбрана первая строка при входе в тип
  end;
  RowCheck := True;
end;

procedure TTpsEditorForm.cbbFieldTypeChangeChange(Sender: TObject);
begin
 {Перебросим выбранное в значение из ComboBox в grid}
  if SGPropsTable.Col =4 then begin
    SGPropsTable.Cells[SGPropsTable.Col, SGPropsTable.Row] := cbbFieldTypeChange.Items[cbbFieldTypeChange.ItemIndex];
    if cbbFieldTypeChange.Text = 'float' then
      SGPropsTable.Cells[5,SGPropsTable.Row] := '8';
    if cbbFieldTypeChange.Text = 'int' then
      SGPropsTable.Cells[5,SGPropsTable.Row] := '4';
    if cbbFieldTypeChange.Text = 'string' then
      SGPropsTable.Cells[5,SGPropsTable.Row] := '20';
    cbbFieldTypeChange.Visible := False;
    cbbFieldTypeChange.ClearSelection;
    CheckFields := True;
    SGPropsTable.SetFocus;
  end;
end;

procedure TTpsEditorForm.cbbEmptyFieldChangeChange(Sender: TObject);
begin
  if SGPropsTable.Col = 7 then begin
    SGPropsTable.Cells[SGPropsTable.Col, SGPropsTable.Row] := cbbEmptyFieldChange.Items[cbbEmptyFieldChange.ItemIndex];
    cbbEmptyFieldChange.Visible := False;
    cbbEmptyFieldChange.ClearSelection;
    CheckFields := True;
    SGPropsTable.SetFocus;
  end;
end;

procedure TTpsEditorForm.SGPropsTableMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if DeleteCheck = False then
    GetCursorPos(P);
  if ((Button = mbLeft) and (SGPropsTable.Col= 6) and not (fctrvw1.Selected.HasChildren)) then
    pmChangeValuesType.Popup(P.X,P.Y);
end;

procedure TTpsEditorForm.N2Click(Sender: TObject);
begin
  FieldValuesListForm.ShowModal;
end;

procedure TTpsEditorForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  TypeEditor.SaveFields;
  TypeEditor.SaveTypes;
  TableHeader.Free;
  SignalValueTypes.Free;
  FieldDataTypes.Free;
  FreeAndNil(CreateValuesList);
end;

procedure TTpsEditorForm.btnCreateNodeClick(Sender: TObject);
begin
  CurType := TSigType(fctrvw1.Selected.Data);
  if CurType.Props.Count =0 then begin
    if TpsEditorForm.fctrvw1.Selected.Data <> nil then
      CurType := TSigType.CreateNew('Тип'+IntToStr(fctrvw1.Items.Count),'','',TpsEditorForm.fctrvw1.Selected.Data)
    else
      CurType := TSigType.CreateNew('Тип'+IntToStr(fctrvw1.Items.Count),'','',nil);
    TypeEditor.Types.Add(CurType);
    fctrvw1.Items.AddChildObject(fctrvw1.Selected,CurType.Name,CurType);
    CurType.TreeNode := fctrvw1.Items.FindNode(CurType.Name,False);
    fctrvw1.Selected.Expand(True); {раскрытие текущей вершины}
    with EditorForm.ibsqlTypes do begin
      SQL.Text := 'INSERT INTO SIGTYPE(TYPENAME,PARENT) VALUES (:TypeName,:Parent)';
      Prepare;
      Params[0].AsString := 'Тип'+IntToStr(fctrvw1.Items.Count-1);
      if Assigned(TSigType(fctrvw1.Selected.Data)) then
        Params[1].AsString := TSigType(fctrvw1.Selected.Data).Name
      else
        Params[1].AsString := 'Base';
      ExecQuery;
    end;
    CheckTypes := True;
    btnSaveTypes.Enabled := True;
  end else
    MessageDlg('Листовой тип не может иметь потомков!', mtWarning, [mbOk], 0);
end;


procedure TTpsEditorForm.btnDelNodeClick(Sender: TObject);
var
  buttonSelected,i: integer;
  DelCheck: Boolean;
begin
  buttonSelected := MessageDlg('Выбран тип '+fctrvw1.Selected.Text+' Удаление типа приведёт к удалению и всех его детей.'
  +'Вы уверены, что хотите продолжить?',mtWarning,mbOKCancel,0);
  if buttonSelected = mrOk then begin
    CurType.Delete;
    CurType.DeleteChildren;
    DelCheck := False;
    for i:=0 to CurType.Parent.Children.Count-1 do begin
      if DelCheck then
        Break;
      DelCheck := TSigType(CurType.Parent.Children[i]).Name = CurType.Name;
      if DelCheck then
      CurType.Parent.Children.Delete(i);
    end;
    CurType.Free;
    fctrvw1.Selected.Delete;
    for i:=1 to SGPropsTable.RowCount-1 do
      SGPropsTable.Rows[i].Clear;
    SGPropsTable.RowCount := 2;
    CheckTypes := True;
    btnSaveTypes.Enabled := True;
    fctrvw1.AutoExpand := True;
  end;
end;


procedure TTpsEditorForm.fctrvw1Click(Sender: TObject);
var
  i: integer;
  myRect: TGridRect;
begin
  NodeCheck := True;
  TypeEditor.SaveFields;
  SGPropsTable.RowHeights[1] := SGPropsTable.DefaultRowHeight;
  btnAddFieldToArchive.Enabled := False;
  btnAddProperty.Enabled := True;
  btnDelProperty.Enabled := True;
  btnSelFieldFromArchive.Enabled := True;
  cbbFieldTypeChange.Visible := False;
  cbbEmptyFieldChange.Visible := False;
  SGPropsTable.Options := SGPropsTable.Options+[goEditing];
  for i:=1 to SGPropsTable.RowCount-1 do
    SGPropsTable.Rows[i].Clear;
  SGPropsTable.RowCount := 2;
  if fctrvw1.Selected.Data <> nil then
    CurType := TSigType(fctrvw1.Selected.Data);
  CurType.ShowFields;
  with myRect do begin
    Left := 2;
    Top := 1;
    Right := 2;
    Bottom := 1;
  end;
  SGPropsTable.Selection := myRect;
  if (fctrvw1.Selected.HasChildren) or (fctrvw1.Selected.Text = 'Все типы') then begin
    btnAddProperty.Enabled := False;
    btnDelProperty.Enabled := False;
    btnSelFieldFromArchive.Enabled := False;
    btnAddFieldToArchive.Enabled := False;
    SGPropsTable.Options := SGPropsTable.Options-[goEditing];
    with myRect do begin
      Left := -1;
      Top := -1;
      Right := -1;
      Bottom := -1;
    end;
    SGPropsTable.Selection := myRect;
  end;
  if Assigned(CreateValuesList) then begin
    if SGPropsTable.Row = 1 then
      if CurType.Props.Count > 0 then
        CreateValuesList := TSigField(CurType.Props[0]).Values
      else
        CreateValuesList.Clear;
  end;
  SetColWidth(SGPropsTable);
  if ((SGPropsTable.RowCount = 2) and (SGPropsTable.Cells[2,1] = ''))  then
    SGPropsTable.RowHeights[1] := 0;
  NodeCheck := False;
end;

procedure TTpsEditorForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  TypeEditor := TTypeEditor.Create;
  TypeEditor.DBReconnect;
  TypeEditor.Load;
  TypeEditor.LoadArchive;
  TSigType(TypeEditor.Types[0]).Load;
  TypeEditor.LoadUniqFields;
  TableHeader := TStringList.Create;
  SignalValueTypes := TStringList.Create;
  FieldDataTypes := TStringList.Create;
  TableHeader.CommaText := '№,"Тип сигнала","Имя поля",Заголовок,Тип,Длина,Значение(я),"Не пусто"';
  SignalValueTypes.CommaText := 'bool,byte,float,int,smallint,word';
  FieldDataTypes.CommaText := 'int,float,string';
  PreviousIndex := -1;
  SGPropsTable.Rows[0].CommaText := TableHeader.CommaText;
  SGPropsTable.DefaultRowHeight := cbbFieldTypeChange.Height;
  cbbFieldTypeChange.Visible := False;
  cbbFieldTypeChange.Items := FieldDataTypes;
  cbbEmptyFieldChange.Visible := False;
  cbbEmptyFieldChange.Items.Add('Не пусто');
  cbbEmptyFieldChange.Items.Add('-');
  CurType := TSigType(TypeEditor.Types[0]);
  fctrvw1.Items.Clear;
  fctrvw1.Items.AddObject(fctrvw1.Selected,'Все типы',TSigType(TypeEditor.Types[0]));
  fctrvw1.AutoExpand:= True;
  TSigType(TypeEditor.Types[0]).TreeNode := fctrvw1.Items.FindNode('Все типы',False);
  TSigType(TypeEditor.Types[0]).ShowChildren(fctrvw1);
  SetColWidth(SGPropsTable);
  for i:=1 to SGPropsTable.RowCount-1 do
    SGPropsTable.Rows[i].Clear;
  fctrvw1.Selected := TSigType(TypeEditor.Types[0]).TreeNode;
  SGPropsTable.RowCount :=2;
  if SGPropsTable.RowCount = 2 then
    SGPropsTable.RowHeights[1] := 0;
  fctrvw1Click(Sender);
  SGPropsTable.Visible := False; //без этого вылазит белая полоса( FormShow -> редактируем значение -> Confirm -> открываем форму по новой
  SGPropsTable.Visible := True; //она пропадает даже после Alt+Tab. Причину выяснить не удалось. 15.07.2016г.
  btnSaveTable.Enabled := False;
  btnSaveTypes.Enabled := False;
end;

procedure TTpsEditorForm.fctrvw1DblClick(TreeView: TfcCustomTreeView;
  Node: TfcTreeNode; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if TSigType(fctrvw1.Selected.Data).Parent <> nil then
    TypeCreateForm.ShowModal;
end;

procedure TTpsEditorForm.btnAddPropertyClick;
var
  i,buttonSelected:Integer;
  CheckRow: Boolean;
begin
  CheckRow := False;
  if CurType.CheckTypeNameEncoding then
    MessageDlg('Название листового типа не может содержать кириллицу!',mtWarning,[mbOK],0)
  else begin
    if SGPropsTable.Cells[2,1] <> '' then
      for i:=1 to SGPropsTable.ColCount-3 do begin
        if SGPropsTable.Cells[i,SGPropsTable.RowCount-1] = '' then
          CheckRow := True;
      end;
    if CheckRow = False then begin
      if ((CurType.Props.Count = 0) and (SGPropsTable.RowHeights[1]=0)) then
        buttonSelected := MessageDlg('Добавление полей к выбранному типу не позволит ему иметь детей. Вы уверены, что хотите продолжить?',mtWarning, mbOKCancel,0);
      if ((buttonSelected = mrOk) or (CurType.Props.Count >0)) then begin
        if not CurType.CheckTableExist then
          CurType.AddTable;
        if SGPropsTable.Cells[2,1] <> '' then
          SGPropsTable.RowCount := SGPropsTable.RowCount+1
        else
          SGPropsTable.RowHeights[1] := 18;
        SGPropsTable.Rows[SGPropsTable.RowCount-1].Clear;
        SGPropsTable.Cells[0,SGPropsTable.RowCount-1] := IntToStr(SGPropsTable.RowCount-1);
        SGPropsTable.Cells[1,SGPropsTable.RowCount-1] := fctrvw1.Selected.Text;
        {for i:=0 to CurType.Props.Count-1 do
          SGPropsTable.Objects[0,i+1] := TSigField(CurType.Props[i]);}
        SGPropsTable.Objects[0,SGPropsTable.RowCount-1] := TSigField.CreateNew;
        btnSaveTable.Enabled := True;
        CheckFields := True;
      end;
    end else if not CheckSender then
      MessageDlg('Заполните предыдущее поле!',mtWarning,[mbOK],0)
  end;
end;


procedure TTpsEditorForm.btnDelPropertyClick(Sender: TObject);
var
  i: Integer;
begin
  DeleteCheck := True;
  if TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]) <>  nil then
    TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Delete;
  SGPropsTable.Rows[SGPropsTable.Row].Clear;
  if SGPropsTable.RowCount = 2 then
    SGPropsTable.RowHeights[1] := 0
  else
    DeleteRow(SGPropsTable,SGPropsTable.Row);
  for i:=1 to SGPropsTable.RowCount-1 do
    SGPropsTable.Cells[0,i] := IntToStr(i);
  CreateValuesList.Assign(TSigField(SGPropsTable.Objects[0,1]).Values);
  btnSaveTable.Enabled := True;
  DeleteCheck := False;
end;

procedure TTpsEditorForm.btnSaveTableClick(Sender: TObject);
var
  i,Row:integer;
begin
  if ((SGPropsTable.Row > 0) and not((SGPropsTable.Row > CurType.Props.Count) and (CurType.CheckFieldExists(SGPropsTable.Cells[2,SGPropsTable.Row])))) then
    TypeEditor.CheckFieldInUniqList(SGPropsTable.Cells[2,SGPropsTable.Row]);
  if ((SGPropsTable.Row > CurType.Props.Count) and (CurType.CheckFieldExists(SGPropsTable.Cells[2,SGPropsTable.Row]))) then begin
    MessageDlg('Поле с таким именем уже существует!',mtWarning,[mbOK],0);
    btnDelPropertyClick(Sender);
  end
  else begin
  if SGPropsTable.Row > 0 then
    if ((TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).SigType = nil) and (TypeEditor.GetFieldList.Count > 0)) then
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).SaveNewField(TypeEditor.GetFieldList)
    else if ((not CheckLength) and (CurType.Props.Count = SGPropsTable.RowCount-1)) then begin
      if SGPropsTable.Row < 1 then
        Row := SGPropsTable.RowCount-1
      else
        Row := SGPropsTable.Row;
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Number := StrToInt(SGPropsTable.Cells[0,Row]);
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Name := SGPropsTable.Cells[2,Row];
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Header := SGPropsTable.Cells[3,Row];
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).FieldType := SGPropsTable.Cells[4,Row];
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Length := StrToInt(SGPropsTable.Cells[5,Row]);
      if ((SGPropsTable.Cells[6,Row] <> '') and (SGPropsTable.Cells[6,Row] <> '(...)')) then begin  //если одиночное значение, то делаем это. Неодиночное сохраняется в FieldValuesList
        if not Assigned(CreateValuesList) then
          CreateValuesList := TStringList.Create;
        CreateValuesList.Clear;
       for i:=0 to Length(SGPropsTable.Cells[6,Row]) do
          if SGPropsTable.Cells[6,Row][i] in ['А'..'я','Ё','ё','A'..'z',',','.','0'..'9'] then
            CreateValuesList.Add(SGPropsTable.Cells[6,Row]);
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Values := CreateValuesList;
      end;
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Empty := SGPropsTable.Cells[7,Row] <> 'Не пусто';
    end;
  end;
  CheckFields := False;
  btnSaveTable.Enabled := False;
  EditorForm.ibtrnsctn1.CommitRetaining;
end;

procedure TTpsEditorForm.SetColWidth(SG: TStringGrid);
var
  i,j,width: Integer;
begin
  for i:=0 to SG.ColCount-1 do begin
    width :=0;
    for j:=0 to SG.RowCount-1 do begin
      if SG.Canvas.TextWidth(SG.Cells [i,j]) +10 > width then begin
        width := SG.Canvas.TextWidth(SG.Cells [i,j])+20;
        SG.ColWidths[i] := width;
      end;
    end;
  end;
end;

function TTpsEditorForm.CheckLength: Boolean;
var
  Check: Boolean;
begin
  CheckLength := False;
  Check := False;
  if SGPropsTable.Row > 0 then begin
    Check := System.Length(SGPropsTable.Cells[2,SGPropsTable.Row]) > TypeEditor.GetFieldLength('NAME');
    if Check then begin
      MessageDlg('Значение в поле Имя не может быть длинее ' +IntToStr(TypeEditor.GetFieldLength('NAME'))+'-ти символов!',mtWarning,[mbOK],0);
      SGPropsTable.Cells[2,SGPropsTable.Row] := TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Name;
      SetColWidth(SGPropsTable);
      CheckLength := True;
    end;
    Check := System.Length(SGPropsTable.Cells[3,SGPropsTable.Row]) > TypeEditor.GetFieldLength('CAPTION');
    if Check then begin
      MessageDlg('Значение в поле Заголовок не может быть длинее ' +IntToStr(TypeEditor.GetFieldLength('CAPTION'))+'-ти символов!',mtWarning,[mbOK],0);
      SGPropsTable.Cells[3,SGPropsTable.Row] := TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Header;
      SetColWidth(SGPropsTable);
      CheckLength := True;
    end;
  end;
end;

procedure TTpsEditorForm.btnSelFieldFromArchiveClick(Sender: TObject);
begin
  SelArrchFieldForm.ShowModal;
end;

procedure TTpsEditorForm.btnAddFieldToArchiveClick(Sender: TObject);
var
  i,buttonSelected,ArchFieldNumber: integer;
  CheckField: Boolean;
begin
  CheckField := False;
  if ((TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]) = nil) or (SGPropsTable.Cells[2,SGPropsTable.Row] = '')) then
    MessageDlg('Поле не выбрано!',mtInformation,[mbOK],0)
  else begin
    if ((TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Name = 'NAME') or (TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Name = 'INFO')) then begin
      MessageDlg('Поле '+TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Name+' не может быть добавлено в архив!',mtInformation,[mbOK],0);
      Exit;
    end;
    for i:=0 to TypeEditor.FieldsArchive.Count-1 do begin
      if TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Name = TSigField(TypeEditor.FieldsArchive[i]).Name then begin
        CheckField := True;
        ArchFieldNumber := i;
      end;
    end;
    if not CheckField then begin
      TypeEditor.FieldsArchive.Add(TSigField.CreateNewArchiveField(TSigField(SGPropsTable.Objects[0,SGPropsTable.Row])));
      TSigField(TypeEditor.FieldsArchive[TypeEditor.FieldsArchive.Count-1]).AddToArchive;
    end
    else begin
      buttonSelected := MessageDlg('Поле '+TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Name+' уже есть в архиве! Хотите заменить?',mtInformation,mbOKCancel,0);
      if buttonSelected = mrOk then
        TSigField(TypeEditor.FieldsArchive[ArchFieldNumber]).Assign(TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]),ArchFieldNumber);
    end;
  end;
end;

procedure TTpsEditorForm.btnDelFieldFromArchiveClick(Sender: TObject);
begin
  delArchFieldsForm.ShowModal;
end;

procedure TTpsEditorForm.SGPropsTableSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
begin
  btnSaveTable.Enabled := True;
  CheckFields := True;
end;

procedure TTpsEditorForm.btnSaveTypesClick(Sender: TObject);
begin
  EditorForm.ibtrnsctn1.CommitRetaining;
  btnSaveTypes.Enabled := False;
  CheckTypes := False;
end;

procedure TTpsEditorForm.fctrvw1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  Target: TSigType;
begin
  Accept := False;
  if (Source = fctrvw1) and (Sender = fctrvw1) then begin
    if fctrvw1.DropTarget = nil then
      Exit;
    Target := TSigType(fctrvw1.DropTarget.Data);
    if (CurType = nil) or (Target = nil) then
      Exit;
    Accept := (Target.Props.Count = 0);
    if CurType.AllowMoveDrop(Target) then
      fctrvw1.DragCursor := crDrag;
  end;
end;

procedure TTpsEditorForm.fctrvw1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  TSigType(fctrvw1.Selected.Data).Parent := TSigType(fctrvw1.DropTarget.Data);
  CheckTypes := True;
  btnSaveTypes.Enabled := True;
end;

procedure TTpsEditorForm.N1Click(Sender: TObject);
begin
  if SGPropsTable.Cells[6,SGPropsTable.Row] ='(...)' then begin
    SGPropsTable.Cells[6,SGPropsTable.Row] := '';
    if Assigned(TSigField(SGPropsTable.Objects[0,SGPropsTable.Row])) then
      TSigField(SGPropsTable.Objects[0,SGPropsTable.Row]).Values.Clear
    else
      CreateValuesList := TStringList.Create;
  end else if ((SGPropsTable.Cells[6,SGPropsTable.Row] = '') or (not Assigned(CreateValuesList))) then
    CreateValuesList := TStringList.Create;
end;

procedure TTpsEditorForm.SGPropsTableDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  s: string; //текст в ячейке
begin
  with Sender as TStringGrid do begin
    s:=cells[acol,arow]; //сохраняем текст из ячейки
    Rect.Left := Rect.Left+3; //чтобы текст не сильно жался к левому краю
    canvas.FillRect (rect);
    //перерисовываем ячейку, здесь же можно изменить цвет
    DrawText(canvas.handle,pchar(s),-1,Rect,DT_SINGLELINE OR DT_VCENTER );
      //например ВЕРТИКАЛЬНО_ПО_ЦЕНТРУ + ГОРИЗОНТАЛЬНО_ПО_ЦЕНТРУ(OR DT_CENTER)
  end;
end;



procedure TTpsEditorForm.SGPropsTableEnter(Sender: TObject);
begin
  SetColWidth(SGPropsTable);
end;

end.
