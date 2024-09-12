import 'package:flutter/material.dart';
import '../colors/colors.dart';
import 'consumer_registration.dart';
import 'service_provider_registration.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home page', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.lightBlue,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.app_registration, color: AppColors.white), // Icon related to registration
            onSelected: (value) {
              if (value == 'consumer') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConsumerRegistrationPage()),
                );
              } else if (value == 'serviceProvider') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ServiceProviderRegistrationPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'consumer',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,  // Light blue background for button-like appearance
                    borderRadius: BorderRadius.circular(8),  // Rounded corners
                  ),
                  child: Center(
                    child: Text(
                      'Consumer Registration',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'serviceProvider',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,  // Light blue background
                    borderRadius: BorderRadius.circular(8),  // Rounded corners
                  ),
                  child: Center(
                    child: Text(
                      'Service Provider Registration',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the Home Page!', style: TextStyle(color: AppColors.black, fontSize: 18)),
      ),
    );
  }
}
