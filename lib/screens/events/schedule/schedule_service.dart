import 'package:momento/screens/events/schedule/schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleService {
  final SupabaseClient _supabase;

  ScheduleService(this._supabase);

  Stream<List<Schedule>> streamSchedules(int eventId) {
    return _supabase
        .from('event_schedule')
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .order('schedule_date', ascending: true)
        .order('schedule_time',
            ascending: true) // This ensures proper time ordering
        .map((data) => data.map((json) => Schedule.fromJson(json)).toList());
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _supabase.from('event_schedule').insert(schedule.toJson());
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _supabase
        .from('event_schedule')
        .update(schedule.toJson())
        .eq('id', schedule.id as Object);
  }

  Future<void> deleteSchedule(int scheduleId) async {
    await _supabase.from('event_schedule').delete().eq('id', scheduleId);
  }
}
