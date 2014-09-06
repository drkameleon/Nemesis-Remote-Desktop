program NEMESIS;

uses
  Forms,
  Unit1NEMESIS in 'Unit1NEMESIS.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
