// import 'package:flutter/material.dart';
// import 'package:momento/model/expense_bucket.dart';
// import 'package:momento/view/chart_bar.dart';
// import 'package:momento/model/expense.dart';

// class ChartsPage extends StatelessWidget {
//   const ChartsPage({super.key, required this.expenses});

//   final List<Expense> expenses;

//   List<ExpenseBucket> get buckets {
//     return [
//       ExpenseBucket.forCategory(expenses, Category.food),
//       ExpenseBucket.forCategory(expenses, Category.gift),
//       ExpenseBucket.forCategory(expenses, Category.decoration),
//       ExpenseBucket.forCategory(expenses, Category.music),
//       ExpenseBucket.forCategory(expenses, Category.venue),
//       ExpenseBucket.forCategory(expenses, Category.raffleDraw),
//       ExpenseBucket.forCategory(expenses, Category.tShirt),
//       ExpenseBucket.forCategory(expenses, Category.transport),
//     ];
//   }

//   double get maxTotalExpense {
//     double maxTotalExpense = 0;
//     for (final bucket in buckets) {
//       if (bucket.totalExpenses > maxTotalExpense) {
//         maxTotalExpense = bucket.totalExpenses;
//       }
//     }
//     return maxTotalExpense == 0 ? 1 : maxTotalExpense;
//   }

//   @override
//   Widget build(BuildContext context) {

// //    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Expense Chart'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Card(
//         margin: const EdgeInsets.all(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Expenses by Category',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const Spacer(),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: buckets.map((bucket) {
//                     final fill = bucket.totalExpenses / maxTotalExpense;
//                     return ChartBar(
//                       fill: fill.isFinite ? fill : 0,
//                       category: bucket.category,
//                       totalAmount: bucket.totalExpenses,
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
          
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:momento/model/expense_bucket.dart';
import 'package:momento/view/chart_bar.dart';
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

  double get maxTotalExpense {
    double maxTotalExpense = 0;
    for (final bucket in buckets) {
      if (bucket.totalExpenses > maxTotalExpense) {
        maxTotalExpense = bucket.totalExpenses;
      }
    }
    return maxTotalExpense == 0 ? 1 : maxTotalExpense;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Chart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expenses by Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: buckets.map((bucket) {
                            final fill = bucket.totalExpenses / maxTotalExpense;
                            return ChartBar(
                              fill: fill.isFinite ? fill : 0,
                              category: bucket.category,
                              totalAmount: bucket.totalExpenses,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Add additional content here that would make vertical scrolling useful
                      ExpenseSummary(buckets: buckets),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Add a summary widget to show more details
class ExpenseSummary extends StatelessWidget {
  const ExpenseSummary({
    super.key,
    required this.buckets,
  });

  final List<ExpenseBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final totalExpenses = buckets.fold<double>(
      0,
      (sum, bucket) => sum + bucket.totalExpenses,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: buckets.length,
            itemBuilder: (context, index) {
              final bucket = buckets[index];
              final percentage = (bucket.totalExpenses / totalExpenses * 100)
                  .toStringAsFixed(1);
              return ListTile(
                leading: Icon(categoryIcons[bucket.category]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                ),
                
                title: Text(bucket.category.name.toUpperCase()),
                trailing: Text(
                  '৳ ${bucket.totalExpenses.toStringAsFixed(2)} ($percentage%)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Expenses:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '৳ ${totalExpenses.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}