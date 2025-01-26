// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:intl/intl.dart';
// // import 'package:momento/screens/events/notification_add.dart';

// // class EventNotification extends StatefulWidget {
// //   const EventNotification({super.key});

// //   @override
// //   State<EventNotification> createState() => _EventNotificationState();
// // }

// // class _EventNotificationState extends State<EventNotification> {
// //   // Dummy notification data (you can fetch this from a database or API)
// //   final List<Map<String, dynamic>> _notifications = [
// //     {
// //       'title': 'New message from John',
// //       'date': DateTime.now().subtract(const Duration(hours: 2))
// //     },
// //     {
// //       'title': 'Your order has been shipped',
// //       'date': DateTime.now().subtract(const Duration(days: 1))
// //     },
// //     {
// //       'title': 'Reminder: Meeting at 3 PM',
// //       'date': DateTime.now().subtract(const Duration(days: 2))
// //     },
// //     {
// //       'title': 'Your weekly report is ready',
// //       'date': DateTime.now().subtract(const Duration(days: 5))
// //     },
// //     {
// //       'title': 'Update available for your app',
// //       'date': DateTime.now().subtract(const Duration(days: 10))
// //     },
// //   ];

// //   // Method to format the date as "Today", "Yesterday", or day of the week, or a full date if older
// //   String formatDate(DateTime date) {
// //     final now = DateTime.now();
// //     final difference = now.difference(date).inDays;

// //     if (difference == 0) {
// //       return 'Today';
// //     } else if (difference == 1) {
// //       return 'Yesterday';
// //     } else if (difference < 7) {
// //       return DateFormat.EEEE().format(date); // Day of the week (like Monday)
// //     } else {
// //       return DateFormat('dd/MM/yyyy').format(date); // Full date format
// //     }
// //   }

// //   // Method to format the time to 12-hour format with AM/PM
// //   String formatTime(DateTime date) {
// //     return DateFormat('h:mm a').format(date); // 12-hour format with AM/PM
// //   }

// //   // Method to delete a notification
// //   void _deleteNotification(int index) {
// //     setState(() {
// //       _notifications.removeAt(index);
// //     });
// //   }

// //   void _clearAllNotifications() async {
// //     int length = _notifications.length;
// //     for (int i = 0; i < length; i++) {
// //       await Future.delayed(
// //           const Duration(milliseconds: 200)); // Delay for smooth animation
// //       setState(() {
// //         _notifications.removeAt(0); // Remove the first notification
// //       });
// //     }
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(
// //         content: Text('All notifications cleared'),
// //         duration: Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   void _moreActions() {
// //     showMenu(
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       color: Colors.blueGrey,
// //       context: context,
// //       position: const RelativeRect.fromLTRB(
// //           1000, 80, 0, 0), // Positioning of the menu
// //       items: [
// //         const PopupMenuItem(
// //           padding: EdgeInsets.all(10),
// //           value: 'clear_all',
// //           child: Text('Clear All Notifications',
// //               style: TextStyle(color: Colors.white)),
// //         ),
// //       ],
// //     ).then((value) {
// //       if (value == 'clear_all') {
// //         _clearAllNotifications(); // Call the function to clear notifications
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //         backgroundColor: const Color(0xFF003675),
// //         foregroundColor: Colors.white,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.more_vert),
// //             onPressed: _moreActions,
// //           )
// //         ],
// //       ),
// //       backgroundColor: Colors.white,
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () => showNotificationModal(context),
// //         backgroundColor: const Color(0xFF003675),
// //         foregroundColor: Colors.white,
// //         child: const Icon(Icons.add),
// //       ),
// //       body: _notifications.isEmpty
// //           ? const Center(
// //               child: Text('No notifications available'),
// //             )
// //           : ListView.builder(
// //               itemCount: _notifications.length,
// //               itemBuilder: (context, index) {
// //                 final notification = _notifications[index];
// //                 final date = notification['date'] as DateTime;
// //                 final formattedDate = formatDate(date);
// //                 final formattedTime = formatTime(date);

// //                 return Dismissible(
// //                   key: Key(notification['title'] + date.toString()),
// //                   direction: DismissDirection
// //                       .horizontal, // Swipe left or right to delete
// //                   onDismissed: (direction) {
// //                     _deleteNotification(index);
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       SnackBar(
// //                         content: const Text('Notification dismissed'),
// //                         duration: const Duration(seconds: 2),
// //                         action: SnackBarAction(
// //                           label: 'Undo',
// //                           onPressed: () {
// //                             setState(() {
// //                               _notifications.insert(index, notification);
// //                             });
// //                           },
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                   background: Container(
// //                     color: const Color(0xFF003675),
// //                     alignment: Alignment.centerLeft,
// //                     padding: const EdgeInsets.only(left: 20),
// //                     child: const Icon(Icons.delete, color: Colors.white),
// //                   ),
// //                   secondaryBackground: Container(
// //                     color: const Color(0xFF003675),
// //                     alignment: Alignment.centerRight,
// //                     padding: const EdgeInsets.only(right: 20),
// //                     child: const Icon(Icons.delete, color: Colors.white),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Padding(
// //                         padding: const EdgeInsets.all(16.0),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               notification['title'],
// //                               style: TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 16.sp,
// //                               ),
// //                             ),
// //                             SizedBox(height: 8.h),
// //                             Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Text(
// //                                   formattedDate,
// //                                   style: TextStyle(
// //                                     fontSize: 14.sp,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   formattedTime,
// //                                   style: TextStyle(
// //                                     fontSize: 14.sp,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Container(
// //                         height: 1.h,
// //                         width: double.infinity,
// //                         color: Colors.grey[300],
// //                       )
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:momento/main.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// final supabase = Supabase.instance.client;

// class EventNotification extends StatefulWidget {
//   const EventNotification({super.key,});

//   @override
//   State<EventNotification> createState() => _EventNotificationState();
// }

// class _EventNotificationState extends State<EventNotification> {
//   late final Stream<List<Map<String, dynamic>>> _notificationStream;
//   final String userId = prefs.getString('userId')!;

//   @override
//   void initState() {
//     super.initState();
//     _notificationStream = supabase
//         .from('guest_notification')
//         .stream(primaryKey: ['id'])
//         .eq('guest_id', userId)
//         .map((List<Map<String, dynamic>> rows) {
//           final notificationIds = rows.map((row) => row['notification_id']).toList();
//           final response=supabase
//               .from('add_notifications')
//               .select()
//               .filter('id', 'in', notificationIds)
//               .order('date', ascending: false);

//           return response;
//         });

//     // _notificationStream = supabase
//     // .from('guest_notification')
//     // .stream(primaryKey: ['id'])
//     // .eq('guest_id', userId)
//     // .asyncMap((List<Map<String, dynamic>> rows) async {
//     //   final notificationIds = rows.map((row) => row['notification_id']).toList();

//     //   if (notificationIds.isEmpty) {
//     //     // Return an empty list if no notification IDs
//     //     return [];
//     //   }

//     //   // Fetch notifications matching the IDs
//     //   final response = await supabase
//     //       .from('add_notifications')
//     //       .select()
//     //       .filter('id', 'in', notificationIds)
//     //       .order('date', ascending: false);

//     //   if (response == null) {
//     //     // Handle error appropriately
//     //     print('Error fetching notifications: ${response.toString()}');
//     //     return [];
//     //   }

//     //   return response;
//     // });
//   }


//   Future<void> _deleteNotification(int notificationId) async {
//     try {
//       await supabase
//           .from('guest_notification')
//           .delete()
//           .match({'guest_id': userId, 'notification_id': notificationId});
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   String formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date).inDays;

//     if (difference == 0) return 'Today';
//     if (difference == 1) return 'Yesterday';
//     if (difference < 7) return DateFormat.EEEE().format(date);
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         backgroundColor: const Color(0xFF003675),
//         foregroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.white,
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: _notificationStream,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final notifications = snapshot.data!;
//           if (notifications.isEmpty) {
//             return const Center(child: Text('No notifications available'));
//           }

//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final notification = notifications[index];
//               final date = DateTime.parse(notification['date']);

//               return Dismissible(
//                 key: Key(notification['id'].toString()),
//                 onDismissed: (_) => _deleteNotification(notification['id']),
//                 background: Container(
//                   color: const Color(0xFF003675),
//                   alignment: Alignment.centerLeft,
//                   padding: const EdgeInsets.only(left: 20),
//                   child: const Icon(Icons.delete, color: Colors.white),
//                 ),
//                 secondaryBackground: Container(
//                   color: const Color(0xFF003675),
//                   alignment: Alignment.centerRight,
//                   padding: const EdgeInsets.only(right: 20),
//                   child: const Icon(Icons.delete, color: Colors.white),
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             notification['title'],
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16.sp,
//                             ),
//                           ),
//                           SizedBox(height: 8.h),
//                           Text(
//                             notification['message'],
//                             style: TextStyle(fontSize: 14.sp),
//                           ),
//                           SizedBox(height: 8.h),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 formatDate(date),
//                                 style: TextStyle(fontSize: 14.sp),
//                               ),
//                               Text(
//                                 formatTime(date),
//                                 style: TextStyle(fontSize: 14.sp),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       height: 1.h,
//                       width: double.infinity,
//                       color: Colors.grey[300],
//                     )
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
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
          final notificationIds = rows.map((row) => row['notification_id']).toList();
          if (notificationIds.isEmpty) return [];
          final response = await supabase
              .from('add_notifications')
              .select()
              .filter('id', 'in',notificationIds)
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
            return const Center(child: Text('No notifications available'));
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
                            notification['title'],
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
}