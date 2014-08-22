program ExemploMonitorarPastaDoWindows;

uses
  Vcl.Forms,
  uFrmPrincipal in 'uFrmPrincipal.pas' {FrmPrincipal},
  uNotificadorDeAlteracaoNaPasta in 'uNotificadorDeAlteracaoNaPasta.pas',
  uMonitoradorDeDiretorio in 'uMonitoradorDeDiretorio.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
