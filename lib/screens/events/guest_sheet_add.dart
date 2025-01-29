import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/events/create_guest_bloc/create_guest_bloc.dart';
import 'package:momento/screens/events/create_guest_bloc/create_guest_event.dart';
import 'package:momento/screens/events/create_guest_bloc/create_guest_state.dart';
import 'package:momento/screens/events/create_guest_bloc/guest_create_api.dart';

// Function to show the modal
void showImportGuestSheetModal(
    BuildContext context, int eventId, VoidCallback onGuestsImported) {
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
            CreateGuestBloc(apiService: GuestCreateApiService()),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ImportGuestSheetModal(
                eventId: eventId, onGuestsImported: onGuestsImported),
          ),
        ),
      );
    },
  );
}

// Modal Widget
class ImportGuestSheetModal extends StatefulWidget {
  final int eventId;
  final VoidCallback onGuestsImported;

  const ImportGuestSheetModal(
      {super.key, required this.eventId, required this.onGuestsImported});

  @override
  State<ImportGuestSheetModal> createState() => _ImportGuestSheetModalState();
}

class _ImportGuestSheetModalState extends State<ImportGuestSheetModal> {
  final _formKey = GlobalKey<FormState>();
  final _sheetUrlController = TextEditingController();

  @override
  void dispose() {
    _sheetUrlController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final bloc = context.read<CreateGuestBloc>();
      bloc.add(
        ImportGuestFromExcel(
          _sheetUrlController.text,
          widget.eventId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateGuestBloc, CreateGuestState>(
      listener: (context, state) {
        if (state is CreateGuestSuccess) {
          widget.onGuestsImported(); // Notify parent to refresh guest list
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CreateGuestFailure) {
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
            // Modal handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Import Guests from Google Sheet',
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
                        // Sheet URL Input
                        _buildLabel('Google Sheet URL'),
                        TextFormField(
                          controller: _sheetUrlController,
                          decoration:
                              _inputDecoration('Paste Google Sheet URL'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a Google Sheet URL';
                            }
                            // Add more specific URL validation if needed
                            if (!value.contains(
                                'https://docs.google.com/spreadsheets')) {
                              return 'Please enter a valid Google Sheets URL';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 24.h),

                        // Submit Button
                        FilledButton(
                          onPressed: state is CreateGuestLoading
                              ? null
                              : () => _handleSubmit(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: state is CreateGuestLoading
                                ? const Color(0xFF003675).withAlpha(204)
                                : const Color(0xFF003675),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: state is CreateGuestLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Import Guests',
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

  // Helper methods for styling (same as previous example)
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
