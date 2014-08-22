unit uNotificadorDeAlteracaoNaPasta;

interface

uses
  Windows, Messages, SysUtils, Classes;

type

  TNotificadorDeAlteracaoNaPasta = class(TThread)
  private
    { Private declarations }
    FHandle: THandle;
    Proc: TThreadProcedure;
  protected
    procedure Execute; override;

  public
    constructor Create(ADiretorio: string; AProc: TThreadProcedure); reintroduce;
    destructor Destroy; override;
  end;
implementation

{ TNotificadorDeAlteracaoNaPasta }

constructor TNotificadorDeAlteracaoNaPasta.Create(ADiretorio: string; AProc: TThreadProcedure);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  Priority := tpLowest;
  Proc := AProc;

  FHandle := FindFirstChangeNotification(PChar(ADiretorio), False,
    FILE_NOTIFY_CHANGE_FILE_NAME or FILE_NOTIFY_CHANGE_DIR_NAME or FILE_NOTIFY_CHANGE_ATTRIBUTES or
      FILE_NOTIFY_CHANGE_SIZE or FILE_NOTIFY_CHANGE_LAST_WRITE);
end;

destructor TNotificadorDeAlteracaoNaPasta.Destroy;
begin
  if (FHandle <> INVALID_HANDLE_VALUE) then
    FindCloseChangeNotification(FHandle);
  inherited;
end;

procedure TNotificadorDeAlteracaoNaPasta.Execute;
begin
  if (FHandle <> INVALID_HANDLE_VALUE) then
  begin
    while not Terminated do
    begin
      if WaitForSingleObject(FHandle, 1000) = WAIT_OBJECT_0 then
      begin // Caso tenha alguma mudança no diretório
        Synchronize(Proc);
      end;

      FindNextChangeNotification(FHandle);
    end;
  end;
end;

end.
