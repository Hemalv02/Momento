import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main_project/Screens/CreateGuestList.dart';
import 'package:main_project/bloc/event_management_bloc.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _organizedByController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();

  @override
  void dispose() {
    _eventNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _organizedByController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text =
            "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _onSubmit(BuildContext context) {
    if (_validateFields()) {
      if (kDebugMode) {
        print('Submitting event form...');
      }

      context.read<EventBloc>().add(
            SubmitEvent(
              eventName: _eventNameController.text,
              date: _dateController.text,
              time: _timeController.text,
              location: _locationController.text,
              budget: _budgetController.text,
              organizedBy: _organizedByController.text,
            ),
          );
    }
  }

  bool _validateFields() {
    if (_eventNameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _budgetController.text.isEmpty ||
        _organizedByController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }

    if (double.tryParse(_budgetController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventBloc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 2, 41, 73),
          title: const Text(
            "Create Event",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.group_add, color: Colors.white),
              tooltip: "Add Guests",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGuestPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<EventBloc, EventManagementState>(
          listener: (context, state) {
            if (state is EventSubmitting) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is EventSubmissionSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event created successfully!'),
                  backgroundColor: Color.fromARGB(255, 20, 166, 25),
                ),
              );
              Navigator.pop(context);
            } else if (state is EventSubmissionFailure) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    label: "Event Name",
                    controller: _eventNameController,
                    prefixIcon: Icons.event,
                  ),
                  const SizedBox(height: 16),
                  _buildDatePickerField(
                    context: context,
                    label: "Date",
                    controller: _dateController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Time",
                    controller: _timeController,
                    prefixIcon: Icons.access_time,
                    readOnly: true,
                    onTap: () => _selectTime(context),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Location",
                    controller: _locationController,
                    prefixIcon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Budget",
                    controller: _budgetController,
                    prefixIcon: Icons.attach_money,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Organized By",
                    controller: _organizedByController,
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _onSubmit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 33, 144, 235),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Create Event",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.calendar_today),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          setState(() {
            controller.text =
                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
          });
        }
      },
    );
  }
}
