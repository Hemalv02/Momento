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
  String gender = '';
  String occupation = '';

  // Define lists of options for dropdowns
  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> occupationOptions = [
    'Student',
    'Educator/Teacher',
    'Healthcare Professional',
    'Engineer/Technologist',
    'Artist/Creative Professional',
    'Entrepreneur/Business Owner',
    'Sales/Marketing Professional',
    'Freelancer/Consultant',
    'Government Employee',
    'Lawyer/Legal Professional',
    'Finance/Accounting Professional',
    'Researcher/Scientist',
    'Social Worker/Nonprofit Professional',
    'Retired',
    'Other'
  ];

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        String updatedName = name;
        String updatedEmail = email;
        DateTime? updatedDob = dob;
        String updatedPhone1 = phone1;
        String updatedAddress1 = address1;
        String updatedGender = gender;
        String updatedOccupation = occupation;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => updatedName = value,
                            controller: TextEditingController(text: name),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => updatedEmail = value,
                            controller: TextEditingController(text: email),
                          ),
                          const SizedBox(height: 16),
                          // Dropdown for Gender
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            value: updatedGender.isEmpty ? null : updatedGender,
                            hint: const Text('Select Gender'),
                            items: genderOptions.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setModalState(() {
                                updatedGender = newValue ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Dropdown for Occupation
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Occupation',
                              border: OutlineInputBorder(),
                            ),
                            value: updatedOccupation.isEmpty
                                ? null
                                : updatedOccupation,
                            hint: const Text('Select Occupation'),
                            items: occupationOptions.map((String occupation) {
                              return DropdownMenuItem<String>(
                                value: occupation,
                                child: Text(occupation),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setModalState(() {
                                updatedOccupation = newValue ?? '';
                              });
                            },
                            isExpanded: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Date of Birth',
                              border: const OutlineInputBorder(),
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
                                    setModalState(() {
                                      updatedDob = selectedDate;
                                    });
                                  }
                                },
                              ),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: updatedDob != null
                                  ? updatedDob!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]
                                  : "",
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => updatedPhone1 = value,
                            controller: TextEditingController(text: phone1),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => updatedAddress1 = value,
                            controller: TextEditingController(text: address1),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                name = updatedName;
                                email = updatedEmail;
                                dob = updatedDob;
                                phone1 = updatedPhone1;
                                address1 = updatedAddress1;
                                gender = updatedGender;
                                occupation = updatedOccupation;
                              });
                              String url =
                                  "http://10.0.2.2:8000/update-profile/$username";
                              final Map<String, dynamic> jsonBody = {
                                "Username": username,
                                "Email": email,
                                "Name": name,
                                "DOB": dob!.toLocal().toString().split(' ')[0],
                                "Phone": phone1,
                                "Address": address1,
                                "Gender": gender,
                                "Occupation": occupation
                              };
                              try {
                                await http.put(
                                  Uri.parse(url),
                                  headers: {
                                    "Content-Type": "application/json",
                                  },
                                  body: jsonEncode(jsonBody),
                                );
                                Navigator.pop(context);
                              } catch (e) {
                                print("Error updating profile: $e");
                              }
                            },
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        gender = jsonResponse["data"][0]["Gender"]; // New field
        occupation = jsonResponse["data"][0]["Occupation"]; // New field
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
            onPressed: () {
              Navigator.pushNamed(context, '/settingspage');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('images/anindya.jpg'),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ProfileDetail(
              title: 'Personal Information',
              icon: Icons.person,
              details: [
                DetailItem(label: 'Username', value: username),
                DetailItem(label: 'Name', value: name),
                DetailItem(label: 'Email', value: email),
                DetailItem(label: 'Gender', value: gender),
                DetailItem(label: 'Occupation', value: occupation),
              ],
            ),
            const SizedBox(height: 16),
            ProfileDetail(
              title: 'Contact Information',
              icon: Icons.contact_phone,
              details: [
                DetailItem(label: 'Phone Number', value: phone1),
                DetailItem(label: 'Address', value: address1),
              ],
            ),
            const SizedBox(height: 16),
            ProfileDetail(
              title: 'Additional Information',
              icon: Icons.info,
              details: [
                DetailItem(
                  label: 'Date of Birth',
                  value: dob != null
                      ? dob!.toLocal().toString().split(' ')[0]
                      : 'Not set',
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailItem {
  final String label;
  final String value;

  DetailItem({required this.label, required this.value});
}

class ProfileDetail extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<DetailItem> details;

  const ProfileDetail({
    super.key,
    required this.title,
    required this.icon,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.label,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.value,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
