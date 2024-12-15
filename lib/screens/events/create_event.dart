import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now();
  String selectedEventType = "Conference";
  final List<String> eventTypes = [
    "Conference",
    "Workshop",
    "Meetup",
    "Seminar"
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? startDateTime : endDateTime,
      firstDate: DateTime(1900),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        title: const Text("Create Event"),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name
              _buildTextField("Event Name"),
              SizedBox(height: 10.h),

              // Organized By
              _buildTextField("Organized By"),
              SizedBox(height: 10.h),

              // Start Date & Time
              Text(
                "Start Date & Time",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.h),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      onTap: () => _selectDate(context, true),
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        DateFormat('MM/dd/yyyy').format(startDateTime),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                      ),
                      selectedTileColor: const Color(0xFFEFF5FF),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // End Date & Time
              Text(
                "End Date & Time",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                      ),
                      selectedTileColor: const Color(0xFFEFF5FF),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // Event Description
              _buildTextField("Event Description", maxLines: 5),
              SizedBox(height: 10.h),

              // Upload Event Banner
              // _buildBannerUploadField(),
              // SizedBox(height: 20.h),

              // Create Event Button
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF003675),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text("Create Event", style: TextStyle(fontSize: 18.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, {int maxLines = 1}) {
    return TextField(
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
    );
  }
}
