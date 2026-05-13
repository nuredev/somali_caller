import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class CaptionsService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _apiKey = '';
  
  CaptionsService() {
    _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  }

  Future<void> startCapturing() async {
    if (_apiKey.isEmpty) {
      print("❌ GROQ_API_KEY not found");
      return;
    }
    
    bool hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      print("❌ Microphone permission denied");
      return;
    }
    
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/capture.m4a';
    
    await _recorder.start(const RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 16000,
    ), path: path);
    
    _isRecording = true;
    print("🎤 Capturing audio for captions...");
  }

  Future<String?> stopAndTranscribe() async {
    if (!_isRecording) return null;
    
    final path = await _recorder.stop();
    _isRecording = false;
    
    if (path == null) return null;
    
    return await _transcribeAudio(path);
  }

  Future<String?> _transcribeAudio(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final base64Audio = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file': base64Audio,
          'model': 'whisper-large-v3-turbo',
          'language': 'so',
          'response_format': 'json',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'];
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
  
  bool get isCapturing => _isRecording;
  
  void dispose() {
    _recorder.dispose();
  }
}
