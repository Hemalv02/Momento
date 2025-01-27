import 'package:flutter/material.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/qa_modal.dart';
import 'package:momento/screens/events/qa_model.dart';
import 'package:momento/screens/events/qa_reply.dart';
import 'package:momento/screens/profile/user_profile_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

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
  final Map<String, Uint8List?> _profilePicturesCache =
      {}; // Cache for profile pictures

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

  Future<Uint8List?> _getProfilePicture(String username) async {
    if (_profilePicturesCache.containsKey(username)) {
      return _profilePicturesCache[username];
    }

    try {
      final response = await supabase
          .from('profile_pics')
          .select('url')
          .eq('username', username)
          .single();

      final url = response['url'];
      if (url != null) {
        final imageResponse = await http.get(Uri.parse(url));
        if (imageResponse.statusCode == 200) {
          final imageBytes = imageResponse.bodyBytes;
          _profilePicturesCache[username] = imageBytes;
          return imageBytes;
        }
      }
    } catch (error) {
      debugPrint('Error fetching profile picture: $error');
    }

    _profilePicturesCache[username] = null;
    return null;
  }

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
                  return FutureBuilder<Uint8List?>(
                    future: _getProfilePicture(username),
                    builder: (context, profilePictureSnapshot) {
                      final profilePicture = profilePictureSnapshot.data;
                      return _QuestionCard(
                        question: question,
                        username: username,
                        profilePicture: profilePicture,
                      );
                    },
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
  final Uint8List? profilePicture;

  const _QuestionCard({
    required this.question,
    required this.username,
    this.profilePicture,
  });

  Future<int> _getReplyCount(int questionId) async {
    try {
      final response = await Supabase.instance.client
          .from('event_answers')
          .select()
          .eq('question_id', questionId);

      return response.length;
    } catch (error) {
      debugPrint('Error fetching reply count: $error');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF003675).withAlpha(23),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    // Get the user ID for this question
                    final userIdForThisQuestion = question.userId;
                    final usernameResponse = await Supabase.instance.client
                        .from('users')
                        .select('username')
                        .eq('id', userIdForThisQuestion)
                        .single();

                    final viewedUsername = usernameResponse['username'];
                    final prefs = await SharedPreferences.getInstance();
                    // Only navigate if it's not the current user
                    if (viewedUsername != prefs.getString("username")) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserProfileViewPage(
                                  viewedUsername: viewedUsername)));
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: profilePicture != null
                        ? MemoryImage(profilePicture!)
                        : null,
                    child: profilePicture == null
                        ? Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.isNotEmpty ? username : 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF003675),
                      ),
                    ),
                    Text(
                      format(question.createdAt, locale: 'en_short'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(
              color: Colors.grey,
              thickness: 0.8,
            ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        replyText,
                        style: const TextStyle(
                          color: Color(0xFF003675),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF003675),
                      ),
                    ],
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
