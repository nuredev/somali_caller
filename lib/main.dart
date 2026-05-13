import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'keypad_page.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const SomaliCaller());
}

class SomaliCaller extends StatelessWidget {
  const SomaliCaller({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somali Caller',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade50,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const MainTabScreen(),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FavoritesPage(),
    const RecentsPage(),
    const ContactsPage(),
    const KeypadPage(),
    const VoicemailPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star_outline), activeIcon: Icon(Icons.star), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Recents'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts_outlined), activeIcon: Icon(Icons.contacts), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.dialpad), label: 'Keypad'),
          BottomNavigationBarItem(icon: Icon(Icons.voicemail), label: 'Voicemail'),
        ],
      ),
    );
  }
}

// ============================================================
// FAVORITES PAGE
// ============================================================
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = [
      {'name': 'Ahmed Hassan', 'number': '+252 61 1234567', 'initials': 'AH'},
      {'name': 'Fatima Ali', 'number': '+252 62 2345678', 'initials': 'FA'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final contact = favorites[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(contact['initials']!, style: TextStyle(color: Colors.green.shade700)),
            ),
            title: Text(contact['name']!),
            subtitle: Text(contact['number']!),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () => _showCallDialog(context, contact['name']!, contact['number']!),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// RECENTS PAGE
// ============================================================
class RecentsPage extends StatefulWidget {
  const RecentsPage({super.key});

  @override
  State<RecentsPage> createState() => _RecentsPageState();
}

class _RecentsPageState extends State<RecentsPage> {
  List<Map<String, dynamic>> recents = [
    {'name': 'Ahmed Hassan', 'number': '+252 61 1234567', 'type': 'incoming', 'time': 'Today', 'missed': false},
    {'name': 'Fatima Ali', 'number': '+252 62 2345678', 'type': 'outgoing', 'time': 'Yesterday', 'missed': false},
    {'name': 'Hassan Omar', 'number': '+252 63 3456789', 'type': 'incoming', 'time': 'Yesterday', 'missed': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recents'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: recents.length,
        itemBuilder: (context, index) {
          final call = recents[index];
          IconData icon;
          Color color;
          if (call['missed']) {
            icon = Icons.call_missed;
            color = Colors.red;
          } else if (call['type'] == 'incoming') {
            icon = Icons.call_received;
            color = Colors.green;
          } else {
            icon = Icons.call_made;
            color = Colors.blue;
          }
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(call['name'], style: call['missed'] ? const TextStyle(color: Colors.red) : null),
            subtitle: Text(call['number']),
            trailing: Text(call['time'], style: const TextStyle(color: Colors.grey)),
            onTap: () => _showCallDialog(context, call['name'], call['number']),
          );
        },
      ),
    );
  }
}

// ============================================================
// CONTACTS PAGE
// ============================================================
class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {'name': 'Ahmed Hassan', 'number': '+252 61 1234567', 'initials': 'AH'},
      {'name': 'Fatima Ali', 'number': '+252 62 2345678', 'initials': 'FA'},
      {'name': 'Hassan Omar', 'number': '+252 63 3456789', 'initials': 'HO'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(contact['initials']!, style: TextStyle(color: Colors.green.shade700)),
            ),
            title: Text(contact['name']!),
            subtitle: Text(contact['number']!),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () => _showCallDialog(context, contact['name']!, contact['number']!),
            ),
            onTap: () => _showContactOptions(context, contact['name']!, contact['number']!),
          );
        },
      ),
    );
  }
}

// ============================================================
// VOICEMAIL PAGE
// ============================================================
class VoicemailPage extends StatelessWidget {
  const VoicemailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voicemail'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.voicemail, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No Voicemails', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Call your voicemail to set up', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DIALOGS
// ============================================================

void _showCallDialog(BuildContext context, String name, String number) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(name[0], style: const TextStyle(color: Colors.green)),
            ),
            title: Text(name),
            subtitle: Text(number),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('Call'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.message, color: Colors.green),
            title: const Text('Message'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

void _showContactOptions(BuildContext context, String name, String number) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(name[0], style: const TextStyle(color: Colors.green)),
            ),
            title: Text(name),
            subtitle: Text(number),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('Call'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.message, color: Colors.green),
            title: const Text('Message'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.yellow),
            title: const Text('Add to Favorites'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
