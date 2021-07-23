unit uMavlink;

interface

uses
  System.SysUtils,

  uUtil, uCRC;

const
  MAVLINK_MSG_ID_HEARTBEAT = 0;
  MAVLINK_MSG_ID_SYS_STATUS = 1;
  MAVLINK_MSG_ID_COMMAND_LONG = 76;
  MAVLINK_MSG_ID_COMMAND_ACK = 77;
  MAVLINK_MSG_ID_FILE_TRANSFER_PROTOCOL = 110;
  MAVLINK_MSG_ID_SERIAL_CONTROL = 126;
  MAVLINK_MSG_ID_AUTOPILOT_VERSION = 148;
  MAVLINK_MSG_ID_DATA16 = 169;
  MAVLINK_MSG_ID_DATA64 = 171;
  MAVLINK_MSG_ID_HOME_POSITION = 242;
  MAVLINK_MSG_ID_STATUSTEXT = 253;

  // in COMMAND_LONG
  MAV_CMD_PREFLIGHT_REBOOT_SHUTDOWN = 246;
  MAV_CMD_GET_HOME_POSITION = 410;
  MAV_CMD_REQUEST_AUTOPILOT_CAPABILITIES = 520;

  MAV_FTP_None = 0;
  MAV_FTP_TerminateSession = 1;
  MAV_FTP_ResetSessions = 2;
  MAV_FTP_ListDirectory = 3;
  MAV_FTP_OpenFileRO = 4;
  MAV_FTP_ReadFile = 5;
  MAV_FTP_CreateFile = 6;
  MAV_FTP_WriteFile = 7;
  MAV_FTP_RemoveFile = 8;
  MAV_FTP_CreateDirectory = 9;
  MAV_FTP_RemoveDirectory = 10;
  MAV_FTP_OpenFileWO = 11;
  MAV_FTP_TruncateFile = 12;
  MAV_FTP_Rename = 13;
  MAV_FTP_CalcFileCRC32 = 14;
  MAV_FTP_BurstReadFile = 15;
  MAV_FTP_ACK = 128;
  MAV_FTP_NAK = 129;

  MAV_FTP_ERR_None = 0;
  MAV_FTP_ERR_Fail = 1;
  MAV_FTP_ERR_FailErrno = 2;
  MAV_FTP_ERR_InvalidDataSize = 3;
  MAV_FTP_ERR_InvalidSession = 4;
  MAV_FTP_ERR_NoSessionsAvailable = 5;
  MAV_FTP_ERR_EOF = 6;
  MAV_FTP_ERR_UnknownCommand = 7;
  MAV_FTP_ERR_FileExists = 8;
  MAV_FTP_ERR_FileProtected = 9;
  MAV_FTP_ERR_FileNotFound = 10;

type
  TMavMessageHeader = packed record
    Magic: Byte;
    Payload_legth: Byte;
    Packet_sequence: Byte;
    System_id: Byte;
    Component_id: Byte;
    Message_id: Byte;
  end;
  PMavMessageHeader = ^TMavMessageHeader;

  TMavMsg_Heartbeat = packed record
    custom_mode: Cardinal;
    type_:Byte;
    autopilot: Byte;
    base_mode: Byte;
    system_status: Byte;
    mavlink_version: Byte;
  end;

  TMavMsg_Sys_Status = packed record
    onboard_control_sensors_present: Cardinal;
    onboard_control_sensors_enabled: Cardinal;
    onboard_control_sensors_health: Cardinal;
    load: Word;
    voltage_battery: Word;
    current_battery: SmallInt;
    drop_rate_comm: Word;
    errors_comm: Word;
    errors_count1: Word;
    errors_count2: Word;
    errors_count3: Word;
    errors_count4: Word;
    battery_remaining: ShortInt;
  end;

  TFTP_Payload = packed record
    seq_number: Word;
    session: Byte;
    opcode: Byte;
    size: Byte;
    req_opcode: Byte;
    burst_complete: Byte;
    padding: Byte;
    offset: Cardinal;
    data: array[0..238] of Byte;
  end;

  TMavMsg_File_Transfer_protocol = packed record {110}
    target_network: Byte;
    target_system: Byte;
    target_component: Byte;
    case Byte of
      0: (payload_bytes: array[0..250] of Byte);
      1: (payload: TFTP_Payload);
  end;

  TMavMsg_Serial_Control = packed record {126}
    baudrate: Cardinal;
    timeout: Word;
    device: Byte;
    flags: Byte;
    count: Byte;
    data: array[0..69] of Byte;
  end;

  TMavMsg_Command_Long = packed record
    param1: Single;
    param2: Single;
    param3: Single;
    param4: Single;
    param5: Single;
    param6: Single;
    param7: Single;
    command: Word;
    target_system: Byte;
    target_component: Byte;
    confirmation: Byte;
  end;

  TMavMsg_Command_Ack = packed record
    command: Word;
    result: Byte;
    progress: Byte;
    result_param2: Integer;
    target_system: Byte;
    target_component: Byte;
  end;

  TMavMsg_Data16 = packed record
    type_: Byte;
    len: Byte;
    data: array[0..15] of Byte;
  end;

  TMavMsg_Data64 = packed record
    type_: Byte;
    len: Byte;
    data: array[0..63] of Byte;
  end;

  TData16_92 = packed record
    yaw: Word;  //Deg
    latitude: Integer;  // Deg*1e7
    longitude: Integer;
    altitude_ahrs: SmallInt;  // m*10
    altitude_gps_raw: SmallInt;  // m*10
    voltage: Word;  // mv
  end;

  TData16_93 = packed record
    gps_time: array[0..2] of Byte;  // int
    satellite_count: Byte;
    fix_type: Byte;
    dance_state: Byte;
    time_to_start: Integer;  // seconds to start
    time_to_land: Integer;  // seconds to land
    dance_ready_flag: Word;
  end;

  TData16_95 = packed record
    vib_x: SmallInt;  // *10  // vibrations
    vib_y: SmallInt;
    vib_z: SmallInt;
    hor_speed: SmallInt;  // m/s*100
    ver_speed: SmallInt;  // m/s*100
    t_boot: Cardinal;  // ms  // time since boot
  end;

  TData64_94 = packed record
    // DATA64 header
    type_: Byte;
    len: Byte;

    // first point position, x-y-z
    start_pos_local_x: Single;
    start_pos_local_y: Single;
    start_pos_local_z: Single;

    // max dance altitude
    dance_max_altitude: Single;

    // min dace altitude
    min_alt: SmallInt;

    // max distance from center
    dance_max_distance_from_center: Single;

    // max hor speed
    max_hor_speed: SmallInt;

    // max ver speed
    max_ver_speed: SmallInt;

    // max ang speed
    max_ang_speed: SmallInt;

    // fps
    fps: Single;

    // path length
    path_length: SmallInt;

    // finish mode
    finish_mode: Byte;

    // dance type
    dance_type: Byte;

    // fence crc
    fence_crc: Word;

    // dance start time
    start_time: array[0..2] of Byte;  // int

    // dance takeoff offset time
    takeoff_offset_time: SmallInt;

    // dance moving to position offset time
    moving_to_pos_offset_time: SmallInt;

    // land offset time
    land_offset_time: SmallInt;

    // dance takeoff altitude
    takeoff_altitude: Integer;

    // target
    target_lat: Integer;
    target_lon: Integer;
    target_alt: Integer;

    reserved: Byte;
  end;

  TMavMsg_Home_Position = packed record
    latitude: Integer; // deg*1e7
    longitude: Integer; // deg*1e7
    altitude: Integer; // mm, + up
    x: Single; // m
    y: Single; // m
    z: Single; // m
    q: array[0..3] of Single; //<  World to surface normal and heading transformation of the takeoff position. Used to indicate the heading and slope of the ground
    approach_x: Single; // m
    approach_y: Single; // m
    approach_z: Single; // m
//    time_usec: UInt64;  // [us] Timestamp (UNIX Epoch time or time since system boot). The receiving end can infer timestamp format (since 1.1.1970 or since system boot) by checking for the magnitude the number.
  end;

  TMavMsg_StatusText = packed record
    severity: Byte; //<  Severity of status. Relies on the definitions within RFC-5424.
    text: array[0..49] of AnsiChar; //<  Status text message, without null termination character
    id: Word; //<  Unique (opaque) identifier for this statustext message.  May be used to reassemble a logical long-statustext message from a sequence of chunks.  A value of zero indicates this is the only chunk in the sequence and the message can be emitted immediately.
    chunk_seq: Byte; //<  This chunk's sequence number; indexing is from zero.  Any null character in the text field is taken to mean this was the last chunk.
  end;

function GenMavlinkPacket(PayloadLength, PacketSequence, System_id, Component_id, MessageID: Byte; const Payload): TBytes;

implementation

const MAVLINK_MESSAGE_CRCS: array[0..249, 0..1] of Integer = ((0, 50), (1, 124), (2, 137), (4, 237), (5, 217), (6, 104), (7, 119), (8, 117), (11, 89), (20, 214), (21, 159), (22, 220), (23, 168), (24, 24), (25, 23), (26, 170), (27, 144), (28, 67), (29, 115),
  (30, 39), (31, 246), (32, 185), (33, 104), (34, 237), (35, 244), (36, 222), (37, 212), (38, 9), (39, 254), (40, 230), (41, 28), (42, 28), (43, 132), (44, 221), (45, 232), (46, 11), (47, 153), (48, 41), (49, 39), (50, 78), (51, 196), (52, 132), (54, 15),
  (55, 3), (61, 167), (62, 183), (63, 119), (64, 191), (65, 118), (66, 148), (67, 21), (69, 243), (70, 124), (73, 38), (74, 20), (75, 158), (76, 152), (77, 143), (81, 106), (82, 49), (83, 22), (84, 143), (85, 140), (86, 5), (87, 150), (89, 231), (90, 183),
  (91, 63), (92, 54), (93, 47), (100, 175), (101, 102), (102, 158), (103, 208), (104, 56), (105, 93), (106, 138), (107, 108), (108, 32), (109, 185), (110, 84), (111, 34), (112, 174), (113, 124), (114, 237), (115, 4), (116, 76), (117, 128), (118, 56), (119, 116),
  (120, 134), (121, 237), (122, 203), (123, 250), (124, 87), (125, 203), (126, 220), (127, 25), (128, 226), (129, 46), (130, 29), (131, 223), (132, 85), (133, 6), (134, 229), (135, 203), (136, 1), (137, 195), (138, 109), (139, 168), (140, 181), (141, 47), (142, 72),
  (143, 131), (144, 127), (146, 103), (147, 154), (148, 178), (149, 200), (150, 134), (151, 219), (152, 208), (153, 188), (154, 84), (155, 22), (156, 19), (157, 21), (158, 134), (160, 78), (161, 68), (162, 189), (163, 127), (164, 154), (165, 21), (166, 21),
  (167, 144), (168, 1), (169, 234), (170, 73), (171, 181), (172, 22), (173, 83), (174, 167), (175, 138), (176, 234), (177, 240), (178, 47), (179, 189), (180, 52), (181, 174), (182, 229), (183, 85), (184, 159), (185, 186), (186, 72), (191, 92), (192, 36), (193, 71),
  (194, 98), (195, 120), (200, 134), (201, 205), (214, 69), (215, 101), (216, 50), (217, 202), (218, 17), (219, 162), (226, 207), (230, 163), (231, 105), (232, 151), (233, 35), (234, 150), (235, 179), (241, 90), (242, 104), (243, 85), (244, 95), (245, 130),
  (246, 184), (247, 81), (248, 8), (249, 204), (250, 49), (251, 170), (252, 44), (253, 83), (254, 46), (256, 71), (257, 131), (258, 187), (259, 92), (260, 146), (261, 179), (262, 12), (263, 133), (264, 49), (265, 26), (266, 193), (267, 35), (268, 14), (269, 109),
  (270, 59), (299, 19), (300, 217), (310, 28), (311, 95), (320, 243), (321, 88), (322, 243), (323, 78), (324, 132), (330, 23), (331, 91), (332, 236), (333, 231), (334, 135), (335, 225), (340, 99), (350, 232), (360, 11), (365, 36), (370, 98), (371, 161), (375, 251),
  (380, 232), (385, 147), (390, 156), (9000, 113), (10001, 209), (10002, 186), (10003, 4), (11000, 134), (11001, 15), (11002, 234), (11003, 64), (11010, 46), (11011, 106), (11020, 205), (11030, 144), (11031, 133), (11032, 85), (12900, 197), (12901, 16),
  (12902, 254), (12903, 207), (12904, 177), (42000, 227), (42001, 239));

function Get_CRC_EXTRA(MessageID: Integer): Byte;
var
  i: Integer;
begin
  for i:=0 to High(MAVLINK_MESSAGE_CRCS) do
    if MAVLINK_MESSAGE_CRCS[i,0] = MessageID then
      Exit( MAVLINK_MESSAGE_CRCS[i,1] );
  Result := 0;
end;

function GenMavlinkPacket(PayloadLength, PacketSequence, System_id, Component_id, MessageID: Byte; const Payload): TBytes;
var
  Buf: TBytes;
  crc_extra: Byte;
  crc: Word;
begin
  crc_extra := Get_CRC_EXTRA(MessageID);

  Buf := [PayloadLength] + [PacketSequence] +
         [System_id] + [Component_id] +
         [MessageID] + MakeBytes(Payload, PayloadLength) + [crc_extra];
  crc := not CalcCRC16(@Buf[0], Length(Buf));
  Result := [$fe] + Copy(Buf, 0, Length(Buf)-1) + MakeBytes(crc, 2);
end;

end.
