program SignalEditor;

uses
  Forms,
  TpsEditor in 'TpsEditor.pas' {TpsEditorForm},
  TypeCreator in 'TypeCreator.pas' {TypeCreateForm},
  FieldValuesList in 'FieldValuesList.pas' {FieldValuesListForm},
  SelArchField in 'SelArchField.pas' {SelArrchFieldForm},
  DelArchFields in 'DelArchFields.pas' {delArchFieldsForm},
  Editor in 'Editor.pas' {EditorForm},
  SigEditor in 'SigEditor.pas' {SigEditorForm},
  CreateDB in 'CreateDB.pas' {CreateDBForm},
  Base in 'Base.pas',
  ValuesHelp in 'ValuesHelp.pas' {ValuesHlpForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TEditorForm, EditorForm);
  Application.CreateForm(TTpsEditorForm, TpsEditorForm);
  Application.CreateForm(TTypeCreateForm, TypeCreateForm);
  Application.CreateForm(TFieldValuesListForm, FieldValuesListForm);
  Application.CreateForm(TSelArrchFieldForm, SelArrchFieldForm);
  Application.CreateForm(TdelArchFieldsForm, delArchFieldsForm);
  Application.CreateForm(TSigEditorForm, SigEditorForm);
  Application.CreateForm(TCreateDBForm, CreateDBForm);
  Application.CreateForm(TValuesHlpForm, ValuesHlpForm);
  Application.Run;
end.
