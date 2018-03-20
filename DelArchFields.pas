unit DelArchFields;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBSQL, IBDatabase, DB, DBLogDlg, StdCtrls, Grids, Base,
  IBCustomDataSet, IBQuery, Menus, fcTreeView, ComCtrls, ToolWin, ImgList, IniFiles,
  CheckLst;

type
  TdelArchFieldsForm = class(TForm)
    chklstArchFields: TCheckListBox;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  delArchFieldsForm: TdelArchFieldsForm;

implementation

uses TypeCreator,FieldValuesList,TpsEditor,SelArchField,Editor;

{$R *.dfm}



procedure TdelArchFieldsForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  chklstArchFields.Items.Clear;
  for i:=0 to TypeEditor.FieldsArchive.Count-1 do
    chklstArchFields.AddItem(TSigField(TypeEditor.FieldsArchive[i]).Name,TSigField(TypeEditor.FieldsArchive[i]));
end;

procedure TdelArchFieldsForm.btnOkClick(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to chklstArchFields.Items.Count-1 do
    if chklstArchFields.Checked[i] then
      TSigField(chklstArchFields.Items.Objects[i]).DelFromArchive;
  delArchFieldsForm.Close;
end;

procedure TdelArchFieldsForm.btnCancelClick(Sender: TObject);
begin
  delArchFieldsForm.Close;
end;

end.
