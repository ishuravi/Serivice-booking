import 'package:flutter/material.dart';
import 'package:service_booking/screens/home_page.dart';
import 'colors/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registration App',
      theme: ThemeData(
        primaryColor: AppColors.lightBlue,   // Use light blue from colors.dart
        scaffoldBackgroundColor: AppColors.white,  // White background
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.black),  // Black text for large body text
          bodyMedium: TextStyle(color: AppColors.black),  // Black text for medium body text
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: HomePage(),
    );
  }
}
