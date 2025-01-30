import 'package:flutter/material.dart';
import 'package:momento/screens/events/live_q&a/question_card.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/live_q&a/qa_modal.dart';
import 'package:momento/screens/events/live_q&a/qa_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;

class QuestionsScreen extends StatefulWidget {
  final int eventId;
  final bool canDelete;

  const QuestionsScreen({
    super.key,
    required this.eventId,
    required this.canDelete,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final StreamController<List<Question>> _questionsController =
      StreamController<List<Question>>.broadcast();
  final supabase = Supabase.instance.client;
  final String userId = prefs.getString('userId')!;
  final Map<String, String> _usernamesCache = {};
  final Map<String, Uint8List?> _profilePicsCache = {};

  @override
  void initState() {
    super.initState();
    _setupQuestionStream();
  }

  void _setupQuestionStream() {
    supabase
        .from('event_questions')
        .stream(primaryKey: ['id'])
        .eq('event_id', widget.eventId)
        .order('created_at', ascending: false)
        .map((maps) => maps
            .map((map) => Question.fromMap(map: map, myUserId: userId))
            .toList())
        .listen(
          (data) => _questionsController.add(data),
          onError: (error) {
            debugPrint('Stream error: $error');
            _questionsController.addError(error);
          },
        );
  }

  Future<void> _refreshQuestions() async {
    try {
      final response = await supabase
          .from('event_questions')
          .select()
          .eq('event_id', widget.eventId)
          .order('created_at', ascending: false);

      final questions = response
          .map((map) => Question.fromMap(map: map, myUserId: userId))
          .toList();

      if (!_questionsController.isClosed) {
        _questionsController.add(questions);
      }
    } catch (e) {
      debugPrint('Error refreshing questions: $e');
    }
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
      final username = response['username'] as String;
      _usernamesCache[userId] = username;
      return username;
    } catch (e) {
      debugPrint('Error fetching username: $e');
      return 'Unknown User';
    }
  }

  Future<Uint8List?> _getProfilePicture(String username) async {
    if (_profilePicsCache.containsKey(username)) {
      return _profilePicsCache[username];
    }

    try {
      final response = await supabase
          .from('profile_pics')
          .select('url')
          .eq('username', username)
          .single();

      if (response['url'] != null) {
        final imageResponse = await http.get(Uri.parse(response['url']));
        if (imageResponse.statusCode == 200) {
          _profilePicsCache[username] = imageResponse.bodyBytes;
          return imageResponse.bodyBytes;
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile picture: $e');
    }

    _profilePicsCache[username] = null;
    return null;
  }

  @override
  void dispose() {
    _questionsController.close();
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
        stream: _questionsController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data ?? [];
          if (questions.isEmpty) {
            return const Center(
                child: Text('No questions yet. Be the first to ask!'));
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return FutureBuilder<String>(
                future: _getUsername(question.userId),
                builder: (context, usernameSnapshot) {
                  final username = usernameSnapshot.data ?? 'Loading...';
                  return FutureBuilder<Uint8List?>(
                    future: _getProfilePicture(username),
                    builder: (context, profilePicSnapshot) {
                      return QuestionCard(
                        question: question,
                        username: username,
                        profilePicture: profilePicSnapshot.data,
                        canDelete: widget.canDelete,
                        onDeleted: _refreshQuestions,
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
