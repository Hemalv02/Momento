import 'package:momento/controller/expenses.dart';
import 'package:flutter/material.dart';
import 'package:momento/view/themedata.dart';
import 'package:momento/view/dark_themedata.dart';
void main(){
  runApp(MaterialApp(
    theme: themeData,
    darkTheme: darkThemeData,
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home:const Expenses(),
  ),);
}