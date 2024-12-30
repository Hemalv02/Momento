// event_management_bloc.dart
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

part 'event_management_event.dart';
part 'event_management_state.dart';

class EventBloc extends Bloc<EventManagementEvent, EventManagementState> {
  EventBloc() : super(EventInitial()) {
    on<SubmitEvent>(_onSubmitEvent);
  }

  Future<void> _onSubmitEvent(
    SubmitEvent event,
    Emitter<EventManagementState> emit,
  ) async {
    try {
      emit(EventSubmitting());

      final Map<String, dynamic> eventData = {
        "EventName": event.eventName,
        "Date": event.date,
        "Time": event.time,
        "Location": event.location,
        "Budget": double.parse(event.budget),
        "Organized_By": event.organizedBy,
      };

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/table/EventList'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(eventData),
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(EventSubmissionSuccess());
      } else {
        throw Exception('Failed to create event. Status: ${response.statusCode}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error creating event: $error');
      }
      emit(EventSubmissionFailure(error.toString()));
    }
  }
}