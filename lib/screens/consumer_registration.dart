import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Import the http package
import 'dart:convert';  // Import for JSON encoding/decoding
import 'package:service_booking/colors/colors.dart';

import 'api_link.dart';  // Ensure this path is correct

class ConsumerRegistrationPage extends StatefulWidget {
  @override
  _ConsumerRegistrationPageState createState() => _ConsumerRegistrationPageState();
}

class _ConsumerRegistrationPageState extends State<ConsumerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Password visibility controllers
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'firstname': _firstNameController.text,
        'lastname': _lastNameController.text,
        'phoneNumber': _phoneController.text,
        'userName': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'confirm_password': _confirmPasswordController.text,
        'address': '123',  // You can add an address field if needed
      };

      // Make the API call using the base URL constant
      final response = await http.post(
        Uri.parse('${baseUrl}customerReg'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Decode the response body
        final responseData = jsonDecode(response.body);

        // Show the message from the response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      } else {
        // Handle error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register. Please try again.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consumer Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0176d3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Form key for validation
          child: ListView(
            children: [
              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person, color: AppColors.darkBlue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.darkBlue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.account_circle, color: AppColors.darkBlue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Email Address
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email, color: AppColors.darkBlue),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone, color: AppColors.darkBlue),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.darkBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.darkBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_confirmPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBlue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submitForm,  // Call the submit function
                child: Text('Submit', style: TextStyle(fontSize: 18, color: AppColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
