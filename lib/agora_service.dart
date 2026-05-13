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
  bool _isMuted = false;
  bool _isSpeakerOn = true;

  Future<void> initialize() async {
    final appId = dotenv.env['AGORA_APP_ID'];
    if (appId == null || appId.isEmpty) {
      throw Exception('AGORA_APP_ID not found in .env file');
    }

    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine?.enableAudio();
    await _engine?.setChannelProfile(ChannelProfileType.channelProfileCommunication);
    
    _engine?.setEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("✅ Joined channel: ${connection.channelId}");
          _isJoined = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("👤 User joined: $remoteUid");
          _remoteUid = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("👋 User left: $remoteUid");
          _remoteUid = null;
        },
        onError: (int err, String msg) {
          print("❌ Error: $err - $msg");
        },
      ),
    );
  }

  Future<void> joinChannel(String channelName) async {
    if (_engine == null) await initialize();
    _currentChannel = channelName;
    await _engine?.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
    _isJoined = false;
    _remoteUid = null;
    _currentChannel = null;
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _engine?.muteLocalAudioStream(_isMuted);
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    _engine?.setEnableSpeakerphone(_isSpeakerOn);
  }

  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isJoined => _isJoined;
  int? get remoteUid => _remoteUid;

  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
  }
}
