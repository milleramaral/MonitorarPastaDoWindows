unit uMonitoradorDeDiretorio;

interface

uses
  Windows, Messages, SysUtils, Classes, uNotificadorDeAlteracaoNaPasta;

type

  EDiretorioInvalido = class(Exception);

  TArquivoAlterado = procedure(Sender: TObject; Arquivo: string) of object;

  TMonitoradorDeDiretorio = class(TComponent)
  private
    { Private declarations }
    FLista: TStringList;
    FNotificador: TNotificadorDeAlteracaoNaPasta;
    FAtivo: Boolean;
    FDiretorio: string;
    FAoExcluirUmArquivo: TArquivoAlterado;
    FAoAlterarUmArquivo: TArquivoAlterado;
    FAoIncluirUmArquivo: TArquivoAlterado;

    procedure PreencheLista(var Lista: TStringList);
    procedure AtualizarLista;

    procedure SetAtivo(const Value: Boolean);
    procedure SetDiretorio(const Value: string);

    procedure SetAoAlterarUmArquivo(const Value: TArquivoAlterado);
    procedure SetAoExcluirUmArquivo(const Value: TArquivoAlterado);
    procedure SetAoIncluirUmArquivo(const Value: TArquivoAlterado);

  protected
    procedure FinalizarNotificador;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ListaDeArquivos: string;

  published
    property Ativo: Boolean read FAtivo write SetAtivo;
    property Diretorio: string read FDiretorio write SetDiretorio;
    property AoIncluirUmArquivo: TArquivoAlterado read FAoIncluirUmArquivo write SetAoIncluirUmArquivo;
    property AoExcluirUmArquivo: TArquivoAlterado read FAoExcluirUmArquivo write SetAoExcluirUmArquivo;
    property AoAlterarUmArquivo: TArquivoAlterado read FAoAlterarUmArquivo write SetAoAlterarUmArquivo;
  end;

implementation

uses
  Vcl.Forms;

{ TMonitoraDiretorio }

procedure TMonitoradorDeDiretorio.PreencheLista(var Lista: TStringList);
var
  SRec: TSearchRec;
  Done: Integer;
begin
  // carrega o nome dos arquivos do diretório selecionado na lista
  Lista.Sorted := True;
  Done := FindFirst(IncludeTrailingPathDelimiter(Diretorio) + '*.*', 0, SRec);
  while Done = 0 do
  begin
    Lista.AddObject(FDiretorio + SRec.Name, TObject(SRec.Time));
    Done := FindNext(SRec);
  end;

  FindClose(SRec);
end;

procedure TMonitoradorDeDiretorio.AtualizarLista;
var
  NovaLista: TStringList;
  IndVelha, IndNova: Integer;
begin
  NovaLista := TStringList.Create;
  PreencheLista(NovaLista);

  IndVelha := 0;
  IndNova := 0;
  while (IndVelha < FLista.Count) and (IndNova < NovaLista.Count) do
  begin
    if FLista[IndVelha] > NovaLista[IndNova] then
    begin
      // Arquivo criado
      if Assigned(FAoIncluirUmArquivo) then
      begin
        FAoIncluirUmArquivo(Self, NovaLista[IndNova]);
      end;

      Inc(IndNova);
    end
    else
    begin
      if FLista[IndVelha] < NovaLista[IndNova] then
      begin
        // Arquivo excluído
        if Assigned(FAoExcluirUmArquivo) then
          FAoExcluirUmArquivo(Self, FLista[IndVelha]);
        Inc(IndVelha);
      end
      else
      begin
        // Arquivos iguais
        if (FLista.Objects[IndVelha] <> NovaLista.Objects[IndNova]) and Assigned(FAoAlterarUmArquivo) then
          FAoAlterarUmArquivo(Self, FLista[IndVelha]);

        Inc(IndVelha);
        Inc(IndNova);
      end;
    end;
  end;

  // Processa o final das listas
  while (IndVelha < FLista.Count) do
  begin
    if Assigned(FAoExcluirUmArquivo) then
      FAoExcluirUmArquivo(Self, FLista[IndVelha]);
    Inc(IndVelha);
  end;

  while (IndNova < NovaLista.Count) do
  begin
    if Assigned(FAoIncluirUmArquivo) then
      FAoIncluirUmArquivo(Self, NovaLista[IndNova]);
    Inc(IndNova);
  end;

  FLista.Assign(NovaLista);
  NovaLista.Free;
end;

constructor TMonitoradorDeDiretorio.Create(AOwner: TComponent);
begin
  inherited;
  FAtivo := False;
  FDiretorio := 'C:\';
  FLista := TStringList.Create;
end;

destructor TMonitoradorDeDiretorio.Destroy;
begin
  FinalizarNotificador;

  FLista.Free;
  inherited;
end;

procedure TMonitoradorDeDiretorio.FinalizarNotificador;
begin
  if Assigned(FNotificador) then
  begin
    FNotificador.Terminate;

    repeat
      Application.ProcessMessages;
    until (FNotificador.Finished);
  end;
end;

function TMonitoradorDeDiretorio.ListaDeArquivos: string;
begin
  Result := FLista.Text;
end;

procedure TMonitoradorDeDiretorio.SetAtivo(const Value: Boolean);
begin
  if (FAtivo = Value) then
  begin
    Exit;
  end
  else if (Value) then
  begin
    if FDiretorio = '' then
      raise EDiretorioInvalido.Create('Diretório não pode estar em branco');

    PreencheLista(FLista);
    FNotificador := TNotificadorDeAlteracaoNaPasta.Create(FDiretorio, AtualizarLista);
  end
  else
  begin
    FinalizarNotificador;
    FLista.Clear;
  end;
  FAtivo := Value;
end;

procedure TMonitoradorDeDiretorio.SetDiretorio(const Value: string);
begin
  if (FDiretorio <> Value) then
  begin
    if (FAtivo) then
    begin
      raise Exception.Create('Monitorador Ativo.');
    end
    else if (not DirectoryExists(Value, True)) then
    begin
      raise Exception.Create('Diretório não existe.');
    end
    else begin
      FDiretorio := IncludeTrailingPathDelimiter(Value);
    end;
  end;
end;

procedure TMonitoradorDeDiretorio.SetAoAlterarUmArquivo(const Value: TArquivoAlterado);
begin
  FAoAlterarUmArquivo := Value;
end;

procedure TMonitoradorDeDiretorio.SetAoExcluirUmArquivo(const Value: TArquivoAlterado);
begin
  FAoExcluirUmArquivo := Value;
end;

procedure TMonitoradorDeDiretorio.SetAoIncluirUmArquivo(const Value: TArquivoAlterado);
begin
  FAoIncluirUmArquivo := Value;
end;

end.
