import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main_project/bloc/guest_bloc.dart';

class CreateGuestPage extends StatefulWidget {
  @override
  State<CreateGuestPage> createState() => _CreateGuestPageState();
}

class _CreateGuestPageState extends State<CreateGuestPage> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _guestDesignationController = TextEditingController();
  final TextEditingController _guestNumberController = TextEditingController();

  @override
  void dispose() {
    _eventNameController.dispose();
    _guestNameController.dispose();
    _guestDesignationController.dispose();
    _guestNumberController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (_validateFields()) {
      if (kDebugMode) {
        print('Submitting guest form...');
      }

      context.read<GuestBloc>().add(
            AddGuest(
              eventName: _eventNameController.text,
              GuestName: _guestNameController.text,
              GuestDesignation: _guestDesignationController.text,
              GuestNumber: int.tryParse(_guestNumberController.text) ?? 0,
            ),
          );
    }
  }

  void _clearForm() {
    _eventNameController.clear();
    _guestNameController.clear();
    _guestDesignationController.clear();
    _guestNumberController.clear();
  }

  bool _validateFields() {
    if (_eventNameController.text.isEmpty ||
        _guestNameController.text.isEmpty ||
        _guestDesignationController.text.isEmpty ||
        _guestNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }

    if (int.tryParse(_guestNumberController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid guest number')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuestBloc(),
      child: BlocListener<GuestBloc, GuestState>(
        listener: (context, state) {
          if (state is GuestSubmitting) {
            // Show loading indicator
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Adding guest...')),
            );
          } else if (state is GuestSubmissionSuccess) {
            // Show success message and clear form
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Guest added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _clearForm();
          } else if (state is GuestSubmissionFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Create Guest'),
              backgroundColor: Colors.blue.shade800,
            ),
            body: BlocBuilder<GuestBloc, GuestState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Guest Name',
                        controller: _guestNameController,
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        label: 'Guest Designation',
                        controller: _guestDesignationController,
                        prefixIcon: Icons.badge,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        label: 'Event Name',
                        controller: _eventNameController,
                        prefixIcon: Icons.event,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        label: 'Total Guest Number',
                        controller: _guestNumberController,
                        prefixIcon: Icons.group,
                        keyboardType: TextInputType.number,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: state is GuestSubmitting 
                            ? null 
                            : () => _onSubmit(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: state is GuestSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Create Guest',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}