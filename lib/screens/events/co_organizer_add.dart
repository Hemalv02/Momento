import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/events/create_organizer_bloc/create_organizer_bloc.dart';
import 'package:momento/screens/events/create_organizer_bloc/create_organizer_event.dart';
import 'package:momento/screens/events/create_organizer_bloc/create_organizer_state.dart';
import 'package:momento/screens/events/create_organizer_bloc/organizer_create_api.dart';

void showCoOrganizerModal(BuildContext context, int eventId,
    String currentUserId, VoidCallback onCoOrganizerAdded) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return BlocProvider(
        create: (context) =>
            CoOrganizerBloc(apiService: CoOrganizerApiService()),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: CoOrganizerModal(
                eventId: eventId,
                currentUserId: currentUserId,
                onCoOrganizerAdded: onCoOrganizerAdded),
          ),
        ),
      );
    },
  );
}

class CoOrganizerModal extends StatefulWidget {
  final int eventId;
  final String currentUserId;
  final VoidCallback onCoOrganizerAdded;

  const CoOrganizerModal(
      {super.key,
      required this.eventId,
      required this.currentUserId,
      required this.onCoOrganizerAdded});

  @override
  State<CoOrganizerModal> createState() => _CoOrganizerModalState();
}

class _CoOrganizerModalState extends State<CoOrganizerModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final bloc = context.read<CoOrganizerBloc>();
      bloc.add(
        CoOrganizerSubmitted(
          widget.eventId,
          _emailController.text,
          widget.currentUserId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoOrganizerBloc, CoOrganizerState>(
      listener: (context, state) {
        if (state is CoOrganizerSuccess) {
          widget.onCoOrganizerAdded(); // Notify the list to refresh
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CoOrganizerFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
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
                'Add Co-Organizer',
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
                        _buildLabel('Co-Organizer Email'),
                        TextFormField(
                          controller: _emailController,
                          decoration:
                              _inputDecoration('Enter co-organizer email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),
                        FilledButton(
                          onPressed: state is CoOrganizerLoading
                              ? null
                              : () => _handleSubmit(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: state is CoOrganizerLoading
                                ? const Color(0xFF003675).withOpacity(0.7)
                                : const Color(0xFF003675),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF003675).withOpacity(0.7),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: state is CoOrganizerLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Add Co-Organizer',
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
      },
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
