unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, IdGlobal, IdUDPServer,
  IdSocketHandle, System.Math, System.StrUtils, Vcl.Buttons,

  uMavlink, uRS485Protocol, uUtil, uLogFile;

type
  TFileTreeNode = class (TTreeNode)
  public
    Path: string;
    Dir: Boolean;
    Size: Integer;
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
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure HBTimerTimer(Sender: TObject);
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
    RequestedPath: string;
    SavingFileTo: string;
    RequestedOffset: Integer;
    FTP_seq_number: Word;
    FTP_session: Byte;
    procedure AddLog(Memo: TRichEdit; Text: string; Color: TColor = clNone; MaxLines: Integer = -1);
    procedure ShowRawLog(Data: TBytes; Outgoing: Boolean);
    procedure ProcessInputBytes(ConnType: TConnType; const Data; Size: integer);
    procedure ProcessPacket(ConnType: TConnType; const Pkt: TBytes);
    procedure Process_Serial_Control(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_Serial_Control);
    procedure Process_File_Transfer_Protocol(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure Process_FTP_Resp_ListDirectory(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure Process_FTP_Resp_OpenFileRO(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure Process_FTP_Resp_ReadFile(System_id, Component_id, MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
    procedure Process_StatusText(System_id, Component_id, MessageID: Byte;
      const Msg: TMavMsg_StatusText);
    procedure UpdateStateUI();
    procedure RequestFileList(const Path: string; Offset: Integer);
    procedure RequestFileRead(Offset: Integer);
    function NewFTPPacket(): TMavMsg_File_Transfer_protocol;
    function ConnIndicatorColor(ConnType: TConnType): TColor;
  public
    { Public declarations }
    ComStream: THandleStream;
    LastRcvTime: array[TConnType] of Cardinal;
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
  Msg: TMavMsg_Serial_Control;
  s: AnsiString;
  ws: string;
begin
  EnsureConnected();

  ws := EditConsoleCommand.Text;
  if EditConsoleCommand.Items.IndexOf(ws) >= 0 then
    EditConsoleCommand.Items.Move(EditConsoleCommand.Items.IndexOf(ws), 0)
  else
    EditConsoleCommand.Items.Insert(0, ws);

  s := AnsiString(ws) + AnsiChar(#10);

  FillChar(Msg, SizeOf(Msg), 0);
  Msg.device := 10;  // Shell
  Msg.flags := 22;   // Respond Exclusive Multi
  Msg.count := Length(s);
  Move(s[Low(s)], Msg.data, Length(s));

  Send(SizeOf(Msg), MAVLINK_MSG_ID_SERIAL_CONTROL, Msg);

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

procedure TMainForm.BtnFTPDownloadClick(Sender: TObject);
var
  FNode: TFileTreeNode;
  Msg: TMavMsg_File_Transfer_protocol;
  s: AnsiString;
begin
  if FilesTreeView.Selected = nil then Exit;
  FNode := FilesTreeView.Selected as TFileTreeNode;
  if FNode.Dir then
    raise EInvalidUserInput.Create('Cannot download dir');

  SaveDialog1.FileName := FNode.Text;
  if not SaveDialog1.Execute() then Exit;
  SavingFileTo := SaveDialog1.FileName;

  Msg := NewFTPPacket();
  Msg.payload.opcode := MAV_FTP_OpenFileRO;
  s := AnsiString(FNode.Path);
  Msg.payload.size := Length(s);
  Move(s[1], Msg.payload.data[0], Length(s));

  AddLog(MemoFTPConsole, 'Downloading ' + FNode.Path + '...');
  Send(SizeOf(Msg), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg);
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
    RequestFileList(string(GetNodePath(Node, True)).Replace('\','/'), 0);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  IdUDPServer1.OnUDPRead:=IdUDPServer1UDPRead;
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
  PeerIP := ABinding.PeerIP;
  PeerPort := ABinding.PeerPort;
  //ProcessPacket(TBytes(AData));
  ProcessInputBytes(ctUDPServer, AData[0], Length(AData));
end;

function TMainForm.NewFTPPacket: TMavMsg_File_Transfer_protocol;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.target_network := 0;
  Result.target_system := 1;
  Result.target_component := 0;

  Inc(FTP_seq_number);
  Result.payload.seq_number := FTP_seq_number;
  Result.payload.session := FTP_session;
end;

procedure TMainForm.ProcessInputBytes(ConnType: TConnType; const Data; Size: integer);
var
  i, HdrSize, L: Integer;
  Pkt: TBytes;
begin
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
        ProcessPacket(ConnType, Pkt);
      end
      else
        Break;
    end
    else
      Break;
  end;
end;

procedure TMainForm.ProcessPacket(ConnType: TConnType; const Pkt: TBytes);
var
  PayloadLength,
//  PacketSequence,
  System_id,
  Component_id,
  MessageID: Byte;
  Payload: Pointer;
  Buf: array[0..255] of Byte;
  id: Byte;
begin
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

  // Filter by drone ID
  if EditDroneID.Items.IndexOf(IntToStr(System_id)) < 0 then
    EditDroneID.Items.Add(IntToStr(System_id));
  if CBDroneID.Checked then
    id := StrToIntDef(EditDroneID.Text, 255)
  else
    id := 255;
  if (id <> 255) and (System_id <> id) then Exit;

  LastRcvTime[ConnType] := GetTickCount();
  ShowRawLog(Pkt, False);

  case MessageID of
    MAVLINK_MSG_ID_SERIAL_CONTROL:
      begin
        Process_Serial_Control(System_id, Component_id, MessageID, TMavMsg_Serial_Control(Payload^));
      end;
    MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL:
      begin
        Process_File_Transfer_Protocol(System_id, Component_id, MessageID, TMavMsg_File_Transfer_protocol(Payload^));
      end;
    MAVLINK_MSG_ID_STATUSTEXT:
      begin
        Process_StatusText(System_id, Component_id, MessageID, TMavMsg_StatusText(Payload^));
      end;
  end;

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


procedure TMainForm.Process_File_Transfer_Protocol(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
var
  Err: Byte;
  Msg2: TMavMsg_File_Transfer_protocol;
begin
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
        end;
      end;
    MAV_FTP_NAK:
      begin
        Err := Msg.payload.data[0];
        if (Msg.payload.req_opcode = MAV_FTP_ListDirectory) and (Err = MAV_FTP_ERR_EOF) then
        begin
          RequestedPath := '';
        end
        else
        if (Msg.payload.req_opcode = MAV_FTP_ReadFile) and (Err = MAV_FTP_ERR_EOF) and (SavingFileTo <> '') then
        begin
          AddLog(MemoFTPConsole, 'Saved to ' + SavingFileTo);
          SavingFileTo := '';
          Msg2 := NewFTPPacket();
          Msg2.payload.opcode := MAV_FTP_TerminateSession;
          Send(SizeOf(Msg2), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg2);
        end
        else
          AddLog(MemoFTPConsole, 'ERROR: ' + IntToStr(Err));
      end;
  end;
end;

procedure TMainForm.Process_FTP_Resp_ListDirectory(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
var
  Node, Child: TFileTreeNode;
  i: Integer;
  s: AnsiString;
  ws, Name: string;
  a: TArray<string>;
  Dir: Boolean;
begin
  Node := GetTreeNode(FilesTreeView, AnsiString(RequestedPath.Replace('/', '\')), False, '/') as TFileTreeNode;
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

    Child := FilesTreeView.Items.AddChild(Node, Name) as TFileTreeNode;
    Child.Path := RequestedPath + '/' + Name;
    Child.Dir := Dir;
    Child.Size := StrToIntDef(a[i], -1);
    if Dir then
      FilesTreeView.Items.AddChild(Child, sLoadingFilesList);
  end;

  Node.Expand(False);

  RequestFileList(RequestedPath, RequestedOffset + Length(a));
end;

procedure TMainForm.Process_FTP_Resp_OpenFileRO(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
//var
//  Size: Integer;
begin
  FTP_session := Msg.payload.session;
  //Size := PInteger(@Msg.payload.data[0])^;

  RequestFileRead(0);
end;

procedure TMainForm.Process_FTP_Resp_ReadFile(System_id, Component_id,
  MessageID: Byte; const Msg: TMavMsg_File_Transfer_protocol);
var
  fs: TFileStream;
begin
  if SavingFileTo = '' then Exit;

  AddLog(MemoFTPConsole, IntToStr(RequestedOffset + Msg.payload.size) + ' bytes done');

  fs := TFileStream.Create(SavingFileTo, IfThen(RequestedOffset = 0, fmCreate, fmOpenReadWrite));
  try
    fs.Seek(RequestedOffset, soBeginning);
    fs.WriteBuffer(Msg.payload.data, Msg.payload.size);
  finally
    fs.Free;
  end;

  RequestFileRead(RequestedOffset + Msg.payload.size);
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

procedure TMainForm.RefreshComList;
begin
  GetAvailableComPorts(EditCOMName.Items);
  if (EditCOMName.Text = '') and (EditCOMName.Items.Count > 0) then
    EditCOMName.Text := EditCOMName.Items[0];
end;

procedure TMainForm.RequestFileList(const Path: string; Offset: Integer);
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

procedure TMainForm.RequestFileRead(Offset: Integer);
var
  Msg: TMavMsg_File_Transfer_protocol;
begin
  Msg := NewFTPPacket();
  Msg.payload.opcode := MAV_FTP_ReadFile;
  Msg.payload.size := Length(Msg.payload.data);
  Msg.payload.offset := Offset;
  RequestedOffset := Offset;

  Send(SizeOf(Msg), MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL, Msg);
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

const
  LogColors: array[Boolean] of tColor = (clBlack, clBlue);

procedure TMainForm.Send(PayloadLength, MessageID: Byte; const Payload);
var
  Buf: TBytes;
  id: Byte;
begin
  if CBDroneID.Checked then
    id := StrToInt(EditDroneID.Text)
  else
    id := 255;
  Buf := GenMavlinkPacket(PayloadLength, 0, id, 190, MessageID, Payload);
  Send(Buf);
end;

procedure TMainForm.ShowRawLog(Data: TBytes; Outgoing: Boolean);
begin
  WriteLogF('Pkts', AnsiString(Data2Hex(Data)), AnsiString(IfThen(Outgoing, ' < ', '   ')));
  if PageControl1.ActivePage = TabRawMavlink then
    AddLog(MemoRawMavlink, string(Data2Hex(Data, True)), LogColors[Outgoing], 100);
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

end.
