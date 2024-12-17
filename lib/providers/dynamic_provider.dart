import 'package:flutter/material.dart';

class BusinessProvider with ChangeNotifier {
  String? _businessName;
  String? _firstName; // Add a property for the first name
  String? _isVerified;
  String? _id; // New property for _id
  String? _email;

  String? get businessName => _businessName;
  String? get firstName => _firstName; // Getter for the first name
  String? get isVerified => _isVerified;
  String? get id => _id;
  String? get email => _email;


  void setBusinessName(String businessName) {
    _businessName = businessName;
    notifyListeners(); // Notify listeners to update the UI
  }

  void setFirstName(String firstName) {
    _firstName = firstName; // Set the first name
    notifyListeners(); // Notify listeners to update the UI
  }

  void setIsVerified(String isVerified) {
    _isVerified = isVerified;
    notifyListeners();
  }
  void setId(String id) {
    _id = id;
    notifyListeners();
  }
  void setEmail(String email) {
    _email= email;
    notifyListeners(); // Notify listeners to update the UI
  }
}
