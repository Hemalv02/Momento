import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventTicket extends StatelessWidget {
  // Sample ticket data model
  final TicketData ticketData = TicketData(
    eventName: 'Summer Music Festival 2025',
    ticketType: 'VIP Entry + Food',
    usageType: 'Multiple',
    issueDate: DateTime.now(),
    expiryDate: DateTime.now().add(const Duration(days: 180)),
    ticketCode: 'TKT-2025-001',
  );

  EventTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ticket Header
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF7C3AED), // purple-600
                              Color(0xFF3B82F6), // blue-500
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticketData.eventName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.confirmation_number_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  ticketData.ticketCode,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Ticket Body
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Ticket Type and Usage Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColumn(
                                  'Ticket Type',
                                  ticketData.ticketType,
                                ),
                                _buildInfoColumn(
                                  'Usage',
                                  ticketData.usageType,
                                  icon: Icons.people_outline,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Dates Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColumn(
                                  'Issue Date',
                                  DateFormat('yyyy-MM-dd')
                                      .format(ticketData.issueDate),
                                  icon: Icons.calendar_today,
                                ),
                                _buildInfoColumn(
                                  'Expiry Date',
                                  DateFormat('yyyy-MM-dd')
                                      .format(ticketData.expiryDate),
                                  icon: Icons.access_time,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // QR Code Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'images/qr.png', // Replace with your image path
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Scan to verify ticket',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Ticket Footer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey[200]!,
                            ),
                          ),
                        ),
                        child: Text(
                          'This ticket is subject to terms and conditions of the event organizer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment:
          icon == null ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// Data model for the ticket
class TicketData {
  final String eventName;
  final String ticketType;
  final String usageType;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String ticketCode;

  TicketData({
    required this.eventName,
    required this.ticketType,
    required this.usageType,
    required this.issueDate,
    required this.expiryDate,
    required this.ticketCode,
  });
}
