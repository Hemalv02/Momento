import 'package:flutter/material.dart';
import 'package:momento/screens/home.dart';
import 'package:momento/screens/profile_page.dart';

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
    ProfilePageBuilder(),
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
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
