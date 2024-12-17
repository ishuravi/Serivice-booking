import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:service_booking/widgets/vendor%20profile/dynamic_form.dart';
import '../../colors/colors.dart';
import '../../new_changes/screens/home_new.dart';
import '../providers/dynamic_provider.dart';
import '../screens/profiles/vendor_new.dart';

class VendorDrawer extends StatefulWidget {
  @override
  _VendorDrawerState createState() => _VendorDrawerState();
}
class _VendorDrawerState extends State<VendorDrawer> {
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
          // Remaining drawer items
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VendorNewPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notification_add),
            title: Text('Notifications'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          if (businessProvider.isVerified == 'Approved')
            ListTile(
              leading: Icon(Icons.post_add),
              title: Text('Post service'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Post()),
                );
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
