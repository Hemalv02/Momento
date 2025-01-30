import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/budget_add.dart';
import 'package:momento/screens/events/budget_bloc/budget_api_service.dart';
import 'package:momento/screens/events/budget_bloc/budget_bloc.dart';
import 'package:momento/screens/events/budget_bloc/budget_event.dart';
import 'package:momento/screens/events/budget_bloc/budget_model.dart';
import 'package:momento/screens/events/budget_bloc/budget_state.dart';
import 'package:intl/intl.dart';
import 'package:momento/screens/events/event_summary.dart';
import 'package:momento/utils/flutter_toaster.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventBudget extends StatefulWidget {
  final int eventId;
  const EventBudget({super.key, required this.eventId});

  @override
  State<EventBudget> createState() => _EventBudgetState();
}

class _EventBudgetState extends State<EventBudget> {
  final String userId = prefs.getString('userId')!;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    context
        .read<BudgetBloc>()
        .add(FetchTransactions(eventId: widget.eventId, currentUserId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Budget'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => BudgetBloc(BudgetApiService()),
                    child: BudgetAdd(eventId: widget.eventId),
                  ),
                ),
              )
              .then((_) => _refreshData());
        },
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            if (state is BudgetLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BudgetEmpty) {
              return _buildEmptyState();
            } else if (state is BudgetError) {
              return Center(child: Text(state.message));
            } else if (state is TransactionsLoaded) {
              return _buildTransactionList(state.transactions);
            }
            return const Center(child: Text('No transactions available'));
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionCard(transactions[index]);
        },
      ),
    );
  }

  Future<void> onDelete(int id, BuildContext context) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('event_transactions').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> onUpdate(Transaction transaction, BuildContext context) async {
    final supabase = Supabase.instance.client;

    // Variables to hold user input
    String title = transaction.title;
    double amount = transaction.amount;
    TransactionType type = transaction.type;
    TransactionCategory? category =
        transaction.category ?? TransactionCategory.transport;
    String description = transaction.description;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.w,
              right: 16.w,
              top: 16.h,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add a handle at the top for better UX
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Edit Transaction',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF003675),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: TextEditingController(text: title),
                            decoration: const InputDecoration(
                              labelText: 'Task Title',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF003675)),
                              ),
                            ),
                            onChanged: (value) => title = value,
                          ),
                          SizedBox(height: 16.h),
                          TextField(
                            controller:
                                TextEditingController(text: amount.toString()),
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF003675)),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                amount = double.tryParse(value) ?? 0.0,
                          ),
                          SizedBox(height: 16.h),
                          DropdownButtonFormField<TransactionType>(
                            value: type,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF003675)),
                              ),
                            ),
                            items: TransactionType.values
                                .map((TransactionType type) {
                              return DropdownMenuItem<TransactionType>(
                                value: type,
                                child: Text(type
                                    .toString()
                                    .split('.')
                                    .last
                                    .capitalize()),
                              );
                            }).toList(),
                            onChanged: (value) => type = value!,
                          ),
                          SizedBox(height: 16.h),
                          DropdownButtonFormField<TransactionCategory>(
                            value: category,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF003675)),
                              ),
                            ),
                            items: TransactionCategory.values
                                .map((TransactionCategory category) {
                              return DropdownMenuItem<TransactionCategory>(
                                value: category,
                                child: Text(category
                                    .toString()
                                    .split('.')
                                    .last
                                    .capitalize()),
                              );
                            }).toList(),
                            onChanged: (value) => category = value!,
                          ),
                          SizedBox(height: 16.h),
                          TextField(
                            controller:
                                TextEditingController(text: description),
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF003675)),
                              ),
                            ),
                            onChanged: (value) => description = value,
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003675),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                try {
                                  await supabase
                                      .from('event_transactions')
                                      .update({
                                    'title': title,
                                    'amount': amount,
                                    'category':
                                        category.toString().split('.').last,
                                    'type': type.toString().split('.').last,
                                    'description': description,
                                  }).eq('id', transaction.id);

                                  toastInfo(
                                    message: "Transaction Updated",
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                  );
                                  _refreshData();
                                } catch (e) {
                                  toastInfo(
                                    message: "Error: ${e.toString()}",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                }
                              },
                              child: Text(
                                'Update Transaction',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  16.h), // Bottom padding for better spacing
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                  'Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete(transaction.id, context);
      },
      background: Container(
        color: const Color(0xFF003675),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 0,
        color: const Color(0xFF003675).withAlpha(15),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          title: Text(
            transaction.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.description,
                style: TextStyle(fontSize: 14.sp),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(transaction.date),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(symbol: '\৳')
                        .format(transaction.amount),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: transaction.type == TransactionType.income
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  if (transaction.category != null)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003675).withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        transaction.category.toString().split('.').last,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF003675),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF003675),
                ),
                onPressed: () => onUpdate(transaction, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    const baseColor = Color(0xFF003675);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: baseColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.money,
                  size: 64,
                  color: baseColor.withAlpha(178),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No transactions or budgets Yet',
                style: TextStyle(
                  fontSize: 20,
                  color: baseColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the + button to add your first transaction or budget item',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: baseColor.withAlpha(178),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
