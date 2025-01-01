import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // back navigation logic
          },
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: const SettingsBody(),
    );
  }
}

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfileHeader(
          imagePath: 'images/anindya.jpg',
          userName: 'Anindya Kundu',
          joinedDate: 'Joined: 20 days ago',
        ),
        const SizedBox(height: 10),
        // Notification Setting
        SettingsTile(
          icon: Icons.notifications,
          title: 'Notification Setting',
          subtitle: 'Manage Notifications',
          onTap: () {
            // Navigate to Notification Setting Page
          },
        ),
        // App Language
        SettingsTile(
          icon: Icons.language,
          title: 'App Language',
          subtitle: 'English (Device Language)',
          onTap: () {
            // Navigate to App Language Page
          },
        ),
        // Contact Us
        SettingsTile(
          icon: Icons.mail_outline,
          title: 'Contact Us',
          subtitle: 'Support, Queries, Feedback',
          onTap: () {
            Navigator.pushNamed(context, '/feedbackpage');
          },
        ),
        // About the Developers
        SettingsTile(
          icon: Icons.info_outline,
          title: 'About The Developers',
          subtitle: 'Know more about the team',
          onTap: () {
            // Navigate to About Developers Page
          },
        ),
      ],
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String imagePath;
  final String userName;
  final String joinedDate;

  const ProfileHeader(
      {required this.imagePath,
      required this.userName,
      required this.joinedDate,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                joinedDate,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Widget for Settings Tile
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
