import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventSummaryScreen extends StatefulWidget {
  final int eventId;

  const EventSummaryScreen({super.key, required this.eventId});

  @override
  State<EventSummaryScreen> createState() => _EventSummaryScreenState();
}

class _EventSummaryScreenState extends State<EventSummaryScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _summaryData;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/summarization/${widget.eventId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _summaryData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load summary: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildSummaryCard(String title, Map<String, dynamic> summary) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003675),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sentiment: ${summary['sentiment'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Key Points:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            ...List<String>.from(summary['key_points'] ?? []).map(
              (point) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Summary'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF003675),
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryCard(
                        'Food Summary',
                        _summaryData?['summaries']['food'] ?? {},
                      ),
                      _buildSummaryCard(
                        'Accommodation Summary',
                        _summaryData?['summaries']['accommodation'] ?? {},
                      ),
                      _buildSummaryCard(
                        'Management Summary',
                        _summaryData?['summaries']['management'] ?? {},
                      ),
                      _buildSummaryCard(
                        'App Usage Summary',
                        _summaryData?['summaries']['app_usage'] ?? {},
                      ),
                    ],
                  ),
                ),
    );
  }
}