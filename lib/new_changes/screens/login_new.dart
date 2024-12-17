import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/dynamic_provider.dart';
import '../../providers/login_provider.dart';
import '../../screens/dashboard/customer_dashboard.dart';
import '../../screens/dashboard/vendor_dashboard.dart';
import '../../colors/colors.dart';
import '../../screens/profiles/vendor_new.dart';
import 'home_first_users.dart';
import 'login_register.dart'; // Assuming this is your register page
import 'package:awesome_dialog/awesome_dialog.dart'; // Add this for showing dialogs

class LoginPageNew extends StatefulWidget {
  @override
  _LoginPageNewState createState() => _LoginPageNewState();
}

class _LoginPageNewState extends State<LoginPageNew> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // For showing the loader
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }
  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }
  Future<void> _saveUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  // Function to handle login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loader
      });

      final String email = _emailController.text;
      final String password = _passwordController.text;

      final Map<String, dynamic> payload = {
        'email': email,
        'password': password,
      };

      try {
        print("Payload: ${jsonEncode(payload)}");
        // API request to login
        final response = await http.post(
          Uri.parse('http://103.61.224.178:4444/user/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");


        if (response.statusCode == 200) {
          // Decode the response
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          print("Decoded Response Data: $responseData");
          final user = responseData['user'];

          final String? businessName = user['BusinessName'];
          final String? firstName = user['firstname']; // Extract the first name
          final String? email = user['email']; // Extract the first name

          if (businessName != null || firstName != null|| user['_id'] != null) {
            final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

            if (businessName != null) {
              businessProvider.setBusinessName(businessName); // Set the business name
            }

            if (firstName != null) {
              businessProvider.setFirstName(firstName); // Set the first name
            }
            if (user['_id'] != null) {
              businessProvider.setId(user['_id']); // Set the _id
            }
            if (user['email'] != null) {
              businessProvider.setEmail(user['email']); // Set the _id
            }


          }
          print('bussiness name: $businessName');

          final String role = user['role']?.toString() ?? '';
          final String isVerified = user['isVerified']?.toString() ?? '';
          final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
          businessProvider.setIsVerified(isVerified);
          print('is verifieddddddddddd? $isVerified');

          final loginProvider = Provider.of<LoginProvider>(context, listen: false);
          loginProvider.setUserData(user['_id'], user['email']);
          print('email of the vendor: $email');

          if (isVerified == 'Initiated') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => VendorNewPage()),
            );
            return; // Exit the function to avoid further navigation
          }


          // final loginProvider = Provider.of<LoginProvider>(context, listen: false);
          // loginProvider.setUserData(user['_id'], user['email']);
          // print('email of the vendor: $email');
          await _saveUserCredentials();
          // Prioritize role check first
          if (role == 'vendor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => VendorDashboard()),
            );
          } else if (role == 'customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ConsumerDashboard()),
            );
          } else {
            // Additional checks for vendor and customer flags if role is unknown
            final bool isVendor = user['isvendor'] ?? false;
            final bool isCustomer = user['iscustomer'] ?? false;

            if (!isVendor && !isCustomer) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeFirstUsers()),
              );
            } else {
              _showMessage('Invalid role. Please try again.', DialogType.error);
            }
          }
        } else {
          _showMessage('Invalid credentials. Please try again.', DialogType.error);
        }
      } catch (e) {
        print("Exception: $e");
        _showMessage('Failed to connect to the server. Please try again.', DialogType.error);
      } finally {
        setState(() {
          _isLoading = false; // Hide loader
        });
      }
    }
  }

  // Function to show messages using AwesomeDialog
  void _showMessage(String message, DialogType dialogType) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.bottomSlide,
      title: 'Login Status',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    String selectedRole = 'customer'; // Default dropdown value

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown for selecting role
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: [
                  DropdownMenuItem(value: 'customer', child: Text('customer')),
                  DropdownMenuItem(value: 'vendor', child: Text('vendor')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email, color: AppColors.lightBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text;

                if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                  _showMessage('Please enter a valid email address.', DialogType.warning);
                  return;
                }

                Navigator.pop(context); // Close the dialog

                // Call the API for Forgot Password
                await _forgotPassword(selectedRole, email);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _forgotPassword(String role, String email) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('http://103.61.224.178:4444/user/resetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': role, 'email': email}),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == "Password reset successfully. Check your email for the new password.") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected response: ${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send password reset instructions. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.lightBlue,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Login Icon
                  Icon(Icons.login, size: 80, color: AppColors.lightBlue),
                  SizedBox(height: 24),

                  // Email Address Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email, color: AppColors.lightBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: AppColors.lightBlue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.lightBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Remember Me and Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          Text('Remember me'),
                        ],
                      ),
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text('Forgot Password?',
                            style: TextStyle(color: AppColors.lightBlue)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Login Button with Loader
                  Center(
                    child: _isLoading
                        ? CircularProgressIndicator() // Show loader when API is in progress
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightBlue,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                            //     () {
                            //   Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => HomeFirstUsers()),
                            //   );
                            // },

                            _login,
                            child: Text('Login',
                                style: TextStyle(color: AppColors.white)),
                          ),
                  ),
                  SizedBox(height: 24),

                  // "Don't have an account? Register here" Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginRegisterPage()),
                            );
                          },
                          child: Text(
                            'Register here',
                            style: TextStyle(
                                color: AppColors.lightBlue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
