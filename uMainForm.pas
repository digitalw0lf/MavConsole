unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, IdGlobal, IdUDPServer,
  IdSocketHandle, System.Math, System.StrUtils, Vcl.Buttons, Generics.Collections,

  uMavlink, uRS485Protocol, uUtil, uLogFile, Vcl.Samples.Gauges;

type
  TFileTreeNode = class (TTreeNode)
  public
    Path: string;
    Dir: Boolean;
    Size: Integer;
  end;

  TMavFTPClient = class
  private type
    TFileRange = record
      AStart, AEnd: Cardinal;
    end;
  private
    LastRcvTicks, LastSendTicks: Cardinal;
    procedure AddLog(Text: string; Color: TColor = clNone; MaxLines: Integer = -1);
    procedure Send(PayloadLength, MessageID: Byte; const Payload); overload;
    function RequestNextReadPortion(): Boolean;
    procedure AddReceivedPortion(AStart, AEnd: Cardinal);
  public
    RequestedPath: string;
    SavingFileTo: string;
    ExpectedFileSize: Cardinal;
    RequestedOffset: Integer;
    FTP_seq_number: Word;
    FTP_session: Byte;
    ReceivedRanges: TList<TFileRange>;
    procedure Process_File_Transfer_Protocol(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure Process_FTP_Resp_ListDirectory(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure Process_FTP_Resp_OpenFileRO(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure Process_FTP_Resp_ReadFile(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure Process_FTP_Resp_BurstReadFile(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure RequestFileList(const Path: string; Offset: Integer);
    procedure RequestFileRead(Offset, Size: Integer);
    procedure DeleteFile(const Path: string; IsDirectory: Boolean);
    procedure DownloadFile(const Path, SaveTo: string);
    procedure AbortOperation();
    function NewFTPPacket(): TMavMsg_File_Transfer_protocol;
    constructor Create();
    destructor Destroy(); override;
    procedure OnTimer();
  end;

  TMavlinkInspectorItem = record
    MessageCode: Integer;
    LastRcvTime: Cardinal;
    Interval: Double;  // Seconds
  end;

  TMavlinkInspector = class
  public
    Items: TArray<TMavlinkInspectorItem>;
    constructor Create();
    destructor Destroy(); override;
    procedure PacketRecieved();
  end;

  TMainForm = class(TForm)
    SpeedButton1: TSpeedButton;
    Panel5: TPanel;
    Splitter1: TSplitter;
    MemoStatusText: TRichEdit;
    Panel6: TPanel;
    Button2: TButton;
    Panel7: TPanel;
    CBSendHeartbeats: TCheckBox;
    HBTimer: TTimer;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    CBDroneID: TCheckBox;
    EditDroneID: TComboBox;
    BtnFTPDelete: TButton;
    ImgUDPServerInfo: TImage;
    TabMavlinkInspector: TTabSheet;
    ListView1: TListView;
    Gauge1: TGauge;
    LblDownloadProgress: TLabel;
    BtnFTPAbort: TButton;
    TabMotorTest: TTabSheet;
    TrackBar1: TTrackBar;
    LblMotorThro: TLabel;
    CBMotorTestEnable: TCheckBox;
    MemoPwrStatus: TMemo;
    Panel8: TPanel;
    CBRawMavlinkShowIn: TCheckBox;
    LblPktsPerSecond: TLabel;
    CBRawMavlinkShowDecoded: TCheckBox;
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure HBTimerTimer(Sender: TObject);
    procedure BtnFTPDeleteClick(Sender: TObject);
    procedure ImgUDPServerInfoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure BtnFTPAbortClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure CBMotorTestEnableClick(Sender: TObject);
  public type
    TConnType = (ctNone, ctUDPClient, ctUDPServer, ctCOMPort);
  published
    PageControl1: TPageControl;
    TabConsole: TTabSheet;
    TabFiles: TTabSheet;
    MemoConsole: TRichEdit;
    Panel1: TPanel;
    EditConsoleCommand: TComboBox;
    Panel2: TPanel;
    EditDestAddr: TComboBox;
    EditDestPort: TComboBox;
    BtnConsoleSend: TButton;
    IdUDPClient1: TIdUDPClient;
    EditCOMName: TComboBox;
    EditCOMBaud: TComboBox;
    Timer1: TTimer;
    TabRawMavlink: TTabSheet;
    MemoRawMavlink: TRichEdit;
    EditSrvPort: TComboBox;
    IdUDPServer1: TIdUDPServer;
    Button1: TButton;
    Panel3: TPanel;
    BtnSendRaw: TButton;
    BtnConnectUDPClient: TButton;
    EditCmdPayload: TComboBox;
    Button3: TButton;
    EditCmdID: TComboBox;
    FilesTreeView: TTreeView;
    Panel4: TPanel;
    BtnFTPRefresh: TButton;
    BtnFTPDownload: TButton;
    SaveDialog1: TSaveDialog;
    MemoFTPConsole: TRichEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    IndicatorShapeUDPClient: TShape;
    IndicatorShapeUDPServer: TShape;
    IndicatorShapeCOM: TShape;
    BtnConnectUDPServer: TButton;
    BtnConnectCOM: TButton;
    procedure BtnConsoleSendClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure EditConsoleCommandKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BtnConnectUDPClientClick(Sender: TObject);
    procedure BtnSendRawClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BtnFTPRefreshClick(Sender: TObject);
    procedure FilesTreeViewExpanded(Sender: TObject; Node: TTreeNode);
    procedure FilesTreeViewCreateNodeClass(Sender: TCustomTreeView;
      var NodeClass: TTreeNodeClass);
    procedure FilesTreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure BtnFTPDownloadClick(Sender: TObject);
  private
    { Private declarations }
    InputBuf: TBytes;
    PeerIP: string;
    PeerPort: Integer;
    MavFTPClient: TMavFTPClient;
    procedure AddLog(Memo: TRichEdit; Text: string; Color: TColor = clNone; MaxLines: Integer = -1);
    procedure ShowRawLog(Data: TBytes; Outgoing: Boolean);
    function ProcessInputBytes(ConnType: TConnType; const Data; Size: integer): Boolean;
    function ProcessPacket(ConnType: TConnType; const Pkt: TBytes): Boolean;
    procedure Process_Serial_Control(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_Serial_Control);
    procedure Process_StatusText(System_id, Component_id, MessageID: Byte;
      const Msg: TMavMsg_StatusText);
    procedure Process_Sys_Status(System_id, Component_id, MessageID: Byte;
      const Msg: TMavMsg_Sys_Status);
    procedure UpdateStateUI();
    function ConnIndicatorColor(ConnType: TConnType): TColor;
    procedure SendConsoleCmd(const Text: string);
  public
    { Public declarations }
    ComStream: THandleStream;
    LastRcvTime: array[TConnType] of Cardinal;
    ReceivedPkts: Integer;  // In last second
    InspectorItems: TList<TMavlinkInspectorItem>;
    procedure RefreshComList();
    procedure EnsureConnected();
    function Connected(ConnType: TConnType): Boolean;
    function HasPackets(ConnType: TConnType): Boolean;
    procedure Connect(ConnType: TConnType);
    procedure Disconnect(ConnType: TConnType);
    procedure Send(const Pkt: TBytes); overload;
    procedure Send(PayloadLength, MessageID: Byte; const Payload); overload;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

const
  sLoadingFilesList = '<loading...>';

  LogColors: array[Boolean] of tColor = (clBlack, clBlue);

procedure TMainForm.AddLog(Memo: TRichEdit; Text: string; Color: TColor;
  MaxLines: Integer);
begin
  if Color <> clNone then
  begin
    Memo.SelStart := Memo.GetTextLen;
    Memo.SelAttributes.Color := Color;
  end;

  Memo.Lines.Add(Text);
  if (MaxLines > 0) and (Memo.Lines.Count > MaxLines) then
    Memo.Lines.Clear();
  ShowMemoCaret(Memo, True);
end;

procedure TMainForm.BtnConnectUDPClientClick(Sender: TObject);
var
  ct: TConnType;
begin
  ct := TConnType((Sender as TButton).Tag);
  if Connected(ct) then
    Disconnect(ct)
  else
    Connect(ct);
end;

procedure TMainForm.BtnConsoleSendClick(Sender: TObject);
var
  ws: string;
begin
  EnsureConnected();

  ws := EditConsoleCommand.Text;
  if EditConsoleCommand.Items.IndexOf(ws) >= 0 then
    EditConsoleCommand.Items.Move(EditConsoleCommand.Items.IndexOf(ws), 0)
  else
    EditConsoleCommand.Items.Insert(0, ws);

  SendConsoleCmd(ws);

  EditConsoleCommand.Text := '';
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  MemoConsole.Lines.Clear;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  MemoStatusText.Lines.Clear();
end;

procedure TMainForm.BtnFTPAbortClick(Sender: TObject);
begin
  MavFTPClient.AbortOperation();
end;

procedure TMainForm.BtnFTPDeleteClick(Sender: TObject);
var
  FNode: TFileTreeNode;
begin
  if FilesTreeView.Selected = nil then Exit;
  FNode := FilesTreeView.Selected as TFileTreeNode;

  if Application.MessageBox(PChar('Delete ' + FNode.Path + ' ?'), 'Delete', MB_OKCANCEL) <> IDOK then Exit;

  MavFTPClient.DeleteFile(FNode.Path, FNode.Dir);
end;

procedure TMainForm.BtnFTPDownloadClick(Sender: TObject);
var
  FNode: TFileTreeNode;
begin
  if FilesTreeView.Selected = nil then Exit;
  FNode := FilesTreeView.Selected as TFileTreeNode;
  if FNode.Dir then
    raise EInvalidUserInput.Create('Cannot download dir');

  SaveDialog1.FileName := FNode.Text;
  if not SaveDialog1.Execute() then Exit;

  MavFTPClient.DownloadFile(FNode.Path, SaveDialog1.FileName);

end;

procedure TMainForm.BtnFTPRefreshClick(Sender: TObject);
var
  Node: tTreeNode;
begin
  FilesTreeView.Items.Clear();
  Node := FilesTreeView.Items.Add(nil, '/');
  FilesTreeView.Items.AddChild(Node, sLoadingFilesList);
  Node.Expand(False);
end;

procedure TMainForm.BtnSendRawClick(Sender: TObject);
var
  CmdID: Integer;
  Payload: TBytes;
  s: string;
begin
  EnsureConnected();

  s := EditCmdID.Text;
  CmdID := StrToInt(GetNextWord(s));
  Payload := HexToData(AnsiString(EditCmdPayload.Text));

  Send(Length(Payload), CmdID, Payload[0]);

//  EditCmdPayload.Text := '';
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  MemoRawMavlink.Lines.Clear;
end;

procedure TMainForm.CBMotorTestEnableClick(Sender: TObject);
begin
  TrackBar1.Position := 100;  // Inverted
  TrackBar1Change(Sender);
end;

procedure TMainForm.Connect(ConnType: TConnType);
begin
  if Connected(ConnType) then Exit;

  case ConnType of
    ctUDPClient:
      begin
        IdUDPClient1.Host := EditDestAddr.Text;
        IdUDPClient1.Port := StrToInt(EditDestPort.Text);
        IdUDPClient1.Connect();
      end;
    ctUDPServer:
      begin
        IdUDPServer1.DefaultPort := StrToInt(EditSrvPort.Text);
        IdUDPServer1.Active := True;
      end;
    ctCOMPort:
      begin
        OpenComPort(ComStream, True, EditCOMName.Text, StrToInt(EditCOMBaud.Text), ONESTOPBIT);
      end;
  end;

  UpdateStateUI();
end;

function TMainForm.Connected(ConnType: TConnType): Boolean;
begin
  case ConnType of
    ctUDPClient:
      Result := IdUDPClient1.Connected;
    ctUDPServer:
      Result := IdUDPServer1.Active;
    ctCOMPort:
      Result := (ComStream <> nil);
    else
      Result := False;
  end;
end;

procedure TMainForm.Disconnect(ConnType: TConnType);
begin
  case ConnType of
    ctUDPClient:
      IdUDPClient1.Disconnect();
    ctUDPServer:
      IdUDPServer1.Active := False;
    ctCOMPort:
      CloseComPort(ComStream);
  end;
  UpdateStateUI();
end;

procedure TMainForm.EditConsoleCommandKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  n: Integer;
begin
  if Key = VK_RETURN then
    BtnConsoleSend.Click;
  if ((Key = VK_UP) or (Key = VK_DOWN)) and
     (not EditConsoleCommand.DroppedDown) and
     (not (ssAlt in Shift)) then
  begin
    if Key = VK_UP then
    begin
      if EditConsoleCommand.Text = '' then
        n := 0
      else
        n := EditConsoleCommand.ItemIndex + 1;
    end
    else n := EditConsoleCommand.ItemIndex - 1;
    if (n >= 0) and (n < EditConsoleCommand.Items.Count) then
      EditConsoleCommand.ItemIndex := n;
    Key := 0;
  end;
end;

procedure TMainForm.EnsureConnected;
begin
  if not (Connected(ctUDPClient) or Connected(ctUDPServer) or Connected(ctCOMPort)) then
    raise EInvalidUserInput.Create('Not connected');
end;

procedure TMainForm.FilesTreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
  var PaintImages, DefaultDraw: Boolean);
var
  FNode: TFileTreeNode;
  s: string;
  R: TRect;
begin
  DefaultDraw := True;
  if Stage = cdPostPaint then
  begin
    if not (Node is TFileTreeNode) then
    begin
      Exit;
    end;

    FNode := TFileTreeNode(Node);
    s := Node.Text;
    if FNode.Dir then
      s := '[' + s + ']'
    else
      s := s + '    ' + IntToStr(FNode.Size) + ' bytes';

    R := Node.DisplayRect(True);
    Inc(R.Right, 100);
    if cdsSelected in State then
      Sender.Canvas.Brush.Color := clHighlight;
    
    Sender.Canvas.TextRect(R, R.Left, R.Top, s);

  end;
end;

procedure TMainForm.FilesTreeViewCreateNodeClass(Sender: TCustomTreeView;
  var NodeClass: TTreeNodeClass);
begin
  NodeClass := TFileTreeNode;
end;

procedure TMainForm.FilesTreeViewExpanded(Sender: TObject; Node: TTreeNode);
begin
  if (Node.Count = 1) and (Node.Item[0].Text = sLoadingFilesList) then
  begin
    MavFTPClient.RequestFileList(string(GetNodePath(Node, True)).Replace('\','/'), 0);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  InspectorItems := TList<TMavlinkInspectorItem>.Create();
  MavFTPClient := TMavFTPClient.Create();
  IdUDPServer1.OnUDPRead:=IdUDPServer1UDPRead;
  PageControl1.ActivePageIndex := 0;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  MavFTPClient.Free;
  InspectorItems.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  RefreshComList();
end;

function TMainForm.HasPackets(ConnType: TConnType): Boolean;
begin
  Result := (GetTickCount() - LastRcvTime[ConnType] < 5000);
end;

procedure TMainForm.HBTimerTimer(Sender: TObject);
var
  Msg: TMavMsg_Heartbeat;
begin
  LblPktsPerSecond.Caption := IntToStr(ReceivedPkts) + ' pkts/sec';
  ReceivedPkts := 0;

  if not CBSendHeartbeats.Checked then Exit;
  if not (Connected(ctUDPClient) or Connected(ctUDPServer) or Connected(ctCOMPort)) then Exit;

  ZeroMemory(@Msg, SizeOf(Msg));
  Msg.type_ := 6;  // GCS
  Msg.autopilot := 8;  // No autopilot
  Msg.mavlink_version := 3;

  Send(SizeOf(Msg), MAVLINK_MSG_ID_HEARTBEAT, Msg);
end;

procedure TMainForm.IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
begin
  if Application.Terminated then Exit;
  if ProcessInputBytes(ctUDPServer, AData[0], Length(AData)) then
  begin
    PeerIP := ABinding.PeerIP;
    PeerPort := ABinding.PeerPort;
  end;
end;

procedure TMainForm.ImgUDPServerInfoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  ImgUDPServerInfo.Hint := PeerIP + ':' + IntToStr(PeerPort);
  ImgUDPServerInfo.ShowHint := True;
end;

procedure TMavFTPClient.AbortOperation;
begin
  SavingFileTo := '';
end;

procedure TMavFTPClient.AddLog(Text: string; Color: TColor; MaxLines: Integer);
begin
  MainForm.AddLog(MainForm.MemoFTPConsole, Text, Color, MaxLines);
end;

procedure TMavFTPClient.AddReceivedPortion(AStart, AEnd: Cardinal);
var
  i: Integer;
  Range: TFileRange;
begin
  // Insert
  Range.AStart := AStart;
  Range.AEnd := AEnd;
  i := ReceivedRanges.Count;
  while (i > 0) and (ReceivedRanges[i-1].AStart > AStart) do
    Dec(i);
  ReceivedRanges.Insert(i, Range);

  // Merge with neighbors
  for i := ReceivedRanges.Count - 2 downto 0 do
  begin
    if ReceivedRanges[i].AEnd >= ReceivedRanges[i+1].AStart then
    begin
      Range.AStart := Min(ReceivedRanges[i].AStart, ReceivedRanges[i+1].AStart);
      Range.AEnd := Max(ReceivedRanges[i].AEnd, ReceivedRanges[i+1].AEnd);
      ReceivedRanges.Delete(i+1);
      ReceivedRanges[i] := Range;
    end;
  end;
end;

constructor TMavFTPClient.Create;
begin
  ReceivedRanges := TList<TFileRange>.Create();
end;

procedure TMavFTPClient.DeleteFile(const Path: string; IsDirectory: Boolean);
var
  Msg: TMavMsg_File_Transfer_protocol;
  s: AnsiString;
begin
  Msg := NewFTPPacket();
  if IsDirectory then
    Msg.payload.opcode := MAV_FTP_RemoveDirectory
  else
    Msg.payload.opcode := MAV_FTP_RemoveFile;

  s := AnsiString(Path);
  Msg.payload.size := Length(s);
  Move(s[1], Msg.payload.data[0], Length(s));

  AddLog('Deleting ' + Path + '...');
  Send(SizeOf(Msg), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg);
end;

destructor TMavFTPClient.Destroy;
begin
  ReceivedRanges.Free;
  inherited;
end;

procedure TMavFTPClient.DownloadFile(const Path, SaveTo: string);
var
  Msg: TMavMsg_File_Transfer_protocol;
  s: AnsiString;
begin
  SavingFileTo := SaveTo;
  System.SysUtils.DeleteFile(SaveTo);
  ReceivedRanges.Clear();
  ExpectedFileSize := 0;
  LastRcvTicks := GetTickCount();

  Msg := NewFTPPacket();
  Msg.payload.opcode := MAV_FTP_OpenFileRO;
  s := AnsiString(Path);
  Msg.payload.size := Length(s);
  Move(s[1], Msg.payload.data[0], Length(s));

  AddLog('Downloading ' + Path + '...');
  Send(SizeOf(Msg), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg);
end;

function TMavFTPClient.NewFTPPacket: TMavMsg_File_Transfer_protocol;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.target_network := 0;
  Result.target_system := 0;
  Result.target_component := 0;

  Inc(FTP_seq_number);
  Result.payload.seq_number := FTP_seq_number;
  Result.payload.session := FTP_session;
end;

procedure TMavFTPClient.OnTimer;
begin
  if (SavingFileTo <> '') and (ExpectedFileSize > 0) and
     (GetTickCount() - LastRcvTicks > 500) and (GetTickCount() - LastSendTicks > 500) then
    RequestNextReadPortion();
end;

function TMainForm.ProcessInputBytes(ConnType: TConnType; const Data; Size: integer): Boolean;
var
  i, HdrSize, L: Integer;
  Pkt: TBytes;
begin
  Result := False;
  InputBuf := InputBuf + MakeBytes(Data, Size);
  while InputBuf <> nil do
  begin
    i := 0;
    while (i < Length(InputBuf)) and (InputBuf[i] <> $FE) and (InputBuf[i] <> $FD) do
      Inc(i);
    Delete(InputBuf, 0, i);
    if InputBuf = nil then Break;
    if InputBuf[0] = $FD then HdrSize := 12
                         else HdrSize := 8;
    if (Length(InputBuf) >= HdrSize) then
    begin
      L := PByte(@InputBuf[1])^;
      if Length(InputBuf) >= HdrSize + L then
      begin
        Pkt := Copy(InputBuf, 0, HdrSize + L);
        Delete(InputBuf, 0, HdrSize + L);
        if ProcessPacket(ConnType, Pkt) then
          Result := True;
      end
      else
        Break;
    end
    else
      Break;
  end;
end;

function TMainForm.ProcessPacket(ConnType: TConnType; const Pkt: TBytes): Boolean;
var
  PayloadLength,
//  PacketSequence,
  System_id,
  Component_id: Byte;
  MessageID: Integer;
  Payload: Pointer;
  Buf: array[0..255] of Byte;
  Full_id, Filter_Id: string;  // CompID:SysID
begin
  Result := False;
  if Pkt[0] = $FE then
  begin
    PayloadLength  := Pkt[1];
  //  PacketSequence := Pkt[2];
    System_id      := Pkt[3];
    Component_id   := Pkt[4];
    MessageID      := Pkt[5];
    Payload        := @Pkt[6];
  end
  else if Pkt[0] = $FD then
  begin
    PayloadLength  := Pkt[1];
  //  PacketSequence := Pkt[4];
    System_id      := Pkt[5];
    Component_id   := Pkt[6];
    MessageID      := pWord(@Pkt[7])^;
    Payload        := @Pkt[10];
  end
  else
    Exit;
  // Mavlink2 truncates zero bytes at message end.
  ZeroMemory(@Buf[0], SizeOf(Buf));
  Move(Payload^, Buf, PayloadLength);
  Payload := @Buf[0];

  Full_id := IntToStr(Component_id) + ':' + IntToStr(System_id);
  // Filter by drone ID
  if EditDroneID.Items.IndexOf(Full_Id) < 0 then
    EditDroneID.Items.Add(Full_Id);
  if CBDroneID.Checked then
    Filter_Id := Trim(EditDroneID.Text)
  else
    Filter_Id := '';
  if (Filter_Id <> '') and (Full_Id <> Filter_Id) then Exit;

  LastRcvTime[ConnType] := GetTickCount();
  Inc(ReceivedPkts);
  ShowRawLog(Pkt, False);

  case MessageID of
    MAVLINK_MSG_ID_SERIAL_CONTROL:
      begin
        Process_Serial_Control(System_id, Component_id, MessageID, TMavMsg_Serial_Control(Payload^));
      end;
    MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL:
      begin
        MavFTPClient.Process_File_Transfer_Protocol(System_id, Component_id, MessageID, TMavMsg_File_Transfer_protocol(Payload^));
      end;
    MAVLINK_MSG_ID_STATUSTEXT:
      begin
        Process_StatusText(System_id, Component_id, MessageID, TMavMsg_StatusText(Payload^));
      end;
    MAVLINK_MSG_ID_SYS_STATUS:
      begin
        Process_Sys_Status(System_id, Component_id, MessageID, TMavMsg_Sys_Status(Payload^));
      end;
  end;
  Result := True;
end;

procedure TMainForm.Process_Serial_Control(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_Serial_Control);
var
  s: AnsiString;
  i: Integer;
  InEscape: Boolean;
begin
  s := '';
  InEscape := False;
  for i := 0 to Msg.count-1 do
  begin
    if Msg.data[i] = $1B then
      InEscape := True;
    if not InEscape then
      s := s + AnsiChar(Msg.data[i]);
    if (InEscape) and (Msg.data[i] <> Ord(AnsiChar('['))) and (Msg.data[i] >= $40) and (Msg.data[i] <= $7F) then
      InEscape := False;
  end;

  if s <> '' then
  begin
    MemoConsole.Text := MemoConsole.Text + string(s);
    AppendTextFile(ExePath+'console.log', s);
    ShowMemoCaret(MemoConsole, True);
  end;
end;


procedure TMavFTPClient.Process_File_Transfer_Protocol(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
var
  Err: Byte;
begin
  LastRcvTicks := GetTickCount();

  case Msg.payload.opcode of
    MAV_FTP_ACK:
      begin
        case Msg.payload.req_opcode of
          MAV_FTP_ListDirectory:
            begin
              Process_FTP_Resp_ListDirectory(System_id, Component_id, MessageID, Msg);
            end;
          MAV_FTP_OpenFileRO:
            begin
              Process_FTP_Resp_OpenFileRO(System_id, Component_id, MessageID, Msg);
            end;
          MAV_FTP_ReadFile:
            begin
              Process_FTP_Resp_ReadFile(System_id, Component_id, MessageID, Msg);
            end;
          MAV_FTP_BurstReadFile:
            begin
              Process_FTP_Resp_BurstReadFile(System_id, Component_id, MessageID, Msg);
            end;
          else
            AddLog('Done');
        end;
      end;
    MAV_FTP_NAK:
      begin
        Err := Msg.payload.data[0];
        if (Msg.payload.req_opcode = MAV_FTP_ListDirectory) and (Err = MAV_FTP_ERR_EOF) then
        begin
          RequestedPath := '';
        end
//        else
//        if ((Msg.payload.req_opcode = MAV_FTP_ReadFile)) and
//           (Err = MAV_FTP_ERR_EOF) and (SavingFileTo <> '') then
//        begin
//          AddLog('Saved to ' + SavingFileTo);
//          SavingFileTo := '';
//          Msg2 := NewFTPPacket();
//          Msg2.payload.opcode := MAV_FTP_TerminateSession;
//          Send(SizeOf(Msg2), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg2);
//        end
        else
        if (Msg.payload.req_opcode = MAV_FTP_BurstReadFile) and
           (Err = MAV_FTP_ERR_EOF) and (SavingFileTo <> '') then
        begin
          RequestNextReadPortion();
        end
        else
          AddLog('ERROR: ' + IntToStr(Err));
      end;
    MAV_FTP_BurstReadFile:
      begin
        Process_FTP_Resp_BurstReadFile(System_id, Component_id, MessageID, Msg);
      end;
  end;
end;

procedure TMavFTPClient.Process_FTP_Resp_BurstReadFile(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
var
  fs: TFileStream;
  Done: Integer;
begin
  if SavingFileTo = '' then Exit;

  fs := TFileStream.Create(SavingFileTo, IfThen(FileExists(SavingFileTo), fmOpenReadWrite, fmCreate));
  try
    fs.Seek(Msg.payload.offset, soBeginning);
    fs.WriteBuffer(Msg.payload.data, Msg.payload.size);
  finally
    fs.Free;
  end;

  AddReceivedPortion(Msg.payload.offset, Msg.payload.offset + Msg.payload.size);

  //AddLog(MemoFTPConsole, IntToStr(Msg.payload.offset + Msg.payload.size) + ' bytes done');
  Done := ReceivedRanges.Last.AEnd;
  if ExpectedFileSize > 0 then
    MainForm.Gauge1.Progress := Round(Done / ExpectedFileSize * 100);
  MainForm.LblDownloadProgress.Caption := Format('%d KB / %d KB', [Done div 1024, ExpectedFileSize div 1024]);

  if Msg.payload.burst_complete <> 0 then
    RequestNextReadPortion();
end;

procedure TMavFTPClient.Process_FTP_Resp_ListDirectory(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
var
  Node, Child: TFileTreeNode;
  i: Integer;
  s: AnsiString;
  ws, Name: string;
  a: TArray<string>;
  Dir: Boolean;
begin
  Node := GetTreeNode(MainForm.FilesTreeView, AnsiString(RequestedPath.Replace('/', '\')), False, '/') as TFileTreeNode;
  if Node = nil then Exit;
  if RequestedOffset = 0 then
    Node.DeleteChildren();
  s := MakeStr(Msg.payload.data[0], Msg.payload.size);
  ws := string(s);
  a := ws.Split([#0], TStringSplitoptions.ExcludeLastEmpty);

  for i := 0 to Length(a)-1 do
  begin
    if (a[i]='') or (a[i][1] = 'S') then Continue; // "Skip"
    Dir := (a[i][1] = 'D');
    Delete(a[i], 1, 1);
    Name := GetNextWord(a[i], #9);

    Child := MainForm.FilesTreeView.Items.AddChild(Node, Name) as TFileTreeNode;
    Child.Path := RequestedPath + '/' + Name;
    Child.Dir := Dir;
    Child.Size := StrToIntDef(a[i], -1);
    if Dir then
      MainForm.FilesTreeView.Items.AddChild(Child, sLoadingFilesList);
  end;

  Node.AlphaSort();
  Node.Expand(False);

  RequestFileList(RequestedPath, RequestedOffset + Length(a));
end;

procedure TMavFTPClient.Process_FTP_Resp_OpenFileRO(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
//var
//  Size: Integer;
begin
  FTP_session := Msg.payload.session;
  //Size := PInteger(@Msg.payload.data[0])^;
  ExpectedFileSize := PInteger(@Msg.payload.data[0])^;
//  ReceivedPtr := 0;

//  RequestFileRead(0);
  RequestNextReadPortion();
end;

procedure TMavFTPClient.Process_FTP_Resp_ReadFile(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
//var
//  fs: TFileStream;
begin
//  if SavingFileTo = '' then Exit;
//
//  AddLog(IntToStr(RequestedOffset + Msg.payload.size) + ' bytes done');
//
//  fs := TFileStream.Create(SavingFileTo, IfThen(RequestedOffset = 0, fmCreate, fmOpenReadWrite));
//  try
//    fs.Seek(RequestedOffset, soBeginning);
//    fs.WriteBuffer(Msg.payload.data, Msg.payload.size);
//  finally
//    fs.Free;
//  end;
//
//  RequestFileRead(RequestedOffset + Msg.payload.size);
end;

procedure TMainForm.Process_StatusText(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_StatusText);
const
  Severity:array[0..7] of string = (
    'EMRG',
    'ALRT',
    'CRIT',
    'ERRO',
    'WARN',
    'NOTE',
    'INFO',
    'DEBG');
var
  s: AnsiString;
  ws: string;
  sev: Integer;
begin
  s := MakeStr(Msg.text[0], Length(Msg.text));
  s := PAnsiChar(s);  // Till zero
  sev := BoundValue(Msg.severity, 0, 7);
  ws := '[' + Severity[sev] + '] ' + string(s);

  MemoStatusText.Lines.Add(DateTime2Str(Now(), 'hh:nn:ss.zzz') + '   ' + ws);
  //AppendTextFile(ExePath+'statustext.log', AnsiString(DateTime2Str(Now(), 'yyyy-mm-dd hh:nn:ss.zzz')) + s);
  WriteLogF('StatusText', s, '   ');
  ShowMemoCaret(MemoStatusText, True);
end;

procedure TMainForm.Process_Sys_Status(System_id, Component_id, MessageID: Byte;
  const Msg: TMavMsg_Sys_Status);
var
  s: string;
begin
  s := Format('V: %.2f' + sLineBreak +
              'A: %.2f' + sLineBreak +
              'P: %.2f' + sLineBreak , [Msg.voltage_battery / 1000, Msg.current_battery / 1000, Msg.voltage_battery / 1000 * Msg.current_battery / 1000 ]);
  MemoPwrStatus.Text := s;
end;

procedure TMainForm.RefreshComList;
begin
  GetAvailableComPorts(EditCOMName.Items);
  if (EditCOMName.Text = '') and (EditCOMName.Items.Count > 0) then
    EditCOMName.Text := EditCOMName.Items[0];
end;

procedure TMavFTPClient.RequestFileList(const Path: string; Offset: Integer);
var
  Msg: TMavMsg_File_Transfer_protocol;
  s: AnsiString;
begin
  RequestedPath := Path;

  Msg := NewFTPPacket();
  Msg.payload.opcode := MAV_FTP_ListDirectory;
  s := AnsiString(Path);
  Msg.payload.size := Length(s);
  Move(s[Low(s)], Msg.payload.data[0], Length(s));
  Msg.payload.offset := Offset;
  RequestedOffset := Offset;

  Send(SizeOf(Msg), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg);
end;

procedure TMavFTPClient.RequestFileRead(Offset, Size: Integer);
//const
//  BURST_READ_SIZE = 50000;
var
  Msg: TMavMsg_File_Transfer_protocol;
begin
  AddLog('Req ' + IntToStr(Offset) + ' ' + IntToStr(Size));

  Msg := NewFTPPacket();
//  Msg.payload.opcode := MAV_FTP_ReadFile;
//  Msg.payload.size := Length(Msg.payload.data);
//  Msg.payload.offset := Offset;
  Msg.payload.opcode := MAV_FTP_BurstReadFile;
  Msg.payload.size := 4;
  Msg.payload.offset := Offset;
  PCardinal(@Msg.payload.data)^ := Size; //BURST_READ_SIZE;

  RequestedOffset := Offset;

  Send(SizeOf(Msg), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg);
end;

function TMavFTPClient.RequestNextReadPortion(): Boolean;
// Returns False if all received
const
  BURST_READ_SIZE = 50000;
var
  Offset, Size: Cardinal;
  Msg2: TMavMsg_File_Transfer_protocol;
begin
  if SavingFileTo = '' then Exit(False);

  if (ExpectedFileSize = 0) or
     ((ReceivedRanges.Count = 1) and (ReceivedRanges[0].AStart = 0) and
      (ReceivedRanges[0].AEnd = ExpectedFileSize)) then
  begin
    AddLog('Saved to ' + SavingFileTo);
    SavingFileTo := '';
    Msg2 := NewFTPPacket();
    Msg2.payload.opcode := MAV_FTP_TerminateSession;
    Send(SizeOf(Msg2), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg2);
    Exit(False);
  end;

  if ReceivedRanges.Count = 0 then
  begin
    Offset := 0;
    Size := Min(BURST_READ_SIZE, ExpectedFileSize);
  end
  else
  if ReceivedRanges[0].AStart > 0 then
  begin
    Offset := 0;
    Size := ReceivedRanges[0].AStart;
  end
  else
  if ReceivedRanges.Count = 1 then
  begin
    Offset := ReceivedRanges[0].AEnd;
    Size := Min(BURST_READ_SIZE, ExpectedFileSize - Offset);
  end
  else
  begin
    Offset := ReceivedRanges[0].AEnd;
    Size := ReceivedRanges[1].AStart - ReceivedRanges[0].AEnd;
  end;

  RequestFileRead(Offset, Size);
  Result := True;
end;

procedure TMavFTPClient.Send(PayloadLength, MessageID: Byte; const Payload);
begin
  LastSendTicks := GetTickCount();
  MainForm.Send(PayloadLength, MessageID, Payload);
end;

procedure TMainForm.Send(const Pkt: TBytes);
begin
  ShowRawLog(Pkt, True);

  if Connected(ctUDPClient) then
  try
    IdUDPClient1.SendBuffer({EditDestAddr.Text, StrToInt(EditDestPort.Text),} TIdBytes(Pkt));
  except
    Disconnect(ctUDPClient);
    raise;
  end;

  if Connected(ctUDPServer) then
  try
    IdUDPServer1.SendBuffer(PeerIP, PeerPort, TIdBytes(Pkt));
  except
    Disconnect(ctUDPServer);
    raise;
  end;

  if Connected(ctCOMPort) then
  try
    ComStream.WriteBuffer(Pkt[0], Length(Pkt));
  except
    Disconnect(ctCOMPort);
    raise;
  end;
end;

procedure TMainForm.Send(PayloadLength, MessageID: Byte; const Payload);
var
  Buf: TBytes;
begin
  Buf := GenMavlinkPacket(PayloadLength, 0, 254, 190, MessageID, Payload);
  Send(Buf);
end;

procedure TMainForm.SendConsoleCmd(const Text: string);
var
  Msg: TMavMsg_Serial_Control;
  s: AnsiString;
begin

  s := AnsiString(Text);
  if not EndsStr(#10, Text) then
    s := s + AnsiChar(#10);

  FillChar(Msg, SizeOf(Msg), 0);
  Msg.device := 10;  // Shell
  Msg.flags := 22;   // Respond Exclusive Multi
  Msg.count := Length(s);
  Move(s[Low(s)], Msg.data, Length(s));

  Send(SizeOf(Msg), MAVLINK_MSG_ID_SERIAL_CONTROL, Msg);
end;

procedure TMainForm.ShowRawLog(Data: TBytes; Outgoing: Boolean);
var
  h1: PMavMessageHeaderV1;
  h2: PMavMessageHeaderV2;
begin
  WriteLogF('Pkts', AnsiString(Data2Hex(Data)), AnsiString(IfThen(Outgoing, ' < ', '   ')));
  if (PageControl1.ActivePage = TabRawMavlink) and (CBRawMavlinkShowIn.Checked) then
  begin
    AddLog(MemoRawMavlink, string(Data2Hex(Data, True)), LogColors[Outgoing], 100);
    if CBRawMavlinkShowDecoded.Checked then
    begin
      h1 := @Data[0]; h2 := @Data[0];
      case Data[0] of
        Mavlink_Magic_V1:
          AddLog(MemoRawMavlink, Format('v1 len:%d seq:%d sys:%d comp:%d msg:%d', [h1.Payload_legth, h1.Packet_sequence, h1.System_id, h1.Component_id, h1.Message_id]) , LogColors[Outgoing], 100);
        Mavlink_Magic_V2:
          AddLog(MemoRawMavlink, Format('v1 len:%d seq:%d sys:%d comp:%d msg:%d', [h2.Payload_legth, h2.Packet_sequence, h2.System_id, h2.Component_id, h2.Message_id]) , LogColors[Outgoing], 100);
      end;
    end;
  end;
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
  RefreshComList();
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
  i: Integer;
  Pkt: TBytes;
  s: AnsiString;
begin
  UpdateStateUI();

  // Receive by COM port
  if (Connected(ctCOMPort)) then
  begin
    s := ReadFromComPort(ComStream, 100000);
    ProcessInputBytes(ctCOMPort, s[1], Length(s));
  end;

  // Receive by UDP client
  if (Connected(ctUDPClient)) then
  begin
    SetLength(Pkt, 10000);
    while True do
    begin
      i := IdUDPClient1.ReceiveBuffer(TIdBytes(Pkt), 0);
      if i > 0 then
      begin
        ProcessInputBytes(ctUDPClient, Pkt[0], i);
      end
      else
        Break;
    end;
  end;

  MavFTPClient.OnTimer();
end;

procedure TMainForm.TrackBar1Change(Sender: TObject);
var
  p: Integer;
//  Msg: TMavMsg_Command_Long;
begin
  if not CBMotorTestEnable.Checked then Exit;
  EnsureConnected();

  p := 100 - TrackBar1.Position;
  LblMotorThro.Caption := IntToStr(p) + ' %';

//  FillChar(Msg, SizeOf(Msg), 0);
//  Msg.command := MAV_CMD_DO_MOTOR_TEST;
//  Msg.target_system := 1;
//  Msg.target_component := 0;
//  Msg.param1 := 1; // motor index
//  Msg.param2 := 0;
//  Msg.param3 := p;
//  Msg.param4 := 0;//3;
//  Msg.param5 := 0;
//  Msg.param6 := 2;
//  Msg.param7 := 0;
//
//  Send(SizeOf(Msg), MAVLINK_MSG_ID_COMMAND_LONG, Msg);

  SendConsoleCmd('c' + #10 + 'pwm test -c 1 -p ' + IntToStr(1000 + 10 * p) + #10);
end;

function TMainForm.ConnIndicatorColor(ConnType: TConnType): TColor;
begin
  if Connected(ConnType) then
  begin
    if HasPackets(ConnType) then
      Result := clGreen
    else
      Result := clYellow;
  end
  else
    Result := clLtGray;
end;

procedure TMainForm.UpdateStateUI;
begin
  IndicatorShapeUDPClient.Brush.Color := ConnIndicatorColor(ctUDPClient);
  if Connected(ctUDPClient) then
    BtnConnectUDPClient.Caption := 'Disconnect'
  else
    BtnConnectUDPClient.Caption := 'Connect';

  IndicatorShapeUDPServer.Brush.Color := ConnIndicatorColor(ctUDPServer);
  if Connected(ctUDPServer) then
    BtnConnectUDPServer.Caption := 'Disconnect'
  else
    BtnConnectUDPServer.Caption := 'Connect';

  IndicatorShapeCOM.Brush.Color := ConnIndicatorColor(ctCOMPort);
  if Connected(ctCOMPort) then
    BtnConnectCOM.Caption := 'Disconnect'
  else
    BtnConnectCOM.Caption := 'Connect';
end;

{ TMavlinkInspector }

constructor TMavlinkInspector.Create;
begin

end;

destructor TMavlinkInspector.Destroy;
begin

  inherited;
end;

procedure TMavlinkInspector.PacketRecieved;
begin

end;

end.
