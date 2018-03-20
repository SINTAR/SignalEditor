unit TypeCreator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBLogDlg, Base;

type
  TTypeCreateForm = class(TForm)
    edtTypeName: TEdit;
    lbl1: TLabel;
    btnEditType: TButton;
    btnCancel: TButton;
    lbl2: TLabel;
    edtSignalDataType: TEdit;
    cbbSignalValueType: TComboBox;
    lbl3: TLabel;
    lbl4: TLabel;
    cbbNodeTypeChange: TComboBox;
    lbl5: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnEditTypeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TypeCreateForm: TTypeCreateForm;

implementation

uses TpsEditor,FieldValuesList,SelArchField,DelArchFields,Editor;

{$R *.dfm}

procedure TTypeCreateForm.btnCancelClick(Sender: TObject);
begin
  TypeCreateForm.Close;
end;

procedure TTypeCreateForm.btnEditTypeClick(Sender: TObject);
var
  buttonSelected,i: Integer;
begin
  CurType.Name := edtTypeName.Text;
  CurType.ValFldType := cbbSignalValueType.Text;
  CurType.DataType := edtSignalDataType.Text;
  TpsEditorForm.fctrvw1.Selected.Text := CurType.Name;
  if cbbNodeTypeChange.ItemIndex = 0 then begin
    if TpsEditorForm.fctrvw1.Selected.HasChildren then begin
      buttonSelected := MessageDlg('Установка типа листовым приведёт к удалению всех его потомков. Вы уверены, что хотите продолжить?',mtWarning,mbOKCancel,0);
      if buttonSelected = mrOK then begin
        if not CurType.CheckTableExist then
          CurType.AddTable;
        CurType.DeleteChildren;
      end;
    end;
  end else begin
    if CurType.Props.Count > 0 then begin
      buttonSelected := MessageDlg('Установка типа нелистовым приведёт к удалению всех его полей. Вы уверены, что хотите продолжить?',mtWarning,mbOKCancel,0);
      if buttonSelected = mrOK then begin
        with EditorForm.ibsqlTypes do begin
          if CurType.CheckTableExist then  begin
            SQL.Text := 'DROP TABLE "'+CurType.Name+'" ';
            SQL.Text := AnsiUpperCase(SQL.Text);
            ExecQuery;
            CheckTypes := True;
          end;
        end;
        for i:=0 to CurType.Props.Count-1 do begin
          TSigField(CurType.Props[i]).Free;
          TpsEditorForm.SGPropsTable.Rows[i+1].Clear;
        end;
        TpsEditorForm.SGPropsTable.RowHeights[1] :=0;
      end;
    end;
  end;
  TpsEditorForm.SGPropsTable.RowCount := 2;
  TpsEditorForm.SGPropsTable.RowHeights[1] := 0;
  CurType.ShowFields;
  TypeCreateForm.Close;
end;

procedure TTypeCreateForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  cbbSignalValueType.ClearSelection;
  cbbSignalValueType.Items := SignalValueTypes;
  edtTypeName.Enabled := True;
  with TpsEditorForm.fctrvw1.Selected do begin
    lbl4.Caption := 'Текущий родитель:  '+TSigType(Data).Parent.Name+'';
    edtTypeName.Text := TSigType(Data).Name;
    edtSignalDataType.Text := TSigType(Data).DataType;
    for i:=0 to cbbSignalValueType.Items.Count-1 do
      if cbbSignalValueType.Items[i] = TSigType(Data).ValFldType then
        cbbSignalValueType.ItemIndex := i;
    if CurType.Props.Count = 0 then
      cbbNodeTypeChange.ItemIndex := 1
    else
      cbbNodeTypeChange.ItemIndex := 0;
    if CurType.CheckTableExist then
      edtTypeName.Enabled := False;
  end;
end;



end.
