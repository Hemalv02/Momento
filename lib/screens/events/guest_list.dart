import 'package:flutter/material.dart';

class GuestList extends StatefulWidget {
  const GuestList({super.key});

  @override
  State<GuestList> createState() => _GuestListState();
}

class _GuestListState extends State<GuestList> {
  final List<Map<String, String>> guestList = [
    {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'guestType': 'Chief Guest',
      'invited': 'Yes',
    },
    {
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'guestType': 'Regular Guest',
      'invited': 'No',
    },
    {
      'name': 'Michael Brown',
      'email': 'michael.brown@example.com',
      'guestType': 'VIP Guest',
      'invited': 'Yes',
    },
    // Add more guests as needed
  ];

  List<bool> selectedGuests = [];
  int? longPressedIndex; // To track which item was long-pressed

  @override
  void initState() {
    super.initState();
    selectedGuests = List.generate(guestList.length, (index) => false);
  }

  void _toggleSelection(int index) {
    setState(() {
      if (longPressedIndex == null) {
        selectedGuests[index] = !selectedGuests[index];
      }
    });
  }

  void _removeSelectedGuests() {
    setState(() {
      // Remove guests whose corresponding selectedGuests value is true
      for (int i = guestList.length - 1; i >= 0; i--) {
        if (selectedGuests[i]) {
          guestList.removeAt(i);
          selectedGuests.removeAt(i);
        }
      }
    });
  }

  void _generateTicket(int index) {
    // Handle ticket generation logic here
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ticket generated for ${guestList[index]['name']}'),
    ));
  }

  void _removeGuest(int index) {
    setState(() {
      guestList.removeAt(index);
      selectedGuests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest List'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        actions: [
          if (selectedGuests
              .contains(true)) // Only show if some guests are selected
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _removeSelectedGuests,
            ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: guestList.length,
        itemBuilder: (context, index) {
          final guest = guestList[index];
          return GestureDetector(
            onLongPress: () {
              setState(() {
                longPressedIndex = index; // Track the long-pressed item
                selectedGuests[index] = true; // Mark the item as selected
              });
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              color: Color.fromARGB(
                  255, 208, 218, 235), // Light blue background for visibility
              child: ListTile(
                onTap: () => _toggleSelection(
                    index), // Only toggle selection when not long pressed
                contentPadding: const EdgeInsets.all(16),
                leading: longPressedIndex == index
                    ? Checkbox(
                        value: selectedGuests[index],
                        onChanged: (value) {
                          setState(() {
                            selectedGuests[index] = value ?? false;
                            // If unchecked, remove the checkbox
                            if (!selectedGuests[index]) {
                              longPressedIndex = null;
                            }
                          });
                        },
                      )
                    : null, // Show checkbox only for long-pressed item
                title: Text(
                  guest['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF003675), // Dark blue color for the name
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${guest['email']}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    Row(
                      children: [
                        Text(
                          guest['guestType']!,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        const Text("  -  "),
                        const Text(
                          "Invited: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          guest['invited']!,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'generateTicket') {
                      _generateTicket(index);
                    } else if (action == 'removeGuest') {
                      _removeGuest(index);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'generateTicket',
                        child: Text('Generate Ticket'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'removeGuest',
                        child: Text('Remove Guest'),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
