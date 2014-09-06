object Form1: TForm1
  Left = 407
  Top = 159
  Width = 314
  Height = 113
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 40
    Width = 209
    Height = 65
    TabOrder = 0
  end
  object MediaPlayer1: TMediaPlayer
    Left = 16
    Top = 128
    Width = 253
    Height = 33
    TabOrder = 1
  end
  object toCONSOLE: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = toCONSOLEConnect
  end
  object fromCONSOLE: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = fromCONSOLEClientConnect
    OnClientDisconnect = fromCONSOLEClientDisconnect
    OnClientRead = fromCONSOLEClientRead
    Left = 64
  end
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
    Left = 104
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer2Timer
    Left = 136
  end
  object toTransferCONSOLE: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnRead = ClientRead
    Left = 32
  end
  object RETARD_TIMER: TTimer
    Enabled = False
    Interval = 10
    OnTimer = RETARD_TIMERTimer
    Left = 168
  end
  object Timer3: TTimer
    Enabled = False
    Interval = 45
    OnTimer = Timer3Timer
    Left = 200
  end
end
