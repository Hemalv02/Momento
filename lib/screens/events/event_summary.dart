import 'dart:typed_data';
import 'package:flutter/services.dart';  // For clipboard functionality
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionSummaryWidget extends StatefulWidget {
  final int eventId;

  const TransactionSummaryWidget({super.key, required this.eventId});

  @override
  State<TransactionSummaryWidget> createState() => _TransactionSummaryWidgetState();
}

class _TransactionSummaryWidgetState extends State<TransactionSummaryWidget> {
  final _supabase = Supabase.instance.client;
  double totalIncome = 0;
  double totalExpense = 0;
  Map<String, double> categoryTotals = {};
  bool isLoading = true;
  final ScreenshotController screenshotController = ScreenshotController();

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
      final amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0;
      final type = transaction['type'] ?? 'Not Specified'; // Default to empty string if null
      final category = transaction['category'] ?? 'others'; // Default to 'others' if null

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
Future<void> _generateAndUploadPdf() async {
  try {
    final pdf = pw.Document();

    // Handle edge case where total expense is 0
    final effectiveTotalExpense = totalExpense == 0 ? 1 : totalExpense;

    // Find max value for bar chart scaling
    final maxValue = categoryTotals.values.isEmpty
        ? 1  // Use 1 as minimum to prevent scaling issues
        : categoryTotals.values.reduce((a, b) => a > b ? a : b);
    
    // Ensure maxValue is not 0
    final effectiveMaxValue = maxValue == 0 ? 1 : maxValue;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title
                pw.Center(
                  child: pw.Text(
                    'Transaction Summary',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Financial Summary Cards
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPdfSummaryCard('Total Income', totalIncome, PdfColors.green),
                    _buildPdfSummaryCard('Total Expense', totalExpense, PdfColors.red),
                    _buildPdfSummaryCard(
                      'Remaining Budget', 
                      totalIncome - totalExpense,
                      (totalIncome - totalExpense) >= 0 ? PdfColors.blue : PdfColors.red,
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Expenses by Category
                pw.Text(
                  'Expenses by Category',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Bar Chart
                pw.Container(
                  height: 200,
                  child: pw.Chart(
                    grid: pw.CartesianGrid(
                      xAxis: pw.FixedAxis.fromStrings(
                        List.generate(
                          categoryTotals.length,
                          (index) => categoryTotals.keys.elementAt(index).capitalize(),
                        ),
                        marginStart: 30,
                        marginEnd: 30,
                      ),
                      yAxis: pw.FixedAxis(
                        [0, effectiveMaxValue * 0.25, effectiveMaxValue * 0.5, 
                         effectiveMaxValue * 0.75, effectiveMaxValue],
                        format: (v) => 'BDT.${v.toStringAsFixed(0)}',
                      ),
                    ),
                    datasets: [
                      pw.BarDataSet(
                        data: List.generate(
                          categoryTotals.length,
                          (index) => pw.PointChartValue(
                            index.toDouble(),
                            categoryTotals.values.elementAt(index),
                          ),
                        ),
                        color: PdfColors.blue,
                        legend: 'Expenses',
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Category Distribution
                pw.Text(
                  'Category Distribution',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Category distribution table with safe percentage calculation
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Category',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Percentage',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    // Data rows with safe percentage calculation
                    ...categoryTotals.entries.map(
                      (entry) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(entry.key.capitalize()),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('BDT.${entry.value.toStringAsFixed(2)}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              '${(entry.value / effectiveTotalExpense * 100).toStringAsFixed(1)}%',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );


final pdfBytes = await pdf.save();
    final filename = 'transaction_summary_${widget.eventId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    await _supabase
        .storage
        .from('PDF')
        .uploadBinary(filename, pdfBytes);

    final fileUrl = await _supabase
        .storage
        .from('PDF')
        .getPublicUrl(filename);

    await _supabase.from('PDF').insert({
      'event_id': widget.eventId,
      'pdf_url': fileUrl,
    });

    if (mounted) {
      // Show bottom sheet with URL
      _showPdfUrlSheet(context, fileUrl);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF uploaded successfully')),
      );
    }
  } catch (e) {
    debugPrint('Error generating PDF: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }
}

void _showPdfUrlSheet(BuildContext context, String pdfUrl) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PDF Generated Successfully',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003675),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pdfUrl,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFF003675)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: pdfUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('URL copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copy URL',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003675),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await Clipboard.setData(ClipboardData(text: pdfUrl));
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PDF URL copied successfully!'),
                              ),
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error copying URL: $error'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Copy Link',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}


// Helper method to build summary cards in PDF
pw.Widget _buildPdfSummaryCard(String title, double amount, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: color),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'BDT.${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final remainingBudget = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Summary'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        actions: [  // Add this actions property
        IconButton(
        onPressed: _generateAndUploadPdf,
        icon: const Icon(Icons.picture_as_pdf),
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
                    child: SizedBox(
                      height: 300,
                      width: categoryTotals.length *
                          80.0, // Adjust width based on number of categories
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
        return const Color(0xFF1E88E5); // Blue
      case 'gift':
        return const Color(0xFF8E24AA); // Purple
      case 'transport':
        return const Color(0xFFFFA726); // Orange
      case 'entertainment':
        return const Color(0xFF43A047); // Green
      case 'bills':
        return const Color(0xFFE53935); // Red
      default:
        return const Color(0xFF757575); // Grey
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
            'BDT.${amount.toStringAsFixed(2)}',
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