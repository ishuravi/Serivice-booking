import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:provider/provider.dart';
import 'package:service_booking/new_changes/screens/home_new.dart';
import '../../colors/colors.dart';
import '../../providers/login_provider.dart';
import '../../screens/profiles/customer_new.dart';
import '../../screens/profiles/vendor_new.dart';
import 'package:http/http.dart' as http;


class HomeFirstUsers extends StatefulWidget {
  @override
  _HomeFirstUsersState createState() => _HomeFirstUsersState();
}

class _HomeFirstUsersState extends State<HomeFirstUsers> {
  @override
  void initState() {
    super.initState();
    // Show notification dialog on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showProfileNotification();
    });
  }

  void _showProfileNotification() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Notification',
      desc: 'You are successfully logged in \n Kindly set profile first',
      btnOkOnPress: () {
        _showRoleSelectionDialog(); // Show the second dialog after closing the first
      },
      btnOkText: 'OK',
      btnOkColor: AppColors.darkBlue, // Using the imported colors
      titleTextStyle: TextStyle(
        color: AppColors.lightBlue,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: TextStyle(
        color: AppColors.black,
      ),
    ).show();
  }



  void _showRoleSelectionDialog() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    String selectedRole = 'Vendor'; // Default selection
    String userId = loginProvider.userId; // Get userId from provider
    print("id for first time users : $userId");

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: 'Select Role',
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Role',
                style: TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RadioListTile<String>(
                title: Text('Post a service', style: TextStyle(color: AppColors.black)),
                value: 'Vendor',
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                activeColor: AppColors.darkBlue,
              ),
              RadioListTile<String>(
                title: Text('Book a service', style: TextStyle(color: AppColors.black)),
                value: 'Customer',
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                activeColor: AppColors.darkBlue,
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
      btnOkOnPress: () async {
        // Prepare JSON data for the API request
        Map<String, dynamic> data = {
          "userId": userId,
          if (selectedRole == 'Vendor') "isVendor": true, // Set true for Vendor
          if (selectedRole == 'Customer') "isCustomer": true, // Set true for Customer
        };

        // Make the POST request
        var response = await http.post(
          Uri.parse('http://103.61.224.178:4444/user/register/updateType'),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          print('Role updated successfully');
          // Navigate based on role
          if (selectedRole == 'Vendor') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VendorNewPage()), // Replace with actual page
            );
          } else if (selectedRole == 'Customer') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConsumerProfileSetupPage()), // Replace with actual page
            );
          }
        } else {
          print('Failed to update role: ${response.body}');
          // You can show an error dialog here if needed
        }

        print('Selected Role: $selectedRole');
      },
      btnOkText: 'Go',
      btnOkColor: AppColors.darkBlue,
    ).show();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue, // Using the imported colors
        title: Text('Home', style: TextStyle(color: AppColors.white)),
        actions: [
          PopupMenuButton<String>(
            color: AppColors.white, // Background color of the popup menu
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)), // Rounded corners
            ),
            onSelected: (value) {
              if (value == 'Profile') {
                // Show the role selection dialog when 'Profile' is selected
                _showRoleSelectionDialog();
              } else if (value == 'Logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePageNew()), // Replace with actual page
                );
              }
            },
            icon: Icon(
              Icons.more_vert, // Icon for the popup button
              color: AppColors.white, // Icon color
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: AppColors.darkBlue), // Profile icon
                      SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.darkBlue), // Logout icon
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Center the column within the available space
          children: [
            Text(
              'Welcome to our services',
              style: TextStyle(fontSize: 24, color: AppColors.black),
            ),
            const SizedBox(height: 16), // Add spacing between the text and button
            ElevatedButton(
              onPressed: () {
                // Handle button click action here
                _showRoleSelectionDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue, // Button background color
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Button corner radius
                ),
              ),
              child: const Text(
                'Click Here',
                style: TextStyle(fontSize: 16, color: Colors.white), // Button text style
              ),
            ),
          ],
        ),
      ),

      backgroundColor: AppColors.white, // Using the imported colors
    );
  }
}
