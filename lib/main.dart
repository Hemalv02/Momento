import 'package:flutter/material.dart';
import 'package:main_project/Screens/CreateEventScreen.dart';
import 'package:main_project/Screens/GuestList.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:main_project/Screens/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'About.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await dotenv.load();
  
  
  final String supabaseUrl = dotenv.env['PROJECT_URL'] ?? '';
  final String supabaseKey = dotenv.env['SUPABASE_KEY'] ?? '';
  
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw Exception('Supabase credentials not found in .env file');
  }
  
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Momento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 2, 41, 73),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 33, 144, 235),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<({String title, Widget screen, IconData icon})> menuItems = [
      (
        title: 'About Us',
        screen:  AboutUsPage(),
        icon: Icons.info_outline
      ),
      (
        title: 'Create Event',
        screen: const CreateEventScreen(),
        icon: Icons.event_available
      ),
      (
        title: 'Guest List',
        screen: const GuestList(),
        icon: Icons.people_outline
      ),
      (
        title: 'Transactions',
        screen: const TransactionPage(),
        icon: Icons.account_balance_wallet_outlined
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Momento",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to Momento',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 2, 41, 73),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Event Management Solution',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => item.screen),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 40,
                            color: const Color.fromARGB(255, 33, 144, 235),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}