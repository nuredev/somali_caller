import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  RtcEngine? _engine;
  bool _isJoined = false;
  String? _currentChannel;
  int? _remoteUid;

  Future<void> initialize() async {
    final appId = dotenv.env['AGORA_APP_ID'];
    if (appId == null || appId.isEmpty) {
      throw Exception('AGORA_APP_ID not found in .env file');
    }

    _engine = await RtcEngine.create(appId);
    await _engine?.enableAudio();
    await _engine?.setChannelProfile(ChannelProfileType.channelProfileCommunication);
    
    _engine?.setEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print("✅ Joined channel: ${connection.channelId}");
          _isJoined = true;
        },
        onUserJoined: (connection, uid, elapsed) {
          print("👤 User joined: $uid");
          _remoteUid = uid;
        },
        onUserOffline: (connection, uid, reason) {
          print("👋 User left: $uid");
          _remoteUid = null;
        },
        onError: (err, msg) {
          print("❌ Error: $err - $msg");
        },
      ),
    );
  }

  Future<void> joinChannel(String channelName) async {
    if (_engine == null) await initialize();
    _currentChannel = channelName;
    await _engine?.joinChannel(token: '', channelId: channelName, uid: 0);
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
    _isJoined = false;
    _remoteUid = null;
    _currentChannel = null;
  }

  void muteMicrophone(bool muted) {
    _engine?.muteLocalAudioStream(muted);
  }

  void enableSpeakerphone(bool enabled) {
    _engine?.setEnableSpeakerphone(enabled);
  }

  bool get isJoined => _isJoined;
  int? get remoteUid => _remoteUid;
  String? get currentChannel => _currentChannel;

  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
  }
}
