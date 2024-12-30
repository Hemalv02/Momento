import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
part 'guest_event.dart';
part 'guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  GuestBloc() : super(GuestInitial()) {
    on<AddGuest>(_onSubmitGuestEvent);
  }

  Future<void> _onSubmitGuestEvent(
    AddGuest event, // type of event, eikhan theke data nibo
    Emitter<GuestState> emit,)
    async {
    try {
      emit(GuestSubmitting());

      final Map<String, dynamic> GuestData = {
        "GuestName": event.GuestName,
        "GuestDesignation": event.GuestDesignation,
        "GuestNumber": event.GuestNumber,
        "EventName": event.eventName
      };

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/table/GuestList'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(GuestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(GuestSubmissionSuccess());
      } else {
        throw Exception(
            'Failed to create event. Status: ${response.statusCode}');
      }
    } catch (e) {
      emit(GuestSubmissionFailure(e.toString()));
    }
  }
}
