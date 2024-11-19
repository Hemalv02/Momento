import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TeamMember(
            name: "Nafis Shyan",
            roll: 10,
            imagePath: "assets/images/man1.jpeg",
          ),
          TeamMember(
            name: "Mominul Islam Hemal",
            roll: 40,
            imagePath: "assets/images/man2.jpeg",
          ),
          TeamMember(
            name: "Jannatul Ferdousi",
            roll: 8,
            imagePath: "assets/images/woman1.jpeg",
          ),
          TeamMember(
            name: "Anindya Kundu",
            roll: 9,
            imagePath: "assets/images/man3.jpeg",
          ),
        ],
      ),
    );
  }
}

class TeamMember extends StatelessWidget {
  final String name;
  final int roll;
  final String imagePath;

  const TeamMember({
    required this.name,
    required this.roll,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imagePath),
              onBackgroundImageError: (_, __) => Icon(Icons.person, size: 40),
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Roll: $roll",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
