object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MavConsole'
  ClientHeight = 628
  ClientWidth = 1266
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 747
    Top = 97
    Width = 5
    Height = 531
    Align = alRight
    ExplicitLeft = 749
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 97
    Width = 747
    Height = 531
    ActivePage = TabConsole
    Align = alClient
    TabOrder = 0
    object TabConsole: TTabSheet
      Caption = 'Console'
      object MemoConsole: TRichEdit
        Left = 0
        Top = 0
        Width = 739
        Height = 462
        Align = alClient
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        Zoom = 100
      end
      object Panel1: TPanel
        Left = 0
        Top = 462
        Width = 739
        Height = 41
        Align = alBottom
        TabOrder = 1
        DesignSize = (
          739
          41)
        object EditConsoleCommand: TComboBox
          Left = 8
          Top = 8
          Width = 520
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnKeyDown = EditConsoleCommandKeyDown
        end
        object BtnConsoleSend: TButton
          Left = 534
          Top = 6
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Send'
          TabOrder = 1
          OnClick = BtnConsoleSendClick
        end
        object Button1: TButton
          Left = 655
          Top = 6
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Clear'
          TabOrder = 2
          OnClick = Button1Click
        end
      end
    end
    object TabFiles: TTabSheet
      Caption = 'Files'
      ImageIndex = 1
      object FilesTreeView: TTreeView
        Left = 0
        Top = 41
        Width = 739
        Height = 378
        Align = alClient
        Indent = 19
        TabOrder = 0
        OnAdvancedCustomDrawItem = FilesTreeViewAdvancedCustomDrawItem
        OnCreateNodeClass = FilesTreeViewCreateNodeClass
        OnExpanded = FilesTreeViewExpanded
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 739
        Height = 41
        Align = alTop
        TabOrder = 1
        object BtnFTPRefresh: TButton
          Left = 8
          Top = 8
          Width = 75
          Height = 25
          Caption = 'Refresh'
          TabOrder = 0
          OnClick = BtnFTPRefreshClick
        end
        object BtnFTPDownload: TButton
          Left = 96
          Top = 8
          Width = 75
          Height = 25
          Caption = 'Download'
          TabOrder = 1
          OnClick = BtnFTPDownloadClick
        end
      end
      object MemoFTPConsole: TRichEdit
        Left = 0
        Top = 419
        Width = 739
        Height = 84
        Align = alBottom
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 2
        WordWrap = False
        Zoom = 100
      end
    end
    object TabRawMavlink: TTabSheet
      Caption = 'RawMavlink'
      ImageIndex = 2
      object MemoRawMavlink: TRichEdit
        Left = 0
        Top = 0
        Width = 739
        Height = 432
        Align = alClient
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
        Zoom = 100
      end
      object Panel3: TPanel
        Left = 0
        Top = 432
        Width = 739
        Height = 71
        Align = alBottom
        TabOrder = 1
        DesignSize = (
          739
          71)
        object Label4: TLabel
          Left = 8
          Top = 11
          Width = 19
          Height = 13
          Caption = 'Msg'
        end
        object Label5: TLabel
          Left = 8
          Top = 42
          Width = 21
          Height = 13
          Caption = 'Cmd'
          Visible = False
        end
        object BtnSendRaw: TButton
          Left = 534
          Top = 6
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Send'
          TabOrder = 0
          OnClick = BtnSendRawClick
        end
        object EditCmdPayload: TComboBox
          Left = 136
          Top = 8
          Width = 392
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          OnKeyDown = EditConsoleCommandKeyDown
        end
        object Button3: TButton
          Left = 655
          Top = 6
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Clear'
          TabOrder = 2
          OnClick = Button3Click
        end
        object EditCmdID: TComboBox
          Left = 45
          Top = 8
          Width = 85
          Height = 21
          TabOrder = 3
          Text = '0'
        end
        object ComboBox1: TComboBox
          Left = 45
          Top = 39
          Width = 85
          Height = 21
          TabOrder = 4
          Text = '0'
          Visible = False
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1266
    Height = 97
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 10
      Width = 50
      Height = 13
      Caption = 'UDP Client'
    end
    object Label2: TLabel
      Left = 8
      Top = 38
      Width = 55
      Height = 13
      Caption = 'UDP Server'
    end
    object Label3: TLabel
      Left = 8
      Top = 66
      Width = 23
      Height = 13
      Caption = 'COM'
    end
    object IndicatorShapeUDPClient: TShape
      Left = 288
      Top = 10
      Width = 16
      Height = 16
      Brush.Color = clGray
      Shape = stCircle
    end
    object IndicatorShapeUDPServer: TShape
      Left = 288
      Top = 38
      Width = 16
      Height = 16
      Brush.Color = clGray
      Shape = stCircle
    end
    object IndicatorShapeCOM: TShape
      Left = 288
      Top = 66
      Width = 16
      Height = 16
      Brush.Color = clGray
      Shape = stCircle
    end
    object SpeedButton1: TSpeedButton
      Left = 45
      Top = 63
      Width = 21
      Height = 21
      Hint = 'Refresh list'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        1800000000000003000000000000000000000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFEFCFCFEFCFCFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFC4DBC31B78151B7815FDFCFCFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFDFCFB1B7A188CBC8AFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF8CBD8D1B7D1DC4DD
        C4FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFDFBFBFF00FFFF00FFFF
        00FFFF00FFFF00FF99C59C1B80228CBE8FFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFDFBFB1B8327FDFBFBFF00FFFF00FFFDFBFBFDFBFB7AB6811B83271B83
        27FDFBFBFDFBFBFF00FFFF00FFFF00FFFDFBFB1C872E1C872E1C872EFDFBFBFD
        FBFB1C872E1C872E1C872E1C872E1C872E1C872E1C872EFDFBFBFF00FFFDFCFC
        248F37248F37248F37248F37248F37FDFCFCFDFCFC248F37248F37248F37248F
        37248F37FDFCFCFF00FFFDFCFC329A45329A45329A45329A45329A45329A4532
        9A45FDFCFCFDFCFC329A45329A45329A45FDFCFCFF00FFFF00FFFF00FFFDFCFC
        FDFCFC40A45240A4528FCA9AFDFCFCFDFCFCFF00FFFF00FFFDFCFC40A452FDFC
        FCFF00FFFF00FFFF00FFFF00FFFF00FFFEFEFEA2D5AB49AB5AAEDAB6FF00FFFF
        00FFFF00FFFF00FFFF00FFFDFDFCFEFEFEFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFD1EAD651B161A6D8AFFDFDFDFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFCFCFCAADAB358B567FDFDFDFD
        FDFDFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFDFDFD5CB96B5CB96BD4EDD9FF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFAFBFBFDFDFDFDFDFDFA
        FBFBFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton1Click
    end
    object EditDestAddr: TComboBox
      Left = 72
      Top = 7
      Width = 113
      Height = 21
      TabOrder = 0
      Text = '192.168.1.255'
    end
    object EditDestPort: TComboBox
      Left = 192
      Top = 7
      Width = 81
      Height = 21
      ItemIndex = 0
      TabOrder = 1
      Text = '14555'
      Items.Strings = (
        '14555')
    end
    object EditCOMName: TComboBox
      Left = 72
      Top = 63
      Width = 113
      Height = 21
      TabOrder = 2
    end
    object EditCOMBaud: TComboBox
      Left = 192
      Top = 63
      Width = 81
      Height = 21
      ItemIndex = 2
      TabOrder = 3
      Text = '57600'
      Items.Strings = (
        '9600'
        '19200'
        '57600'
        '115200'
        '921600')
    end
    object EditSrvPort: TComboBox
      Left = 192
      Top = 35
      Width = 81
      Height = 21
      TabOrder = 4
      Text = '14550'
      Items.Strings = (
        '14550')
    end
    object BtnConnectUDPClient: TButton
      Tag = 1
      Left = 312
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 5
      OnClick = BtnConnectUDPClientClick
    end
    object BtnConnectUDPServer: TButton
      Tag = 2
      Left = 312
      Top = 33
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 6
      OnClick = BtnConnectUDPClientClick
    end
    object BtnConnectCOM: TButton
      Tag = 3
      Left = 312
      Top = 61
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 7
      OnClick = BtnConnectUDPClientClick
    end
    object CBSendHeartbeats: TCheckBox
      Left = 472
      Top = 37
      Width = 105
      Height = 17
      Caption = 'Send Heartbeats'
      Checked = True
      State = cbChecked
      TabOrder = 8
    end
    object CBDroneID: TCheckBox
      Left = 472
      Top = 9
      Width = 64
      Height = 17
      Caption = 'Only ID:'
      TabOrder = 9
    end
    object EditDroneID: TComboBox
      Left = 538
      Top = 7
      Width = 63
      Height = 21
      TabOrder = 10
    end
  end
  object Panel5: TPanel
    Left = 752
    Top = 97
    Width = 514
    Height = 531
    Align = alRight
    TabOrder = 2
    object MemoStatusText: TRichEdit
      Left = 1
      Top = 25
      Width = 512
      Height = 464
      Align = alClient
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      Zoom = 100
    end
    object Panel6: TPanel
      Left = 1
      Top = 489
      Width = 512
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        512
        41)
      object Button2: TButton
        Left = 429
        Top = 6
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Clear'
        TabOrder = 0
        OnClick = Button2Click
      end
    end
    object Panel7: TPanel
      Left = 1
      Top = 1
      Width = 512
      Height = 24
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = '  StatusText'
      TabOrder = 2
    end
  end
  object IdUDPClient1: TIdUDPClient
    BroadcastEnabled = True
    Port = 0
    Left = 100
    Top = 123
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 212
    Top = 123
  end
  object IdUDPServer1: TIdUDPServer
    Bindings = <>
    DefaultPort = 0
    Left = 100
    Top = 193
  end
  object SaveDialog1: TSaveDialog
    Left = 188
    Top = 193
  end
  object HBTimer: TTimer
    OnTimer = HBTimerTimer
    Left = 296
    Top = 128
  end
end
