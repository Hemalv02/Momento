import 'package:flutter/material.dart';

const kDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF03DAC6), // Main color for buttons and AppBar
  onPrimary: Colors.black,
  primaryContainer: Color(0xFF3700B3),
  onPrimaryContainer: Colors.white,
  secondary: Color(0xFF03DAC6),
  onSecondary: Colors.black,
  secondaryContainer: Color(0xFF018786),
  onSecondaryContainer: Colors.white,
  tertiary: Color(0xFFCF6679),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFB00020),
  onTertiaryContainer: Colors.white,
  surface: Color(0xFF1F1B24), // Scaffold background
  onSurface: Colors.white,
  error: Color(0xFFCF6679),
  onError: Colors.white,
);

final ThemeData darkThemeData = ThemeData.dark().copyWith(
  colorScheme: kDarkColorScheme,
  scaffoldBackgroundColor: kDarkColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: kDarkColorScheme.secondary, // Updated for a distinct color
    foregroundColor: kDarkColorScheme.onSecondaryContainer, // Ensures readable text/icon colors
    elevation: 2, // Subtle elevation to make the AppBar stand out
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: kDarkColorScheme.onSecondary,
    ),
    iconTheme: IconThemeData(
      color: kDarkColorScheme.onSecondary,
    ),
  ),
  cardTheme: CardTheme(
    color: kDarkColorScheme.secondaryContainer, // Slightly lighter for distinction
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kDarkColorScheme.primary,
      foregroundColor: kDarkColorScheme.onPrimary,
    ),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kDarkColorScheme.secondaryContainer,
    ),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(kDarkColorScheme.surface),
    ),
    textStyle: TextStyle(
      color: kDarkColorScheme.onSurface,
    ),
  ),
  textTheme: ThemeData.dark().textTheme.copyWith(
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: kDarkColorScheme.onSecondaryContainer,
    ),
  ),
);
