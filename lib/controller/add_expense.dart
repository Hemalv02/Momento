import 'package:momento/model/expense.dart';
import 'package:flutter/material.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key, required this.addExpense});
  final void Function(Expense expense) addExpense;
  @override
  State<AddExpense> createState() {
    return _AddExpenseState();
  }
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.food;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid||
        _selectedDate == null) {
      showDialog(context: context, builder: (ctx) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Please make sure a valid title, amount, date and category was entered'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            )
          ],
        );
      });
      return;
    }
    widget.addExpense(Expense(
      title: _titleController.text.toUpperCase(),
      amount: enteredAmount,
      date: _selectedDate!,
      category: _selectedCategory,
    ));
  }

  void _datePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: DateTime.now());

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              keyboardType: TextInputType.text,
              maxLength: 50,
              controller: _titleController),
          Row(
            children: [
              Expanded(
                child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '৳',
                    ),
                    keyboardType: TextInputType.number,
                    controller: _amountController),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_selectedDate == null
                        ? 'No Selected Date'
                        : formatter.format(_selectedDate!)),
                    IconButton(
                        onPressed: _datePicker,
                        icon: const Icon(
                          Icons.calendar_month_sharp,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              DropdownButton(
                value: _selectedCategory,
                items: Category.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category.name.toUpperCase(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _submitExpenseData,
                child: const Text('Add Expense'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
