program MavConsole;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {MainForm},
  uMavlink in 'uMavlink.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
