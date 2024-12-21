import 'package:flutter/material.dart';

class CreateProfilePage extends StatelessWidget {
  const CreateProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NewProfilePage(),
    );
  }
}

class NewProfilePage extends StatefulWidget {
  const NewProfilePage({super.key});
  @override
  NewProfilePageState createState() => NewProfilePageState();
}

class NewProfilePageState extends State<NewProfilePage> {
  String name = '';
  DateTime? dob;
  String phone1 = '';
  String address1 = '';

  void _saveProfile() {
    if (name.isNotEmpty && phone1.isNotEmpty && address1.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Profile Saved'),
            content: const Text('Your profile has been saved successfully!'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incomplete Details'),
            content: const Text('Please fill all the fields before saving.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'New Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'images/anindya.jpg'), // Replace with image asset path
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: dob ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          dob = selectedDate;
                        });
                      }
                    },
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: dob != null
                      ? dob!.toLocal().toString().split(' ')[0]
                      : '',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => phone1 = value,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (value) => address1 = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
