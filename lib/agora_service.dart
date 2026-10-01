import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  RtcEngine? _engine;
  bool _isInCall = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  String? _currentChannel;

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
          _isInCall = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("👤 User joined: $remoteUid");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("👋 User left: $remoteUid");
        },
        onError: (int err, String msg) {
          print("❌ Agora Error: $err - $msg");
        },
      ),
    );
  }

  Future<void> startCall(String channelName) async {
    if (_engine == null) await initialize();
    _currentChannel = channelName;
    await _engine?.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> endCall() async {
    await _engine?.leaveChannel();
    _isInCall = false;
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

  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;

  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
  }
}
