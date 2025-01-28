import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionSummaryWidget extends StatefulWidget {
  final int eventId;

  const TransactionSummaryWidget({super.key, required this.eventId});

  @override
  State<TransactionSummaryWidget> createState() =>
      _TransactionSummaryWidgetState();
}

class _TransactionSummaryWidgetState extends State<TransactionSummaryWidget> {
  final _supabase = Supabase.instance.client;
  double totalIncome = 0;
  double totalExpense = 0;
  Map<String, double> categoryTotals = {};
  bool isLoading = true;
  final ScreenshotController _barChartController = ScreenshotController();
  final ScreenshotController _pieChartController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _supabase
          .from('event_transactions')
          .select()
          .eq('event_id', widget.eventId)
          .order('date', ascending: false);

      totalIncome = 0;
      totalExpense = 0;
      categoryTotals = {
        'food': 0,
        'gift': 0,
        'transport': 0,
        'entertainment': 0,
        'bills': 0,
        'others': 0,
      };

      for (var transaction in response) {
        final amount = double.parse(transaction['amount'].toString());
        final type = transaction['type'];
        final category = transaction['category'];

        if (type == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        }
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _generateAndSavePdf() async {
    try {
      final barChartImage = await _barChartController.capture();
      final pieChartImage = await _pieChartController.capture();

      if (barChartImage == null || pieChartImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture charts')),
        );
        return;
      }

      final pdf = pw.Document();
      final netBalance = totalIncome - totalExpense;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Transaction Summary',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Financial Summary',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Total Income: ৳${totalIncome.toStringAsFixed(2)}'),
                pw.Text('Total Expense: ৳${totalExpense.toStringAsFixed(2)}'),
                pw.Text(
                  'Remaining Budget: ৳${netBalance.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    color:
                        netBalance >= 0 ? PdfColors.green : PdfColors.red,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Expenses by Category',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Image(
                  pw.MemoryImage(barChartImage),
                  width: 500,
                  height: 300,
                ),
                pw.SizedBox(height: 20),
                pw.Text('Category Distribution',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Image(
                  pw.MemoryImage(pieChartImage),
                  width: 200,
                  height: 200,
                ),
                pw.SizedBox(height: 20),
                pw.Text('Category Breakdown:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ...categoryTotals.entries.map((entry) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(
                        '${entry.key.capitalize()}: ৳${entry.value.toStringAsFixed(2)}'),
                  );
                }).toList(),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingBudget = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Summary'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _generateAndSavePdf,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Summary',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SummaryCard(
                          title: 'Total Income',
                          amount: totalIncome,
                          color: Colors.green,
                        ),
                        _SummaryCard(
                          title: 'Total Expense',
                          amount: totalExpense,
                          color: Colors.red,
                        ),
                        _SummaryCard(
                          title: 'Remaining Budget',
                          amount: remainingBudget,
                          color:
                              remainingBudget >= 0 ? Colors.blue : Colors.red,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Expenses by Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Screenshot(
                      controller: _barChartController,
                      child: SizedBox(
                        height: 300,
                        width: categoryTotals.length * 80.0,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: categoryTotals.values.isEmpty
                                ? 0
                                : categoryTotals.values
                                        .reduce((a, b) => a > b ? a : b) *
                                    1.2,
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final categories =
                                        categoryTotals.keys.toList();
                                    if (value >= 0 && value < categories.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          categories[value.toInt()].capitalize(),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: categoryTotals.entries
                                .map(
                                  (entry) => BarChartGroupData(
                                    x: categoryTotals.keys
                                        .toList()
                                        .indexOf(entry.key),
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value,
                                        color: _getCategoryColor(entry.key),
                                        width: 20,
                                        borderRadius: BorderRadius.circular(8),
                                        backDrawRodData:
                                            BackgroundBarChartRodData(
                                          show: true,
                                          toY: categoryTotals.values.reduce(
                                                  (a, b) => a > b ? a : b) *
                                              1.2,
                                          color: Colors.grey.withAlpha(25),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Category Distribution',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 300,
                          child: Screenshot(
                            controller: _pieChartController,
                            child: PieChart(
                              PieChartData(
                                sections: categoryTotals.entries
                                    .map(
                                      (entry) => PieChartSectionData(
                                        color: _getCategoryColor(entry.key),
                                        value: entry.value,
                                        title:
                                            '${(entry.value / totalExpense * 100).toStringAsFixed(1)}%',
                                        radius: 50,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categoryTotals.keys.map((category) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: _getCategoryColor(category),
                                ),
                                const SizedBox(width: 8),
                                Text(category.capitalize()),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'food':
        return const Color(0xFF1E88E5);
      case 'gift':
        return const Color(0xFF8E24AA);
      case 'transport':
        return const Color(0xFFFFA726);
      case 'entertainment':
        return const Color(0xFF43A047);
      case 'bills':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF757575);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(127)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}