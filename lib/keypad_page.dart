import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeypadPage extends StatefulWidget {
  const KeypadPage({super.key});

  @override
  State<KeypadPage> createState() => _KeypadPageState();
}

class _KeypadPageState extends State<KeypadPage> {
  String _number = '';

  @override
  void initState() {
    super.initState();
    // Lock to portrait mode (like Apple Phone app)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Restore rotation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _addDigit(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      _number += digit;
    });
  }

  void _deleteDigit() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_number.isNotEmpty) {
        _number = _number.substring(0, _number.length - 1);
      }
    });
  }

  void _clearNumber() {
    setState(() {
      _number = '';
    });
  }

  void _makeCall() {
    if (_number.isNotEmpty) {
      // Navigate to call screen (will implement real calling)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(phoneNumber: _number, contactName: _number),
        ),
      );
    }
  }

  Widget _buildKey(String digit, String letters) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _addDigit(digit),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 16
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(digit, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400)),
              if (letters.isNotEmpty)
                Text(letters, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keypad'),
        centerTitle: true,
        actions: [
          if (_number.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear), onPressed: _clearNumber),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            // Number display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              alignment: Alignment.center,
              child: Text(
                _number.isEmpty ? "" : _number,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              ),
            ),
            // Keypad grid
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [_buildKey('1', ''), _buildKey('2', 'ABC'), _buildKey('3', 'DEF')]),
                  const SizedBox(height: 8),
                  Row(children: [_buildKey('4', 'GHI'), _buildKey('5', 'JKL'), _buildKey('6', 'MNO')]),
                  const SizedBox(height: 8),
                  Row(children: [_buildKey('7', 'PQRS'), _buildKey('8', 'TUV'), _buildKey('9', 'WXYZ')]),
                  const SizedBox(height: 8),
                  Row(children: [_buildKey('*', ''), _buildKey('0', '+'), _buildKey('#', '')]),
                ],
              ),
            ),
            // Call button
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: _makeCall,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                  child: const Icon(Icons.phone, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple CallScreen for now
class CallScreen extends StatelessWidget {
  final String phoneNumber;
  final String contactName;
  const CallScreen({super.key, required this.phoneNumber, required this.contactName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text('Calling: $contactName', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text(phoneNumber, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.call_end),
              label: const Text('End Call'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
