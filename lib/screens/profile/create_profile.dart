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
  bool _isSaving = false;

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
    final uri = Uri.parse('https://fastapi-momento.vercel.app/profile/upload');
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
      setState(() {
        _isSaving = true; // Set loading state to true before API call
      });

      final prefs = await SharedPreferences.getInstance();
      String url = "https://fastapi-momento.vercel.app/profile/create-profile";
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

        setState(() {
          _isSaving = false; // Set loading state to false after API call
        });

        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text('Profile Saved'),
                content:
                    const Text('Your profile has been saved successfully!'),
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
        }
      } catch (e) {
        setState(() {
          _isSaving = false; // Set loading state to false if there's an error
        });
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text('Error'),
                content:
                    const Text('Failed to save profile. Please try again.'),
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
          'Create Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF003675),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF003675),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        backgroundImage: isloading
                            ? const AssetImage('assets/images/loading.jpg')
                                as ImageProvider
                            : _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : const AssetImage('assets/logo.png')
                                    as ImageProvider,
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 30,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF003675),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Color(0xFF003675),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                label: 'Full Name',
                onChanged: (value) => name = value,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Gender',
                value: gender.isEmpty ? null : gender,
                items: ['Male', 'Female'],
                onChanged: (value) => setState(() => gender = value!),
                prefixIcon: Icons.people_outline,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Occupation',
                value: occupation.isEmpty ? null : occupation,
                items: occupations,
                onChanged: (value) => setState(() => occupation = value!),
                prefixIcon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Phone Number',
                onChanged: (value) => phone1 = value,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Address',
                onChanged: (value) => address1 = value,
                maxLines: 3,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55, // Increased button height
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003675),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF003675)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF003675),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey[600]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20, // Increased vertical padding
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF003675)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF003675),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20, // Increased vertical padding
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16,
                color: value == item ? const Color(0xFF003675) : Colors.black87,
                fontWeight: value == item ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF003675)),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(
          text: dob != null ? dob!.toLocal().toString().split(' ')[0] : '',
        ),
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF003675),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF003675),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey[600]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20, // Increased vertical padding
          ),
        ),
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: dob ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF003675),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (selectedDate != null) {
            setState(() => dob = selectedDate);
          }
        },
      ),
    );
  }
}
