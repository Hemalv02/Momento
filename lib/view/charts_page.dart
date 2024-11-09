import 'package:momento/model/expense_bucket.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:momento/model/expense.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key, required this.expenses});

  final List<Expense> expenses;

  List<ExpenseBucket> get buckets {
    return [
      ExpenseBucket.forCategory(expenses, Category.food),
      ExpenseBucket.forCategory(expenses, Category.gift),
      ExpenseBucket.forCategory(expenses, Category.decoration),
      ExpenseBucket.forCategory(expenses, Category.music),
      ExpenseBucket.forCategory(expenses, Category.venue),
      ExpenseBucket.forCategory(expenses, Category.raffleDraw),
      ExpenseBucket.forCategory(expenses, Category.tShirt),
      ExpenseBucket.forCategory(expenses, Category.transport),
    ];
  }

  double get totalExpense {
    return buckets.fold(0, (sum, bucket) => sum + bucket.totalExpenses);
  }

  @override
  Widget build(BuildContext context) {
    //final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense PieChart"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: buckets.map((bucket) {
                final expensePercentage = bucket.totalExpenses / totalExpense * 100;
                return PieChartSectionData(
                  value: bucket.totalExpenses,
                  title: '${expensePercentage.toStringAsFixed(1)}%\n',
                  showTitle: false,
                  color: _getCategoryColor(bucket.category),
                  radius: 60,
                  badgeWidget: Icon(
                    categoryIcons[bucket.category],
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(Category category) {
    switch (category) {
      case Category.food:
        return Colors.orange;
      case Category.gift:
        return Colors.red;
      case Category.decoration:
        return Colors.green;
      case Category.music:
        return Colors.blue;
      case Category.venue:
        return Colors.purple;
      case Category.raffleDraw:
        return Colors.pink;
      case Category.tShirt:
        return Colors.teal;
      case Category.transport:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
