import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dummy notification data (you can fetch this from a database or API)
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New message from John',
      'date': DateTime.now().subtract(Duration(hours: 2))
    },
    {
      'title': 'Your order has been shipped',
      'date': DateTime.now().subtract(Duration(days: 1))
    },
    {
      'title': 'Reminder: Meeting at 3 PM',
      'date': DateTime.now().subtract(Duration(days: 2))
    },
    {
      'title': 'Your weekly report is ready',
      'date': DateTime.now().subtract(Duration(days: 5))
    },
    {
      'title': 'Update available for your app',
      'date': DateTime.now().subtract(Duration(days: 10))
    },
  ];

  // Method to format the date as "Today", "Yesterday", or day of the week, or a full date if older
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat.EEEE().format(date); // Day of the week (like Monday)
    } else {
      return DateFormat('dd/MM/yyyy').format(date); // Full date format
    }
  }

  // Method to format the time to 12-hour format with AM/PM
  String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date); // 12-hour format with AM/PM
  }

  // Method to delete a notification
  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  void _clearAllNotifications() async {
    int length = _notifications.length;
  for (int i = 0; i < length; i++) {
    await Future.delayed(const Duration(milliseconds: 200)); // Delay for smooth animation
    setState(() {
      
      _notifications.removeAt(0); // Remove the first notification
    });
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('All notifications cleared'),
      duration: Duration(seconds: 2),
    ),
  );
}

void moreActions(){
  showMenu(
      context: context,
      position: RelativeRect.fromLTRB(1000, 80, 0, 0), // Positioning of the menu
      items: [
        PopupMenuItem(
          value: 'clear_all',
          child: Text('Clear All Notifications'),
        ),
      ],
    ).then((value) {
      if (value == 'clear_all') {
        _clearAllNotifications(); // Call the function to clear notifications
      }
    });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: moreActions,
          )
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text('No notifications available'),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final date = notification['date'] as DateTime;
                final formattedDate = formatDate(date);
                final formattedTime = formatTime(date);

                return Dismissible(
                  key: Key(notification['title'] + date.toString()),
                  direction: DismissDirection
                      .horizontal, // Swipe left or right to delete
                  onDismissed: (direction) {
                    _deleteNotification(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notification dismissed'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            setState(() {
                              _notifications.insert(index, notification);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
