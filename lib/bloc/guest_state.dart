part of 'guest_bloc.dart';

@immutable
sealed class GuestState {}

class GuestInitial extends GuestState {}

class GuestSubmitting extends GuestState {}

class GuestSubmissionSuccess extends GuestState {}

class GuestSubmissionFailure extends GuestState {
  final String error;
  GuestSubmissionFailure(this.error);
}
