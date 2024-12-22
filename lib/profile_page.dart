import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String username = "Anindya42001";
  String name = '';
  String email = '';
  DateTime? dob = DateTime.now();
  String phone1 = '';
  String address1 = '';

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
                  onPressed: () async {
                    setState(() {
                      name = updatedName;
                      email = updatedEmail;
                      dob = updatedDob;
                      phone1 = updatedPhone1;
                      address1 = updatedAddress1;
                    });
                    String url =
                        "http://10.0.2.2:8000/update-profile/$username";
                    final Map<String, dynamic> jsonBody = {
                      "Username": username,
                      "Email": email,
                      "Name": name,
                      "DOB": dob!.toLocal().toString().split(' ')[0],
                      "Phone": phone1,
                      "Address": address1
                    };
                    try {
                      await http.put(
                        Uri.parse(url),
                        headers: {
                          "Content-Type": "application/json",
                        },
                        body: jsonEncode(jsonBody),
                      );
                    } catch (e) {
                      print("Error");
                    }
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

  void filldata() async {
    String url = "http://10.0.2.2:8000/get-profile/$username";
    final response = await http.get(Uri.parse(url));
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        name = jsonResponse["data"][0]["Name"];
        email = jsonResponse["data"][0]["Email"];
        dob = DateTime.parse(jsonResponse["data"][0]["DOB"]);
        phone1 = jsonResponse["data"][0]["Phone"];
        address1 = jsonResponse["data"][0]["Address"];
      });
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    filldata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
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
