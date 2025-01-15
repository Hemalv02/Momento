import 'package:equatable/equatable.dart';
import 'package:momento/screens/events/budget_bloc/budget_model.dart';

abstract class BudgetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTransactions extends BudgetEvent {
  final int eventId;
  final String currentUserId; // Add this

  FetchTransactions({
    required this.eventId,
    required this.currentUserId, // Add this
  });

  @override
  List<Object?> get props => [eventId, currentUserId];
}

class FetchBudgetSummary extends BudgetEvent {
  final int eventId;
  final String currentUserId; // Add this

  FetchBudgetSummary({
    required this.eventId,
    required this.currentUserId, // Add this
  });

  @override
  List<Object?> get props => [eventId, currentUserId];
}

class CreateTransaction extends BudgetEvent {
  final Transaction transaction;

  CreateTransaction({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
