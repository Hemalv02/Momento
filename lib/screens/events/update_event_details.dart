import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateEventScreen extends StatefulWidget {
  final int eventId;

  const UpdateEventScreen({super.key, required this.eventId});

  @override
  State<UpdateEventScreen> createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends State<UpdateEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now().add(const Duration(hours: 1));

  final TextEditingController eventName = TextEditingController();
  final TextEditingController organizedBy = TextEditingController();
  final TextEditingController eventDescription = TextEditingController();
  final TextEditingController location = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    final response = await Supabase.instance.client
        .from('event')
        .select()
        .eq('id', widget.eventId)
        .single();

    setState(() {
      eventName.text = response['event_name'];
      organizedBy.text = response['organized_by'];
      location.text = response['location'];
      startDateTime = DateTime.parse(response['start_date']);
      endDateTime = DateTime.parse(response['end_date']);
      eventDescription.text = response['description'];
    });
  }

  Future<void> _deleteEvent() async {
    try {
      await Supabase.instance.client
          .from('event')
          .delete()
          .eq('id', widget.eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Event deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          'home_structure',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete event: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF003675)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEvent();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateEvent(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (startDateTime.isAfter(endDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("End date must be after start date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('event').update({
        'event_name': eventName.text,
        'organized_by': organizedBy.text,
        'location': location.text,
        'start_date': startDateTime.toIso8601String(),
        'end_date': endDateTime.toIso8601String(),
        'description': eventDescription.text,
      }).eq('id', widget.eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Event updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update event: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final currentDate = DateTime.now();
    final initialDate = isStart ? startDateTime : endDateTime;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          initialDate.isBefore(currentDate) ? currentDate : initialDate,
      firstDate: isStart ? currentDate : startDateTime,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF003675),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(isStart ? startDateTime : endDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF003675),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStart) {
            startDateTime = newDateTime;
            if (endDateTime.isBefore(newDateTime)) {
              endDateTime = newDateTime.add(const Duration(hours: 1));
            }
          } else {
            endDateTime = newDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        title: const Text("Settings"),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Update Event Information",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF003675),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildTextField(
                      "Event Name",
                      eventName,
                      Icons.event,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      "Organized By",
                      organizedBy,
                      Icons.people,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      "Location",
                      location,
                      Icons.location_on,
                    ),
                    SizedBox(height: 16.h),
                    _buildDateTimeField(
                      "Start Date & Time",
                      startDateTime,
                      () => _selectDate(context, true),
                      Icons.calendar_today,
                    ),
                    SizedBox(height: 16.h),
                    _buildDateTimeField(
                      "End Date & Time",
                      endDateTime,
                      () => _selectDate(context, false),
                      Icons.calendar_today,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      "Event Description",
                      eventDescription,
                      Icons.description,
                      maxLines: 3,
                    ),
                    SizedBox(height: 26.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => _updateEvent(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003675),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.w),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                "Update",
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: _showDeleteConfirmation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.w),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                "Delete",
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF003675)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.w),
          borderSide: const BorderSide(color: Color(0xFF003675)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.w),
          borderSide: const BorderSide(color: Color(0xFF003675), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "$label is required" : null,
    );
  }

  Widget _buildDateTimeField(
    String label,
    DateTime dateTime,
    VoidCallback onTap,
    IconData icon,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF003675)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.w),
            borderSide: const BorderSide(color: Color(0xFF003675)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.w),
            borderSide: const BorderSide(color: Color(0xFF003675), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          DateFormat('MM/dd/yyyy    hh:mm a').format(dateTime),
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
    );
  }
}
