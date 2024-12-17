import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import '../../screens/dashboard/customer_dashboard.dart';

import 'login_new.dart';
import 'login_register.dart';


class HomePageNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Common home page', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.lightBlue,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.app_registration, color: AppColors.white),
            onSelected: (value) {
              if (value == 'Register') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPageNew()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

              PopupMenuItem<String>(
                value: 'Register',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Signup/Login',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ConsumerDashboard(showDrawer: false), // No drawer on Home Page
    );
  }
}
