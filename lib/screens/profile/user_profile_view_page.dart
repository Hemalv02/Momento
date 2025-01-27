import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class UserProfileViewPage extends StatefulWidget {
  final String viewedUsername;

  const UserProfileViewPage({super.key, required this.viewedUsername});

  @override
  UserProfileViewState createState() => UserProfileViewState();
}

class UserProfileViewState extends State<UserProfileViewPage> {
  final supabase = Supabase.instance.client;

  String name = '';
  String email = '';
  DateTime? dob = DateTime.now();
  String phone1 = '';
  String address1 = '';
  String gender = '';
  String occupation = '';
  File? _selectedImage;
  bool isLoading = true;

  Future<File> _bytesToFile(Uint8List bytes, String username) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${username}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = p.join(tempDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> filldata() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('Username', widget.viewedUsername)
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
            .eq('username', widget.viewedUsername)
            .single();

        if (imageResponse != null) {
          final imageUrl = imageResponse['url'];
          final http.Response downloadResponse =
              await http.get(Uri.parse(imageUrl));
          _selectedImage = await _bytesToFile(
              downloadResponse.bodyBytes, widget.viewedUsername);
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
      setState(() => isLoading = false);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '${widget.viewedUsername}\'s Profile',
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF003675),
      ),
      body: (isLoading)
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
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
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
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : const AssetImage('assets/logo.png')
                                    as ImageProvider,
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
                              DetailItem(
                                  label: 'Username',
                                  value: widget.viewedUsername),
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

// Reuse the existing DetailItem and ModernProfileDetail classes from the previous implementation
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
    // This is the same implementation as in the previous ProfilePage
    // Copy the entire ModernProfileDetail class from the original implementation
    // ... (the entire ModernProfileDetail class from the previous code)
  }
}
