// import 'package:momento/controller/add_expense.dart';
// import 'package:momento/controller/charts_page.dart';
// import 'package:momento/dummy_data.dart';
// import 'package:momento/model/expense.dart';
// import 'package:flutter/material.dart';
// import 'package:momento/controller/expenses_list.dart';

// class Expenses extends StatefulWidget {
//   const Expenses({super.key});

//   @override
//   State<Expenses> createState() {
//     return _ExpensesState();
//   }
// }

// class _ExpensesState extends State<Expenses> {
//   final List<Expense> _registeredExpensesList =
//       DummyData().registeredExpensesList;

//   void _addExpense(Expense newExpense) {
//     setState(() {
//       _registeredExpensesList.add(newExpense);
//     });
//   }

//   void _deleteExpense(Expense expense) {
//     final index = _registeredExpensesList.indexOf(expense);
//     setState(() {
//       _registeredExpensesList.remove(expense);
//     });
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('${expense.title} deleted'),
//       duration: const Duration(seconds: 3),
//       action: SnackBarAction(
//         label: 'Undo',
//         onPressed: () {
//           setState(() {
//             _registeredExpensesList.insert(index, expense);
//           });
//         },
//       ),
//     ));
//   }

//   void _onAddNewExpenseLayout() {
//     showModalBottomSheet(
//       isScrollControlled: true,
//       useSafeArea: true,
//       context: context,
//       builder: (ctx) => Padding(
//         padding: EdgeInsets.fromLTRB(
//           0,
//           0,
//           0,
//           MediaQuery.of(ctx).viewInsets.bottom,
//         ),
//         child: AddExpense(
//           addExpense: _addExpense,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Event ExpenseTracker"),
//         actions: [
//           IconButton(
//             onPressed: _onAddNewExpenseLayout,
//             icon: const Icon(Icons.add),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         ChartsPage(expenses: _registeredExpensesList)),
//               );
//             },
//             child: const Card(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.bar_chart, size: 24),
//                   SizedBox(width: 8),
//                   Text(
//                     "The Chart",
//                     style: TextStyle(fontSize: 20),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: ExpensesList(
//                 expenses: _registeredExpensesList,
//                 deleteExpense: _deleteExpense),
//           ),
//         ],
//       ),
//     );
//   }
// }
