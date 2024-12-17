import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:service_booking/new_changes/screens/login_new.dart';
import '../../colors/colors.dart';
import '../../providers/login_provider.dart';
import '../../widgets/vendor profile/text_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import '../dashboard/customer_dashboard.dart';

class ConsumerProfileSetupPage extends StatefulWidget {
  @override
  _ConsumerProfileSetupPageState createState() => _ConsumerProfileSetupPageState();
}

class _ConsumerProfileSetupPageState extends State<ConsumerProfileSetupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key for validation

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController termsController = TextEditingController();


  DateTime? selectedDate;
  String? selectedGender;
  bool termsAccepted = false;
  bool privacyAccepted = false;
  bool isAddressExpanded = false;
  String? imagePath;
  File? _logoImage; // Variable to hold the logo image
  String? _profileUrl; // Profile image URL from API


  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page loads
    _fetchTerms();
  }
  Future<void> _fetchTerms() async {
    const url = 'http://103.61.224.178:4444/admin/getTerms'; // API endpoint

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Set the fetched content to the termsController
          setState(() {
            termsController.text = data[0]['content'] ?? '';
          });
        }
      } else {
        print('Failed to fetch terms: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching terms: $error');
    }
  }
  Future<void> _fetchUserData() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    String email = loginProvider.email;

    final url = 'http://103.61.224.178:4444/user/getuser/$email';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];

        setState(() {
          // Populate controllers and variables with fetched data
          firstNameController.text = user['firstname'] ?? '';
          lastNameController.text = user['lastname'] ?? '';
          emailController.text = user['email'] ?? '';
          phoneNumberController.text = user['phoneNumber'] ?? '';
          selectedGender = user['gender'];
          selectedDate = user['date_of_birth'] != null
              ? DateTime.parse(user['date_of_birth'])
              : null;

          // Populate address fields
          cityController.text = user['address']?['city'] ?? '';
          stateController.text = user['address']?['state'] ?? '';
          countryController.text = user['address']?['street'] ?? ''; // Adjust key if needed
          zipCodeController.text = user['address']?['pincode'] ?? '';
          // Populate terms and privacy acceptance
          termsAccepted = user['termsAccepted'] ?? false;
          privacyAccepted = user['privacyPolicyAccepted'] ?? false;
          if (user['profile'] != null && user['profile'].isNotEmpty) {
            _profileUrl =
            'http://103.61.224.178:4444${user['profile'][0]['url']}';
          }
        });
      } else {
        _showDialog('Error', 'Failed to retrieve user data. Please try again.');
      }
    } catch (error) {
      _showDialog('Error', 'Something went wrong. Please try again.');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  _logoImage != null
                      ? Image.file(
                    _logoImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                      : (_profileUrl != null
                      ? Image.network(
                    _profileUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Error loading image',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      );
                    },
                  )
                      : Container(
                    color: AppColors.lightBlue,
                    child: Center(
                      child: Text(
                        'No Logo Selected',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: _pickImage, // Call the image picker method
                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                      tooltip: 'Upload Logo',
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors
                .transparent, // Make the AppBar transparent to see the image
            pinned: true,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ConsumerDashboard()),
                  );
                },
                child: Text(
                  'Skip here',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileForm() {
    return Column(
      children: [

        CustomTextField(controller:firstNameController, label: 'First Name',icon: Icons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'First name is required';
            }
            return null;
          },),
        SizedBox(height: 7),
        CustomTextField(controller:lastNameController, label:'Last Name',icon: Icons.person),
        SizedBox(height: 7),
        CustomTextField(controller:phoneNumberController, label:'Phone Number', icon:Icons.phone, validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Phone number is required';
          }
          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'Enter a valid 10-digit phone number';
          }
          return null;
        },),
        SizedBox(height: 7),
        ListTile(
          title: Text('Date of Birth', style: TextStyle(color: AppColors.black)),
          subtitle: Text(
            selectedDate != null
                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                : "Select your date of birth",
            style: TextStyle(color: AppColors.darkGrey),
          ),
          trailing: Icon(Icons.calendar_today, color: AppColors.lightBlue),
          onTap: _selectDate,
        ),
        SizedBox(height: 7),
        DropdownButtonFormField<String>(
          value: selectedGender,
          items: ['male', 'female', 'other'].map((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.people, color: AppColors.lightBlue),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Gender is required';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
        ),

        ExpansionTile(
          title: Text('Address', style: TextStyle(color: AppColors.black)),
          trailing: Icon(isAddressExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.lightBlue),
          onExpansionChanged: (expanded) {
            setState(() {
              isAddressExpanded = expanded;
            });
          },
          children: [
            Row(
              children: [
                Expanded(child: CustomTextField(controller:countryController, label:'Door no',icon: Icons.door_back_door_outlined)),
                SizedBox(width: 7),
                Expanded(child: CustomTextField(controller:stateController,label: 'Street name',icon: Icons.location_on)),
              ],
            ),
            SizedBox(height: 7),
            Row(
              children: [
                Expanded(child: CustomTextField(controller:cityController,label: 'Area/town/city', icon:Icons.location_city,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },)),
                SizedBox(width: 7),
                Expanded(child: CustomTextField(controller:zipCodeController,label: 'Pincode', icon:Icons.pin_drop_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'pincode is required';
                    }
                    return null;
                  },
                ),
                ),
              ],
            ),
          ],
        ),
        CustomTextField(
          controller: termsController,
          label: 'Terms of Service',
          icon: Icons.document_scanner,
          inputType: TextInputType.multiline,
          maxLines: 5, // Allows up to 5 lines
        ),
        CheckboxListTile(
          value: termsAccepted,
          onChanged: (bool? value) {
            setState(() {
              termsAccepted = value ?? false;
            });
          },
          title: Text('Agree to Terms of User and Privacy Policy', style: TextStyle(color: AppColors.black)),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.lightBlue,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _updateProfile(); // Update profile only if validation passes
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.white,
            backgroundColor: AppColors.darkBlue,
          ),
          child: Text('Save Profile'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _logoImage = File(image.path); // Update the _logoImage with the selected file
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _skipProfileSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ConsumerDashboard()),
    );
  }

  void _updateProfile() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    String email = loginProvider.email;

    final url = 'http://103.61.224.178:4444/user/customer/$email'; // replace email dynamically if needed
    print('Preparing request...');
    var request = http.MultipartRequest('PUT', Uri.parse(url));
    request.fields['firstname'] = firstNameController.text;
    request.fields['lastname'] = lastNameController.text;
    request.fields['phoneNumber'] = phoneNumberController.text;
    request.fields['date_of_birth'] =selectedDate != null ? "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}" : null?? '';
    request.fields['gender']=selectedGender ?? '';
    request.fields['address'] = json.encode({
      'street': stateController.text,
      'city': cityController.text,
      'DoorNo': countryController.text,
      'state': stateController.text,
      'pincode': zipCodeController.text,
    });
    request.fields['termsAccepted']=termsAccepted.toString();
    request.fields['privacyPolicyAccepted']=privacyAccepted.toString() ;
    // Attach the profile image **only if a new image is selected**
    if (_logoImage != null) {
      print('Adding file: ${_logoImage!.path}');
      request.files.add(await http.MultipartFile.fromPath(
        'profile',
        _logoImage!.path,
        contentType: MediaType('image', 'jpeg'), // Ensure correct MIME type
      ));
    } else {
      print('No new image selected. Keeping existing profile image.');
    }

    // Add headers if needed
    request.headers['Content-Type'] = 'multipart/form-data';

    try {
      print('Sending request...');
      var response = await request.send().timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var responseBody = json.decode(responseData.body);
        print('Response: ${responseBody.toString()}');

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Success',
          desc: 'Vendor user updated successfully.',
          btnOkOnPress: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPageNew()),
            );
          },
        ).show();
      } else {
        print('Response failed with status: ${response.statusCode}');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Failed to update vendor. Please try again.',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      print('Error: $e');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'An error occurred. Please try again later.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  void _showDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: title == 'Success' ? DialogType.success : DialogType.error,
      title: title,
      desc: message,
      btnOkOnPress: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPageNew()),
        );
      },
    ).show();
  }


}