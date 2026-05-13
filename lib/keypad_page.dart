import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'call_screen.dart';

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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _makeCall() {
    if (_number.isNotEmpty) {
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
        onTap: () => setState(() => _number += digit),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(digit, style: const TextStyle(fontSize: 28)),
              if (letters.isNotEmpty) Text(letters, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keypad'), centerTitle: true,
        actions: [_number.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _number = '')) : Container()],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Text(_number.isEmpty ? "" : _number, style: const TextStyle(fontSize: 32)),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [_buildKey('1', ''), _buildKey('2', 'ABC'), _buildKey('3', 'DEF')]),
                  Row(children: [_buildKey('4', 'GHI'), _buildKey('5', 'JKL'), _buildKey('6', 'MNO')]),
                  Row(children: [_buildKey('7', 'PQRS'), _buildKey('8', 'TUV'), _buildKey('9', 'WXYZ')]),
                  Row(children: [_buildKey('*', ''), _buildKey('0', '+'), _buildKey('#', '')]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: _makeCall,
                child: Container(
                  width: 70, height: 70,
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
