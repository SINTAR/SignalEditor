unit CreateDB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBSQL, IBDatabase, DB, DBLogDlg, StdCtrls, Grids, Base,
  IBCustomDataSet, IBQuery, Menus, fcTreeView, ComCtrls, ToolWin, ImgList, IniFiles,
  ExtCtrls, Buttons, FileCtrl, ShellCtrls;

type
  TCreateDBForm = class(TForm)
    pnlFolderTree: TPanel;
    tvSelectPath: TShellTreeView;
    btnCreate: TButton;
    btnCancel: TButton;
    lblBDName: TLabel;
    edtBDName: TEdit;
    lblParentFolder: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CreateDBForm: TCreateDBForm;

implementation

uses Editor;

{$R *.dfm}

procedure TCreateDBForm.btnCancelClick(Sender: TObject);
begin
  CreateDBForm.Close;
end;

procedure TCreateDBForm.btnCreateClick(Sender: TObject);
var
  IniFile: TIniFile;
  buttonSelected: Integer;
begin
  if tvSelectPath.Path = '' then begin
    MessageDlg('Выберите каталог!',mtInformation,[mbOK],0);
    Exit;
  end;
  if edtBDName.Text = '' then
    MessageDlg('Введите имя БД!',mtInformation,[mbOK],0)
  else begin
    if FileExists(tvSelectPath.Path + edtBDName.Text + '.IB') then begin
      buttonSelected := MessageDlg('Файл ' +tvSelectPath.Path+edtBDName.Text+ '.IB Уже существует. Хотите заменить?',mtInformation,mbOKCancel,0);
      if buttonSelected = mrOk then
        SysUtils.DeleteFile(tvSelectPath.Path + edtBDName.Text + '.IB')
      else
        Exit;
    end;
    CopyFile(PChar(GetCurrentDir + '\TYPES.IB'),PChar(tvSelectPath.Path + edtBDName.Text + '.IB'),True);
    with EditorForm.ibdtbs1 do begin
      Connected := False;
      Params.Clear;
      if Length(tvSelectPath.Path) > 3 then        //проверка на то, создаётся ли БД непосредственно на локальном диске. Если да - то второй слеш в пути на главной форме будет нкрасиво отображаться. А если БД лежит непосредственно на диске - то длина пути будет всегда равна 3  
        DatabaseName := tvSelectPath.Path + '\' + edtBDName.Text + '.IB'
      else
        DatabaseName := tvSelectPath.Path + edtBDName.Text + '.IB';
      {Params.Add('user ''SYSDBA'' password ''masterkey'' ');
      Params.Add('page_size 4096');
      Params.Add('default character set win1251');
      CreateDatabase;}
      Connected :=False;
      Params.Clear;
      LoginPrompt:=False;
      Params.Add('user_name=SYSDBA');
      Params.Add('password=masterkey');
      //Params.Add('lc_ctype=win1251');
      IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'config.ini');
      IniFile.WriteString('DATABASE','Name',DatabaseName);
      IniFile.Free;
      Connected := True;
      EditorForm.ibtrnsctn1.Active := True;
      EditorForm.edtBDName.Text := DatabaseName;
    end;
    CreateDBForm.Close;
  end;
end;

procedure TCreateDBForm.FormShow(Sender: TObject);
begin
  tvSelectPath.Path := EditorForm.ibdtbs1.DatabaseName;
end;

end.
