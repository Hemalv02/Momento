import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/budget_bloc/budget_model.dart';
import 'budget_event.dart';
import 'budget_state.dart';
import 'budget_api_service.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetApiService _apiService;

  BudgetBloc(this._apiService) : super(BudgetInitial()) {
    on<CreateTransaction>(_onCreateTransaction);
    on<FetchTransactions>(_onFetchTransactions);
    on<FetchBudgetSummary>(_onFetchBudgetSummary);
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final transaction =
          await _apiService.createTransaction(event.transaction);
      emit(TransactionCreated(transaction));
    } catch (e) {
      print('Error creating transaction: $e');
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final transactions =
          await _apiService.getTransactions(event.eventId, event.currentUserId);
      if (transactions.isEmpty) {
        emit(BudgetEmpty());
      } else {
        emit(TransactionsLoaded(transactions));
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onFetchBudgetSummary(
    FetchBudgetSummary event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final summary = await _apiService.getBudgetSummary(
          event.eventId, event.currentUserId);
      emit(BudgetSummaryLoaded(
        totalIncome: summary['total_income'] is String
            ? double.parse(summary['total_income'])
            : summary['total_income'],
        totalExpense: summary['total_expense'] is String
            ? double.parse(summary['total_expense'])
            : summary['total_expense'],
        balance: summary['balance'] is String
            ? double.parse(summary['balance'])
            : summary['balance'],
        expensesByCategory: Map.fromEntries(
          (summary['expenses_by_category'] as Map<String, dynamic>).entries.map(
                (e) => MapEntry(
                  TransactionCategory.values.firstWhere(
                      (cat) => cat.toString().split('.').last == e.key),
                  e.value is String ? double.parse(e.value) : e.value,
                ),
              ),
        ),
        latestTransactions: (summary['latest_transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList(),
      ));
    } catch (e) {
      print('Error fetching budget summary: $e');
      emit(BudgetError(e.toString()));
    }
  }
}
