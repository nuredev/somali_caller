import 'package:flutter/material.dart';
import 'call_screen.dart';

class KeypadScreen extends StatefulWidget {
  const KeypadScreen({super.key});

  @override
  State<KeypadScreen> createState() => _KeypadScreenState();
}

class _KeypadScreenState extends State<KeypadScreen> {
  String _phoneNumber = "";

  void _addDigit(String digit) {
    setState(() {
      _phoneNumber += digit;
    });
  }

  void _deleteDigit() {
    setState(() {
      if (_phoneNumber.isNotEmpty) {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      }
    });
  }

  void _clearNumber() {
    setState(() {
      _phoneNumber = "";
    });
  }

  void _makeCall() {
    if (_phoneNumber.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            phoneNumber: _phoneNumber,
            contactName: _phoneNumber,
          ),
        ),
      );
    }
  }

  Widget _buildDialButton(String digit, String letters) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: Colors.green.shade50,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => _addDigit(digit),
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(digit, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(letters, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Keypad', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _phoneNumber.isEmpty ? "Enter number" : _phoneNumber,
                    style: TextStyle(fontSize: 20, color: _phoneNumber.isEmpty ? Colors.grey : Colors.black),
                  ),
                ),
                IconButton(icon: const Icon(Icons.backspace, color: Colors.red), onPressed: _deleteDigit),
                if (_phoneNumber.isNotEmpty)
                  IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: _clearNumber),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(children: [_buildDialButton("1", ""), _buildDialButton("2", "ABC"), _buildDialButton("3", "DEF")]),
                  Row(children: [_buildDialButton("4", "GHI"), _buildDialButton("5", "JKL"), _buildDialButton("6", "MNO")]),
                  Row(children: [_buildDialButton("7", "PQRS"), _buildDialButton("8", "TUV"), _buildDialButton("9", "WXYZ")]),
                  Row(children: [_buildDialButton("*", ""), _buildDialButton("0", "+"), _buildDialButton("#", "")]),
                  const SizedBox(height: 8),
                  FloatingActionButton.extended(
                    onPressed: _makeCall,
                    backgroundColor: Colors.green,
                    icon: const Icon(Icons.call),
                    label: const Text("Call"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
