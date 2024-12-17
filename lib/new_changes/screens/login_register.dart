import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../colors/colors.dart';
import '../../screens/api_link.dart';
import 'login_new.dart';

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // Track loading state

  // Function to handle registration API call
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loader
      });

      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String confirmPassword = _confirmPasswordController.text;

      // Prepare the request payload
      final Map<String, dynamic> payload = {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword
      };

      try {
        // Make the POST request
        final response = await http.post(
          Uri.parse('${baseUrl}register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        // Check the response status code
        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          _showMessage(responseData['message'], DialogType.success);
        } else if (response.statusCode == 400) {
          _showMessage('The given mail id already exists', DialogType.error);
        } else {
          _showMessage('Something went wrong. Please try again later.', DialogType.error);
        }
      } catch (e) {
        _showMessage('Failed to connect to the server. Please try again.', DialogType.error);
      } finally {
        setState(() {
          _isLoading = false; // Hide loader after process
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
      title: 'Registration Status',
      desc: message,
      btnOkOnPress: () { Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPageNew()),
      );},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.lightBlue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.app_registration, size: 80, color: AppColors.lightBlue),
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
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must include at least one uppercase letter';
                      }
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Password must include at least one lowercase letter';
                      }
                      if (!RegExp(r'\d').hasMatch(value)) {
                        return 'Password must include at least one number';
                      }
                      if (!RegExp(r'[#!?@$%^&*-]').hasMatch(value)) {
                        return 'Password must include at least one special character (#, ?, !, etc.)';
                      }
                      return null; // Password is valid
                    },
                  ),

                  SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.lightBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),

                  // Register Button or Loader
                  Center(
                    child: _isLoading
                        ? CircularProgressIndicator() // Show loader when loading
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _register,
                      child: Text(
                        'Register',
                        style: TextStyle(color: AppColors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // "Already have an account? Login here" Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPageNew()),
                            );
                          },
                          child: Text(
                            'Login here',
                            style: TextStyle(
                              color: AppColors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
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
