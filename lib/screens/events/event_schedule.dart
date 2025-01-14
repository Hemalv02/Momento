import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:momento/screens/events/schedule/schedule.dart';
import 'package:momento/screens/events/schedule/schedule_service.dart';
import 'package:momento/screens/events/schedule/schedule_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventSchedule extends StatelessWidget {
  final int eventId;
  final ScheduleService _scheduleService =
      ScheduleService(Supabase.instance.client);

  EventSchedule({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Schedule"),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Schedule>>(
        stream: _scheduleService.streamSchedules(eventId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final schedules = snapshot.data!;

          // Empty state handling
          if (schedules.isEmpty) {
            return _buildEmptyState(context);
          }

          final groupedSchedules = _groupSchedulesByDate(schedules);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: groupedSchedules.length,
              itemBuilder: (context, index) {
                final date = groupedSchedules.keys.elementAt(index);
                final daySchedules = groupedSchedules[date]!;

                return Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF003675).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            _formatDate(date),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF003675),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Column(
                          children: daySchedules.map((schedule) {
                            return Dismissible(
                              key: Key(schedule.id.toString()),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) =>
                                  _scheduleService.deleteSchedule(schedule.id!),
                              child: TimelineTile(
                                schedule: schedule,
                                onTap: () =>
                                    _showScheduleModal(context, schedule),
                              ),
                            );
                          }).toList(),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 4.0),
                          width: 16.w,
                          height: 16.h,
                          decoration: const BoxDecoration(
                            color: Color(0xFF003675),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleModal(context),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64.w,
            color: const Color(0xFF003675).withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Schedules Yet',
            style: TextStyle(
              fontSize: 20.sp,
              color: const Color(0xFF003675),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to add your first schedule',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Schedule>> _groupSchedulesByDate(
      List<Schedule> schedules) {
    final grouped = <DateTime, List<Schedule>>{};
    for (var schedule in schedules) {
      final date = DateTime(schedule.scheduleDate.year,
          schedule.scheduleDate.month, schedule.scheduleDate.day);
      grouped.putIfAbsent(date, () => []).add(schedule);
    }
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  void _showScheduleModal(BuildContext context, [Schedule? schedule]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleBottomSheet(
        eventId: eventId,
        schedule: schedule,
        scheduleService: _scheduleService,
      ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback? onTap;

  const TimelineTile({
    super.key,
    required this.schedule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.w, // Fixed width for timeline column
              child: Column(
                children: [
                  Icon(
                    schedule.icon,
                    color: const Color(0xFF003675),
                    size: 20.w, // Slightly smaller icon
                  ),
                  Container(
                    width: 2.w,
                    height: 35.h, // Reduced height for less gap
                    color: const Color(0xFF003675),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0), // Reduced spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.scheduleTime.format(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    schedule.activityName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    schedule.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
