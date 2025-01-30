import 'package:flutter/material.dart';
import 'package:momento/screens/home.dart';
import 'package:momento/screens/profile/settings.dart';
import 'package:momento/screens/upcoming_events.dart';

class HomeStructure extends StatelessWidget {
  const HomeStructure({super.key});
  @override
  Widget build(BuildContext context) {
    return const TabbedPage();
  }
}

class TabbedPage extends StatefulWidget {
  const TabbedPage({super.key});
  @override
  State<TabbedPage> createState() => _TabbedPageState();
}

class _TabbedPageState extends State<TabbedPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const UpcomingEvents(),
    const SettingsScreen(),
    // const CreateProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Your Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: 'Upcoming Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF003675),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
