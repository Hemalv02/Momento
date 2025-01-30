
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/live_q&a/qa_model.dart';
import 'package:momento/screens/events/live_q&a/qa_reply.dart';
import 'package:momento/screens/profile/user_profile_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String username;
  final Uint8List? profilePicture;
  final bool canDelete;
  final VoidCallback onDeleted;
  final String userId = prefs.getString('userId')!;


  QuestionCard({super.key, 
    required this.question,
    required this.username,
    required this.onDeleted,
    this.profilePicture,
    this.canDelete = false,
  });



  Future<void> _showEditDialog(BuildContext context) async {
    final TextEditingController controller =
        TextEditingController(text: question.question);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Edit Question',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003675),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF003675)),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003675),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Question cannot be empty')),
                      );
                      return;
                    }
                    try {
                      await Supabase.instance.client
                          .from('event_questions')
                          .update({'question': controller.text.trim()}).eq(
                              'id', question.id);

                      if (context.mounted) {
                        Navigator.pop(context);
                        onDeleted(); // Refresh the list after update
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Question updated successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error updating question: $e')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Update Question',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final supabase = Supabase.instance.client;

                  // Delete answers first
                  await supabase
                      .from('event_answers')
                      .delete()
                      .eq('question_id', question.id);

                  // Then delete the question
                  await supabase
                      .from('event_questions')
                      .delete()
                      .eq('id', question.id);

                  if (context.mounted) {
                    Navigator.pop(context);
                    onDeleted(); // Refresh the list after deletion
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Question deleted successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting question: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
                Expanded(
                  child: Column(
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
                ),
                if (question.userId == userId || canDelete)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF003675)),
                    onSelected: (value) {
                      if (value == 'edit' && question.userId == userId) {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      if (question.userId == userId)
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                      if (question.userId == userId || canDelete)
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
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
            const Divider(color: Colors.grey, thickness: 0.8),
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) =>
                            QaReplyScreen(questionId: question.id),
                      ),
                    )
                    .then(
                        (_) => onDeleted()); // Refresh when coming back
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    question.replyCount > 0
                        ? 'Replies (${question.replyCount})'
                        : 'Reply',
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
            ),
          ],
        ),
      ),
    );
  }
}