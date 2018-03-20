unit Base;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBSQL, IBDatabase, DB, DBLogDlg, Grids, StdCtrls, IBCustomDataSet, IBQuery, Menus, fcTreeView, ComCtrls, ToolWin, ImgList, IniFiles,
  ExtCtrls, fcCombo, fctreecombo, fcColorCombo;
type
  TSigType = class (TObject)
  private
    FName: string; {имя типа}
    FDataType: string;
    FValFldType: string;
    FParent: TSigType;
    FTreeNode: TfcTreeNode;
    procedure SetDataType (DataTypeValue: string);
    procedure SetValFldType (ValFldTypeValue: string);
    procedure SetName (NameValue: string);
    procedure SetTreeNode (TreeNodeValue: TfcTreeNode);
    procedure SetParent(ParentValue: TSigType);
  public
    Props: TList; {набор свойств типа}
    Children: TList; {набор "детей" класса типов}
    Signals: TList;
    property Name: string read FName write SetName;
    property DataType: string read FDataType write SetDataType;
    property ValFldType: string read FValFldType write SetValFldType;
    property Parent: TSigType read FParent write SetParent;
    property TreeNode: TfcTreeNode read FTreeNode write SetTreeNode;
    constructor CreateNew(TypeName,DataType,ValFldType: string; Parent: TSigType);
    constructor CreateLoad;
    destructor Free; reintroduce;
    //procedure Save;
    procedure Load;
    procedure Show;
    procedure Delete;
    procedure AddTable;
    function FindTypeInTree: Boolean; {проверяет, внесен ли текущий тип в дерево}
    function CheckTableExist: Boolean; {проверяет, существует ли таблица}
    procedure LoadChildren;
    procedure ShowChildren(TV: TfcTreeView);
    procedure ShowFields;
    procedure DeleteChildren;
    function CheckTypeNameEncoding: Boolean;
    function AllowMoveDrop(DropTarget: TSigType): Boolean;
    procedure LoadSignals;
    procedure ShowSignals(FillStartCol: Integer);
    function CheckFieldExists(FieldName: string): Boolean; //проверяет, существует ли поле у текущего типа
    procedure ShowSigTableFields(FillStartCol: Integer); //отобразить "шапку" центральной таблицы
    procedure ShowSigPropsTableFields; //отобразить индивидуальные свойства типа
    procedure ShowSigPropsTableSignals(SigRow: Integer); //отобразить поля сигнала в правой таблице(если выбран сигнал в не-листовом типе)
    procedure cbbSelectTypeFill;
    function GetNotEmptyList: TStringList;
    function NotEmptyListCheck: Boolean; //если хоть какая-то ячейка, которая должна быть заполнена по критерию NOT NULL, не заполнена + проверка указания типа
  end;

  TTypeEditor = class (TObject)
  private

  public
    Types: TList;
    FieldsArchive: TList;
    UniqFields: TList;
    constructor Create;
    destructor Free; reintroduce;
    procedure Load;
    procedure SaveFields;
    procedure SaveTypes;
    //procedure GetCurField;
    function TypeByName(aName: string): TSigType;
    function GetFieldLength(FieldName: string): Integer; {получает максимально допустимую длину значения для столбцов типа VARCHAR записей таблицы TYPEFIELD}
    procedure LoadArchive;
    procedure LoadUniqFields; //создаёт список, состоящий из всех полей всех типов(без дубликатов)
    procedure CheckFieldInUniqList(FieldName: string);
    procedure SaveFieldChanges(FieldList: TList);
    procedure DBReconnect; //реконнект бд и транзакций. Таким незамысловатым образом избавляюсь от "object *table* in use"
    function GetCurTypeForSignals(ARow: Integer): TSigType; //получает CurType из таблицы/дерева сигналов
    function GetCurSignalFields: TStringList;
    function GetCurName: string;
    function GetCurInfo: string;
    procedure SaveSignals;
    function GetFieldList: TStringList;
    function CountSpaces (Value: string): SmallInt; //подсчет количества стартовых символов-пробелов в строке (нужно для дерева в cbb)
  end;

  TSigField = class (TPersistent)
  public
    FFieldID: Integer;
    FName: string;
    FHeader: string;
    FFieldType: string;
    FLength: Integer;
    FNumber: Integer;
    FValues: TStringList;
    FEmpty: Boolean;
    FSigType: TSigType;
    procedure SetName (NameValue: string);
    procedure SetHeader (HeaderValue: string);
    procedure SetFieldType (FieldTypeValue: string);
    procedure SetLength (LengthValue: Integer);
    procedure SetNumber (NumberValue: Integer);
    procedure SetValues (ValuesList: TStringList);
    procedure SetEmpty (EmptyValue: Boolean);
    procedure SetSigType(const Value: TSigType);
    procedure SetFieldID(const Value: Integer);
    property SigType: TSigType read FSigType write SetSigType;
    property FieldID: Integer read FFieldID write SetFieldID;
    property Name: string read FName write SetName;
    property Header: string read FHeader write SetHeader;
    property FieldType: string read FFieldType write SetFieldType;
    property Length: Integer read FLength write SetLength;
    property Number: Integer read FNumber write SetNumber;
    property Values: TStringList read FValues write SetValues;
    property Empty: boolean read FEmpty write SetEmpty;
    constructor CreateLoad(TypeName: string; SignalType: TSigType);
    constructor CreateNew;
    procedure SaveNewField(FieldsList: TStringList);
    constructor CreateNewArchiveField(SigField: TSigField);
    constructor CreateLoadArchiveField;
    destructor Free; reintroduce;
    procedure Save(FieldsList: TStringList);
    procedure Delete;
    function CheckFieldExists: boolean;
    procedure AddToArchive;
    procedure ShowField; {после добавления к типу поля из архива показывает это поле в пользовательской таблице}
    procedure DelFromArchive;
    procedure Assign (Source: TPersistent; Number: integer); //override; //Number передаётся для того, чтобы определить, добавляется поле в архив, или в другое место
    function IsTree: Boolean; //проверить, является ли список Values деревом (напр. поле LIN)
    procedure FillTreeValsCmb (fcTreecbb: TfcTreeCombo);
  end;

  TSignal = class (TObject)
  private
    FSigID: integer;
    FName: string;
    FInfo: string;
    FFields: TStringList;
    procedure SetName (NameValue: string);
    procedure SetInfo (InfoValue: string);
    procedure SetFields(Value: TStringList);
  public
    SigType: TSigType;
    property SigID: integer read FSigID;
    property Name: string read FName write SetName;
    property Info: string read FInfo write SetInfo;
    property FIelds: TStringList read FFields write SetFields;
    constructor CreateNew;
    constructor CreateLoad(SignalType: TSigType);
    destructor Free; reintroduce;
    procedure SaveNewSignal; //заполняет свойства новосозданного объекта, и вносит его в бд
    function SignalExists(SignalName: string): Boolean; //проверяет, внесён ли уже сигнал в БД
    procedure Delete;

  end;

var
  CurType: TSigType;
  CheckFields,CheckTypes,CheckSignals,FieldExists,CheckSender: Boolean; //FieldExists - проверка существования поля у всех детей выбранного типа
                                                                        //CheckSender - проверяет, кто вызвал btnAddPropertyClick. Если вызвана при добавлении в архив - то не надо выбивать сообщение "заполните предыдущие поля"

implementation

uses TypeCreator,TpsEditor,FieldValuesList,Editor,SigEditor,SelArchField;

{ TSigType }

constructor TSigType.CreateNew(TypeName,DataType,ValFldType: string; Parent: TSigType);
begin
  FName := TypeName;
  FDataType := DataType;
  FValFldType := ValFldType;
  Children := TList.Create;
  Props := TList.Create;
  FParent := Parent;
  Signals := TList.Create;
end;

procedure TSigType.AddTable;
var
  i: integer;
begin
  if Self.CheckTypeNameEncoding then
    MessageDlg('Название листового типа не может содержать кириллицу!',mtWarning,[mbOK],0)
  else with EditorForm.ibsqlTypes do begin
    SQL.Text := 'create table "'+AnsiUpperCase(FName)+'" (SIGNALID integer not null primary key, NAME VARCHAR(30) NOT NULL, INFO VARCHAR(70) NOT NULL)';
    ExecQuery;
    for i:=0 to TypeEditor.UniqFields.Count-1 do
      if TSigField(TypeEditor.UniqFields[i]).Name = 'NAME' then begin
        Props.Add(TSigField.CreateNew);
        TSigField(Props[Props.Count-1]).Assign(TSigField(TypeEditor.UniqFields[i]),Props.Count);
        TSigField(Props[Props.Count-1]).SigType := Self;
        SQL.Text := 'INSERT INTO TYPEFIELD VALUES (:ID,:TypeName,''NAME'',''Имя'',''string'',30,1,''Не пусто'',0)';
        Prepare;
        Params[0].AsInteger := TSigField(Props[Props.Count-1]).FieldID;
        Params[1].AsString := FName;
        ExecQuery;
      end
      else if TSigField(TypeEditor.UniqFields[i]).Name = 'INFO' then begin
        Props.Add(TSigField.CreateNew);
        TSigField(Props[Props.Count-1]).Assign(TSigField(TypeEditor.UniqFields[i]),Props.Count);
        TSigField(Props[Props.Count-1]).SigType := Self;
        SQL.Text := 'INSERT INTO TYPEFIELD VALUES (:ID,:TypeName,''INFO'',''Назначение'',''string'',70,2,''Не пусто'',0)';
        Prepare;
        Params[0].AsInteger := TSigField(Props[Props.Count-1]).FieldID;
        Params[1].AsString := FName;
        ExecQuery;
      end;
  end;
  TypeEditor.DBReconnect;
  for i:=0 to Props.Count-1 do
    TSigField(Props[i]).ShowField;
  CheckTypes := False;
end;

procedure TSigType.Delete;
begin
  with EditorForm.ibsqlTypes do begin
    if Self.CheckTableExist = True then  begin
      TypeEditor.DBReconnect; //для корректного удаления таблицы(с существующим FK не удаляется)
     {EditorForm.ibsqlExtract.SQL.Text := 'SELECT * FROM RDB$RELATION_CONSTRAINTS WHERE RDB$RELATION_NAME = :TypeName AND RDB$CONSTRAINT_TYPE = ''FOREIGN KEY''';
      EditorForm.ibsqlExtract.Prepare;
      EditorForm.ibsqlExtract.Params[0].AsString := FName;
      EditorForm.ibsqlExtract.ExecQuery;
      ConstraintName := EditorForm.ibsqlExtract.FieldByName('RDB$CONSTRAINT_NAME').AsString;
      EditorForm.ibsqlExtract.Close;
      EditorForm.ibtrnsctnExtract.CommitRetaining;
      EditorForm.ibsqlExtract.SQL.Text := 'SELECT * FROM RDB$CHECK_CONSTRAINTS WHERE RDB$CONSTRAINT_NAME = :ConstraintName';
      EditorForm.ibsqlExtract.Prepare;
      EditorForm.ibsqlExtract.Params[0].AsString := ConstraintName;
      EditorForm.ibsqlExtract.ExecQuery;
      Triggers := TStringList.Create;
      while not EditorForm.ibsqlExtract.Eof do begin
        Triggers.Add(EditorForm.ibsqlExtract.FieldByName('RDB$TRIGGER_NAME').AsString);
        EditorForm.ibsqlExtract.Next;
      end;
      EditorForm.ibsqlExtract.Close;
      for i:=0 to Triggers.Count -1 do begin
        EditorForm.ibsqlExtract.SQL.Text := 'DROP TRIGGER "' +Triggers[i]+ '"';
        ExecQuery;
      end;
      Triggers.Free;
      EditorForm.ibtrnsctnExtract.CommitRetaining;
      EditorForm.ibsqlExtract.SQL.Text := 'ALTER TABLE "' +FName+ '" DROP CONSTRAINT "' +ConstraintName+ '"';
      {EditorForm.ibsqlExtract.SQL.Add('ALTER TABLE "' +FName+ '" ADD CONSTRAINT "' +ConstraintName+ '" FOREIGN KEY (SIGNALID) REFERENCES SIGNALS(SIGNALID)');}
      {EditorForm.ibsqlExtract.ExecQuery;
      EditorForm.ibtrnsctnExtract.CommitRetaining;}
      SQL.Text := 'DROP TABLE "'+FName+'" ';
      ExecQuery;
    end;
    SQL.Text := 'DELETE FROM SIGTYPE WHERE TYPENAME= :TypeName';
    Prepare;
    Params[0].AsString := FName;
    ExecQuery;
    if Self <> CurType then
      Self.Free;
    CheckTypes := True;
  end;
end;

destructor TSigType.Free;
var
  i: integer;
  DelCheck: Boolean;
begin
  for i:=0 to Props.Count-1 do
    TSigField(Props[i]).Free;
  Props.Free;
  Children.Clear;
  Children.Free;
  DelCheck := False;
  for i:=0 to TypeEditor.Types.Count-1 do begin
    if DelCheck then
      Break;
    DelCheck := TSigType(TypeEditor.Types[i]).Name = Self.Name;
    if DelCheck then
      TypeEditor.Types.Delete(i);
  end;
end;

procedure TSigType.Load; {заполняется список Props, поэтому работает через ibsql1}
var
  i: integer;
begin
  with EditorForm.ibsqlFields1 do begin
    SQL.Text := 'SELECT * FROM TYPEFIELD WHERE TYPEFIELD.TYPENAME = :TypeName ORDER BY NUMBER';
    Prepare;
    Params[0].AsString := FName;
    ExecQuery;
    while not Eof do begin
      Props.Add(TSigField.CreateLoad(FName,Self));
      Next;
    end;
    Close;
  end;
  for i:=0 to Self.Children.Count-1 do
    if TSigType(Self.Children[i]).Props.Count = 0 then
      TSigType(Self.Children[i]).Load;
end;

{procedure TSigType.Save;
begin
  with EditorForm.ibsqlTypes do begin
    SQL.Text := 'INSERT INTO SIGTYPE(TYPENAME,DATATYPE,VALFIELDTYPE,PARENT) VALUES (:TypeName,:DataType,:ValFieldType,:Parent)';
    Prepare;
    Params[0].AsString := FName;
    Params[1].AsString := FDataType;
    Params[2].AsString := FValFldType;
    if Assigned(FParent) then
      Params[3].AsString := FParent.Name
    else
      Params[3].AsString := 'Base';
    ExecQuery;
    CheckTypes := True;
  end;
end;}

procedure TSigType.Show;
var
  i: Integer;
begin
  with TpsEditorForm.SGPropsTable do begin
    for i:=0 to Props.Count-1 do begin
      if not (Cells[1,1] = '') then
          RowCount := RowCount+1;
      Objects[0,RowCount-1] := TSigField(Props[i]);
      Cells[0,RowCount-1] := IntToStr(TSigField(Props[i]).Number);
      Cells[1,RowCount-1] := FName;
      Cells[2,RowCount-1] := TSigField(Props[i]).Name;
      Cells[3,RowCount-1] := TSigField(Props[i]).Header;
      Cells[4,RowCount-1] := TSigField(Props[i]).FieldType;;
      Cells[5,RowCount-1] := IntToStr(TSigField(Props[i]).Length);
      if TSigField(Props[i]).Values.Count>1 then
        Cells[6,RowCount-1] := '(...)'
      else if TSigField(Props[i]).Values.Count =1 then
        Cells[6,RowCount-1] := TSigField(Props[i]).Values[0];
      if TSigField(Props[i]).Empty = False then
        Cells[7,RowCount-1] := 'Не пусто';
    end;
    if ((Props.Count = 0) and (Children.Count = 0) and (TpsEditorForm.fctrvw1.Selected.Text = FName)) then begin
      Cells[0,RowCount-1] := '1';
      Cells[1,RowCount-1] := Self.Name;
    end;
  end;
end;

{ TEditor }

constructor TTypeEditor.Create;
begin
  Types := TList.Create;
  FieldsArchive := TList.Create;
  UniqFields := TList.Create;
end;

destructor TTypeEditor.Free;
var
  i: Integer;
begin
  while Types.Count > 0 do //удаление непосредственно элемента списка происходит в деструкторе TSigType, т.к. не всегда вызов деструктора типа идёт из деструктора TypeEditor
    TSigType(Types[Types.Count-1]).Free;
  for i:=0 to FieldsArchive.Count-1 do
    TSigField(FieldsArchive[i]).Free;
  FieldsArchive.Free;
  Types.Free;
  UniqFields.Free;
end;

procedure TTypeEditor.Load;
var
  Base: TSigType;
begin
  with EditorForm.ibsqlTypes do begin
    SQL.Text := 'SELECT * FROM SIGTYPE WHERE TYPENAME = ''Base''';
    ExecQuery;
    Base := TSigType.CreateLoad;
    Close;
    Types.Add(Base);
    Base.LoadChildren;
  end;
end;

procedure TSigType.SetDataType(DataTypeValue: string);
begin
  if FDataType <> DataTypeValue then begin
    FDataType := DataTypeValue;
    with EditorForm.ibsqlTypes do begin
      if FDataType = '' then begin
        SQL.Text := 'UPDATE SIGTYPE SET DATATYPE = NULL WHERE TYPENAME = :Name';
        Prepare;
        Params[0].AsString := FName;
      end else begin
        SQL.Text := 'UPDATE SIGTYPE SET DATATYPE = :Value WHERE TYPENAME = :Name';
        Prepare;
        Params[0].AsString := FDataType;
        Params[1].AsString := FName;
      end;
      ExecQuery;
    end;
    CheckTypes := True;
  end;
end;

procedure TSigType.SetValFldType(ValFldTypeValue: string);
begin
  if FValFldType <> ValFldTypeValue then begin
    FValFldType := ValFldTypeValue;
    with EditorForm.ibsqlTypes do begin
      SQL.Text := 'UPDATE SIGTYPE SET VALFIELDTYPE = :Value WHERE TYPENAME = :Name';
      Prepare;
      Params[0].AsString := ValFldTypeValue;
      Params[1].AsString := FName;
      ExecQuery;
    end;
    CheckTypes := True;
    TpsEditorForm.btnSaveTypes.Enabled := True;
  end;
end;

constructor TSigType.CreateLoad;
begin
  Props := TList.Create;
  with EditorForm.ibsqlTypes do begin
    FName := FieldByName('TYPENAME').AsString;
    FDataType := FieldByName('DATATYPE').AsString;
    FValFldType := FieldByName('VALFIELDTYPE').AsString;
    FParent := nil;
    if FName <> 'Base' then
      FParent := TypeEditor.TypeByName(FieldByName('PARENT').AsString); //Родитель создан раньше, поэтому уже есть в Types
    Children := TList.Create;
    Signals := TList.Create;
  end;
end;

procedure TSigType.SetName(NameValue: string);
var
  NameCheck: Boolean;
begin
  if FName <> NameValue then begin
    NameCheck := True;
    with EditorForm.ibsqlTypes do begin   //SELECT из системной таблицы, которая, естественно, удаляться не будет. Поэтому ibsqlTypes
      SQL.Text := 'SELECT * FROM RDB$RELATIONS WHERE RDB$SYSTEM_FLAG = 0';
      ExecQuery;
      while not Eof do begin
        NameCheck := NameCheck and (NameValue <> FieldByName('RDB$RELATION_NAME').AsString);
        Next;
      end;
      Close;
      if NameCheck then  begin
        SQL.Text := 'UPDATE SIGTYPE SET TYPENAME = :Value WHERE TYPENAME = :Name';
        Prepare;
        Params[0].AsString := NameValue;
        Params[1].AsString := FName;
        ExecQuery;
        FName := NameValue;
        CheckTypes := True;
        TpsEditorForm.btnSaveTypes.Enabled := True;
      end;
    end;
  end;
end;

function TSigType.FindTypeInTree: Boolean;
var
  Node: TfcTreeNode;
  i: Integer;
begin
  FindTypeInTree := false;
  for i:=0 to TpsEditorForm.fctrvw1.Items.Count do begin
    Node := TpsEditorForm.fctrvw1.Items.GetFirstNode;
    while ((Node <> nil) or (FindTypeInTree= false)) do begin
      FindTypeInTree := TpsEditorForm.fctrvw1.Selected.Text = CurType.Name;
      Node := Node.GetNext;
    end;
  end;
end;

procedure TSigType.ShowChildren(TV: TfcTreeView);
var
  i: integer;
begin
  for i:=0 to Children.Count-1 do begin
    with TV do begin
      if Self.Parent = nil then
        Items.AddChildObject(Items.FindNode('Все типы',False),TSigType(Children[i]).Name,TSigType(Children[i]))
      else
        Items.AddChildObject(Items.FindNode(FName,False),TSigType(Children[i]).Name,TSigType(Children[i]));
      TSigType(Children[i]).TreeNode := Items.FindNode(TSigType(Children[i]).Name,False);
    end;
    TSigType(Children[i]).ShowChildren(TV);
  end;
end;

procedure TSigType.LoadChildren;
var
  i: integer;
begin
  with EditorForm.ibsqlTypes do begin
    SQL.Text := 'SELECT * FROM SIGTYPE WHERE PARENT = :Name ORDER BY TYPENAME';
    Prepare;
    Params[0].AsString := FName;
    ExecQuery;
    while not Eof do begin
      TypeEditor.Types.Add(TSigType.CreateLoad);
      Children.Add(TSigType(TypeEditor.Types[TypeEditor.Types.Count-1])); {заполняем список Children текущего объекта, и, попутно, список Types}
      Next;
    end;
    Close;
    for i:=0 to Self.Children.Count-1 do
        TSigType(Self.Children[i]).LoadChildren; {Заполняем детей детей текущего объекта и так до "дна"}
  end;
end;

procedure TSigType.ShowFields;
var
  i: integer;
begin
  if not (Children.Count = 0) then
    for i:=0 to Children.Count-1 do begin
      if TSigType(Children[i]).Props.Count=0 then
        TSigType(Children[i]).Load;
      TSigType(Children[i]).Show;
      TSigType(Children[i]).ShowFields;
    end
  else if Self =CurType then begin
    if Self.Props.Count = 0 then
      Self.Load;
    Self.Show;
  end;
end;

procedure TSigType.DeleteChildren;
var
  i: integer;
begin
  if not (Children.Count = 0) then
  for i:= 0 to Children.Count-1 do begin
    TSigType(Children[i]).DeleteChildren;
    {if CheckTableExist then
      TSigType(Children[i]).Delete;}
  end
  else if CurType <> Self then
    Self.Delete;
end;

function TSigType.CheckTableExist: Boolean;
begin
  Result := false;
  with EditorForm.ibsqlTypes do begin
    if not Self.CheckTypeNameEncoding then begin
      SQL.Text := 'SELECT * FROM TYPEFIELD WHERE TYPENAME = :Name';
      Prepare;
      Params[0].AsString := FName;
      ExecQuery;
      while not Eof do begin
        Result := True;
        Next;
      end;
      Close;
    end;
  end;
end;

procedure TSigType.SetTreeNode(TreeNodeValue: TfcTreeNode);
begin
  FTreeNode := TreeNodeValue;
end;

function TSigType.CheckTypeNameEncoding: Boolean;
var
  i: integer;
begin
  CheckTypeNameEncoding := False;
  for i:=0 to Length(FName)-1 do
    if FName[i] in ['А'..'я','Ё','ё'] then begin
      CheckTypeNameEncoding := True;
      Exit;
    end;
end;

procedure TSigType.SetParent(ParentValue: TSigType);
begin
  if FParent <> ParentValue then begin
    if FParent <> nil then
      FParent.Children.Remove(Self);
    FParent := ParentValue;
    with EditorForm.ibsqlTypes do begin
      SQL.Text := 'UPDATE SIGTYPE SET PARENT = :Value WHERE TYPENAME = :Name';
      Prepare;
      Params[0].AsString := ParentValue.Name;
      Params[1].AsString := FName;
      ExecQuery;
    end;
    if FParent <> nil then
      FParent.Children.Add(Self);
    FTreeNode.MoveTo(ParentValue.TreeNode,fcnaAddChild);
    CheckTypes := True;
    TpsEditorForm.btnSaveTypes.Enabled := True;
  end;
end;

function TSigType.AllowMoveDrop(DropTarget: TSigType): Boolean;
begin
  Result := False;
  if DropTarget.Props.Count = 0 then
    Result := True;
end;

procedure TSigType.LoadSignals;
begin
  with EditorForm.ibsqlSignals do begin
       //объекту TSignal необходимо передавать ссылку на тип
    SQL.Text := 'SELECT * FROM "' +Self.Name+ '"';
    ExecQuery;
    while not Eof do begin
      Signals.Add(TSignal.CreateLoad(Self));
      Next;
    end;
    Close;
  end;
end;

procedure TSigType.ShowSignals(FillStartCol: integer);
var
  i,j,c: Integer;
begin
  with SigEditorForm.SGSigTable do begin
    for i:=0 to Signals.Count-1 do begin
      if RowHeights[1] = 0 then
        RowHeights[1] := DefaultRowHeight
      else
        RowCount := RowCount+1;
      Cells[0,RowCount-1] := IntToStr(RowCount-1);
      Objects[0,RowCount-1] := TSignal(Signals[i]);
      if FillStartCol = 2 then
        Cells[1,RowCount-1] := FName;
      for c := FillStartCol to ColCount-1 do
        if Cells[c,0] = 'Имя' then
          Cells[c,RowCount-1] := TSignal(Signals[i]).Name
        else if Cells[c,0] = 'Назначение' then
          Cells[c,RowCount-1] := TSignal(Signals[i]).Info;
      with TSignal(Signals[i]).Fields do begin
        for j:=0 to Count-1 do
          for c := FillStartCol to ColCount-1 do
            if Cells[c,0] = Names[j] then
              Cells[c,RowCount-1] := Values[Names[j]];
      end;
    end;
    for i:=0 to Children.Count-1 do
        TSigType(Children[i]).ShowSignals(FillStartCol);
    SigEditorForm.lblSignalsCount.Caption := 'Сигналы:' +IntToStr(RowCount-1);
  end;
end;

function TSigType.CheckFieldExists(FieldName: string): Boolean;
var
  i: integer;
begin
  Result := False;
  for i:=0 to Props.Count-1 do
    if TSigField(Props[i]).Name = FieldName then
      Result := True;
  if ((not Result) and (Props.Count >0)) then
    Exit;
end;

procedure TSigType.ShowSigTableFields(FillStartCol: Integer);
var
  i,j,c: integer;
  FieldCheck,NameCheck: boolean;
begin
  FieldCheck := False;
  if Props.Count > 0 then begin               //любой тип, который не имеет свойств, и, как следствие, сигналов, не учитывается при формировании DeleteList-а,
    with SigEditorForm.SGSigTable do begin    //даже если он не имеет детей. Потому как гипотетически он является нелистовым.
      if ColWidths[FillStartCol] = 0 then begin
        ColWidths[FillStartCol] := DefaultColWidth;
        for i:=0 to Props.Count-1 do
          TableHeader.Add(TSigField(Props[i]).Header);
      end else begin
        for i:=0 to TableHeader.Count-1 do begin
          for j:=0 to Props.Count-1 do begin
            FieldCheck := TableHeader[i] = TSigField(Props[j]).Header;
            if FieldCheck then
              Break;
          end;
          if not FieldCheck then begin
            NameCheck := False;
            for c:=0 to DeleteList.Count-1 do begin
              NameCheck := DeleteList[c] = TableHeader[i];
              if NameCheck then
                Break;
            end;
            if not NameCheck then
              DeleteList.Add(TableHeader[i]);
          end;
        end;
      end;
    end;
  end else begin
    for i:=0 to Children.Count-1 do
      TSigType(Children[i]).ShowSigTableFields(FillStartCol);
  end;
end;

procedure TSigType.ShowSigPropsTableFields;
var
  i,j: integer;
  FieldCheck: Boolean;
begin
  SigEditorForm.pnlProps.Visible := True;
  with SigEditorForm.SGSigPropsTable do begin
    for i:=1 to RowCount -1 do
      Rows[i].Clear;
    RowCount := 2;
    RowHeights[1] := 0;
    for i:=0 to Props.Count-1 do begin
      FieldCheck := True;
      for j:=0 to TableHeader.Count-1 do
        FieldCheck := FieldCheck and (TableHeader[j]<>TSigField(Props[i]).Header);
      if FieldCheck then begin
        if RowHeights[1] = 0 then
          RowHeights[1] := DefaultRowHeight
        else
          RowCount := RowCount+1;
        Cells[0,RowCount-1] := TSigField(Props[i]).Header;
      end;
    end;
    if RowHeights[1] = 0 then
      SigEditorForm.lblPropsCount.Caption := 'Свойства: 0'
    else
      SigEditorForm.lblPropsCount.Caption := 'Свойства:' +IntToStr(RowCount-1);
  end;
end;

procedure TSigType.ShowSigPropsTableSignals(SigRow: integer);
var
  i,j,c,NameCol: integer;
begin
  with SigEditorForm.SGSigTable do begin
    for c:=2 to ColCount-1 do begin //определяем колонку с именем сигнала
      if Cells[c,0] = 'Имя' then
        NameCol := c;
    end;
    for i:=0 to Signals.Count-1 do begin
      with TSignal(Signals[i]) do begin
        if Name = Cells[NameCol,SigRow] then begin //выбираем нужный сигнал
          for j:=0 to Fields.Count-1 do
            for c:=1 to SigEditorForm.SGSigPropsTable.RowCount-1 do
              if FIelds.Names[j] = SigEditorForm.SGSigPropsTable.Cells[0,c] then
                SigEditorForm.SGSigPropsTable.Cells[1,c] := FIelds.ValueFromIndex[j];
        end;
      end;
    end;
  end;
  SigEditorForm.SGSigPropsTable.Cells[0,0] := 'Свойство';
  SigEditorForm.SGSigPropsTable.Cells[1,0] := 'Значение';
end;

procedure TSigType.cbbSelectTypeFill;
var
  i: integer;
begin
  if ((CurType <> Self) and (Props.Count > 0)) then
    SigEditorForm.cbbTypeSelect.AddItem(Self.Name,Self);
  for i:=0 to Children.Count-1 do
    TSigType(Children[i]).cbbSelectTypeFill;
end;

function TSigType.GetNotEmptyList: TStringList;
var
  i: integer;
begin
  Result := TStringList.Create;
  for i:=0 to Props.Count-1 do
    if not TSigField(Props[i]).Empty then
      Result.Add(TSigField(Props[i]).Header);
end;

function TSignal.SignalExists(SignalName: string): Boolean;
begin
  Result := False;
  with EditorForm.ibsqlSignals do begin
    SQL.Text := 'SELECT * FROM SIGNALS WHERE NAME = :SigName';
    Prepare;
    Params[0].AsString := SignalName;
    ExecQuery;
    while not Eof do begin
      Result := True;
      Next;
    end;
    Close;
  end;
end;

function TSigType.NotEmptyListCheck: Boolean; 
var
  NotEmptyList: TStringList;
  i,j: integer;
begin
  if Self = nil then begin
    Result := True;
    Exit;
  end;
  with SigEditorForm.SGSigTable do begin
    //TypeEditor.GetCurTypeForSignals(Row);
    NotEmptyList := TStringList.Create;
    NotEmptyList.Assign(GetNotEmptyList);
    Result := False;
    if ((Cells[1,0] = 'Имя типа') and (Cells[1,Row] = '')) then
      Result := True;
    for i:=0 to NotEmptyList.Count-1 do
      if Result then
        Break
      else begin
        for j:=1 to ColCount-1 do begin
          if not Result then
            if ((NotEmptyList[i] = Cells[j,0]) and (Cells[j,Row] = '')) then
              Result := True;
        end;
      end;
    for i:=0 to NotEmptyList.Count-1 do
      if Result then
        Break
      else begin
        for j:=1 to SigEditorForm.SGSigPropsTable.RowCount-1 do begin
          if not Result then
            if ((NotEmptyList[i] = SigEditorForm.SGSigPropsTable.Cells[0,j]) and (SigEditorForm.SGSigPropsTable.Cells[1,j] = '')) then
              Result := True;
        end;
      end;
  end;
end;

{ TSigField }

procedure TSigField.AddToArchive;
var
  DefValFldID,i,DefFldCount: Integer;
begin
  with EditorForm.ibsqlArchive do begin
    SQL.Text := 'select gen_id(FIELDIDGEN,1) from RDB$Database'; //DEFFIELDID не используем, чтобы в архиве корректно устанавливался Number
    ExecQuery;                                                   //В set-метод нельзя передавать параметры, поэтому при изменении значения Number меняем обе таблицы, и используем один генератор, чтобы изменения не вносились в "чужую" таблицу
    FFieldID := Fields[0].AsInteger;
    Close;
    if FValues.Count > 0  then
      SQL.Text := 'INSERT INTO DEFAULTFIELD VALUES (:ID,:Name,:Caption,:FieldType,:Len,:Number,:NotEmpty,1)'
    else
      SQL.Text := 'INSERT INTO DEFAULTFIELD VALUES (:ID,:Name,:Caption,:FieldType,:Len,:Number,:NotEmpty,0)';
    Prepare;
    Params[0].AsInteger := FFieldID;
    Params[1].AsString := FName;
    Params[2].AsString := FHeader;
    Params[3].AsString := FFieldType;
    Params[4].AsInteger := FLength;
    with EditorForm.ibsqlFields2 do begin
      SQL.Text := 'SELECT COUNT(*) FROM DEFAULTFIELD';
      ExecQuery;
      DefFldCount := Fields[0].AsInteger;
      Close;
    end;
    Params[5].AsInteger := DefFldCount+1;
    if not FEmpty then
      Params[6].AsString := 'Не пусто'
    else
      Params[6].AsString := '';
    ExecQuery;
    for i:=0 to FValues.Count-1 do begin
      if FValues[i] <>'' then begin
        SQL.Text := 'select gen_id(DEFVALIDGEN,1) from RDB$Database';
        ExecQuery;
        DefValFldID := Fields[0].AsInteger;
        Close;
        SQL.Text := 'INSERT INTO DEFFIELDVALUE VALUES (:ValID,:FldID,:Value)';
        Prepare;
        Params[0].AsInteger := DefValFldID;
        Params[1].AsInteger := FFieldID;
        Params[2].AsString := FValues[i];
        ExecQuery;
      end;
    end;
  end;
  CheckFields := True;
end;

function TSigField.CheckFieldExists: boolean;
begin
  CheckFieldExists := False;
  with EditorForm.ibsqlFields1 do begin
    SQL.Text := 'SELECT * FROM RDB$RELATION_FIELDS WHERE RDB$FIELD_NAME = :FieldName AND RDB$RELATION_NAME = :TypeName';
    Prepare;
    Params[0].AsString := FName;
    Params[1].AsString := CurType.Name;
    ExecQuery;
    while not Eof do begin
      CheckFieldExists := True;
      Next;
    end;
    Close;
  end;
end;

constructor TSigField.CreateLoad(TypeName: string; SignalType: TSigType);
var
  ValuesCheck,EmptyCheck: string;
begin
  FSigType := SignalType;
  FValues := TStringList.Create;
  with EditorForm.ibsqlFields1 do begin
    FFieldID := FieldByName('FIELDID').AsInteger;
    FName := FieldByName('NAME').AsString;
    FHeader := FieldByName('CAPTION').AsString;
    FFieldType := FieldByName('DATATYPE').AsString;
    FLength := FieldByName('LEN').AsInteger;
    FNumber := FieldByName('NUMBER').AsInteger;
    ValuesCheck := FieldByName('ValueKind').AsString;
    EmptyCheck := FieldByName('NOTEMPTY').AsString;
    if ValuesCheck ='1' then begin
      EditorForm.ibsqlFields2.SQL.Text := 'SELECT * FROM FIELDVALUE WHERE FIELDVALUE.FIELDID = :FFieldID';
      EditorForm.ibsqlFields2.Prepare;
      EditorForm.ibsqlFields2.Params[0].AsInteger := FFieldID;
      EditorForm.ibsqlFields2.ExecQuery;
      while not EditorForm.ibsqlFields2.Eof do begin
        FValues.Add(EditorForm.ibsqlFields2.FieldByName('AVALUE').AsString);
        EditorForm.ibsqlFields2.Next;
      end;
      EditorForm.ibsqlFields2.Close;
    end;
    FEmpty := EmptyCheck <> 'Не пусто';
  end;
end;

constructor TSigField.CreateLoadArchiveField;
var
  EmptyCheck,ValuesCheck: string;
begin
  FValues := TStringList.Create;
  with EditorForm.ibsqlArchive do begin
    FFieldID := FieldByName('DEFFIELDID').AsInteger;
    FName := FieldByName('NAME').AsString;
    FHeader := FieldByName('CAPTION').AsString;
    FFieldType := FieldByName('DATATYPE').AsString;
    FLength := FieldByName('LEN').AsInteger;
    FNumber := FieldByName('NUMBER').AsInteger;
    ValuesCheck := FieldByName('ValueKind').AsString;
    EmptyCheck := FieldByName('NOTEMPTY').AsString;
    if ValuesCheck ='1' then begin
      EditorForm.ibsqlFields2.SQL.Text := 'SELECT * FROM DEFFIELDVALUE WHERE DEFFIELDVALUE.DEFFIELDID = :FFieldID';
      EditorForm.ibsqlFields2.Prepare;
      EditorForm.ibsqlFields2.Params[0].AsInteger := FFieldID;
      EditorForm.ibsqlFields2.ExecQuery;
      while not EditorForm.ibsqlFields2.Eof do begin
        FValues.Add(EditorForm.ibsqlFields2.FieldByName('AVALUE').AsString);
        EditorForm.ibsqlFields2.Next;
      end;
      EditorForm.ibsqlFields2.Close;
    end;
    FEmpty := EmptyCheck <> 'Не пусто';
  end;
end;

procedure TSigField.SaveNewField(FieldsList: TStringList);
begin
  Self.SigType := CurType; //!!! предполагается, что редактирование полей возможно только в случае выбора листовой вершины в дереве
  if not SigType.CheckTableExist then
    SigType.AddTable;
  if FName = '' then
    FSigType.Props.Add(Self);
  FName := FieldsList[0];
  FHeader := FieldsList[1];
  FFieldType := FieldsList[2];
  FLength := StrToInt(FieldsList[3]);
  FNumber := SigType.Props.Count;
  if FieldsList[4] = '(...)' then
    FValues.Assign(CreateValuesList)
  else if (FieldsList[4] <> '(...)') and (FieldsList[4] <> '') then begin
    CreateValuesList := TStringList.Create;
    CreateValuesList.Add(FieldsList[4]);
    FValues.Assign(CreateValuesList);
  end;
  FEmpty := FieldsList[5] <> 'Не пусто';
  Save(FieldsList);
end;

constructor TSigField.CreateNewArchiveField(SigField: TSigField);
begin
  FValues := TStringList.Create;
  FFieldID := SigField.FieldID;
  FName := SigField.Name;
  FHeader := SigField.Header;
  FFieldType := SigField.FieldType;
  FLength := SigField.Length;
  FNumber := TypeEditor.FieldsArchive.Count;
  FValues.Assign(SigField.Values);
  FEmpty := SigField.Empty;
end;

procedure TSigField.Delete;
var
  i: integer;
begin
  with EditorForm.ibsqlFields1 do begin
    SQL.Text := 'DELETE FROM TYPEFIELD WHERE FIELDID = :FFieldID';
    Prepare;
    Params[0].AsInteger := FFieldID;
    ExecQuery;
    if CheckFieldExists then begin
      SQL.Text := 'ALTER TABLE "'+CurType.Name+'" DROP "' +FName+ '"';
      ExecQuery;
    end;
    i := StrToInt(TpsEditorForm.SGPropsTable.Cells[0,TpsEditorForm.SGPropsTable.Row]);
    if i <= CurType.Props.Count-1 then begin
      TSigField(CurType.Props[i-1]).Free;
      CurType.Props.Delete(i-1);
      for i:=0 to CurType.Props.Count-1 do
        TSigField(CurType.Props[i]).Number := i+1;
    end;
    CheckFields := True;
    TpsEditorForm.btnSaveTable.Enabled := True;
  end;
end;

procedure TSigField.DelFromArchive;
var
  i,j: integer;
begin
  with EditorForm.ibsqlArchive do begin
    SQL.Text := 'DELETE FROM DEFAULTFIELD WHERE DEFFIELDID = :DEFFieldID';
    Prepare;
    Params[0].AsInteger := FFieldID;
    ExecQuery;
  end;
  CheckFields := True;
  for i:=0 to TypeEditor.FieldsArchive.Count -1 do
    if TSigField(TypeEditor.FieldsArchive[i]) <> nil then
      if TSigField(TypeEditor.FieldsArchive[i]).FieldID = FFieldID then begin
        TSigField(TypeEditor.FieldsArchive[i]).Free;
        TypeEditor.FieldsArchive.Delete(i);
        for j:=0 to TypeEditor.FieldsArchive.Count-1 do
          TSigField(TypeEditor.FieldsArchive[j]).Number := j+1;
        Exit;
      end;
end;

destructor TSigField.Free;
begin
  FValues.Free;
end;

{procedure TTypeEditor.GetCurField;
var
  i: integer;
begin
  if CurType.Props.Count > 0 then begin
    if TpsEditorForm.SGPropsTable.Row < 1 then
      i := TpsEditorForm.SGPropsTable.RowCount-1
    else
      i := TpsEditorForm.SGPropsTable.Row;
    if i > CurType.Props.Count then
      CurField := nil
    else
      CurField := TSigField(CurType.Props[i-1]);
  end else
    CurField := nil;
end;}

function TTypeEditor.GetFieldLength(FieldName: string): Integer;
var
  FieldSource: string;
begin
  with EditorForm.ibsqlFields1 do begin
    SQL.Text := 'SELECT * FROM RDB$RELATION_FIELDS WHERE RDB$FIELD_NAME = :FieldName AND RDB$RELATION_NAME = ''TYPEFIELD''';
    Prepare;
    Params[0].AsString := FieldName;
    ExecQuery;
    while not Eof do begin
      FieldSource := FieldByName('RDB$FIELD_SOURCE').AsString;
      Next;
    end;
    Close;
    SQL.Text := 'SELECT * FROM RDB$FIELDS WHERE RDB$FIELD_NAME = :FieldSource';
    Prepare;
    Params[0].AsString := FieldSource;
    ExecQuery;
    while not Eof do begin
      GetFieldLength := FieldByName('RDB$FIELD_LENGTH').AsInteger;
      Next;
    end;
    Close;
  end;
end;

procedure TSigField.Save(FieldsList: TStringList);
var
  ValID,i: integer;
begin
  if SigType.CheckTableExist then
    with EditorForm.ibsqlFields2 do begin
      SQL.Text := 'ALTER TABLE "' +SigType.Name+ '" add "' +FName+ '" ';
      if FFieldType = 'string' then
        SQL.Add('VARCHAR(' +IntToStr(FLength)+ ') ')
      else if FFieldType = 'int' then
        SQL.Add('INTEGER')
      else if FFieldType = 'float' then
        SQL.Add('DOUBLE PRECISION');
      if not FEmpty then
        SQL.Add(' NOT NULL');
      ExecQuery;
      Close;
      if FieldsList[4] <> '' then
        SQL.Text := 'INSERT INTO TYPEFIELD VALUES (:ID,:TypeName,:Name,:Caption,:FieldType,:Len,:Number,:NotEmpty,1)'
      else
        SQL.Text := 'INSERT INTO TYPEFIELD VALUES (:ID,:TypeName,:Name,:Caption,:FieldType,:Len,:Number,:NotEmpty,0)';
      Prepare;
      Params[0].AsInteger := FFieldID;
      Params[1].AsString := FSigType.Name;
      Params[2].AsString := FName;
      Params[3].AsString := FHeader;
      Params[4].AsString := FFieldType;
      Params[5].AsInteger := FLength;
      Params[6].AsInteger := FNumber;
      if not FEmpty then
        Params[7].AsString := 'Не пусто'
      else
        Params[7].AsString := '';
      ExecQuery;
      for i:=0 to FValues.Count-1 do begin
        if FValues[i] <>'' then begin
          SQL.Text := 'select gen_id(VALUEIDGEN,1) from RDB$Database';
          ExecQuery;
          ValID := Fields[0].AsInteger;
          Close;
          SQL.Text := 'INSERT INTO FIELDVALUE VALUES (:ValID,:FldID,:Value)';
          Prepare;
          Params[0].AsInteger := ValID;
          Params[1].AsInteger := FFieldID;
          Params[2].AsString := FValues[i];
          ExecQuery;
        end;
      end;
      TpsEditorForm.btnSaveTable.Enabled := True;
    end
  else begin
    SigType.AddTable;
    Self.Save(FieldsList);
  end;
  CheckFields := True;
end;

procedure TSigField.SetEmpty(EmptyValue: Boolean);
begin
  if FEmpty <> EmptyValue then begin
    FEmpty := EmptyValue;
    with EditorForm.ibsqlFields1 do begin
      if FEmpty = False then
        SQL.Text := 'UPDATE TYPEFIELD SET NOTEMPTY = ''Не пусто'' WHERE FIELDID = :ID'
      else
        SQL.Text := 'UPDATE TYPEFIELD SET NOTEMPTY = '''' WHERE FIELDID = :ID';
      Prepare;
      Params[0].AsInteger := FFieldID;
      ExecQuery;
    end;
    TpsEditorForm.btnSaveTable.Enabled := True;
    CheckFields := True;
  end;
end;

procedure TSigField.SetFieldType(FieldTypeValue: string);
begin
  if FFieldType <> FieldTypeValue then begin
    FFieldType := FieldTypeValue;
    with EditorForm.ibsqlFields1 do begin
      if FFieldType = 'string' then
        SQL.Text := 'ALTER TABLE "' +SigType.Name+ '" ALTER "' +FName+ '" TYPE VARCHAR(' +IntToStr(FLength)+ ') CHARACTER SET NONE'
      else if FFieldType = 'int' then
        SQL.Text := 'ALTER TABLE "' +SigType.Name+ '" ALTER "' +FName+ '" TYPE SMALLINT'
      else if FFieldType = 'float' then
        SQL.Text := 'ALTER TABLE "' +SigType.Name+ '" ALTER "' +FName+ '" TYPE DOUBLE PRECISION';
      ExecQuery;
      SQL.Text := 'UPDATE TYPEFIELD SET DATATYPE = :Value WHERE FIELDID = :ID';
      Prepare;
      Params[0].AsString := FieldTypeValue;
      Params[1].AsInteger := FFieldID;
      ExecQuery;
    end;
    TpsEditorForm.btnSaveTable.Enabled := True;
    CheckFields := True;
  end;
end;

procedure TSigField.SetHeader(HeaderValue: string);
begin
  if FHeader <> HeaderValue then begin
    FHeader := HeaderValue;
    with EditorForm.ibsqlFields1 do begin
      SQL.Text := 'UPDATE TYPEFIELD SET CAPTION = :Value WHERE FIELDID = :ID';
      Prepare;
      Params[0].AsString := HeaderValue;
      Params[1].AsInteger := FFieldID;
      ExecQuery;
    end;
    TpsEditorForm.btnSaveTable.Enabled := True;
    CheckFields := True;
  end;
end;

procedure TSigField.SetLength(LengthValue: Integer);
begin
  if FLength <> LengthValue then begin
    with EditorForm.ibsqlFields1 do begin
      SQL.Text := 'ALTER TABLE "' +SigType.Name+ '" ALTER "' +FName+ '" TYPE VARCHAR(' +IntToStr(LengthValue)+ ') CHARACTER SET NONE';
      ExecQuery;
      FLength := LengthValue;
      SQL.Text := 'UPDATE TYPEFIELD SET LEN = :Value WHERE FIELDID = :ID';
      Prepare;
      Params[0].AsString := IntToStr(LengthValue);
      Params[1].AsInteger := FFieldID;
      ExecQuery;
    end;
    TpsEditorForm.btnSaveTable.Enabled := True;
    CheckFields := True;
  end;
end;

procedure TSigField.SetName(NameValue: string);
begin
  if FName <> NameValue then begin
    with EditorForm.ibsqlFields1 do begin
      SQL.Text := 'ALTER TABLE "' +SigType.Name+ '" ALTER "' +FName+ '"  TO "' +NameValue+ '" ';
      ExecQuery;
      FName := NameValue;
      SQL.Text := 'UPDATE TYPEFIELD SET NAME = :Value WHERE FIELDID = :ID';
      Prepare;
      Params[0].AsString := NameValue;
      Params[1].AsInteger := FFieldID;
      ExecQuery;
    end;
    TpsEditorForm.btnSaveTable.Enabled := True;
    CheckFields := True;
  end;
end;

procedure TSigField.SetNumber(NumberValue: Integer);
begin
  if FNumber <> NumberValue then begin
    FNumber := NumberValue;
    with EditorForm.ibsqlFields1 do begin
      SQL.Text := 'UPDATE TYPEFIELD SET Number = :Value WHERE FIELDID = :ID';
      Prepare;
      Params[0].AsString := IntToStr(NumberValue);
      Params[1].AsInteger := FFieldID;
      ExecQuery;
    end;
     with EditorForm.ibsqlArchive do begin
      SQL.Text := 'UPDATE DEFAULTFIELD SET Number = :Value WHERE DEFFIELDID = :ID';
      Prepare;
      Params[0].AsString := IntToStr(NumberValue);
      Params[1].AsInteger := FFieldID;
      ExecQuery;
    end;
    //EditorForm.ibtrnstcn1.CommitRetaining;
    TpsEditorForm.btnSaveTable.Enabled := True;
    CheckFields := True;
  end;
end;

procedure TSigField.SetValues(ValuesList: TStringList);
var
  i,ValID: integer;
begin
  if FValues <> ValuesList then begin
    FValues.Assign(ValuesList);
    with EditorForm.ibsqlFields1 do begin
      SQL.Text :='DELETE FROM FIELDVALUE WHERE FIELDID = :ID';
      Prepare;
      Params[0].AsInteger := FFieldID;
      ExecQuery;
      if ValuesList.Count = 0 then begin
        SQL.Text := 'UPDATE TYPEFIELD SET VALUEKIND = 0 WHERE FIELDID = :ID';
        Prepare;
        Params[0].AsInteger := FFieldID;
        ExecQuery;
      end
      else begin
        SQL.Text := 'UPDATE TYPEFIELD SET VALUEKIND = 1 WHERE FIELDID = :ID';
        Prepare;
        Params[0].AsInteger := FFieldID;
        ExecQuery;
        for i:=0 to ValuesList.Count-1 do begin
          if ValuesList[i] <>'' then begin
            SQL.Text := 'select gen_id(VALUEIDGEN,1) from RDB$Database';
            ExecQuery;
            ValID := Fields[0].AsInteger;
            Close;
            SQL.Text := 'INSERT INTO FIELDVALUE VALUES (:ValID,:FldID,:Value)';
            Params[0].AsInteger := ValID;
            Params[1].AsInteger := FFieldID;
            Params[2].AsString := ValuesList[i];
            ExecQuery;
          end;
        end;
      end;
      Close;
    end;
    TpsEditorForm.btnSaveTable.Enabled := True;
    CheckFields := True;
  end;
end;

procedure TTypeEditor.SaveFields;
var
  buttonSelected: Integer;
  Sender: TObject;
begin
  if ((CheckFields) and (CurType.Children.Count=0)) then
    buttonSelected := MessageDlg('Сохранить изменения?',mtConfirmation,mbOKCancel,0);
    if buttonSelected = mrOk then begin
      TpsEditorForm.btnSaveTableClick(Sender);
      CheckFields := False;
      EditorForm.ibtrnsctn1.CommitRetaining;
    end
    else if buttonSelected = mrCancel then
      EditorForm.ibtrnsctn1.RollbackRetaining;
end;

function TTypeEditor.TypeByName(aName: string): TSigType; //подбор Parent-a.
var                                                       //Поскольку результат функции является объектом TSigType, то здесь можно обращаться к приватным полям этого класса
  i: integer;
begin
  for i:=0 to Types.Count-1 do begin
    Result := TSigType(Types[i]);
    if Result.FName = aName then
      Exit;
  end;
  Result := nil;
end;

procedure TTypeEditor.LoadArchive;
begin
  with EditorForm.ibsqlArchive do begin
    SQL.Text := 'SELECT * FROM DEFAULTFIELD ORDER BY NUMBER';
    ExecQuery;
    while not Eof do begin
      FieldsArchive.Add(TSigField.CreateLoadArchiveField);
      Next;
    end;
    Close;
  end;
end;

procedure TSigField.ShowField;
var
  Sender: TObject;
begin
  TpsEditorForm.btnAddPropertyClick(Sender);
  with TpsEditorForm.SGPropsTable do begin
    {if ((RowCount-1 = CurType.Props.Count) and (CurType.Props.Count > 0)) then
      Cells[0,RowCount-1] := IntToStr(CurType.Props.Count)
    else}
      Cells[0,RowCount-1] := IntToStr(FNumber);
    Cells[1,RowCount-1] := CurType.Name;  //при вызове метода при добавлении из архива FSigType еще пуст, и заполняется только при сохранении поля в бд к конкретному сигналу
    Cells[2,RowCount-1] := FName;
    Cells[3,RowCount-1] := FHeader;
    Cells[4,RowCount-1] := FFieldType;;
    Cells[5,RowCount-1] := IntToStr(FLength);
    if FValues.Count>1 then
      Cells[6,RowCount-1] := '(...)'
    else if FValues.Count =1 then
      Cells[6,RowCount-1] := FValues[0];
    if FEmpty = False then
      Cells[7,RowCount-1] := 'Не пусто';
    if ((CurType.Props.Count = 0) and (CurType.Children.Count = 0) and (TpsEditorForm.fctrvw1.Selected.Text = CurType.Name)) then begin
      Cells[0,RowCount-1] := '1';
      Cells[1,RowCount-1] := CurType.Name;
    end;
    Objects[0,RowCount-1] := Self;
  end;
end;

procedure TTypeEditor.SaveTypes;
var
  buttonSelected: integer;
begin
  if CheckTypes then
    buttonSelected := MessageDlg('Сохранить изменения?',mtConfirmation,mbOKCancel,0);
  if buttonSelected = mrOk then  begin
    
    CheckTypes := False;
    EditorForm.ibtrnsctn1.CommitRetaining;   //Хотя ibsqlSignals закрывается корректно.

  end
  else if buttonSelected = mrCancel then
    EditorForm.ibtrnsctn1.RollbackRetaining;
end;

constructor TSigField.CreateNew;
begin
  with EditorForm.ibsqlFields2 do begin
    SQL.Text := 'select gen_id(FIELDIDGen,1) from RDB$Database';
    ExecQuery;
    FFieldID := Fields[0].AsInteger;
    Close;
  end;
  FValues := TStringList.Create;
end;

procedure TSigField.SetSigType(const Value: TSigType);
begin
  if FSigType <> Value then
    FSigType := Value;
end;

procedure TSigField.SetFieldID(const Value: Integer);
begin
   if FFieldID <> Value then begin
    FFieldID := Value;
    with EditorForm.ibsqlFields1 do begin
      SQL.Text := 'UPDATE TYPEFIELD SET FIELDID = :Value WHERE TYPENAME = :TYPENAME AND NAME = :NAME';
      Prepare;
      Params[0].AsInteger := Value;
      Params[1].AsString := CurType.Name;
      Params[2].AsString := FName;
      ExecQuery;
    end;
    TpsEditorForm.btnSaveTable.Enabled := True;
    CheckFields := True;
  end;
end;



procedure TSigField.Assign(Source: TPersistent; Number: Integer);
begin
  FName := (Source as TSigField).Name;
  FHeader := (Source as TSigField).Header;
  FFieldType := (Source as TSigField).FieldType;
  FLength := (Source as TSigField).Length;
  FNumber := Number;
  FValues.Assign((Source as TSigField).Values);
  FEmpty := (Source as TSigField).Empty;
end;

function TSigField.IsTree: Boolean;
var
  i: integer;
begin
  Result := False;
  for i:=0 to Values.Count-1 do
    if Values[i][1]=' ' then begin
      Result := True;
      Exit;
    end;

end;

procedure TSigField.FillTreeValsCmb (fcTreecbb: TfcTreeCombo);
var
  i,j: integer;
begin
  with fcTreecbb do begin
    for i:=0 to FValues.Count-1 do begin
      if FValues[i][1]<>' ' then
        Items.Add(Items.FindNode((FValues[i]),False),FValues[i])
      else begin
        for j:=i-1 downto 0 do
          if TypeEditor.CountSpaces(FValues[i])-TypeEditor.CountSpaces(FValues[j]) = 1 then begin
            Items.AddChild(Items.FindNode(FValues[j],False),FValues[i]);
            Break;
          end;
      end;
    end;

  end;
end;

{ TSignal }

constructor TSignal.CreateLoad(SignalType: TSigType);
var
  i: integer;
  Fld: TSigField;
begin
  SigType := SignalType;
  FFields := TStringList.Create;
  with EditorForm.ibsqlSignals do begin
    FSigID := FieldByName('SIGNALID').AsInteger;
    FName := FieldByName('NAME').AsString;
    FInfo := FieldByName('INFO').AsString;
    {for i:=0 to SigType.Props.Count-1 do
      if ((TSigField(SigType.Props[i]).Header <> 'Имя') and (TSigField(SigType.Props[i]).Header <> 'Назначение')) then
        FFields.Add(TSigField(SigType.Props[i]).Header + '=');

      if ((FieldByName(TSigField(SigType.Props[i]).Name).AsString <> '') and (TSigField(SigType.Props[i]).Header <> 'Имя') and
      (TSigField(SigType.Props[i]).Header <> 'Назначение')) then
        with FFields do begin
          Insert(IndexOf(TSigField(SigType.Props[i]).Header + '='),TSigField(SigType.Props[i]).Header + '=' +
          FieldByName(TSigField(SigType.Props[i]).Name).AsString);
          Delete(IndexOf(TSigField(SigType.Props[i]).Header + '='));
        end;
    end;}
    for i:=0 to SigType.Props.Count-1 do begin
      Fld := TSigField(SigType.Props[i]);
      if (Fld.Header <> 'Имя') and (Fld.Header <> 'Назначение') then
        FFields.Add(Fld.Header + '=' + FieldByName(Fld.Name).AsString);
    end;
  end;
end;

constructor TSignal.CreateNew;                                  
begin
  FSigID := 0;
  FFields := TStringList.Create;
end;

procedure TSignal.Delete;
begin
  with EditorForm.ibsqlSignals do begin
    SQL.Text := 'DELETE FROM SIGNALS WHERE SIGNALID = :SigID';
    Prepare;
    Params[0].AsInteger := FSigID;
    ExecQuery;
    if FSigID > 0 then begin
      SQL.Text := 'DELETE FROM "'+SigType.Name+'" WHERE SIGNALID = :SigID';
      Prepare;
      Params[0].AsInteger := FSigID;
      ExecQuery;
      {for i:=0 to SigType.Signals.Count-1 do
        if TSignal(SigType.Signals[i]).SigID = FSigID then begin
          SigType.Signals.Delete(i);
          TSignal(SigType.Signals[i]).Free;
        end;}
      SigType.Signals.Remove(Self);
    end;
    FreeAndNil(Self);
    CheckSignals := True;
    SigEditorForm.btnSaveTable.Enabled := True;
  end;
end;

destructor TSignal.Free;
begin
  Fields.Free;
end;

procedure TTypeEditor.LoadUniqFields;
var
  i,j,k: integer;
  CheckType: Boolean;
begin
  for i:=0 to Types.Count-1 do
    if TSigType(Types[i]).Props.Count > 0 then begin
      for j:=0 to TSigType(Types[i]).Props.Count-1 do begin
        CheckType := False;
        for k:=0 to UniqFields.Count-1 do
          if TSigField(UniqFields[k]).Name = TSigField(TSigType(Types[i]).Props[j]).Name then
            CheckType := True;
          if not CheckType then
            UniqFields.Add(TSigField(TSigType(Types[i]).Props[j]));
      end;
    end;
end;

procedure TTypeEditor.CheckFieldInUniqList(FieldName: string);
var
  i,j,buttonSelected: integer;
  FieldExists, FieldMismatch: boolean;
begin
  FieldExists := false;
  FieldMismatch := False;
  with TpsEditorForm.SGPropsTable do begin
    for i:=0 to UniqFields.Count-1 do begin
      if ((FieldExists) and (not FieldMismatch)) then
        Exit;
      if FieldName=TSigField(UniqFields[i]).Name then begin
        FieldExists := True;
        if Cells[3,Row] <> TSigField(UniqFields[i]).Header then
          FieldMismatch := True;
        if Cells[4,Row] <> TSigField(UniqFields[i]).FieldType then
          FieldMismatch := True;
        if Cells[5,Row] <> IntToStr(TSigField(UniqFields[i]).Length) then
          FieldMismatch := True;
        if not Assigned(CreateValuesList) then
            CreateValuesList := TStringList.Create;
        if ((Cells[6,Row] <> '') and (Cells[6,Row] <> '(...)')) then
          CreateValuesList.CommaText := Cells[6,Row];
        if (((Cells[6,Row] <> '') and (TSigField(UniqFields[i]).Values.Count =0)) or ((Cells[6,Row] = '') and (TSigField(UniqFields[i]).Values.Count >0))
          or (CreateValuesList.CommaText <> TSigField(UniqFields[i]).Values.CommaText)) then
          FieldMismatch := True;
        if ((Cells [7,Row] = 'Не пусто') and (TSigField(UniqFields[i]).Empty)) or ((Cells [7,Row] <> 'Не пусто') and (not TSigField(UniqFields[i]).Empty)) then
          FieldMismatch := True;
      end;
      if FieldMismatch and FieldExists then
        buttonSelected := MessageDlg('Поле '+FieldName+' уже существует в базе. Хотите изменить его свойства для всех типов?',
        mtWarning,mbOKCancel,0);
      if buttonSelected=mrOk then begin
        SaveFieldChanges(UniqFields);
        for j:=0 to Types.Count-1 do
          if TSigType(Types[j]).Props.Count > 0 then
            SaveFieldChanges(TSigType(Types[j]).Props);
        Exit;
      end;
      if buttonSelected=mrCancel then begin
        Cells[3,Row] := TSigField(UniqFields[i]).Header;
        Cells[4,Row] := TSigField(UniqFields[i]).FieldType;
        Cells[5,Row] := IntToStr(TSigField(UniqFields[i]).Length);
        CreateValuesList := TSigField(UniqFields[i]).Values; //в CreateValuesList ВСЕГДА значение, которое мы хотим дать списку Values текущего поля, и даём мы его уже после выполнения этой функции
        if TSigField(UniqFields[i]).Empty then
          Cells[7,Row] := ''
        else
          Cells[7,Row] := 'Не пусто';
        Exit;
      end;
    end;
  end;
end;


procedure TTypeEditor.SaveFieldChanges(FieldList: TList);
var
  i: integer;
begin
  for i:=0 to FieldList.Count-1 do
    with TpsEditorForm.SGPropsTable do begin
      if Cells[2,Row] = TSigField(FieldList[i]).Name then begin
        TSigField(FieldList[i]).Header := Cells[3,Row];     //Поскольку в UniqFields хранится ссылка на поле какого-либо типа с соответствующим именем,
        TSigField(FieldList[i]).FieldType := Cells[4,Row];
        TSigField(FieldList[i]).Length := StrToInt(Cells[5,Row]); //можно позволить себе менять значения в UniqFields, не проводя какую-либо уникализацию этого списка в БД
                                                                  //а меняя одно поле с уникальным именем - меняются неуклонно свойства всех(либо не меняются свойства всех),
        if not Assigned(CreateValuesList) then    //CreateValuesList либо заполнен текущими для данного поля значениями, либо он еще не создан
          CreateValuesList := TStringList.Create;
        TSigField(FieldList[i]).Values := CreateValuesList;
        TSigField(FieldList[i]).Empty := Cells[7,Row] <> 'Не пусто';
      end;
    end;
end;

procedure TTypeEditor.DBReconnect;
begin
  EditorForm.ibdtbs1.Connected := False;
  EditorForm.ibdtbs1.Connected := True;
  EditorForm.ibtrnsctn1.Active := True;
end;

function TTypeEditor.GetCurTypeForSignals(ARow: integer): TSigType;
begin
  if SigEditorForm.SGSigTable.Cells[1,0] = 'Имя типа' then begin
    if SigEditorForm.SGSigTable.Cells[1,ARow] <> '' then
      Result := TSigType(SigEditorForm.TVSigTypes.Items.FindNode(SigEditorForm.SGSigTable.Cells[1,ARow],False).Data)
    else
      Result := nil;
  end else
    Result := TSigType(SigEditorForm.TVSigTypes.Selected.Data);
end;

procedure TSignal.SaveNewSignal;
var
  i,j: Integer;
begin
  with EditorForm.ibsqlSignals do begin
    SQL.Text := 'select gen_id(SIGNALIDGEN,1) from RDB$Database';
    ExecQuery;
    FSigID := Fields[0].AsInteger;
    Close;
  end;
  //SigType := TypeEditor.GetCurTypeForSignals(SigEditorForm.SGSigTable.Row);
  with SigEditorForm.SGSigTable do begin
    for i:=1 to ColCount-1 do
      if Cells[i,0] = 'Имя' then
        FName := Cells[i,Row]
      else if Cells[i,0] = 'Назначение' then
        FInfo := Cells[i,Row];
      FFields.Assign(TypeEditor.GetCurSignalFields);
  end;
  SigType.Signals.Add(Self);
  with EditorForm.ibsqlSignals do begin
    SQL.Text := 'INSERT INTO SIGNALS VALUES (:ID,:TypeName,:Name,:Info)';
    Prepare;
    Params[0].AsInteger := FSigID;
    Params[1].AsString := SigType.Name;
    Params[2].AsString := FName;
    Params[3].AsString := FInfo;
    ExecQuery;
    SQL.Text := 'INSERT INTO "' +SigType.Name+ '"(SIGNALID,NAME,INFO) VALUES (:ID,:Name,:Info)';
    Prepare;
    Params[0].AsInteger := FSigID;
    Params[1].AsString := FName;
    Params[2].AsString := FInfo;
    ExecQuery;
    for i:=0 to FFields.Count-1 do begin
      for j:=0 to SigType.Props.Count-1 do
        if TSigField(SigType.Props[j]).Header = FFields.Names[i] then begin
          SQL.Text := 'UPDATE "' +SigType.Name+ '" SET "' +TSigField(SigType.Props[j]).Name+ '" = :Value WHERE SIGNALID = :ID';
          Prepare;
          Params[0].AsString := FFields.ValueFromIndex[i];
          Params[1].AsInteger := FSigID;
          ExecQuery;
      end;
    end;
  end;
  CheckSignals := True;
end;

procedure TSignal.SetFields(Value: TStringList);
var
  i,j: integer;
begin
  if FFields.CommaText <> Value.CommaText then begin  //CommaText чтобы не проверяло одинаковые TStringList
    FFields.Assign(Value);
    Value.Free;
    for i:=0 to SigType.Props.Count-1 do begin
      if ((TSigField(SigType.Props[i]).Name <> 'NAME') and (TSigField(SigType.Props[i]).Name <> 'INFO')) then begin
        for j:=1 to SigEditorForm.SGSigTable.ColCount-1 do
          if SigEditorForm.SGSigTable.Cells[j,0] = TSigField(SigType.Props[i]).Header then
            with EditorForm.ibsqlSignals do begin
              SQL.Text := 'UPDATE "' +SigType.Name+ '" SET "' +TSigField(SigType.Props[i]).Name+ '" = :ColumnValue WHERE SIGNALID = :ID';
              Prepare;
              Params[0].AsString := SigEditorForm.SGSigTable.Cells[j,SigEditorForm.SGSigTable.Row];
              Params[1].AsInteger := FSigID;
              ExecQuery;
            end;
        //if SigEditorForm.pnlProps.Visible then
          for j:=1 to SigEditorForm.SGSigPropsTable.RowCount-1 do
            if SigEditorForm.SGSigPropsTable.Cells[0,j] = TSigField(SigType.Props[i]).Header then
              with EditorForm.ibsqlSignals do begin
                SQL.Text := 'UPDATE "' +SigType.Name+ '" SET "' +TSigField(SigType.Props[i]).Name+ '"= :ColumnValue WHERE SIGNALID = :ID';
                Prepare;
                Params[0].AsString := SigEditorForm.SGSigPropsTable.Cells[1,j];
                Params[1].AsInteger := FSigID;
                ExecQuery;
              end;
      end;
    end;
    CheckSignals := True;
  end;
end;

procedure TSignal.SetInfo(InfoValue: string);
begin
  if FInfo <> InfoValue then begin
    FInfo := InfoValue;
    with EditorForm.ibsqlSignals do begin
      SQL.Text := 'UPDATE SIGNALS SET INFO = :InfoValue WHERE SIGNALID = :ID';
      Prepare;
      Params[0].AsString := InfoValue;
      Params[1].AsInteger := FSigID;
      ExecQuery;
      SQL.Text := 'UPDATE "'+SigType.Name+'" SET INFO = :InfoValue WHERE SIGNALID = :ID';
      Prepare;
      Params[0].AsString := InfoValue;
      Params[1].AsInteger := FSigID;
      ExecQuery;
    end;
    CheckSignals := True;
  end;
end;

procedure TSignal.SetName(NameValue: string);
begin
  if FName <> NameValue then begin
    FName := NameValue;
    with EditorForm.ibsqlSignals do begin
      SQL.Text := 'UPDATE SIGNALS SET NAME = :NameValue WHERE SIGNALID = :ID';
      Prepare;
      Params[0].AsString := NameValue;
      Params[1].AsInteger := FSigID;
      ExecQuery;
      SQL.Text := 'UPDATE "'+SigType.Name+'" SET NAME = :NameValue WHERE SIGNALID = :ID';
      Prepare;
      Params[0].AsString := NameValue;
      Params[1].AsInteger := FSigID;
      ExecQuery;
    end;
    CheckSignals := True;
  end;
end;

function TTypeEditor.GetCurSignalFields: TStringList;
var
  i,j: integer;
  CheckFieldFilling: Boolean;
  SigType: TSigType;
begin
  Result := TStringList.Create;
  {with SigEditorForm.SGSigTable do begin
    for i:=1 to ColCount-1 do
      if ((Cells[i,0] <> 'Имя типа') and (Cells[i,0] <> 'Имя') and (Cells[i,0] <> 'Назначение')) then
        Result.Add(Cells[i,0]+ '=' +Cells[i,Row])
  end;
  with SigEditorForm.SGSigPropsTable do begin
    for i:=1 to RowCount-1 do
      Result.Add(Cells[0,i]+ '=' +Cells[1,i]);
  end;}
  with TSignal(SigEditorForm.SGSigTable.Objects[0,SigEditorForm.SGSigTable.Row]).FIelds do begin
    if Count = 0 then begin
      SigType := TSignal(SigEditorForm.SGSigTable.Objects[0,SigEditorForm.SGSigTable.Row]).SigType;
      for i:=0 to SigType.Props.Count-1 do
        if ((TSigField(SigType.Props[i]).Name <> 'NAME') and (TSigField(SigType.Props[i]).Name <> 'INFO')) then
          Result.Add(TSigField(SigType.Props[i]).Header + '=');
    end
    else
      for i:=0 to Count-1 do
        Result.Add(Names[i] + '=');
  end;
  for i:=0 to Result.Count-1 do begin
    CheckFieldFilling := False;
    with SigEditorForm.SGSigTable do begin
      for j:=0 to ColCount-1 do begin
        if CheckFieldFilling then
          Break;
        if Cells[j,0] = Result.Names[i] then begin
          Result[i] := Result[i]+Cells[j,Row];
          CheckFieldFilling := True;
        end;
      end;
    end;
    with SigEditorForm.SGSigPropsTable do begin
      for j:=1 to RowCount-1 do begin
        if CheckFieldFilling then
          Break;
        if Cells[0,j] = Result.Names[i] then begin
          Result[i] := Result[i]+Cells[1,j];
          CheckFieldFilling := True;
        end;
      end;
    end;
  end;
  for i:=0 to Result.Count-1 do
    with TSignal(SigEditorForm.SGSigTable.Objects[0,SigEditorForm.SGSigTable.Row]).SigType do begin
      for j:=0 to Props.Count-1 do
        if ((AnsiPos(',',Result[i]) <> 0) and (TSigField(Props[j]).FieldType = 'float')) then  //"," не воспринимается корректно при внесении float значения в бд. Поэтому программа заменяет "," на "."
          Result[i] := StringReplace(Result[i],',','.',[rfReplaceAll,rfIgnoreCase]);
    end;
  if Result.CommaText = '=' then
    Result.Clear;
end;

function TTypeEditor.GetCurInfo: string;
var
  i: integer;
begin
  with SigEditorForm.SGSigTable do begin
    for i:=1 to ColCount-1 do
      if Cells[i,0] = 'Назначение' then
        Result := Cells[i,Row]
  end;
end;

function TTypeEditor.GetCurName: string;
var
  i: integer;
begin
  with SigEditorForm.SGSigTable do begin
    for i:=1 to ColCount-1 do
      if Cells[i,0] = 'Имя' then
        Result := Cells[i,Row]
  end;
end;

procedure TTypeEditor.SaveSignals;
var
  buttonSelected: integer;
  Sender: TObject;
begin
  if CheckSignals then
    buttonSelected := MessageDlg('Сохранить изменения?',mtConfirmation,mbOKCancel,0);
    if buttonSelected = mrOk then begin
      SigEditorForm.btnSaveTableClick(Sender);
      EditorForm.ibtrnsctn1.CommitRetaining;
      CheckSignals := False;
    end
    else if buttonSelected = mrCancel then
      EditorForm.ibtrnsctn1.RollbackRetaining;
end;

function TTypeEditor.GetFieldList: TStringList;
var
  i: integer;
  EmptyCheck: Boolean;
begin
  Result := TStringList.Create;
  with TpsEditorForm.SGPropsTable do begin
    EmptyCheck := False;
    for i:=0 to 5 do
      EmptyCheck := Cells[i,Row]='';
    if EmptyCheck then
      MessageDlg('Заполните необходимые поля!',mtWarning,[mbOK],0)
    else begin
      for i:= 2 to ColCount-1 do
        Result.Add(Cells[i,Row]);
    end;
  end;
end;

function TTypeEditor.CountSpaces(Value: string): SmallInt;
var
  i: integer;
begin
  for i:=1 to Length(Value) do
    if Value[i] <> ' ' then begin
      Result := i;
      Exit;
    end;
end;

end.
