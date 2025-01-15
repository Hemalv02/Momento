import 'package:flutter/material.dart';
import 'package:momento/screens/home.dart';
import 'package:momento/screens/profile/create_profile.dart';
import 'package:momento/screens/profile/settings.dart';

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
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    SettingsScreen(),
    // CreateProfilePage()
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF003675), // Your specified color
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8, // Adds a subtle shadow
      ),
    );
  }
}
