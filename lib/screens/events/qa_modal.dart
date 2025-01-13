import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showQuestionModal(BuildContext context, int eventId, String userId) {
  showModalBottomSheet(
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
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: QuestionModal(eventId: eventId, userId: userId),
        ),
      );
    },
  );
}

class QuestionModal extends StatefulWidget {
  final int eventId;
  final String userId;

  const QuestionModal({super.key, required this.eventId, required this.userId});

  @override
  State<QuestionModal> createState() => _QuestionModalState();
}

class _QuestionModalState extends State<QuestionModal> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> _submitQuestion(
    int eventId,
    String userId,
  ) async {
    if (_questionController.text.trim().isEmpty) return;

    try {
      await supabase.from('event_questions').insert({
        'event_id': eventId,
        'user_id': userId,
        'question': _questionController.text.trim(),
      });

      _questionController.clear();

      // Close modal after successful submission
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting question: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _submitQuestion(widget.eventId, widget.userId);
      Navigator.of(context).pop(); // Close the modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Ask a Question',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF003675),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLabel('Your Question'),
                    TextFormField(
                      controller: _questionController,
                      decoration:
                          _inputDecoration('Type your question here...'),
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your question';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    FilledButton(
                      onPressed: _handleSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF003675),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(
          color: const Color(0xFF003675),
          width: 2.w,
        ),
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
