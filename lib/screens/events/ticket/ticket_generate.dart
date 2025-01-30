import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TicketGenerate extends StatefulWidget {
  final int eventId;
  const TicketGenerate({super.key, required this.eventId});

  @override
  State<TicketGenerate> createState() => _TicketGenerateState();
}

class _TicketGenerateState extends State<TicketGenerate> {
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> ticketFeatures = {
    'Entry': {
      'enabled': false,
      'icon': Icons.door_front_door_outlined,
      'field': 'entry',
    },
    'Breakfast': {
      'enabled': false,
      'icon': Icons.free_breakfast_outlined,
      'field': 'breakfast',
    },
    'Lunch': {
      'enabled': false,
      'icon': Icons.lunch_dining_outlined,
      'field': 'lunch',
    },
    'Dinner': {
      'enabled': false,
      'icon': Icons.dinner_dining_outlined,
      'field': 'dinner',
    },
    'Gift': {
      'enabled': false,
      'icon': Icons.card_giftcard_outlined,
      'field': 'gift',
    },
    'T-Shirt': {
      'enabled': false,
      'icon': Icons.checkroom_outlined,
      'field': 'tshirt',
    },
    'Snack': {
      'enabled': false,
      'icon': Icons.fastfood_outlined,
      'field': 'snack',
    },
    'Cultural Program': {
      'enabled': false,
      'icon': Icons.music_note_outlined,
      'field': 'cultural',
    },
  };

  late final Stream<List<Map<String, dynamic>>> _ticketStream;

  @override
  void initState() {
    super.initState();
    _setupTicketStream();
    _initializeTicketData();
  }

  void _setupTicketStream() {
    _ticketStream = supabase
        .from('ticket_schema')
        .stream(primaryKey: ['id'])
        .eq('event_id', widget.eventId)
        .order('created_at', ascending: false);
  }

  Future<void> _initializeTicketData() async {
    try {
      final response = await supabase
          .from('ticket_schema')
          .select()
          .eq('event_id', widget.eventId)
          .single();

      if (mounted && response != null) {
        setState(() {
          ticketFeatures.forEach((key, value) {
            String field = value['field'];
            value['enabled'] = response[field] ?? false;
          });
        });
      }
    } catch (e) {
      // If no data exists, checkboxes will remain unchecked
      print('No ticket configuration found for this event');
    }
  }

  Future<void> generateTicket() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare ticket data for Supabase
      final Map<String, dynamic> ticketData = {
        'event_id': widget.eventId,
      };

      // Add all feature values to the ticket data
      ticketFeatures.forEach((key, value) {
        ticketData[value['field']] = value['enabled'];
      });

      // First, save configuration to Supabase
      await supabase
          .from('ticket_schema')
          .upsert(ticketData, onConflict: 'event_id');

      // Then, call the ticket generation API
      final ticketResponse = await http.post(
        Uri.parse(
            'http://146.190.73.109/ticket/generate'), // Replace with your API base URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'event_id': widget.eventId,
        }),
      );

      if (mounted) {
        if (ticketResponse.statusCode == 200) {
          // Success case
          final responseData = jsonDecode(ticketResponse.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ??
                  'Ticket configuration saved and generation started!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Error case
          final errorData = jsonDecode(ticketResponse.body);
          throw Exception(errorData['detail'] ?? 'Failed to generate ticket');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error in generateTicket: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Ticket'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.featured_play_list_outlined,
                    color: Color(0xFF003675),
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Select Ticket Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003675),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: ticketFeatures.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      color: const Color(0xFF003675).withAlpha(25),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return const Color(0xFF003675);
                                }
                                return Colors.white;
                              },
                            ),
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Row(
                            children: [
                              Icon(
                                entry.value['icon'],
                                color: const Color(0xFF003675),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          value: entry.value['enabled'],
                          onChanged: (bool? value) {
                            setState(() {
                              ticketFeatures[entry.key]!['enabled'] = value!;
                            });
                          },
                          activeColor: const Color(0xFF003675),
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : generateTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003675),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              icon: _isLoading
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.qr_code, color: Colors.white),
              label: Text(
                _isLoading ? 'Generating...' : 'Generate Ticket',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
