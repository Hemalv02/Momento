import 'package:flutter/material.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 41, 73),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Create Event",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 170),
            Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Event Name',
                  filled: true,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Date',
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Time',
                  filled: true,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Location',
                  filled: true,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Budget',
                  filled: true,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Organized By',
                  filled: true,
                ),
              ),
            ),
            // Example Placeholder Fields
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '...',
                  filled: true,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '...',
                  filled: true,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '...',
                  filled: true,
                ),
              ),
            ),
            // Create Event Button
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 15, 8, 4),
              child: SizedBox(
                height: 56, // Match typical TextField height
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button press
                    print("Event Created");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 33, 144, 235),
                  ),
                  child: const Text(
                    "Create Event",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
