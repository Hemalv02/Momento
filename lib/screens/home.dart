import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('create_event');
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF003675),
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      body: Container(),
    );
  }
}
