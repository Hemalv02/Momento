import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/events/event_co_organizer.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';
import 'package:momento/screens/events/guest_list.dart';

class EventHome extends StatefulWidget {
  const EventHome({super.key});

  @override
  State<EventHome> createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  bool isInitialized = false;
  late int eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      // Access ModalRoute here
      final event = ModalRoute.of(context)?.settings.arguments;
      if (event is Event) {
        setState(() {
          eventId = event.id;
        });
      }
      isInitialized = true;
    }
  }

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
                mainAxisSpacing: 24.h, // Increased space between rows
                crossAxisSpacing: 16.w,
                childAspectRatio: 0.9, // Adjusted for better fit
                shrinkWrap: true, // Fix for infinite height
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent nested scrolling
                children: [
                  _buildFeatureItem(
                    icon: Icons.people,
                    label: 'Guests',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GuestList(eventId: eventId),
                      ));
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
                      Navigator.of(context).pushNamed('ticket_scanner');
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
                      Navigator.of(context).pushNamed('event_schedule');
                    },
                  ),
                  _buildFeatureItem(
                    icon: Icons.notifications,
                    label: 'Notify',
                    onTap: () {
                      Navigator.of(context).pushNamed('event_notification');
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                EventCoOrganizer(eventId: eventId)),
                      );
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
          // SizedBox(height: 8.h),
          Text(
            label.length > 10
                ? '${label.substring(0, 10)}...'
                : label, // Trim long labels
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.sp, color: Colors.black87), // Smaller text
          ),
        ],
      ),
    );
  }
}
