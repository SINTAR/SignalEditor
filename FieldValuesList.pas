unit FieldValuesList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBLogDlg, Base, ExtCtrls, ComCtrls, ToolWin,
  ImgList;

type
  TFieldValuesListForm = class(TForm)
    mmoValuesList: TMemo;
    btnSaveValues: TButton;
    btnCancel: TButton;
    pnl1: TPanel;
    il1: TImageList;
    tlb1: TToolBar;
    btnHelp: TToolButton;
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveValuesClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
  end;

var
  FieldValuesListForm: TFieldValuesListForm;
  CreateValuesList: TStringList;

implementation

uses TpsEditor,TypeCreator,SelArchField,DelArchFields,ValuesHelp;

{$R *.dfm}

procedure TFieldValuesListForm.btnCancelClick(Sender: TObject);
begin
  FieldValuesListForm.Close;
end;

procedure TFieldValuesListForm.FormShow(Sender: TObject);
begin
  mmoValuesList.Lines.Clear;
  with CurType do
    if not (Props.Count < TpsEditorForm.SGPropsTable.RowCount-1) then
      mmoValuesList.Lines.CommaText:= TSigField(Props[TpsEditorForm.SGPropsTable.Row-1]).Values.CommaText;
end;

procedure TFieldValuesListForm.btnSaveValuesClick(Sender: TObject);
var
  EmptyCheck: Boolean;
  i: integer;
begin
  CreateValuesList := TStringList.Create;
  if mmoValuesList.Lines.CommaText <> '' then
    CreateValuesList.CommaText := mmoValuesList.Lines.CommaText;
  EmptyCheck := False;
  with TpsEditorForm.SGPropsTable do
  if CreateValuesList.Count = 0 then
    Cells[Col,Row] := ' '
  else if CreateValuesList.Count = 1 then
    Cells[Col,Row] := CreateValuesList[1]
  else
    Cells[Col,Row] := '(...)';
  with CurType do begin
    TpsEditorForm.btnSaveTableClick(Sender); //вызываетс€, чтобы сохранить поле, в которое будут вноситс€ значени€.
    if not (Props.Count < TpsEditorForm.SGPropsTable.RowCount-1) then begin
      TSigField(Props[TpsEditorForm.SGPropsTable.Row-1]).Values.Assign(CreateValuesList);
      FieldValuesListForm.Close;
      TpsEditorForm.btnSaveTable.Enabled := True;
    end else begin
      with TpsEditorForm.SGPropsTable do begin
        for i:=2 to ColCount-1 do begin
          if EmptyCheck then begin
            MessageDlg('«аполните необходимые характеристики пол€!',mtWarning,[mbOK],0);
            Break;
          end;
          if Cells[i,Row] = '' then
            EmptyCheck := True;
        end;
      end;
      end;
  end;
end;

procedure TFieldValuesListForm.btnHelpClick(Sender: TObject);
begin
  ValuesHlpForm.ShowModal;
end;

end.
