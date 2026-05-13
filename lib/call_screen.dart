import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String phoneNumber;
  final String contactName;
  const CallScreen({super.key, required this.phoneNumber, required this.contactName});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isSpeaker = false;
  String _caption = "Captions will appear here during call...";
  String _callDuration = "00:00";
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  void _toggleMute() => setState(() => _isMuted = !_isMuted);
  void _toggleSpeaker() => setState(() => _isSpeaker = !_isSpeaker);
  void _endCall() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.green.shade900, Colors.black]),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    CircleAvatar(radius: 60, backgroundColor: Colors.green, child: Text(widget.contactName.isNotEmpty ? widget.contactName[0] : "?", style: const TextStyle(fontSize: 48, color: Colors.white))),
                    const SizedBox(height: 20),
                    Text(widget.contactName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.phoneNumber, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(_callDuration, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.3))),
                child: Text(_caption, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(icon: _isMuted ? Icons.mic_off : Icons.mic, label: "Mute", onPressed: _toggleMute, isActive: !_isMuted),
                    _buildControlButton(icon: _isSpeaker ? Icons.volume_up : Icons.volume_down, label: "Speaker", onPressed: _toggleSpeaker, isActive: _isSpeaker),
                    _buildControlButton(icon: Icons.call_end, label: "End", onPressed: _endCall, isActive: false, isEndCall: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, required VoidCallback onPressed, required bool isActive, bool isEndCall = false}) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, color: isEndCall ? Colors.red : (isActive ? Colors.green : Colors.white70)), iconSize: 32, onPressed: onPressed),
        Text(label, style: TextStyle(color: isEndCall ? Colors.red : (isActive ? Colors.green : Colors.white70), fontSize: 12)),
      ],
    );
  }
}
