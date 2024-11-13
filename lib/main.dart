import 'package:flutter/material.dart';
import 'package:momento/screen/auth.dart';
import 'package:momento/view/themedata.dart';
import 'package:momento/view/dark_themedata.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    theme: themeData,
    darkTheme: darkThemeData,
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home:const AuthScreen(),
  ),);
}