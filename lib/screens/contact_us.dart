import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/feedback/feedback_bloc.dart';
import 'package:momento/screens/feedback/feedback_event.dart';
import 'package:momento/screens/feedback/feedback_repository.dart';
import 'package:momento/screens/feedback/feedback_state.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedbackBloc(
        repository: FeedbackRepository(),
      ),
      child: const FeedbackView(),
    );
  }
}

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final TextEditingController feedbackController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String userId = prefs.getString('userId')!;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state is FeedbackSuccess) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Feedback Sent'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      feedbackController.clear();
                    },
                    child: const Text('Okay'),
                  ),
                ],
              );
            },
          );
        } else if (state is FeedbackError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<FeedbackBloc, FeedbackState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get In Touch With Us',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    const Text(
                      'Share your feedback with the developer to help improve momento.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20.h),
                    TextFormField(
                      controller: feedbackController,
                      maxLines: 10,
                      decoration: buildInputDecoration(
                          'Feedback, Suggestion, Questions....'),
                      style: const TextStyle(fontSize: 18),
                      validator: validateFeedback,
                    ),
                    SizedBox(height: 8.h),
                    const Text(
                      'Only the feedback, email, and date will be shared.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: state is FeedbackLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<FeedbackBloc>().add(
                                      SubmitFeedbackEvent(
                                        userId: userId,
                                        feedbackMessage:
                                            feedbackController.text,
                                      ),
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50.h),
                        backgroundColor: const Color(0xFF003675),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: state is FeedbackLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Send Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? validateFeedback(String? value) {
    if (value == null || value.isEmpty) {
      return 'Feedback is required';
    }
    if (value.length < 10) {
      return 'Feedback must be at least 10 characters long';
    }
    return null;
  }

  InputDecoration buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF003675), width: 2),
      ),
    );
  }
}
