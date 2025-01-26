import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  AboutUsPage({super.key});

  final List<Map<String, String>> teamMembers = [
    {
      'name': 'Mominul Islam Hemal',
      'email': 'i.mominulislamhemal@gmail.com',
      'image': 'assets/images/hemal.jpg',
    },
    {
      'name': 'Jannatul Ferdousi',
      'email': 'jannatul19112003@gmail.com',
      'image': 'assets/images/jannat.jpg',
    },
    {
      'name': 'Nafis Shyan',
      'email': 'nafis-2021011186@cs.du.ac.bd',
      'image': 'assets/images/shyan.jpg',
    },
    {
      'name': 'Anindya Kundu',
      'email': 'sanindya50@gmail.com',
      'image': 'assets/images/anindya.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true, // Ensures the title is centered
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24), // Gap between AppBar and title text
            const Center(
              child: Text(
                'Meet Our Momento Team',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(
                height: 32), // Gap between title text and the first card
            Expanded(
              child: ListView.builder(
                itemCount: teamMembers.length,
                itemBuilder: (context, index) {
                  final member = teamMembers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(member['image']!),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member['name']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                member['email']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
