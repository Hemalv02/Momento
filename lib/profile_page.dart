import 'package:flutter/material.dart';

class ProfilePageBuilder extends StatelessWidget {
  const ProfilePageBuilder({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String name = 'Anindya Kundu';
  String email = 'sanindya50@gmail.com';
  DateTime? dob = DateTime(2001, 5, 15);
  String phone1 = '+8801844467391';
  String address1 = 'Lalmatia, Dhaka';

  void _editProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedName = name;
        String updatedEmail = email;
        DateTime? updatedDob = dob;
        String updatedPhone1 = phone1;
        String updatedAddress1 = address1;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: (value) => updatedName = value,
                      controller: TextEditingController(text: name),
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (value) => updatedEmail = value,
                      controller: TextEditingController(text: email),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: updatedDob ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setDialogState(() {
                                updatedDob = selectedDate;
                              });
                            }
                          },
                        ),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: updatedDob != null
                            ? updatedDob!.toLocal().toString().split(' ')[0]
                            : "",
                      ),
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      onChanged: (value) => updatedPhone1 = value,
                      controller: TextEditingController(text: phone1),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Address'),
                      onChanged: (value) => updatedAddress1 = value,
                      controller: TextEditingController(text: address1),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    setState(() {
                      name = updatedName;
                      email = updatedEmail;
                      dob = updatedDob;
                      phone1 = updatedPhone1;
                      address1 = updatedAddress1;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('images/anindya.jpg'),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ProfileDetail(title: 'Name', value: name),
            ProfileDetail(title: 'Email', value: email),
            ProfileDetail(
              title: 'Date Of Birth',
              value: dob != null
                  ? dob!.toLocal().toString().split(' ')[0]
                  : 'Not set',
            ),
            ProfileDetail(title: 'Phone Number', value: phone1),
            ProfileDetail(title: 'Address', value: address1),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editProfile,
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final String title;
  final String value;

  const ProfileDetail({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
