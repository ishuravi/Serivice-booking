import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:service_booking/new_changes/screens/login_new.dart';
import '../../colors/colors.dart';
import 'package:http/http.dart' as http;
import '../../providers/login_provider.dart';
import '../../widgets/vendor profile/section_title.dart';
import '../../widgets/vendor profile/text_field.dart';
import '../dashboard/vendor_dashboard.dart'; // Add http package

class VendorNewPage extends StatefulWidget {
  @override
  _VendorNewPageState createState() => _VendorNewPageState();
}

class _VendorNewPageState extends State<VendorNewPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key for validation

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController shopController = TextEditingController();

  final TextEditingController providerNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController taxIdController = TextEditingController();
  final TextEditingController websiteUrlController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController serviceDescriptionController =
      TextEditingController();
  final TextEditingController cancellationPolicyController =
      TextEditingController();
  final TextEditingController termsController = TextEditingController();
  final TextEditingController privacyPolicyController = TextEditingController();

  List<Map<String, String>> operatingHours = [];
  bool privacyPolicyAccepted = false;
  bool termsAccepted = false;

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  bool isAddressExpanded = false;
  String? _profileUrl; // Profile image URL from API
  bool agreeTerms = false;
  bool agreePrivacy = false;
  File? _logoImage; // Variable to hold the logo image

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _fetchUserData(); // Fetch user data when the page loads
    _fetchTerms(); // Fetch Terms of Service content
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
     {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];

        setState(() {
          // Populate controllers and variables with fetched data
          shopController.text=user['shopName']?? '';
          businessNameController.text= user['bussinessName'] ?? '';
          providerNameController.text = user['firstname'] ?? '';
          phoneNumberController.text = user['phoneNumber'] ?? '';
          licenseNumberController.text=user['businessLicenseNumber'] ?? '';
          taxIdController.text=user['taxID'] ?? '';
          websiteUrlController.text=user['websiteURL'] ?? '';
          licenseNumberController.text=user['businessLicenseNumber'] ?? '';
          cityController.text = user['address']?['city'] ?? '';
          stateController.text = user['address']?['state'] ?? '';
          countryController.text = user['address']?['street'] ?? ''; // Adjust key if needed
          zipCodeController.text = user['address']?['pincode'] ?? '';
          serviceDescriptionController.text = user['websiteURL'] ?? '';
          cancellationPolicyController.text=user['appointmentCancellationPolicy'] ?? '';
        //  termsController.text=user['termsOfService'] ?? '';
          privacyPolicyAccepted = user['privacyPolicyAccepted'] ?? false;

          if (user['profile'] != null && user['profile'].isNotEmpty) {
            _profileUrl =
            'http://103.61.224.178:4444${user['profile'][0]['url']}';
          }
        });
      }
    }
  }

  Future<void> fetchCategories() async {
    const url = 'http://103.61.224.178:4444/admin/getCategory';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _categories = data
              .map((category) => {
            'id': category['_id'],
            'name': category['categoryName'],
          })
              .toList();
        });
      } else {
        print('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching categories: $error');
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
                    MaterialPageRoute(builder: (context) => VendorDashboard()),
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form( // Wrap everything inside the Form widget
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    SectionTitle(title: 'Basic Information', icon: Icons.info),
                    Text(
                      'Select Business Category',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedCategoryId,
                      hint: Text('Choose a category'),
                      isExpanded: true,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategoryId = newValue;
                        });
                        print('Selected Category ID: $_selectedCategoryId');
                      },
                    ),
                    CustomTextField(
                      controller: shopController,
                      label: 'Bussiness Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Provider name is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: providerNameController,
                      label: 'Service Provider Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Provider name is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: phoneNumberController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      inputType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Business Information
                    SectionTitle(
                        title: 'Business Information',
                        icon: Icons.business_center),
                    CustomTextField(
                        controller: licenseNumberController,
                        label: 'Business License Number',
                        icon: Icons.card_membership),
                    CustomTextField(
                        controller: taxIdController,
                        label: 'Tax ID (VAT/GST)',
                        icon: Icons.account_balance_wallet),
                    CustomTextField(
                        controller: websiteUrlController,
                        label: 'Website URL',
                        icon: Icons.web),
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
                            Expanded(child: CustomTextField(controller: countryController, label: 'Door no', icon: Icons.door_back_door_outlined)),
                            SizedBox(width: 7),
                            Expanded(child: CustomTextField(controller: stateController, label: 'Street name', icon: Icons.location_on)),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: cityController,
                                label: 'Area/town/city',
                                icon: Icons.location_city,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 7),
                            Expanded(
                              child: CustomTextField(
                                controller: zipCodeController,
                                label: 'Pincode',
                                icon: Icons.pin_drop_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Pincode is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    CustomTextField(
                      controller: termsController,
                      label: 'Terms of Service',
                      icon: Icons.document_scanner,
                      inputType: TextInputType.multiline,
                      maxLines: 5, // Allows up to 5 lines
                    ),
                    _buildCheckbox('Agree to Terms of User and Privacy Policy', agreePrivacy,
                            (value) {
                          setState(() {
                            agreePrivacy = value!;
                          });
                        }),
                    SizedBox(height: 20),

                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Validate the form before submission
                          if (_formKey.currentState!.validate()) {
                            _submitForm();
                          } else {
                            // Show a message or highlight errors
                            print('Form validation failed');
                          }
                        },
                        icon: Icon(Icons.save, color: AppColors.white),
                        label: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          backgroundColor: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildCheckbox(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: TextStyle(color: AppColors.black)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Future<void> _submitForm() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    String email = loginProvider.email;
    final url = 'http://103.61.224.178:4444/user/vendor/$email';

    print('Preparing request...');
    var request = http.MultipartRequest('PUT', Uri.parse(url));

    // Add form fields
    request.fields['firstname'] = providerNameController.text;
    request.fields['shopName'] = shopController.text;
    request.fields['userName'] = usernameController.text;
    request.fields['phoneNumber'] = phoneNumberController.text;
    request.fields['BusinessName'] = _selectedCategoryId ?? '';
    request.fields['businessLicenseNumber'] = licenseNumberController.text;
    request.fields['taxID'] = taxIdController.text;
    request.fields['websiteURL'] = websiteUrlController.text;

    request.fields['address'] = json.encode({
      'street': stateController.text,
      'city': cityController.text,
      'DoorNo': countryController.text,
      'state': stateController.text,
      'pincode': zipCodeController.text,
    });

    request.fields['privacyPolicyAccepted'] = agreePrivacy.toString();

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


}


