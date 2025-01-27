import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

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
  String updatedName = '';
  String updatedEmail = '';
  DateTime? updatedDob;
  String updatedPhone1 = '';
  String updatedAddress1 = '';
  String updatedGender = '';
  String updatedOccupation = '';

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

  Future<File> _bytesToFile(Uint8List bytes, String username) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${username}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = p.join(tempDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    setState(() => isloading = true);

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      final prefs = await SharedPreferences.getInstance();
      String user = prefs.getString("username")!;

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await uploadImage(_selectedImage!, user);
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() => isloading = false);
    }
  }

  Future<void> uploadImage(File imageFile, String username) async {
    try {
      final String path =
          'images/${username}_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';

      // Upload image to Storage
      await supabase.storage.from('profile_pictures').upload(path, imageFile);

      // Get public URL
      final String publicUrl =
          supabase.storage.from('profile_pictures').getPublicUrl(path);

      // Update or insert URL in profile_pics table
      final existing = await supabase
          .from('profile_pics')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        await supabase
            .from('profile_pics')
            .update({'url': publicUrl}).eq('username', username);
      } else {
        await supabase
            .from('profile_pics')
            .insert({'username': username, 'url': publicUrl});
      }

      setState(() => isloading = false);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

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

    nameController.addListener(() => updatedName = nameController.text);
    emailController.addListener(() => updatedEmail = emailController.text);
    phoneController.addListener(() => updatedPhone1 = phoneController.text);
    addressController
        .addListener(() => updatedAddress1 = addressController.text);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF003675), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: Color(0xFF003675),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                          color: Color(0xFF003675),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF003675)),
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
                            decoration:
                                inputDecoration.copyWith(labelText: 'Name'),
                            controller: nameController,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.white,
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: inputDecoration.copyWith(
                                labelText: 'Gender',
                              ),
                              value:
                                  updatedGender.isEmpty ? null : updatedGender,
                              hint: const Text('Select Gender'),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black,
                              ),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF003675)),
                              isExpanded: true,
                              items: genderOptions.map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(
                                    gender,
                                    style: TextStyle(
                                      color: updatedGender == gender
                                          ? const Color(0xFF003675)
                                          : Colors.black,
                                      fontWeight: updatedGender == gender
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setModalState(() {
                                  updatedGender = newValue ?? '';
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.white,
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: inputDecoration.copyWith(
                                labelText: 'Occupation',
                              ),
                              value: updatedOccupation.isEmpty
                                  ? null
                                  : updatedOccupation,
                              hint: const Text('Select Occupation'),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black,
                              ),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF003675)),
                              isExpanded: true,
                              items: occupationOptions.map((String occupation) {
                                return DropdownMenuItem<String>(
                                  value: occupation,
                                  child: Text(
                                    occupation,
                                    style: TextStyle(
                                      color: updatedOccupation == occupation
                                          ? const Color(0xFF003675)
                                          : Colors.black,
                                      fontWeight:
                                          updatedOccupation == occupation
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setModalState(() {
                                  updatedOccupation = newValue ?? '';
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: inputDecoration.copyWith(
                              labelText: 'Date of Birth',
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF003675),
                                ),
                                onPressed: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: updatedDob ?? DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
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
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: inputDecoration.copyWith(
                              labelText: 'Phone Number',
                            ),
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: inputDecoration.copyWith(
                              labelText: 'Address',
                            ),
                            controller: addressController,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
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
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF003675),
                              side: const BorderSide(
                                color: Color(0xFF003675),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003675),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: isSaving
                                ? null
                                : () async {
                                    Navigator.pop(context);
                                    await updateDetails();
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Save Changes'),
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

  Future<void> filldata() async {
    setState(() => isloading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;

    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('Username', username)
          .single();

      setState(() {
        name = response['Name'];
        email = response['Email'];
        dob = DateTime.parse(response['DOB']);
        phone1 = response['Phone'];
        address1 = response['Address'];
        gender = response['Gender'];
        occupation = response['Occupation'];
      });

      try {
        final imageResponse = await supabase
            .from('profile_pics')
            .select()
            .eq('username', username)
            .single();

        if (imageResponse != null) {
          final imageUrl = imageResponse['url'];
          final http.Response downloadResponse =
              await http.get(Uri.parse(imageUrl));
          _selectedImage =
              await _bytesToFile(downloadResponse.bodyBytes, username);
        }
      } catch (e) {
        print('No profile image found');
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isloading = false);
    }
  }

  bool isSaving = false;
  late StreamSubscription<dynamic> _profileSubscription;

  @override
  void initState() {
    super.initState();
    filldata();
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    _profileSubscription = supabase
        .from('user_profiles')
        .stream(primaryKey: ['Username'])
        .eq('Username', username)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final profile = data[0];
            setState(() {
              name = profile['Name'];
              email = profile['Email'];
              dob = DateTime.parse(profile['DOB']);
              phone1 = profile['Phone'];
              address1 = profile['Address'];
              gender = profile['Gender'];
              occupation = profile['Occupation'];
            });
          }
        });
  }

  @override
  void dispose() {
    _profileSubscription.cancel();
    super.dispose();
  }

  Future<void> updateDetails() async {
    setState(() => isSaving = true);

    try {
      final Map<String, dynamic> updateData = {
        "Username": username,
        "Email": email,
        "Name": updatedName,
        "DOB": updatedDob!.toLocal().toString().split(' ')[0],
        "Phone": updatedPhone1,
        "Address": updatedAddress1,
        "Gender": updatedGender,
        "Occupation": updatedOccupation,
      };

      await supabase
          .from('user_profiles')
          .update(updateData)
          .eq('Username', username);

      setState(() {
        name = updatedName;
        email = updatedEmail;
        dob = updatedDob;
        phone1 = updatedPhone1;
        address1 = updatedAddress1;
        gender = updatedGender;
        occupation = updatedOccupation;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error updating profile: $e');
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profile',
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF003675),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: (username.isEmpty)
          ? Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF003675),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    // color: const Color(0xFF003675),
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: isloading
                                      ? const AssetImage(
                                              'assets/images/loading.jpg')
                                          as ImageProvider
                                      : _selectedImage != null
                                          ? FileImage(_selectedImage!)
                                          : const AssetImage('assets/logo.png')
                                              as ImageProvider,
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
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003675),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF003675),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ModernProfileDetail(
                            title: 'Personal Information',
                            icon: Icons.person,
                            details: [
                              DetailItem(label: 'Username', value: username),
                              DetailItem(label: 'Gender', value: gender),
                              DetailItem(
                                  label: 'Occupation', value: occupation),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ModernProfileDetail(
                            title: 'Contact Information',
                            icon: Icons.contact_phone,
                            details: [
                              DetailItem(label: 'Phone Number', value: phone1),
                              DetailItem(label: 'Address', value: address1),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ModernProfileDetail(
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
                        ],
                      ),
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

class ModernProfileDetail extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<DetailItem> details;

  const ModernProfileDetail({
    super.key,
    required this.title,
    required this.icon,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003675).withAlpha(20),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF003675).withAlpha(25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF003675).withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003675).withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF003675),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003675),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...details
              .map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF003675).withAlpha(13),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              detail.label,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF003675).withAlpha(153),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              detail.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003675),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
