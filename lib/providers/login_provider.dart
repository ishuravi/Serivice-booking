import 'package:flutter/material.dart';


class LoginProvider extends ChangeNotifier {
  String _userId = '';
  String _email = '';


  // Getters
  String get userId => _userId;
  String get email => _email;

  // Method to update user data
  void setUserData(String userId, String email) {
    _userId = userId;
    _email = email;
    notifyListeners(); // Notify all listeners about the change
  }

  // Optional: Method to clear user data on logout
  void clearUserData() {
    _userId = '';
    _email = '';
    notifyListeners();
  }
}

