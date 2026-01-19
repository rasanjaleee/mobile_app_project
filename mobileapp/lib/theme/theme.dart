import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 57, 73, 201);
  static const Color primaryLight = Color.fromARGB(255, 47, 76, 206);
  static const Color primaryDark = Colors.blue;

  static const Color secondaryColor = Colors.red;
  static const Color tertiaryColor = Color.fromARGB(255, 9, 195, 52);

  static const List<Color> primaryGradient = [
    primaryColor,
    Color.fromARGB(255, 12, 53, 86),
  ];

  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color.fromARGB(255, 203, 196, 196);
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color.fromARGB(255, 102, 97, 97);

  static const Color success = Color.fromARGB(255, 15, 171, 36);
  static const Color error = Color.fromARGB(255, 142, 27, 19);
  static const Color warning = Color.fromARGB(255, 171, 148, 30);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        error: error,
        surface: surfaceColor,

      ),
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color:textPrimary,
          fontSize:32,
          fontWeight: FontWeight.bold,


        ),
        displayMedium: TextStyle(
          color:textPrimary,
          fontSize:24,
          fontWeight: FontWeight.bold,

        ),
        bodyLarge: TextStyle(
          color:textPrimary,
          fontSize:16,


        ),
        bodyMedium: TextStyle(
          color:textSecondary,
          fontSize:14,


        ),
      ),



    );


  }






}
