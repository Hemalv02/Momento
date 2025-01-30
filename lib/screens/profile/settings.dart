import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:momento/main.dart';
import 'package:momento/screens/about_us_page.dart';
import 'package:momento/screens/contact_us.dart';
import 'package:momento/screens/profile/profile_page.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<UserAccountSectionState> _userAccountKey = GlobalKey();

  Future<void> _handleRefresh() async {
    await _userAccountKey.currentState?.loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF003675),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: const Color(0xFF003675),
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        displacement: 40,
        onRefresh: _handleRefresh,
        child: ListView(
          children: [
            UserAccountSection(key: _userAccountKey),
            const Divider(),
            SettingsOption(
              icon: Icons.info,
              title: "About Us",
              subtitle: "Know the developers of Momento",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AboutUsPage(),
                  ),
                );
              },
            ),
            SettingsOption(
              icon: Icons.help_outline,
              title: "Contact Us",
              subtitle: "Contact the developers of the app",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FeedbackPage(),
                  ),
                );
              },
            ),
            SettingsOption(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out of your account",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          prefs.remove('userId');
                          prefs.remove('token');
                          prefs.remove('email');
                          prefs.remove('username');
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              'login', (Route<dynamic> route) => false);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

abstract class UserAccountSectionState extends State<UserAccountSection> {
  Future<void> loadProfileData();
}

class UserAccountSection extends StatefulWidget {
  const UserAccountSection({super.key});

  @override
  State<UserAccountSection> createState() => _UserAccountSectionState();
}

class _UserAccountSectionState extends UserAccountSectionState {
  final supabase = Supabase.instance.client;
  String username = '';
  String name = '';
  File? profileImage;
  bool isLoading = true;
  late StreamSubscription<dynamic> _profileSubscription;

  Future<File> _bytesToFile(Uint8List bytes, String username) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${username}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = p.join(tempDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
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
              name = profile['Name'] ?? '';
            });
          }
        });
  }

  @override
  Future<void> loadProfileData() async {
    setState(() {
      isLoading = true;
      // Clear existing data
      profileImage = null;
      name = '';
    });

    try {
      // Get username from SharedPreferences
      username = prefs.getString('username') ?? '';

      if (username.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // Fetch user profile data
      final profileData = await supabase
          .from('user_profiles')
          .select()
          .eq('Username', username)
          .single();

      // Fetch profile picture
      try {
        final imageResponse = await supabase
            .from('profile_pics')
            .select()
            .eq('username', username)
            .single();

        if (imageResponse != null && imageResponse['url'] != null) {
          final imageUrl = imageResponse['url'];
          final http.Response downloadResponse =
              await http.get(Uri.parse(imageUrl));
          if (downloadResponse.statusCode == 200) {
            final newProfileImage =
                await _bytesToFile(downloadResponse.bodyBytes, username);

            // Only update the state if the widget is still mounted
            if (mounted) {
              setState(() {
                profileImage = newProfileImage;
              });
            }
          }
        }
      } catch (e) {
        print('No profile image found: $e');
      }

      // Only update the state if the widget is still mounted
      if (mounted) {
        setState(() {
          name = profileData['Name'] ?? '';
          isLoading = false;
        });
      }

      // Cancel existing subscription before setting up a new one
      await _profileSubscription.cancel();
      _setupRealtimeSubscription();
    } catch (e) {
      print('Error loading profile data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfileData();
    _profileSubscription = supabase
        .from('user_profiles')
        .stream(primaryKey: ['Username'])
        .eq('Username', '')
        .listen((_) {}); // Initialize with empty subscription
  }

  @override
  void dispose() {
    _profileSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 80,
      leading: isLoading
          ? const CircleAvatar(
              radius: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF003675),
              ),
            )
          : Hero(
              tag: 'profileImage',
              child: CircleAvatar(
                radius: 30,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : const AssetImage('assets/logo.png') as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
            ),
      title: Text(
        isLoading ? "Loading..." : name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF003675),
        ),
      ),
      subtitle: Text(
        isLoading ? "Loading..." : username,
        style: const TextStyle(
          color: Colors.black54,
        ),
      ),
      onTap: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        )
            .then((_) {
          // Reload data when returning from profile page
          loadProfileData();
        });
      },
    );
  }
}

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF003675)),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
