import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _showMemberDetails(BuildContext context, Map<String, String> member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageDetailScreen(member: member),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Set a white background
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF003675),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SizedBox(
        // Ensure the container takes the full height
        height: screenHeight,
        child: Stack(
          children: [
            // Content
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                child: Column(
                  children: [
                    // Title with custom style
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Meet Our ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        Text(
                          'Momento',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          ' Team',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Team members
                    ...teamMembers.map((member) {
                      return GestureDetector(
                        onTap: () => _showMemberDetails(context, member),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background image with overlay
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      offset: const Offset(0, 10),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Hero(
                                    tag: member['image']!,
                                    child: Stack(
                                      children: [
                                        // Background image
                                        Image.asset(
                                          member['image']!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        // Overlay gradient
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7)
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Member info
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['name']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      member['email']!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final Map<String, String> member;

  const ImageDetailScreen({super.key, required this.member});

  // Function to launch email client
  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: member['email'],
      queryParameters: {
        'subject': 'Hello ${member['name']}',
      },
    );
    try {
      await launchUrl(emailUri);
    } catch (e) {
      // Handle exception by showing an error message or snackbar
      print('Could not launch email client');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(member['name']!),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Large Image
          Expanded(
            child: Hero(
              tag: member['image']!,
              child: Image.asset(
                member['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          // Member Details
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  member['name']!,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Email
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        member['email']!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Email Button
                ElevatedButton(
                  onPressed: _sendEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003675),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send Email'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
