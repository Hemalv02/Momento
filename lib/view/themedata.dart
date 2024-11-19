import 'package:flutter/material.dart';

var kColorScheme = ColorScheme.fromSeed(
    seedColor: //const Color.fromARGB(255, 255, 227, 136));
        const Color.fromARGB(255, 9, 184, 237));
ThemeData themeData = ThemeData().copyWith(
  scaffoldBackgroundColor: kColorScheme.surface,
  colorScheme: kColorScheme,
  appBarTheme: const AppBarTheme().copyWith(
    //backgroundColor: kColorScheme.onPrimaryContainer,
    backgroundColor: kColorScheme.onPrimaryFixedVariant,
    //foregroundColor: kColorScheme.primaryContainer,
    foregroundColor: kColorScheme.secondaryContainer,
  ),
  cardTheme: const CardTheme().copyWith(
    color: kColorScheme.secondaryContainer,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kColorScheme.primaryContainer,
    ),
  ),
  textTheme: ThemeData().textTheme.copyWith(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kColorScheme.onSecondaryContainer,
        ),
      ),
);
