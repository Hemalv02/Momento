import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/schedule/schedule.dart';
import 'package:momento/screens/events/schedule/schedule_service.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final int eventId;
  final Schedule? schedule;
  final ScheduleService scheduleService;

  const ScheduleBottomSheet({
    super.key,
    required this.eventId,
    this.schedule,
    required this.scheduleService,
  });

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _activityNameController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _selectedActivityType = 'event';
  String userId = prefs.getString('userId')!;

  final List<Map<String, dynamic>> _activityTypes = [
    {'value': 'speech', 'label': 'Speech', 'icon': Icons.mic},
    {'value': 'meal', 'label': 'Meal', 'icon': Icons.lunch_dining},
    {'value': 'workshop', 'label': 'Workshop', 'icon': Icons.work},
    {'value': 'networking', 'label': 'Networking', 'icon': Icons.group},
    {'value': 'break', 'label': 'Break', 'icon': Icons.local_cafe},
    {'value': 'ceremony', 'label': 'Ceremony', 'icon': Icons.celebration},
    {'value': 'party', 'label': 'Party', 'icon': Icons.party_mode},
    {'value': 'activity', 'label': 'Activity', 'icon': Icons.self_improvement},
    {'value': 'photo', 'label': 'Photo Session', 'icon': Icons.camera_alt},
    {'value': 'award', 'label': 'Award', 'icon': Icons.emoji_events},
    {'value': 'event', 'label': 'Other Event', 'icon': Icons.event},
  ];

  @override
  void initState() {
    super.initState();
    _activityNameController =
        TextEditingController(text: widget.schedule?.activityName);
    _descriptionController =
        TextEditingController(text: widget.schedule?.description);
    _selectedDate = widget.schedule?.scheduleDate ?? DateTime.now();
    _selectedTime = widget.schedule?.scheduleTime ?? TimeOfDay.now();
    if (widget.schedule != null) {
      _selectedActivityType = widget.schedule!.activityType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF003675);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: bottomPadding + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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

            // Title
            Text(
              widget.schedule == null ? 'Add New Schedule' : 'Edit Schedule',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: baseColor,
              ),
            ),
            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date Picker
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Picker
                  InkWell(
                    onTap: _pickTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activity Name
                  TextFormField(
                    controller: _activityNameController,
                    decoration: InputDecoration(
                      labelText: 'Activity Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.event),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Activity Type
                  DropdownButtonFormField<String>(
                    value: _selectedActivityType,
                    decoration: InputDecoration(
                      labelText: 'Activity Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon:
                          Icon(_getActivityTypeIcon(_selectedActivityType)),
                    ),
                    items: _activityTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['value'] as String,
                        child: Row(
                          children: [
                            Icon(type['icon'], size: 20),
                            const SizedBox(width: 8),
                            Text(type['label']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedActivityType = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveSchedule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: baseColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  IconData _getActivityTypeIcon(String type) {
    final activityType = _activityTypes.firstWhere(
      (t) => t['value'] == type,
      orElse: () => _activityTypes.last,
    );
    return activityType['icon'];
  }

  void _saveSchedule() async {
    if (_formKey.currentState?.validate() ?? false) {
      final schedule = Schedule(
        id: widget.schedule?.id,
        eventId: widget.eventId,
        scheduleDate: _selectedDate,
        scheduleTime: _selectedTime,
        activityName: _activityNameController.text,
        activityType: _selectedActivityType,
        description: _descriptionController.text,
        createdAt: widget.schedule?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: userId,
      );

      try {
        if (widget.schedule == null) {
          await widget.scheduleService.addSchedule(schedule);
        } else {
          await widget.scheduleService.updateSchedule(schedule);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
