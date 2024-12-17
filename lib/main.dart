import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_booking/providers/dynamic_provider.dart';
import 'package:service_booking/providers/login_provider.dart';
import 'package:service_booking/providers/token_provider.dart';
import 'colors/colors.dart';
import 'new_changes/screens/home_new.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TokenProvider()),
      ChangeNotifierProvider(create: (_) => LoginProvider()),
      ChangeNotifierProvider(create: (context) => BusinessProvider()),

    ],
    child: MyApp(),
  ));
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
      home: HomePageNew(),
    );
  }
}
