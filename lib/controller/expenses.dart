import 'package:momento/controller/add_expense.dart';
import 'package:momento/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:momento/controller/expenses_list.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpensesList = [];

  void addExpense(Expense newExpense) {
    setState(() {
      _registeredExpensesList.add(newExpense);
    });
  }

  void _onAddNewExpenseLayout() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => AddExpense(
              addExpense: addExpense,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event ExpenseTrcaker"),
        actions: [
          IconButton(
            onPressed: _onAddNewExpenseLayout,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          const Text("The chart"),
          Expanded(
            child: ExpensesList(expenses: _registeredExpensesList),
          ),
        ],
      ),
    );
  }
}
