import 'package:flutter/material.dart';

class TicketGenerate extends StatefulWidget {
  final int eventId;
  const TicketGenerate({super.key, required this.eventId});

  @override
  State<TicketGenerate> createState() => _TicketGenerateState();
}

class _TicketGenerateState extends State<TicketGenerate> {
  final Map<String, Map<String, dynamic>> ticketFeatures = {
    'Entry': {
      'enabled': true,
      'icon': Icons.door_front_door_outlined,
    },
    'Breakfast': {
      'enabled': false,
      'icon': Icons.free_breakfast_outlined,
    },
    'Lunch': {
      'enabled': false,
      'icon': Icons.lunch_dining_outlined,
    },
    'Dinner': {
      'enabled': false,
      'icon': Icons.dinner_dining_outlined,
    },
    'Gift': {
      'enabled': false,
      'icon': Icons.card_giftcard_outlined,
    },
    'T-Shirt': {
      'enabled': false,
      'icon': Icons.checkroom_outlined,
    },
    'Snack': {
      'enabled': false,
      'icon': Icons.fastfood_outlined,
    },
  };

  Future<void> generateTicket() async {
    try {
      // Add your ticket generation logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket generated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating ticket: $e')),
      );
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
              child: Row(
                children: [
                  Icon(
                    Icons.featured_play_list_outlined,
                    color: const Color(0xFF003675),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
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
              onPressed: generateTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003675),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              icon: const Icon(
                Icons.qr_code,
                color: Colors.white,
              ),
              label: const Text(
                'Generate Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
