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

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(symbol: '\৳').format(transaction.amount),
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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
