unit Editor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBSQL, IBDatabase, DB, DBLogDlg, StdCtrls, Grids, Base,
  IBCustomDataSet, IBQuery, Menus, fcTreeView, ComCtrls, ToolWin, ImgList, IniFiles,
  ExtCtrls, Buttons;

type
  TEditorForm = class(TForm)
    btnSigEditor: TBitBtn;
    btnTypesEditor: TBitBtn;
    ibdtbs1: TIBDatabase;
    ibsqlFields2: TIBSQL;
    ibsqlFields1: TIBSQL;
    ibsqlTypes: TIBSQL;
    dlgOpenDB: TOpenDialog;
    btnOpenDB: TBitBtn;
    lbl1: TLabel;
    edtBDName: TEdit;
    ibsqlArchive: TIBSQL;
    ibsqlSignals: TIBSQL;
    btnCreateDB: TBitBtn;
    ibtrnsctn1: TIBTransaction;
    procedure btnTypesEditorClick(Sender: TObject);
    procedure btnSigEditorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnOpenDBClick(Sender: TObject);
    procedure btnCreateDBClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure GetParams;
    procedure SetParams;
  end;

var
  EditorForm: TEditorForm;
  TypeEditor: TTypeEditor;

implementation

uses TpsEditor,SigEditor,CreateDB;

{$R *.dfm}


procedure TEditorForm.btnTypesEditorClick(Sender: TObject);
begin
  TpsEditorForm.ShowModal;
end;

procedure TEditorForm.btnSigEditorClick(Sender: TObject);
begin
  SigEditorForm.ShowModal;
end;

procedure TEditorForm.GetParams;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'config.ini');
  ibdtbs1.DatabaseName := IniFile.ReadString('DATABASE','Name',ibdtbs1.DatabaseName);
  if ibdtbs1.DatabaseName = '' then
    SetParams;
  IniFile.Free;
end;

procedure TEditorForm.SetParams;
var
  IniFile: TIniFile;
begin
  ibdtbs1.Connected := False;
  if dlgOpenDB.Execute then
    ibdtbs1.DatabaseName:=dlgOpenDB.FileName;
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'config.ini');
  IniFile.WriteString('DATABASE','Name',ibdtbs1.DatabaseName);
  IniFile.Free;
  ibdtbs1.Connected := True;
  ibtrnsctn1.Active := True;
end;

procedure TEditorForm.FormCreate(Sender: TObject);
begin
  GetParams;
  ibdtbs1.Params.Add('user_name=SYSDBA');
  ibdtbs1.Params.Add('password=masterkey');
  ibdtbs1.Connected:=True;
  ibtrnsctn1.Active := True;
end;

procedure TEditorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if TypeEditor <> nil then
    TypeEditor.Free;
end;

procedure TEditorForm.FormShow(Sender: TObject);
begin
  edtBDName.Text := ibdtbs1.DatabaseName;
end;

procedure TEditorForm.btnOpenDBClick(Sender: TObject);
begin
  SetParams;
  edtBDName.Text := ibdtbs1.DatabaseName;
end;

procedure TEditorForm.btnCreateDBClick(Sender: TObject);
begin
  CreateDBForm.ShowModal;
end;



end.
