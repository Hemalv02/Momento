import 'package:momento/view/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:momento/model/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList(
      {super.key, required this.expenses, required this.deleteExpense});

  final List<Expense> expenses;
  final void Function(Expense) deleteExpense;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) => Dismissible(
        key: ValueKey(expenses[index]),
        direction: DismissDirection.startToEnd,
        background: Container(
          color: Theme.of(context).colorScheme.error,
          alignment: Alignment.centerLeft,
          margin: Theme.of(context).cardTheme.margin,
          child: const Icon(Icons.delete, color: Colors.white, size: 40),
        ),
        child: ExpenseItem(expense: expenses[index]),
        onDismissed: (direction) {
          deleteExpense(expenses[index]);
        },
      ),
    );
  }
}
