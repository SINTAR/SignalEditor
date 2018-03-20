unit ValuesHelp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Base, ExtCtrls, StdCtrls, jpeg;

type
  TValuesHlpForm = class(TForm)
    mmo1: TMemo;
    img1: TImage;
    img2: TImage;
    lbl1: TLabel;
    lbl2: TLabel;
    btnClose: TButton;
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ValuesHlpForm: TValuesHlpForm;

implementation

uses FieldValuesList;

{$R *.dfm}

procedure TValuesHlpForm.btnCloseClick(Sender: TObject);
begin
  ValuesHlpForm.Close;
end;

end.
