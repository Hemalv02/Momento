import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/profile/user_profile_view_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Reply {
  final int id;
  final int questionId;
  final String userId;
  final String answer;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reply({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reply.fromMap({required Map<String, dynamic> map}) {
    return Reply(
      id: map['id'],
      questionId: map['question_id'],
      userId: map['user_id'],
      answer: map['answer'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class QaReplyScreen extends StatefulWidget {
  final int questionId;
  final String userId = prefs.getString('userId')!;

  QaReplyScreen({
    super.key,
    required this.questionId,
  });

  @override
  State<QaReplyScreen> createState() => _QaReplyScreenState();
}

class _QaReplyScreenState extends State<QaReplyScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final supabase = Supabase.instance.client;
  late final Stream<List<Reply>> _repliesStream;
  final Map<String, String> _usernamesCache = {};
  final Map<String, Uint8List?> _profilePicsCache = {};

  @override
  void initState() {
    super.initState();
    _initializeReplyStream();
  }

  void _initializeReplyStream() {
    _repliesStream = supabase
        .from('event_answers')
        .stream(primaryKey: ['id'])
        .eq('question_id', widget.questionId)
        .order('created_at', ascending: true)
        .map((maps) => maps.map((map) => Reply.fromMap(map: map)).toList());
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
        final url = response['url'];
        final imageResponse = await http.get(Uri.parse(url));

        if (imageResponse.statusCode == 200) {
          _profilePicsCache[username] = imageResponse.bodyBytes;
          return imageResponse.bodyBytes;
        }
      }
    } catch (error) {
      debugPrint('Error fetching profile picture: $error');
    }

    _profilePicsCache[username] = null;
    return null;
  }

  Future<void> _submitReply() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await supabase.from('event_answers').insert({
        'question_id': widget.questionId,
        'user_id': widget.userId,
        'answer': _commentController.text.trim(),
      });

      _commentController.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting reply: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editReply(Reply reply) async {
    _editController.text = reply.answer;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Reply',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003675),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _editController,
                decoration: InputDecoration(
                  hintText: "Enter Reply",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003675),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final updatedText = _editController.text.trim();
                          if (updatedText.isNotEmpty) {
                            try {
                              await supabase.from('event_answers').update({
                                'answer': updatedText,
                              }).eq('id', reply.id);

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Reply updated successfully!'),
                                  ),
                                );
                              }
                            } catch (error) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error updating reply: $error'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replies'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Reply>>(
                stream: _repliesStream,
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
                      child: Text('No replies yet. Be the first to reply!'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final reply = snapshot.data![index];
                      return FutureBuilder<String>(
                        future: _getUsername(reply.userId),
                        builder: (context, usernameSnapshot) {
                          final username =
                              usernameSnapshot.data ?? 'Loading...';
                          return FutureBuilder<Uint8List?>(
                            future: _getProfilePicture(username),
                            builder: (context, profilePicSnapshot) {
                              final profilePic = profilePicSnapshot.data;
                              return Column(
                                children: [
                                  _buildCommentTile(
                                    name: username,
                                    date: format(reply.createdAt,
                                        locale: 'en_short'),
                                    comment: reply.answer,
                                    profilePic: profilePic,
                                    reply: reply,
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            _buildCommentInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTile({
    required String name,
    required String date,
    required String comment,
    required Reply reply,
    Uint8List? profilePic,
  }) {
    final isCurrentUserReply = reply.userId == prefs.getString('userId')!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onLongPress: isCurrentUserReply ? () => _editReply(reply) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final currentUserId = prefs.getString('userId')!;

                final userIdResponse = await supabase
                    .from('users')
                    .select('id')
                    .eq('username', name)
                    .single();

                final userIdForThisReply = userIdResponse['id'];

                if (userIdForThisReply != currentUserId) {
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileViewPage(viewedUsername: name),
                      ),
                    );
                  }
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: profilePic == null
                    ? const Color(0xFF003675)
                    : Colors.transparent,
                foregroundColor: Colors.white,
                backgroundImage:
                    profilePic != null ? MemoryImage(profilePic) : null,
                child: profilePic == null ? Text(name[0].toUpperCase()) : null,
              ),
            ),
            SizedBox(width: 8.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$name • $date",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(comment),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a reply...",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (value) => _submitReply(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF003675),
            foregroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitReply,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editController.dispose();
    super.dispose();
  }
}
