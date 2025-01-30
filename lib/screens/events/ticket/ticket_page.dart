import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketPage extends StatefulWidget {
  final int eventId;
  final String userEmail;
  const TicketPage({super.key, required this.eventId, required this.userEmail});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? ticketData;
  Map<String, dynamic>? ticketSchemaData;
  Map<String, dynamic>? eventData;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    fetchTicketData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchTicketData() async {
    try {
      final ticketResponse = await supabase
          .from('tickets')
          .select()
          .eq('event_id', widget.eventId)
          .eq('email', widget.userEmail)
          .maybeSingle();

      if (ticketResponse != null) {
        final eventResponse = await supabase
            .from('event')
            .select()
            .eq('id', widget.eventId)
            .single();

        final ticketSchemaResponse = await supabase
            .from('ticket_schema')
            .select()
            .eq('event_id', widget.eventId)
            .single();

        setState(() {
          ticketData = ticketResponse;
          eventData = eventResponse;
          ticketSchemaData = ticketSchemaResponse;
          isLoading = false;
        });
      } else {
        final eventResponse = await supabase
            .from('event')
            .select()
            .eq('id', widget.eventId)
            .single();

        setState(() {
          eventData = eventResponse;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _getTicketInclusions() {
    if (ticketSchemaData == null) return '';

    List<String> inclusions = [];
    if (ticketSchemaData!['entry']) inclusions.add('Entry');
    if (ticketSchemaData!['breakfast']) inclusions.add('Breakfast');
    if (ticketSchemaData!['lunch']) inclusions.add('Lunch');
    if (ticketSchemaData!['dinner']) inclusions.add('Dinner');
    if (ticketSchemaData!['gift']) inclusions.add('Gift');
    if (ticketSchemaData!['tshirt']) inclusions.add('T-Shirt');
    if (ticketSchemaData!['snack']) inclusions.add('Snacks');
    if (ticketSchemaData!['cultural']) inclusions.add('Cultural Events');

    return inclusions.join(' + ');
  }

  Widget _buildNoTicketAnimation() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Ticket'),
        backgroundColor: const Color(0xFF003675),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ticket Not Generated Yet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please complete the registration process\nto generate your ticket.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (eventData != null)
                      Text(
                        'Event: ${eventData!['event_name']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $error')),
      );
    }

    if (ticketData == null) {
      return _buildNoTicketAnimation();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Ticket'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF7C3AED),
                            Color(0xFF3B82F6),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventData!['event_name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ticket #${ticketData!['id']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Location',
                            eventData!['location'],
                            Icons.location_on,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Organized by',
                            eventData!['organized_by'],
                            Icons.business,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailRow(
                                  'Start',
                                  DateFormat('MMM dd, yyyy').format(
                                    DateTime.parse(eventData!['start_date']),
                                  ),
                                  Icons.calendar_today,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailRow(
                                  'End',
                                  DateFormat('MMM dd, yyyy').format(
                                    DateTime.parse(eventData!['end_date']),
                                  ),
                                  Icons.calendar_today,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: ticketData!['ticket_key'],
                                  version: QrVersions.auto,
                                  size: 200.0,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Scan to verify ticket',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ticket Includes:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getTicketInclusions(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Text(
                        'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(ticketData!['created_at']))}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
