import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  String gender = ''; // New field for gender
  String occupation = ''; // New field for occupation

  // List of occupations
  final List<String> occupations = [
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

  void _saveProfile() {
    if (name.isNotEmpty &&
        phone1.isNotEmpty &&
        address1.isNotEmpty &&
        gender.isNotEmpty &&
        occupation.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Profile Saved'),
            content: const Text('Your profile has been saved successfully!'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/profilepage');
                  String url = "http://10.0.2.2:8000/create-profile";
                  final Map<String, dynamic> jsonBody = {
                    "Username": "Anindya42001",
                    "Email": "sanindya50@gmail.com",
                    "Name": name,
                    "DOB": dob!.toLocal().toString().split(' ')[0],
                    "Phone": phone1,
                    "Address": address1,
                    "Gender": gender,
                    "Occupation": occupation
                  };
                  try {
                    await http.post(
                      Uri.parse(url),
                      headers: {
                        "Content-Type": "application/json",
                      },
                      body: jsonEncode(jsonBody),
                    );
                  } catch (e) {
                    print("Error");
                  }
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/anindya.jpg'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        onChanged: (value) => name = value,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Gender Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: InputBorder.none,
                        ),
                        value: gender.isEmpty ? null : gender,
                        hint: const Text('Select Gender'),
                        items: ['Male', 'Female'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            gender = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Occupation Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Occupation',
                          border: InputBorder.none,
                        ),
                        value: occupation.isEmpty ? null : occupation,
                        hint: const Text('Select Occupation'),
                        items: occupations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            occupation = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                          labelStyle: TextStyle(color: Colors.grey[600]),
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
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        onChanged: (value) => phone1 = value,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        maxLines: 3,
                        onChanged: (value) => address1 = value,
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
