import 'package:flutter/material.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/qa_modal.dart';
import 'package:momento/screens/events/qa_model.dart';
import 'package:momento/screens/events/qa_reply.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

class QuestionsScreen extends StatefulWidget {
  final int eventId;

  const QuestionsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late final Stream<List<Question>> _questionsStream;
  final supabase = Supabase.instance.client;
  final String userId = prefs.getString('userId')!;
  final Map<String, String> _usernamesCache = {}; // Cache for usernames

  @override
  void initState() {
    super.initState();
    _initializeQuestionStream();
  }

  void _initializeQuestionStream() {
    final myUserId = userId;
    _questionsStream = supabase
        .from('event_questions')
        .stream(primaryKey: ['id'])
        .eq('event_id', widget.eventId)
        .order('created_at', ascending: false)
        .map((maps) => maps
            .map((map) => Question.fromMap(map: map, myUserId: myUserId))
            .toList());
  }

  Future<String> _getUsername(String userId) async {
    if (_usernamesCache.containsKey(userId)) {
      return _usernamesCache[userId]!;
    }

    try {
      final response = await supabase
          .from('users')
          .select('username')
          .eq('id', userId)
          .single();
      final username = response['username'] ?? 'Unknown User';
      _usernamesCache[userId] = username;
      return username;
    } catch (error) {
      return 'Unknown User';
    }
  }

  // void _showQuestionModal() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(context).viewInsets.bottom,
  //           left: 16,
  //           right: 16,
  //           top: 16,
  //         ),
  //         child: SizedBox(
  //           height: MediaQuery.of(context).size.height * 0.5,
  //           child: Scaffold(
  //             bod: Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 const Text(
  //                   'Ask a Question',
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: Color(0xFF003675),
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Expanded(
  //                   child: TextField(
  //                     controller: _questionController,
  //                     decoration: InputDecoration(
  //                       hintText: 'Type your question here...',
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                         borderSide: const BorderSide(color: Color(0xFF003675)),
  //                       ),
  //                       enabledBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                         borderSide: const BorderSide(color: Color(0xFF003675)),
  //                       ),
  //                       focusedBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                         borderSide: const BorderSide(color: Color(0xFF003675)),
  //                       ),
  //                       contentPadding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 20,
  //                       ),
  //                     ),
  //                     maxLines: null,
  //                     textCapitalization: TextCapitalization.sentences,
  //                   ),
  //                 ),
  //                 SizedBox(height: 16.h),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     if (_questionController.text.trim().isEmpty) {
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(
  //                           content: Text('Question cannot be empty.'),
  //                           backgroundColor: Colors.red,
  //                         ),
  //                       );
  //                       return;
  //                     }
  //                     _submitQuestion();
  //                     Navigator.of(context).pop(); // Close the modal
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color(0xFF003675),
  //                     foregroundColor: Colors.white,
  //                     padding: const EdgeInsets.symmetric(vertical: 16),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: const Text(
  //                     'Send',
  //                     style: TextStyle(fontSize: 16),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q & A'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuestionModal(context, widget.eventId, userId),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Question>>(
        stream: _questionsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No questions yet. Be the first to ask!'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final question = snapshot.data![index];
              return FutureBuilder<String>(
                future: _getUsername(question.userId),
                builder: (context, usernameSnapshot) {
                  final username = usernameSnapshot.data ?? 'Loading...';
                  return _QuestionCard(
                    question: question,
                    username: username,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final String username;

  const _QuestionCard({
    required this.question,
    required this.username,
  });

  Future<int> _getReplyCount(int questionId) async {
    try {
      final response = await Supabase.instance.client
          .from('event_answers')
          .select()
          .eq('question_id', questionId);

      // Return the length of the response array
      return response.length;
    } catch (error) {
      // Log the error for debugging purposes
      debugPrint('Error fetching reply count: $error');
      return 0; // Default to 0 replies if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF003675).withOpacity(0.08),
      elevation: 0,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.isNotEmpty ? username : 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      format(question.createdAt, locale: 'en_short'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Divider(),
            FutureBuilder<int>(
              future: _getReplyCount(question.id),
              builder: (context, snapshot) {
                final replyCount = snapshot.data ?? 0;
                final replyText =
                    replyCount > 0 ? 'Replies ($replyCount)' : 'Reply';

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            QaReplyScreen(questionId: question.id),
                      ),
                    );
                  },
                  child: Text(
                    replyText,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class _QuestionCard extends StatelessWidget {
//   final Question question;
//   final String username;

//   const _QuestionCard({
//     required this.question,
//     required this.username,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: const Color(0xFF003675).withOpacity(0.08),
//       elevation: 0,
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: Colors.grey,
//                   child: Text(
//                     username.isNotEmpty ? username[0].toUpperCase() : 'U',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       username.isNotEmpty ? username : 'Unknown User',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       format(question.createdAt, locale: 'en_short'),
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               question.question,
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             const Divider(),
//             InkWell(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           QaReplyScreen(questionId: question.id)),
//                 );
//                 // Handle add class comment
//               },
//               child: const Text(
//                 "Reply",
//                 style: TextStyle(color: Colors.grey, fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
