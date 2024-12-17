import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../new_changes/screens/home_new.dart';
import '../../providers/dynamic_provider.dart';
import '../screens/profiles/customer_new.dart';
import 'package:http/http.dart' as http;


class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? profileImageUrl;
  bool isLoading = true; // Add loading state
  @override
  void initState() {
    super.initState();
    fetchProfileImage();
  }

  Future<void> fetchProfileImage() async {
    try {
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false); // Use listen: false
      final email = businessProvider.email; // Fetch email dynamically
      print('Email from BusinessProvider: $email'); // Print the email for debugging

      final url = 'http://103.61.224.178:4444/user/getuser/$email';
      print('API URL: $url'); // Print the constructed URL for debugging

      final response = await http.get(Uri.parse(url));
      print('API Response: ${response.body}'); // Log the raw response

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['user'] != null && data['user']['profile'] != null) {
          final profileData = data['user']['profile'];
          if (profileData.isNotEmpty) {
            setState(() {
              profileImageUrl = 'http://103.61.224.178:4444${profileData[0]['url']}';
              isLoading = false; // Update loading state
            });
          } else {
            print('No profile data found');
            setState(() => isLoading = false); // Stop loading if no data found
          }
        }
      } else {
        print('Failed to fetch profile image: ${response.statusCode}');
        setState(() => isLoading = false); // Stop loading on failure
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }
  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String newPassword = passwordController.text.trim();
                  if (newPassword.isNotEmpty) {
                    // Handle password update logic here
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a password')),
                    );
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = Provider.of<BusinessProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white, // Loader color
                  ),
                )
                    : CircleAvatar(
                  radius: 40,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : AssetImage('assets/images/placeholder.png') as ImageProvider,
                  onBackgroundImageError: (_, __) {
                    print('Error loading profile image');
                  },
                ),
                SizedBox(height: 10),
                Text(
                  businessProvider.firstName ?? 'Vendor Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConsumerProfileSetupPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePageNew()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
