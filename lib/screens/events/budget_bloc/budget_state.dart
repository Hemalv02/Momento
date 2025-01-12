import 'package:equatable/equatable.dart';
import 'package:momento/screens/events/budget_bloc/budget_model.dart';

abstract class BudgetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class TransactionCreated extends BudgetState {
  final Transaction transaction;

  TransactionCreated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionsLoaded extends BudgetState {
  final List<Transaction> transactions;

  TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class BudgetSummaryLoaded extends BudgetState {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<TransactionCategory, double> expensesByCategory;
  final List<Transaction> latestTransactions;

  BudgetSummaryLoaded({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.expensesByCategory,
    required this.latestTransactions,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        balance,
        expensesByCategory,
        latestTransactions
      ];
}

class BudgetError extends BudgetState {
  final String message;

  BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}
