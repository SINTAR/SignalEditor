unit SelArchField;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBSQL, IBDatabase, DB, DBLogDlg, StdCtrls, Grids, Base,
  IBCustomDataSet, IBQuery, Menus, fcTreeView, ComCtrls, ToolWin, ImgList, IniFiles;

type
  TSelArrchFieldForm = class(TForm)
    lbl1: TLabel;
    cbbSelArchField: TComboBox;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cbbSelArchFieldChange(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelArrchFieldForm: TSelArrchFieldForm;

implementation

uses TypeCreator,FieldValuesList,TpsEditor,DelArchFields,Editor;

{$R *.dfm}

procedure TSelArrchFieldForm.FormShow(Sender: TObject);
var
  i,j: integer;
  CheckField: Boolean;
begin
  cbbSelArchField.Items.Clear;
  btnOk.Enabled := False;
  for i:=0 to TypeEditor.FieldsArchive.Count-1 do begin
    CheckField := True;
    for j:=0 to CurType.Props.Count-1 do
      CheckField := CheckField and (TSigField(TypeEditor.FieldsArchive[i]).Name <> TSigField(CurType.Props[j]).Name);
    if CheckField then
      cbbSelArchField.Items.AddObject(TSigField(TypeEditor.FieldsArchive[i]).Name,TSigField(TypeEditor.FieldsArchive[i]));
  end;
end;

procedure TSelArrchFieldForm.btnCancelClick(Sender: TObject);
begin
  SelArrchFieldForm.Close;
end;

procedure TSelArrchFieldForm.cbbSelArchFieldChange(Sender: TObject);
begin
  btnOk.Enabled := True;
end;

procedure TSelArrchFieldForm.btnOkClick(Sender: TObject);
var
  FieldsList: TStringList;
begin
  FieldsList := TStringList.Create;
  CheckSender := True;
  with cbbSelArchField do begin
    FieldsList.Add(TSigField(Items.Objects[ItemIndex]).Name);
    FieldsList.Add(TSigField(Items.Objects[ItemIndex]).Header);
    FieldsList.Add(TSigField(Items.Objects[ItemIndex]).FieldType);
    FieldsList.Add(IntToStr(TSigField(Items.Objects[ItemIndex]).Length));
    if TSigField(Items.Objects[ItemIndex]).Values.Count > 1 then
      FieldsList.Add('(...)')
    else if TSigField(Items.Objects[ItemIndex]).Values.Count > 0 then
      FieldsList.Add(TSigField(Items.Objects[ItemIndex]).Values[0])
    else
      FieldsList.Add('');
    if TSigField(Items.Objects[ItemIndex]).Empty then
      FieldsList.Add('')
    else
      FieldsList.Add('Ќе пусто');
    CreateValuesList := TStringList.Create;
    CreateValuesList.Assign(TSigField(Items.Objects[ItemIndex]).Values);
    if not CurType.CheckTableExist then
      CurType.AddTable;
    CurType.Props.Add(TSigField.CreateNew);
    TSigField(CurType.Props[CurType.Props.Count-1]).Assign(TSigField(Items.Objects[ItemIndex]),CurType.Props.Count);
  end;
  {with myRect do begin
      Left := 2;
      Top := 2;
      Right := 2;
      Bottom := 2;
  end;
  TpsEditorForm.SGPropsTable.Selection := myRect;}
  TSigField(CurType.Props[CurType.Props.Count-1]).SaveNewField(FieldsList);
  TSigField(CurType.Props[CurType.Props.Count-1]).ShowField;
  //CreateValuesList.Assign(TSigField(TpsEditorForm.SGPropsTable.Objects[0,TpsEditorForm.SGPropsTable.Row]).Values);  //в CreateValuesList всегда должно быть актуальное значение дл€ пол€, с которого фокус уходит(Objects[0,Row])
  //TpsEditorForm.SGPropsTable.Row := TpsEditorForm.SGPropsTable.RowCount-1;  //смена строки дл€ сохранени€ в бд
  CreateValuesList.Clear;
  //TSigField(CurType.Props[CurType.Props.Count-1]).Number := TpsEditorForm.SGPropsTable.RowCount-1;
  FieldsList.Free;
  SelArrchFieldForm.Close;
  CheckSender := False;
end;

end.
