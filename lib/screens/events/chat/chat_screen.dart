// import 'package:flutter/material.dart';
// import 'package:momento/screens/events/chat/chat_bubble.dart';
// import 'package:momento/screens/events/chat/chat_input_field.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:momento/screens/events/chat/message.dart';
// import 'package:momento/screens/events/chat/profile.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ChatScreen extends StatefulWidget {
//   final int eventId;
//   const ChatScreen({super.key, required this.eventId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   late final Stream<List<Message>> _messagesStream;
//   final Map<String, Profile> _profileCache = {};
//   final supabase = Supabase.instance.client;
//   String? _selectedMessageId;

//   void initState() {
//     const myUserId = "668308c8-ae99-49a9-a1ba-91b3c4348c88";

//     // Ensure event_id is defined and available here
//     _messagesStream = supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('event_id', widget.eventId)
//         .order('created_at') // Order by creation time
//         .map((maps) => maps
//             .map((map) => Message.fromMap(map: map, myUserId: myUserId))
//             .toList());
//     super.initState();
//   }

//   Future<void> _loadProfileCache(String profileId) async {
//     if (_profileCache[profileId] != null) {
//       return;
//     }
//     final data =
//         await supabase.from('users').select().eq('id', profileId).single();
//     final profile = Profile.fromMap(data);
//     setState(() {
//       _profileCache[profileId] = profile;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF003675),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: const Row(
//           children: [
//             CircleAvatar(
//               radius: 22,
//               backgroundColor: Colors.white,
//               child: Icon(
//                 Icons.question_answer,
//                 color: Color(0xFF003675),
//               ),
//             ),
//             SizedBox(width: 10),
//             Text(
//               "Q & A",
//               style: TextStyle(fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Message>>(
//               stream: _messagesStream,
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final messages = snapshot.data!;
//                 if (messages.isEmpty) {
//                   return const Center(child: Text('No messages yet'));
//                 }
//                 return ListView.builder(
//                   padding: const EdgeInsets.only(
//                     bottom: 40,
//                     left: 13,
//                     right: 13,
//                   ),
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final isFirstMessage = index == 0 ||
//                         message.profileId != messages[index - 1].profileId;

//                     return ChatBubble(
//                       message: message.content,
//                       isSentByMe: message.isMine,
//                       isFirstMessage: isFirstMessage,
//                       avatarImage: 'assets/default_avatar.png',
//                       timestamp: message.createdAt, // Pass the timestamp here
//                       showTimestamp: _selectedMessageId == message.id,
//                       onTap: () {
//                         setState(() {
//                           _selectedMessageId =
//                               _selectedMessageId == message.id ? null : message.id;
//                         });
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           ChatInputField(eventId: widget.eventId),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:momento/screens/events/chat/chat_bubble.dart';
import 'package:momento/screens/events/chat/chat_input_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:momento/screens/events/chat/message.dart';
import 'package:momento/screens/events/chat/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final int eventId;
  const ChatScreen({super.key, required this.eventId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final Stream<List<Message>> _messagesStream;
  final Map<String, String> _usernameCache = {};  // Changed to store just usernames
  final supabase = Supabase.instance.client;
  String? _selectedMessageId;

  @override
  void initState() {
    const myUserId = "668308c8-ae99-49a9-a1ba-91b3c4348c88";

    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('event_id', widget.eventId)
        .order('created_at')
        .map((maps) => maps
            .map((map) => Message.fromMap(map: map, myUserId: myUserId))
            .toList());
    super.initState();
  }

  Future<String> _getUsername(String userId) async {
    // Check cache first
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    try {
      // Fetch username from Supabase
      final data = await supabase
          .from('users')
          .select('username')
          .eq('id', userId)
          .single();
      
      final username = data['username'] as String;
      
      // Cache the username
      setState(() {
        _usernameCache[userId] = username;
      });
      
      return username;
    } catch (e) {
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.question_answer,
                color: Color(0xFF003675),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Q & A",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 40,
                    left: 13,
                    right: 13,
                  ),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isFirstMessage = index == 0 ||
                        message.profileId != messages[index - 1].profileId;

                    return FutureBuilder<String>(
                      future: _getUsername(message.profileId),
                      builder: (context, usernameSnapshot) {
                        final username = usernameSnapshot.data ?? 'Loading...';
                        
                        return ChatBubble(
                          message: message.content,
                          isSentByMe: message.isMine,
                          isFirstMessage: isFirstMessage,
                          avatarImage: 'assets/default_avatar.png',
                          timestamp: message.createdAt,
                          showTimestamp: _selectedMessageId == message.id,
                          username: username,  // Add username to ChatBubble
                          onTap: () {
                            setState(() {
                              _selectedMessageId =
                                  _selectedMessageId == message.id ? null : message.id;
                            });
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(eventId: widget.eventId),
        ],
      ),
    );
  }
}