import 'package:flutter/material.dart';
import 'package:momento/screens/events/schedule_add.dart';

final List<Map<String, dynamic>> events = [
  {
    "date": "December 29, 2024",
    "events": [
      {
        "time": "10:00 AM",
        "name": "Opening Speech",
        "icon": Icons.mic,
        "description": "Welcome speech by the host."
      },
      {
        "time": "12:00 PM",
        "name": "Networking Lunch",
        "icon": Icons.lunch_dining,
        "description": "Buffet lunch and networking."
      },
      {
        "time": "3:00 PM",
        "name": "Workshop",
        "icon": Icons.work,
        "description": "Interactive workshop session."
      },
      {
        "time": "5:00 PM",
        "name": "Evening Gala",
        "icon": Icons.event,
        "description": "Formal gala event with dinner."
      }
    ]
  },
  {
    "date": "December 30, 2024",
    "events": [
      {
        "time": "9:00 AM",
        "name": "Panel Discussion",
        "icon": Icons.group,
        "description": "Discussion with industry leaders."
      },
      {
        "time": "11:00 AM",
        "name": "Coffee Break",
        "icon": Icons.local_cafe,
        "description": "Enjoy coffee and snacks."
      },
      {
        "time": "1:00 PM",
        "name": "Closing Ceremony",
        "icon": Icons.celebration,
        "description": "End of the event with a celebration."
      },
      {
        "time": "3:00 PM",
        "name": "Farewell Party",
        "icon": Icons.party_mode,
        "description": "A casual party to conclude the event."
      }
    ]
  },
  {
    "date": "December 31, 2024",
    "events": [
      {
        "time": "8:00 AM",
        "name": "Yoga Session",
        "icon": Icons.self_improvement,
        "description": "Start the day with a relaxing yoga session."
      },
      {
        "time": "10:00 AM",
        "name": "Keynote Speech",
        "icon": Icons.record_voice_over,
        "description": "Inspirational talk by a guest speaker."
      },
      {
        "time": "1:00 PM",
        "name": "Group Photos",
        "icon": Icons.camera_alt,
        "description": "Capture memories with group photos."
      },
      {
        "time": "4:00 PM",
        "name": "Award Ceremony",
        "icon": Icons.emoji_events,
        "description": "Recognition of outstanding participants."
      }
    ]
  }
];

class EventSchedule extends StatelessWidget {
  const EventSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Schedule"),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final day = events[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day['date'],
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003675),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    children:
                        day['events'].asMap().entries.map<Widget>((entry) {
                      final event = entry.value;
                      return TimelineTile(event: event);
                    }).toList(),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 4.0),
                    width: 16.0,
                    height: 16.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF003675),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showScheduleModal(context),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  final Map<String, dynamic> event;

  const TimelineTile({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                event['icon'],
                color: const Color(0xFF003675),
              ),
              Container(
                width: 2.0,
                height: 40.0,
                color: const Color(0xFF003675),
              ),
            ],
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['time'],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  event['name'],
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  event['description'],
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
