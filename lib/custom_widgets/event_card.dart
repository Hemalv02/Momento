import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:momento/custom_widgets/build_date_info.dart';
import 'package:momento/custom_widgets/info_row.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final GestureTapCallback onEventTap;
  const EventCard({
    super.key,
    required this.event,
    required this.onEventTap,
  });

  String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, y, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEventTap,
      child: Card(
        // clickable
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: const Color.fromARGB(255, 240, 246, 252),
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF003675),
                child: Text(
                  event.eventName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dates
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        buildDateInfo(
                          context,
                          Icons.calendar_today,
                          'Start Date',
                          formatDate(event.startDate),
                        ),
                        buildDateInfo(
                          context,
                          Icons.calendar_today,
                          'End Date',
                          formatDate(event.endDate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Location
                    InfoRow(icon: Icons.location_on, label: "Location", value: event.location),
                    const SizedBox(height: 16),
                    // Organizer
                    InfoRow(icon: Icons.person, label: "Organizer", value: event.organizedBy),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}