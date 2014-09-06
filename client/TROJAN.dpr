program TROJAN;

uses
  Forms,
  Unit1TROJAN in 'Unit1TROJAN.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
