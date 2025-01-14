import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class CreateProfilePage extends StatelessWidget {
  const CreateProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const NewProfilePage();
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
  File? _selectedImage;
  bool isloading = false;
  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    isloading = true;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("username")!;
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        uploadImage(_selectedImage!, user);
      });
    }
  }

  Future<void> uploadImage(File imageFile, String username) async {
    final uri = Uri.parse(
        'https://fastapi-momento-qpa72d3hf-mominul-islam-hemals-projects.vercel.app/profile/upload');
    final request = http.MultipartRequest('POST', uri);
    // Attach the image file
    request.files.add(await http.MultipartFile.fromPath(
      'image', // Field name
      imageFile.path,
      filename: p.basename(imageFile.path),
    ));
    // Attach the username
    request.fields['username'] = username;
    // Send the request
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        isloading = false;
        setState(() {});
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      //uploadImage(imageFile, username);
    }
  }

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
  void _saveProfile() async {
    if (name.isNotEmpty &&
        phone1.isNotEmpty &&
        address1.isNotEmpty &&
        gender.isNotEmpty &&
        occupation.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      String url =
          "https://fastapi-momento-qpa72d3hf-mominul-islam-hemals-projects.vercel.app/profile/create-profile";
      final Map<String, dynamic> jsonBody = {
        "Username": prefs.getString('username'),
        "Email": prefs.getString('email'),
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
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      'home_structure', (Route<dynamic> route) => false);
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
        automaticallyImplyLeading: false,
        title: const Text(
          'New Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: isloading == true
                      ? const AssetImage('assets/images/loading.jpg')
                          as ImageProvider // Display the selected image
                      : _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : const AssetImage('assets/logo.png')
                              as ImageProvider, // Default image
                  child: _selectedImage == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.white,
                        )
                      : null, // Show an icon over the default image
                ),
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
                padding: const EdgeInsets.all(12),
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
                        isExpanded: true,
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
                      padding: EdgeInsets.symmetric(horizontal: 15.h),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
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
                          backgroundColor: Color(0xFF003675),
                          foregroundColor: Colors.white,
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
