import 'package:flutter/material.dart';

class GuestList extends StatelessWidget {
  const GuestList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest List'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 24,
        ),
         leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blue[900],
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search,color: Colors.white),
        
          )
        ],
      ),
      body: ListView(
        children: List.generate(10, (index) => const GuestListItem()), 
      ),
    );
  }
}

class GuestListItem extends StatelessWidget {
  const GuestListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/avatar.png'), // Add your image asset
        ),
        title: Text(
          'Nafis Shyan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Chief Guest',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: Icon(
          Icons.more_vert,
          color: Colors.black,
        ),
      ),
    );
  }
}
