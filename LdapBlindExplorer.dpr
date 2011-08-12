program LdapBlindExplorer;

uses
  Forms,
  untMain in 'untMain.pas' {frmMain},
  untIniSettings in 'untIniSettings.pas',
  untVariables in 'untVariables.pas',
  untGenericProcedures in 'untGenericProcedures.pas',
  untLog in 'untLog.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

