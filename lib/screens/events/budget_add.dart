import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/budget_bloc/budget_bloc.dart';
import 'package:momento/screens/events/budget_bloc/budget_event.dart';
import 'package:momento/screens/events/budget_bloc/budget_model.dart';
import 'package:momento/screens/events/budget_bloc/budget_state.dart';

class BudgetAdd extends StatefulWidget {
  final int eventId;

  const BudgetAdd({super.key, required this.eventId});

  @override
  State<BudgetAdd> createState() => _BudgetAddState();
}

class _BudgetAddState extends State<BudgetAdd> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _transactionType = '';
  String _category = '';
  final String userId = prefs.getString('userId')!;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _transactionType.isNotEmpty) {
      final transaction = Transaction(
        id: 0, // This will be assigned by the backend
        eventId: widget.eventId,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        type: _transactionType == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        category: _category.isNotEmpty
            ? TransactionCategory.values.firstWhere((e) =>
                e.toString().split('.').last.toLowerCase() ==
                _category.toLowerCase())
            : null,
        description: _descriptionController.text,
        date: DateTime.now(),
        createdBy: userId, // Replace with actual user ID
        createdAt: DateTime.now(),
      );

      context
          .read<BudgetBloc>()
          .add(CreateTransaction(transaction: transaction));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is TransactionCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Return to previous screen
        } else if (state is BudgetError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Transaction'),
          backgroundColor: const Color(0xFF003675),
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 5.h),
                                child: Text(
                                  'Title',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF003675),
                                        width: 2.w),
                                  ),
                                  hintText: 'Enter Transaction Title',
                                  hintStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a title';
                                  }

                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                margin: EdgeInsets.only(bottom: 5.h),
                                child: Text(
                                  'Amount',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _amountController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF003675),
                                        width: 2.w),
                                  ),
                                  hintText: 'Enter amount',
                                  hintStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                margin: EdgeInsets.only(bottom: 5.h),
                                child: Text(
                                  'Transaction Type',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Wrap(
                                spacing: 10.w,
                                runSpacing: 10.h,
                                children: [
                                  ChoiceChip(
                                    side: BorderSide(
                                      color: const Color(0xFF003675),
                                      width: 1.w,
                                    ),
                                    backgroundColor: Colors.white,
                                    label: Text(
                                      'Income',
                                      style: TextStyle(
                                          color: _transactionType == 'income'
                                              ? Colors.white
                                              : const Color(0xFF003675)),
                                    ),
                                    selected: _transactionType == 'income',
                                    selectedColor: const Color(0xFF003675),
                                    onSelected: (selected) {
                                      setState(() {
                                        _transactionType =
                                            selected ? 'income' : '';
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    side: BorderSide(
                                      color: const Color(0xFF003675),
                                      width: 1.w,
                                    ),
                                    backgroundColor: Colors.white,
                                    label: Text(
                                      'Expense',
                                      style: TextStyle(
                                          color: _transactionType == 'expense'
                                              ? Colors.white
                                              : const Color(0xFF003675)),
                                    ),
                                    selected: _transactionType == 'expense',
                                    selectedColor: const Color(0xFF003675),
                                    onSelected: (selected) {
                                      setState(() {
                                        _transactionType =
                                            selected ? 'expense' : '';
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                margin: EdgeInsets.only(bottom: 5.h),
                                child: Text(
                                  'Category',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Wrap(
                                spacing: 10.w,
                                runSpacing: 10.h,
                                children: [
                                  for (var category in [
                                    'Transport',
                                    'Entertainment',
                                    'Food',
                                    'Gift',
                                    'Bills',
                                    'Others'
                                  ])
                                    ChoiceChip(
                                      side: BorderSide(
                                        color: const Color(0xFF003675),
                                        width: 1.w,
                                      ),
                                      backgroundColor: Colors.white,
                                      label: Text(
                                        category,
                                        style: TextStyle(
                                            color: _category == category
                                                ? Colors.white
                                                : const Color(0xFF003675)),
                                      ),
                                      selected: _category == category,
                                      selectedColor: const Color(0xFF003675),
                                      onSelected: (selected) {
                                        setState(() {
                                          _category = selected ? category : '';
                                        });
                                      },
                                    ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                margin: EdgeInsets.only(bottom: 5.h),
                                child: Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF003675),
                                        width: 2.w),
                                  ),
                                  hintText: 'Enter description',
                                  hintStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                maxLines: 4, // Makes the description box larger
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24.h),
                              FilledButton(
                                onPressed: state is BudgetLoading
                                    ? null
                                    : _handleSubmit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: state is BudgetLoading
                                      ? const Color(0xFF003675).withAlpha(178)
                                      : const Color(0xFF003675),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: state is BudgetLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Add Transaction',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
