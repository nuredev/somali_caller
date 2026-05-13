import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'keypad_screen.dart';
import 'call_screen.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  await _requestPermissions();
  runApp(const SomaliCaller());
}

Future<void> _requestPermissions() async {
  await [Permission.microphone, Permission.camera].request();
}

class SomaliCaller extends StatefulWidget {
  const SomaliCaller({super.key});

  @override
  State<SomaliCaller> createState() => _SomaliCallerState();
}

class _SomaliCallerState extends State<SomaliCaller> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FavoritesScreen(),
    const RecentsScreen(),
    const ContactsScreen(),
    const KeypadScreen(),
    const VoicemailScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somali Caller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Recents'),
            BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
            BottomNavigationBarItem(icon: Icon(Icons.dialpad), label: 'Keypad'),
            BottomNavigationBarItem(icon: Icon(Icons.voicemail), label: 'Voicemail'),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FAVORITES SCREEN
// ============================================================
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> favorites = [
      {"name": "Ahmed Hassan", "number": "+252 61 1234567"},
      {"name": "Fatima Ali", "number": "+252 62 2345678"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Favorites', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final contact = favorites[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(contact['name']![0], style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(contact['name']!),
            subtitle: Text(contact['number']!),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () {
                _makeCall(context, contact['number']!, contact['name']!);
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// RECENTS SCREEN
// ============================================================
class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  void _showContactOptions(BuildContext context, String name, String number) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text("Message"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.green),
              title: const Text("Call"),
              onTap: () {
                Navigator.pop(context);
                _makeCall(context, number, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call, color: Colors.green),
              title: const Text("Video Call"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text("Block this Caller"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.green),
              title: const Text("Add to Contacts"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> callHistory = [
      {"name": "Ahmed Hassan", "number": "+252 61 1234567", "type": "Incoming", "duration": "5:23", "date": "Today", "missed": false},
      {"name": "Fatima Ali", "number": "+252 62 2345678", "type": "Outgoing", "duration": "2:15", "date": "Yesterday", "missed": false},
      {"name": "Hassan Omar", "number": "+252 63 3456789", "type": "Incoming", "duration": "", "date": "Yesterday", "missed": true},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Recents', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: callHistory.length,
        itemBuilder: (context, index) {
          final call = callHistory[index];
          IconData icon;
          Color iconColor;
          
          if (call['missed'] == true) {
            icon = Icons.call_missed;
            iconColor = Colors.red;
          } else if (call['type'] == "Incoming") {
            icon = Icons.call_received;
            iconColor = Colors.green;
          } else {
            icon = Icons.call_made;
            iconColor = Colors.blue;
          }
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            title: Text(call['name'], style: call['missed'] == true ? const TextStyle(color: Colors.red) : null),
            subtitle: Text(call['number']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.grey),
                  onPressed: () => _showContactOptions(context, call['name'], call['number']),
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _makeCall(context, call['number'], call['name']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// CONTACTS SCREEN
// ============================================================
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  void _showContactOptions(BuildContext context, String name, String number) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star, color: Colors.yellow),
              title: const Text("Add to Favorites"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text("Message"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.green),
              title: const Text("Call"),
              onTap: () {
                Navigator.pop(context);
                _makeCall(context, number, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Edit Contact"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Contact"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> contacts = [
      {"name": "Ahmed Hassan", "number": "+252 61 1234567"},
      {"name": "Fatima Ali", "number": "+252 62 2345678"},
      {"name": "Hassan Omar", "number": "+252 63 3456789"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Contacts', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add contact feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(contact['name']![0], style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(contact['name']!),
            subtitle: Text(contact['number']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.grey),
                  onPressed: () => _showContactOptions(context, contact['name']!, contact['number']!),
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _makeCall(context, contact['number']!, contact['name']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// VOICEMAIL SCREEN
// ============================================================
class VoicemailScreen extends StatelessWidget {
  const VoicemailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Voicemail', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.voicemail, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text("No Voicemails", style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 10),
            Text("Call your voicemail to set up", style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAKE CALL FUNCTION
// ============================================================
void _makeCall(BuildContext context, String number, String name) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CallScreen(
        phoneNumber: number,
        contactName: name,
      ),
    ),
  );
}
