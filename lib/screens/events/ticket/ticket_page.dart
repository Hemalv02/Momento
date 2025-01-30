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
          .limit(1)
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
      if (e is PostgrestException && e.code == '406') {
        setState(() {
          error = 'Multiple tickets found for this event and email.';
          isLoading = false;
        });
      } else {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  String _getTicketInclusions() {
    if (ticketSchemaData == null) return '';

    List<String> inclusions = [];
    if (ticketSchemaData!['entry'] == true) inclusions.add('Entry');
    if (ticketSchemaData!['breakfast'] == true) inclusions.add('Breakfast');
    if (ticketSchemaData!['lunch'] == true) inclusions.add('Lunch');
    if (ticketSchemaData!['dinner'] == true) inclusions.add('Dinner');
    if (ticketSchemaData!['gift'] == true) inclusions.add('Gift');
    if (ticketSchemaData!['tshirt'] == true) inclusions.add('T-Shirt');
    if (ticketSchemaData!['snack'] == true) inclusions.add('Snacks');
    if (ticketSchemaData!['cultural'] == true)
      inclusions.add('Cultural Events');

    return inclusions.join(' + ');
  }

  Widget _buildNoTicketState() {
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
                  color: Color(0xFF003675).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 64,
                  color: Color(0xFF003675).withAlpha(153),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ticket Not Generated Yet',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF003675),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (eventData != null)
                Text(
                  'Event: ${eventData!['event_name']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF003675),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event Ticket'),
          backgroundColor: const Color(0xFF003675),
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $error')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Ticket'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      body: ticketData == null
          ? _buildNoTicketState()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Header with custom design
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF003675),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.confirmation_num_rounded,
                                      color: Colors.white70,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        eventData?['event_name'] ??
                                            'Event Name',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Ticket #${ticketData?['id'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Ticket details with improved styling
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(
                                  'Location',
                                  eventData?['location'] ?? 'N/A',
                                  Icons.location_on,
                                ),
                                const SizedBox(height: 20),
                                _buildDetailRow(
                                  'Organized by',
                                  eventData?['organized_by'] ?? 'N/A',
                                  Icons.business,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF003675)
                                        .withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Start Date',
                                              style: TextStyle(
                                                color: Color(0xFF003675),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('MMM dd, yyyy').format(
                                                DateTime.parse(
                                                    eventData?['start_date'] ??
                                                        DateTime.now()
                                                            .toString()),
                                              ),
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: const Color(0xFF003675)
                                            .withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'End Date',
                                                style: TextStyle(
                                                  color: Color(0xFF003675),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat('MMM dd, yyyy')
                                                    .format(
                                                  DateTime.parse(
                                                      eventData?['end_date'] ??
                                                          DateTime.now()
                                                              .toString()),
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),
                                // QR Code with improved container
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF003675)
                                          .withOpacity(0.1),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      QrImageView(
                                        data: ticketData?['ticket_key'] ?? '',
                                        version: QrVersions.auto,
                                        size: 200.0,
                                        foregroundColor:
                                            const Color(0xFF003675),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.qr_code_scanner,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Scan to verify ticket',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Footer with subtle design
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003675).withOpacity(0.02),
                              border: Border(
                                top: BorderSide(
                                  color:
                                      const Color(0xFF003675).withOpacity(0.1),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Generated on',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy HH:mm').format(
                                    DateTime.parse(
                                      ticketData?['created_at'] ??
                                          DateTime.now().toString(),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF003675),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
