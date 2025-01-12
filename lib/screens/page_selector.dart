import 'package:flutter/material.dart';
import 'package:momento/screens/create_profile_screen.dart';
import 'package:momento/screens/home_structure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PageSelector extends StatefulWidget {
  const PageSelector({super.key});

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  bool? isFirstLogin;

  Future<bool> checkCondition() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    String url =
        "https://frtz47r1-8000.inc1.devtunnels.ms/profile/get-profile/$username";
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse['data'] != null && jsonResponse['data'].isEmpty) {
      return true;
      //print(isFirstLogin);
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    bool result = await checkCondition();
    setState(() {
      isFirstLogin = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstLogin == null) {
      return Container(
        color: Colors.white, // White background
        child: const Center(
          child: CircularProgressIndicator(), // Loading spinner
        ),
      );
    } else if (isFirstLogin!) {
      return const CreateProfilePage();
    } else {
      return const HomeStructure();
    }
  }
}
