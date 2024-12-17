import 'package:flutter/material.dart';
import 'package:momento/allocated_screen/chat_screen.dart';
import 'package:momento/allocated_screen/feedback_screen.dart';
import 'package:momento/allocated_screen/notifications_screen.dart';
import 'package:momento/controller/expenses.dart';
import 'package:momento/log_in/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildOptionCard(
            context,
            title: 'Chat & Q&A',
            icon: Icons.chat,
            color: Colors.blueAccent,
            screen: ChatScreen(),
          ),
          _buildOptionCard(
            context,
            title: 'Notifications',
            icon: Icons.notifications,
            color: Colors.orangeAccent,
            screen: NotificationScreen(),
          ),
          _buildOptionCard(
            context,
            title: 'Feedback',
            icon: Icons.feedback,
            color: Colors.greenAccent,
            screen: FeedbackScreen(),
          ),
          _buildOptionCard(
            context,
            title: 'Expenses',
            icon: Icons.attach_money,
            color: Colors.redAccent,
            screen: Expenses(),
          ),
          _buildOptionCard(
            context,
            title: 'Logout',
            icon: Icons.logout,
            color: Colors.grey,
            screen: Login(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () async {
        if (title == 'Logout') {
          await Supabase.instance.client.auth.signOut();
          Navigator.of(context)
              .pushNamedAndRemoveUntil('login', (route) => false);
        }
        if (title != 'Logout') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Colors.white),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
