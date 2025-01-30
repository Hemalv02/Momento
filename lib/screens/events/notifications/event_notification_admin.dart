import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:momento/custom_widgets/build_empty_notification.dart';
import 'package:momento/screens/events/notifications/notification_add.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class EventNotificationAdmin extends StatefulWidget {
  final int eventId;
  const EventNotificationAdmin({super.key, required this.eventId});

  @override
  State<EventNotificationAdmin> createState() => _EventNotificationAdminState();
}

class _EventNotificationAdminState extends State<EventNotificationAdmin> {
  late final Stream<List<Map<String, dynamic>>> _notificationStream;

  @override
  void initState() {
    super.initState();
    _setupNotificationStream();
  }

  void _setupNotificationStream() {
    _notificationStream = supabase
        .from('add_notifications')
        .stream(primaryKey: ['id'])
        .eq('event_id', widget.eventId)
        .order('date', ascending: false);
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      await supabase
          .from('add_notifications')
          .delete()
          .match({'id': notificationId});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return DateFormat.EEEE().format(date);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNotificationModal(context, eventId: widget.eventId);
        },
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notificationStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return buildEmptyNotificationState();
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final date = DateTime.parse(notification['date']);

              return Dismissible(
                key: Key(notification['id'].toString()),
                onDismissed: (_) => _deleteNotification(notification['id']),
                background: Container(
                  color: const Color(0xFF003675),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: const Color(0xFF003675),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${notification['title']}",
                            style: TextStyle(
                              fontSize: 20.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            notification['message'],
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDate(date),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Text(
                                formatTime(date),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1.h,
                      width: double.infinity,
                      color: Colors.grey[300],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  
}
