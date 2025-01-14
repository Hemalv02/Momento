import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String username = "";
  String name = '';
  String email = '';
  DateTime? dob = DateTime.now();
  String phone1 = '';
  String address1 = '';
  String gender = '';
  String occupation = '';
  File? _selectedImage;
  bool isloading = true;
  Uint8List? _imageBytes;
  String updatedName = '';
  String updatedEmail = '';
  DateTime? updatedDob;
  String updatedPhone1 = '';
  String updatedAddress1 = '';
  String updatedGender = '';
  String updatedOccupation = '';
  Future<File> _bytesToFile(Uint8List bytes, String username) async {
    // Get temporary directory
    final tempDir = await getTemporaryDirectory();

    // Create a unique filename using username and timestamp
    final fileName = '${username}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Create the file path
    final filePath = p.join(tempDir.path, fileName);

    // Write bytes to file
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

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
    final uri =
        Uri.parse('https://8bzqcx5t-8000.inc1.devtunnels.ms/profile/upload');
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

  void updateDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    String url =
        "https://8bzqcx5t-8000.inc1.devtunnels.ms/profile/update-profile/$username";
    final Map<String, dynamic> jsonBody = {
      "Username": username,
      "Email": email,
      "Name": updatedName,
      "DOB": updatedDob!.toLocal().toString().split(' ')[0],
      "Phone": updatedPhone1,
      "Address": updatedAddress1,
      "Gender": updatedGender,
      "Occupation": updatedOccupation,
    };
    try {
      await http
          .put(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      updateDetails();
    }
  }

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
    updatedName = name;
    updatedEmail = email;
    updatedDob = dob;
    updatedPhone1 = phone1;
    updatedAddress1 = address1;
    updatedGender = gender;
    updatedOccupation = occupation;
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phone1);
    final addressController = TextEditingController(text: address1);
    nameController.addListener(() {
      updatedName = nameController.text;
    });
    emailController.addListener(() {
      updatedEmail = emailController.text;
    });
    phoneController.addListener(() {
      updatedPhone1 = phoneController.text;
    });
    addressController.addListener(() {
      updatedAddress1 = addressController.text;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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
                            controller: nameController,
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
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                            controller: addressController,
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
                              Navigator.pop(context);
                              setState(() {
                                name = updatedName;
                                email = updatedEmail;
                                dob = updatedDob;
                                phone1 = updatedPhone1;
                                address1 = updatedAddress1;
                                gender = updatedGender;
                                occupation = updatedOccupation;
                              });
                              updateDetails();
                              // Navigator.pop(context);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    //print("Called");
    try {
      String url =
          "https://8bzqcx5t-8000.inc1.devtunnels.ms/profile/get-profile/$username";
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
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
      final response2 = await http.get(
        Uri.parse(
            'https://8bzqcx5t-8000.inc1.devtunnels.ms/profile/get_profile_image/$username'),
      );
      if (response2.statusCode == 200) {
        _selectedImage = await _bytesToFile(response2.bodyBytes, username);
        isloading = false;
        setState(() {});
      } else {
        isloading = false;
        setState(() {});
      }
    } catch (e) {
      filldata();
    }
  }

  @override
  void initState() {
    super.initState();
    filldata();
  }

  @override
  Widget build(BuildContext context) {
    return (username.isEmpty)
        ? Container(
            color: Colors.white, // White background
            child: const Center(
              child: CircularProgressIndicator(), // Loading spinner
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              centerTitle: true,
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, 'settingspage');
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          'login', (Route<dynamic> route) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
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
