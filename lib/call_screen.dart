import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class CallScreen extends StatefulWidget {
  final String phoneNumber;
  final String contactName;
  const CallScreen({super.key, required this.phoneNumber, required this.contactName});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String _callDuration = "00:00";
  int _seconds = 0;
  String _caption = "Tap 'Caption' button to transcribe";
  String _apiKey = '';
  bool _isRecording = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    print("API Key loaded: ${_apiKey.substring(0, 10)}...");
    _initRecorder();
    _startTimer();
  }

  void _initRecorder() async {
    await _recorder.openRecorder();
    print("Recorder opened");
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (mounted) {
      setState(() {
        _seconds++;
        int minutes = _seconds ~/ 60;
        int secs = _seconds % 60;
        _callDuration = "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
        _startTimer();
      });
    }
  }

  void _startRecording() async {
    if (_isRecording) return;
    
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/recording.wav';
      print("Recording to: $path");
      
      // Same format as working Somali STT
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );
      
      setState(() {
        _isRecording = true;
        _caption = "🔴 Recording... Speak Somali (5 seconds)";
      });
      
      await Future.delayed(const Duration(seconds: 5));
      
      final recordedPath = await _recorder.stopRecorder();
      print("Recorded path: $recordedPath");
      
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _caption = "🔄 Sending to Groq API...";
      });
      
      if (recordedPath != null) {
        await _sendToGroq(recordedPath);
      }
    } catch (e) {
      print("Recording error: $e");
      setState(() {
        _caption = "Error: $e";
        _isRecording = false;
        _isProcessing = false;
      });
    }
  }

  Future<void> _sendToGroq(String filePath) async {
    if (_apiKey.isEmpty) {
      setState(() {
        _caption = "No API Key";
        _isProcessing = false;
      });
      return;
    }
    
    try {
      final uri = Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions');
      
      // Use multipart request (this is what works with Groq)
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['model'] = 'whisper-large-v3-turbo';
      request.fields['language'] = 'so';
      request.fields['response_format'] = 'json';
      
      print("Sending request to Groq...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("API Response status: ${response.statusCode}");
      print("API Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['text'] ?? '';
        print("Raw transcription: $text");
        
        // Fix Somali spelling
        text = _fixSomaliSpelling(text);
        
        setState(() {
          _caption = text;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _caption = "API Error: ${response.statusCode}";
          _isProcessing = false;
        });
      }
    } catch (e) {
      print("Transcription error: $e");
      setState(() {
        _caption = "Error: $e";
        _isProcessing = false;
      });
    }
  }

  String _fixSomaliSpelling(String text) {
    String fixed = text.toLowerCase();
    fixed = fixed.replaceAll('abdullah', 'Cabdullahi');
    fixed = fixed.replaceAll('abdul', 'Cabdu');
    fixed = fixed.replaceAll('woriah', 'waryaa');
    fixed = fixed.replaceAll('seita hai', 'seetahay');
    fixed = fixed.replaceAll("a'", 'c');
    fixed = fixed.replaceAll("o'", 'c');
    return fixed;
  }

  void _endCall() async {
    await _recorder.closeRecorder();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.contactName.isNotEmpty ? widget.contactName[0] : "?",
                        style: const TextStyle(fontSize: 48, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(widget.contactName, style: const TextStyle(color: Colors.white, fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(widget.phoneNumber, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(_callDuration, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text("Somali Captions", style: TextStyle(color: Colors.green)),
                    const SizedBox(height: 12),
                    if (_isProcessing)
                      const CircularProgressIndicator()
                    else
                      Text(_caption, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      icon: _isRecording ? Icons.stop : Icons.mic,
                      label: _isRecording ? "Stop" : "Caption",
                      onPressed: _isRecording ? null : _startRecording,
                      isActive: true,
                    ),
                    _buildButton(
                      icon: Icons.call_end,
                      label: "End",
                      onPressed: _endCall,
                      isActive: false,
                      isEndCall: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback? onPressed, required bool isActive, bool isEndCall = false}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEndCall ? Colors.red : (isActive ? Colors.green : Colors.white.withOpacity(0.1)),
          ),
          child: IconButton(
            icon: Icon(icon, color: isEndCall ? Colors.white : Colors.white),
            iconSize: 28,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: isEndCall ? Colors.red : Colors.white70, fontSize: 12)),
      ],
    );
  }
}
