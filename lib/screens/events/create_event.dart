import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:momento/screens/auth/sign_up/loading.dart';
import 'package:momento/screens/events/create_event_bloc/create_event_bloc.dart';
import 'package:momento/screens/events/create_event_bloc/create_event_event.dart';
import 'package:momento/screens/events/create_event_bloc/create_event_state.dart';
import 'package:momento/services/event_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now();
  String selectedEventType = "Conference";

  final TextEditingController eventName = TextEditingController();
  final TextEditingController organizedBy = TextEditingController();
  final TextEditingController eventDescription = TextEditingController();
  final TextEditingController location = TextEditingController();

  final List<String> eventTypes = [
    "Conference",
    "Workshop",
    "Meetup",
    "Seminar"
  ];
  String? _dateTimeError;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? startDateTime : endDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          startDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            startDateTime.hour,
            startDateTime.minute,
          );
        } else {
          endDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            endDateTime.hour,
            endDateTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStart
          ? TimeOfDay.fromDateTime(startDateTime)
          : TimeOfDay.fromDateTime(endDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          startDateTime = DateTime(
            startDateTime.year,
            startDateTime.month,
            startDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          endDateTime = DateTime(
            endDateTime.year,
            endDateTime.month,
            endDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      });
    }
  }

  void _validateAndSubmit(BuildContext context, String userId) {
    setState(() {
      _dateTimeError = null;
    });

    if (startDateTime.isAfter(endDateTime)) {
      setState(() {
        _dateTimeError = "Start date-time must be before end date-time.";
      });
      return;
    }

    if (startDateTime.isBefore(DateTime.now())) {
      setState(() {
        _dateTimeError = "Start date-time cannot be in the past.";
      });
      return;
    }

    // If no errors, proceed with form submission
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<CreateEventBloc>().add(
            CreateEventSubmitted(
              eventName.text,
              organizedBy.text,
              location.text,
              startDateTime,
              endDateTime,
              eventDescription.text,
              userId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateEventBloc(apiService: EventApiService()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF003675),
          foregroundColor: Colors.white,
          title: const Text("Create Event"),
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<CreateEventBloc, CreateEventState>(
          listener: (context, state) {
            if (state is CreateEventSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Event created successfully.")),
              );
              Future.delayed(const Duration(seconds: 1));
              Navigator.of(context).pop(true);
            }
            if (state is CreateEventFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return AnimatedLoadingOverlay(
              isLoading: state is CreateEventLoading,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Name
                        _buildTextField("Event Name", eventName),
                        SizedBox(height: 10.h),

                        // Organized By
                        _buildTextField("Organized By", organizedBy),
                        SizedBox(height: 10.h),

                        // location
                        _buildTextField("Location", location),
                        SizedBox(height: 10.h),

                        // Start Date & Time
                        Text(
                          "Start Date & Time",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                onTap: () => _selectDate(context, true),
                                leading: const Icon(Icons.calendar_today),
                                title: Text(
                                  DateFormat('MM/dd/yyyy')
                                      .format(startDateTime),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                onTap: () => _selectTime(context, true),
                                leading: const Icon(Icons.access_time),
                                title: Text(
                                  DateFormat('hh:mm a').format(startDateTime),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // End Date & Time
                        Text(
                          "End Date & Time",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                onTap: () => _selectDate(context, false),
                                leading: const Icon(Icons.calendar_today),
                                title: Text(
                                  DateFormat('MM/dd/yyyy').format(endDateTime),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                onTap: () => _selectTime(context, false),
                                leading: const Icon(Icons.access_time),
                                title: Text(
                                  DateFormat('hh:mm a').format(endDateTime),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_dateTimeError != null)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Text(
                              _dateTimeError!,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.sp),
                            ),
                          ),
                        SizedBox(height: 10.h),

                        // Event Description
                        _buildTextField("Event Description", eventDescription,
                            maxLines: 5),
                        SizedBox(height: 20.h),

                        // Create Event Button
                        FilledButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getString("userId");

                            _validateAndSubmit(context, userId!);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF003675),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          child: Text("Create Event",
                              style: TextStyle(fontSize: 18.sp)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.w)),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
        ),
      ),
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hintText is required.";
        }
        return null;
      },
    );
  }
}
