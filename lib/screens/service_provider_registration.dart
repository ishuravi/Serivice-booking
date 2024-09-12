import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:service_booking/colors/colors.dart';

class ServiceProviderRegistrationPage extends StatefulWidget {
  @override
  _ServiceProviderRegistrationPageState createState() => _ServiceProviderRegistrationPageState();
}

class _ServiceProviderRegistrationPageState extends State<ServiceProviderRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _businessNameController = TextEditingController();
  final _serviceProviderNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _businessNameController.dispose();
    _serviceProviderNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _registerVendor() async {
    final url = Uri.parse('http://103.61.224.178:4444/user/vendorReg');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "firstname": _firstNameController.text,
          "lastname": _lastNameController.text,
          "phoneNumber": _phoneController.text,
          "userName": _usernameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "confirm_password": _confirmPasswordController.text,
          "address": _addressController.text,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final message = jsonResponse['message'];

        _showMessageDialog(context, 'Success', message);
      } else {
        _showMessageDialog(context, 'Error', 'Something went wrong. Please try again.');
      }
    } catch (error) {
      _showMessageDialog(context, 'Error', 'Failed to connect to the server.');
    }
  }

  void _showMessageDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Provider Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0176d3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                  prefixIcon: Icon(Icons.person, color: AppColors.darkBlue),
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

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.darkBlue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
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
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.darkBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
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
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.darkBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerVendor();
                  }
                },
                child: Text('Submit', style: TextStyle(fontSize: 18, color: AppColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
