unit uFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uMonitoradorDeDiretorio, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFrmPrincipal = class(TForm)
    Panel1: TPanel;
    edtPastaParaMonitorar: TEdit;
    lblPastaParaMonitorar: TLabel;
    btnIniciar: TButton;
    btnListarArquivos: TButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    GroupBox1: TGroupBox;
    mmoIncluidos: TMemo;
    GroupBox2: TGroupBox;
    mmoAlterados: TMemo;
    GroupBox3: TGroupBox;
    mmoExcluidos: TMemo;
    GroupBox4: TGroupBox;
    mmoListaDeArquivo: TMemo;
    btnParar: TButton;
    procedure btnIniciarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPararClick(Sender: TObject);
    procedure btnListarArquivosClick(Sender: TObject);
  private
    Monitor: TMonitoradorDeDiretorio;
    procedure AoIncluir(Sender: TObject; Arquivo: string);
    procedure AoAlterar(Sender: TObject; Arquivo: string);
    procedure AoExcluir(Sender: TObject; Arquivo: string);
  public
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

procedure TFrmPrincipal.AoAlterar(Sender: TObject; Arquivo: string);
begin
  mmoAlterados.Lines.Insert(0, FormatDateTime('hh:mm:sss:zzz ', Now)+' - ' + Arquivo );
end;

procedure TFrmPrincipal.AoExcluir(Sender: TObject; Arquivo: string);
begin
  mmoExcluidos.Lines.Insert(0, FormatDateTime('hh:mm:sss:zzz ', Now)+' - ' + Arquivo );
end;

procedure TFrmPrincipal.AoIncluir(Sender: TObject; Arquivo: string);
begin
  mmoIncluidos.Lines.Insert(0, FormatDateTime('hh:mm:sss:zzz ', Now)+' - ' + Arquivo );
end;

procedure TFrmPrincipal.btnIniciarClick(Sender: TObject);
begin
  Monitor.Ativo := False;
  Monitor.Diretorio := edtPastaParaMonitorar.Text;
  Monitor.Ativo := True;
  btnIniciar.Enabled := False;
  btnListarArquivos.Enabled := True;
end;

procedure TFrmPrincipal.btnPararClick(Sender: TObject);
begin
  Monitor.Ativo := False;
  btnIniciar.Enabled := True;
  btnListarArquivos.Enabled := False;
end;

procedure TFrmPrincipal.btnListarArquivosClick(Sender: TObject);
begin
  mmoListaDeArquivo.Text := Monitor.ListaDeArquivos;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  btnListarArquivos.Enabled := False;
  edtPastaParaMonitorar.Text := ExtractFilePath(Application.ExeName);

  Monitor := TMonitoradorDeDiretorio.Create(Self);
  Monitor.AoIncluirUmArquivo := AoIncluir;
  Monitor.AoAlterarUmArquivo := AoAlterar;
  Monitor.AoExcluirUmArquivo := AoExcluir;
end;

end.
