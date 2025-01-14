import 'package:flutter/material.dart';

class Schedule {
  final int? id;
  final int eventId;
  final DateTime scheduleDate;
  final TimeOfDay scheduleTime;
  final String activityName;
  final String activityType;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Schedule({
    this.id,
    required this.eventId,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.activityName,
    required this.activityType,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  IconData get icon {
    switch (activityType.toLowerCase()) {
      case 'speech':
        return Icons.mic;
      case 'meal':
        return Icons.lunch_dining;
      case 'workshop':
        return Icons.work;
      case 'networking':
        return Icons.group;
      case 'break':
        return Icons.local_cafe;
      case 'ceremony':
        return Icons.celebration;
      case 'party':
        return Icons.party_mode;
      case 'activity':
        return Icons.self_improvement;
      case 'photo':
        return Icons.camera_alt;
      case 'award':
        return Icons.emoji_events;
      default:
        return Icons.event;
    }
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      eventId: json['event_id'],
      scheduleDate: DateTime.parse(json['schedule_date']),
      scheduleTime: TimeOfDay.fromDateTime(
          DateTime.parse(json['schedule_date'] + ' ' + json['schedule_time'])),
      activityName: json['activity_name'],
      activityType: json['activity_type'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'schedule_date': scheduleDate.toIso8601String().split('T')[0],
      'schedule_time':
          '${scheduleTime.hour.toString().padLeft(2, '0')}:${scheduleTime.minute.toString().padLeft(2, '0')}:00',
      'activity_name': activityName,
      'activity_type': activityType,
      'description': description,
      'created_by': createdBy,
    };
  }
}
