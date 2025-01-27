import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:momento/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class EventNotification extends StatefulWidget {
  const EventNotification({super.key});

  @override
  State<EventNotification> createState() => _EventNotificationState();
}

class _EventNotificationState extends State<EventNotification> {
  late final Stream<List<Map<String, dynamic>>> _notificationStream;
  final String userId = prefs.getString('userId')!;

  @override
  void initState() {
    super.initState();
    _setupNotificationStream();
  }

  void _setupNotificationStream() {
    _notificationStream = supabase
        .from('guest_notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .asyncMap((rows) async {
          final notificationIds =
              rows.map((row) => row['notification_id']).toList();
          if (notificationIds.isEmpty) return [];
          final response = await supabase
              .from('add_notifications')
              .select()
              .filter('id', 'in', notificationIds)
              .order('date', ascending: false);

          return response;
        });
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      await supabase
          .from('guest_notifications')
          .delete()
          .match({'user_id': userId, 'notification_id': notificationId});
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
            return _buildEmptyNotificationState();
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
                            "${notification['event_name']} :${notification['title']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
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

  Widget _buildEmptyNotificationState() {
    const baseColor = Color(0xFF003675);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: baseColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: baseColor.withAlpha(153)
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Notifications Yet',
                style: TextStyle(
                  fontSize: 20,
                  color: baseColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You don’t have any notifications right now.\nCheck back later!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: baseColor.withAlpha(153),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
