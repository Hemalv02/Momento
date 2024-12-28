import 'package:flutter/material.dart';

class EventHome extends StatefulWidget {
  const EventHome({super.key});

  @override
  State<EventHome> createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Dashboard'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 4, // Four items per row
                mainAxisSpacing: 24, // Increased space between rows
                crossAxisSpacing: 16,
                childAspectRatio: 0.9, // Adjusted for better fit
                shrinkWrap: true, // Fix for infinite height
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent nested scrolling
                children: [
                  _buildFeatureItem(
                    icon: Icons.people,
                    label: 'Guests',
                    onTap: () {
                      print('Guests tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.checklist,
                    label: 'To-Do',
                    onTap: () {
                      print('To-Do tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.qr_code_scanner,
                    label: 'Scanner',
                    onTap: () {
                      print('Scanner tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.monetization_on,
                    label: 'Budget',
                    onTap: () {
                      print('Budget tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.fastfood,
                    label: 'Food',
                    onTap: () {
                      print('Food tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.schedule,
                    label: 'Schedule',
                    onTap: () {
                      print('Schedule tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.notifications,
                    label: 'Notify',
                    onTap: () {
                      print('Notify tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.bar_chart,
                    label: 'Reports',
                    onTap: () {
                      print('Reports tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      print('Settings tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.group_add,
                    label: 'Organizers',
                    onTap: () {
                      print('Organizers tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.question_answer,
                    label: 'Q&A',
                    onTap: () {
                      print('Q&A tapped');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.help_center,
                    label: 'Help',
                    onTap: () {
                      print('Help tapped');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding:
                const EdgeInsets.all(12), // Reduced padding for smaller icons
            decoration: BoxDecoration(
              color: const Color(0xFF003675)
                  .withOpacity(0.1), // Light background for icons
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: const Color(0xFF003675), size: 24), // Smaller icon size
          ),
          const SizedBox(height: 8),
          Text(
            label.length > 10
                ? '${label.substring(0, 10)}...'
                : label, // Trim long labels
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, color: Colors.black87), // Smaller text
          ),
        ],
      ),
    );
  }
}
