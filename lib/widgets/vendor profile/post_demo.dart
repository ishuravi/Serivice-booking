import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../providers/dynamic_provider.dart';
import '../custom_dropdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostDemo extends StatefulWidget {


  const PostDemo({Key? key}) : super(key: key);

  @override
  State<PostDemo> createState() => _PostDemoState();
}

class _PostDemoState extends State<PostDemo> {
  List<Map<String, dynamic>> mainCategories = [];
  List<Map<String, dynamic>> subCategories = [];
  List<Map<String, dynamic>> serviceTypes = [];
  List<Map<String, dynamic>> dynamicFields = [];
  Map<String, String?> validationErrors = {};

  String? selectedMainCategory;

  //String? selectedMainCategory = '673c86ded3d478d08746e490';
  String? selectedMainCategoryId; // Store the category ID separately
  String? selectedSubCategory;
  String? selectedSubCategoryId; // Store the subcategory ID separately
  String? selectedServiceType;
  String? selectedServiceTypeId; // Store the service type ID separately
  Map<String, dynamic> dynamicFieldValues = {}; // To store dynamic field values

  @override
  void initState() {
    super.initState();
    // Access the business name from the provider
    final businessName = Provider.of<BusinessProvider>(context, listen: false).businessName;

    // Use the business name as the main category ID
    selectedMainCategory = businessName;
    selectedMainCategoryId = businessName;

    // Fetch the main categories data
    fetchMainCategoryData();
  }

  void fetchMainCategoryData() async {
    final data = await fetchMainCategories();
    setState(() {
      mainCategories = data;
      // Find and set the default category
      final defaultCategory = mainCategories.firstWhere(
            (category) => category['id'] == selectedMainCategory,
        orElse: () => {},
      );
      selectedMainCategory = defaultCategory.isNotEmpty ? defaultCategory['name'] : null;
      selectedMainCategoryId = defaultCategory.isNotEmpty ? defaultCategory['id'] : null;

      // Fetch subcategories if a category is selected
      if (selectedMainCategoryId != null) {
        fetchSubCategoryData(selectedMainCategoryId!);
      }
    });
  }

  void fetchSubCategoryData(String categoryId) async {
    final data = await fetchSubCategories(categoryId);
    setState(() {
      subCategories = data;
    });
  }

  void fetchServiceTypeData(String categoryId, String subCategoryId) async {
    final data = await fetchServiceTypes(categoryId, subCategoryId);
    setState(() {
      serviceTypes = data;
    });
  }



  Future<List<Map<String, dynamic>>> fetchMainCategories() async {
    final response = await http
        .get(Uri.parse('http://103.61.224.178:4444/admin/getCategory'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((item) {
        return {
          'id': item['_id'],
          'name': item['categoryName'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load main categories');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSubCategories(
      String categoryId) async {
    final response = await http.get(Uri.parse(
        'http://103.61.224.178:4444/admin/subcategories/$categoryId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['subcategories'] as List).map((item) {
        return {
          'id': item['_id'],
          'name': item['subCategoryName'][0],
        };
      }).toList();
    } else {
      throw Exception('Failed to load subcategories');
    }
  }

  Future<List<Map<String, dynamic>>> fetchServiceTypes(
      String categoryId, String subCategoryId) async {
    final response = await http.get(Uri.parse(
        'http://103.61.224.178:4444/admin/service-types/$categoryId/$subCategoryId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['serviceTypes'] as List).map((item) {
        return {
          'id': item['_id'],
          'name': item['serviceTypeName'][0],
        };
      }).toList();
    } else {
      throw Exception('Failed to load service types');
    }
  }

  void fetchDynamicFields(String categoryId, String subCategoryId, String serviceTypeId) async {
    final url = Uri.parse(
        'http://103.61.224.178:4444/admin/dynamicFields/$categoryId/$subCategoryId/$serviceTypeId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dynamicFields =
            (data['data']['fields'] as List).cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to load dynamic fields');
    }
    print('category id : $categoryId');
    print('sub category id : $subCategoryId');
    print('service type id : $serviceTypeId');
  }


  void _handleSubmit() {
    setState(() {
      validationErrors.clear();
      bool isValid = true;

      for (var field in dynamicFields) {
        final fieldName = field['fieldName'];
        final isRequired = field['validationRules']['required'] ?? false;
        final value = dynamicFieldValues[fieldName];

        if (isRequired && (value == null || value.isEmpty)) {
          validationErrors[fieldName] = field['validationRules']
          ['placeholder'] ??
              'This field is required';
          isValid = false;
        }
      }

      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submitted successfully!')),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        title: const Text('Post Service dynamic'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle('Choose Main Category:'),
                _buildSpacing(),

                CustomDropdown(
                  value: selectedMainCategory,
                  hint: 'Select Main Category',
                  items: mainCategories.map((e) => e['name'].toString()).toList(),
                  onChanged: (value) {
                    final selected = mainCategories.firstWhere((e) => e['name'] == value);
                    setState(() {
                      selectedMainCategory = value;
                      selectedMainCategoryId = selected['id']; // Store the category ID
                      selectedSubCategory = null;
                      selectedServiceType = null;
                      dynamicFields = []; // Clear dynamic fields

                      // Fetch subcategory and service type data based on selected category
                      fetchSubCategoryData(selectedMainCategoryId!);
                    });
                  },
                ),
                _buildSpacing(),
                _buildTitle('Choose Sub Category:'),
                _buildSpacing(),

                CustomDropdown(
                  value: selectedSubCategory,
                  hint: 'Select Subcategory',
                  items: subCategories.map((e) => e['name'].toString()).toList(),
                  onChanged: (value) {
                    final selected = subCategories.firstWhere((e) => e['name'] == value);
                    setState(() {
                      selectedSubCategory = value;
                      selectedSubCategoryId = selected['id']; // Store subcategory ID
                      selectedServiceType = null; // Reset service type when subcategory is changed
                      selectedServiceTypeId = null; // Reset service type ID
                      dynamicFields = []; // Clear dynamic fields

                      // Fetch service types based on selected categoryId and subCategoryId
                      fetchServiceTypeData(selectedMainCategoryId!, selectedSubCategoryId!);
                    });
                  },
                ),


                _buildSpacing(),
                _buildTitle('Choose Service Type:'),
                _buildSpacing(),

                CustomDropdown(
                  value: selectedServiceType,
                  hint: 'Select Service Type',
                  items: serviceTypes.map((e) => e['name'].toString()).toList(),
                  onChanged: (value) {
                    final selected = serviceTypes.firstWhere((e) => e['name'] == value);
                    setState(() {
                      selectedServiceType = value;
                      selectedServiceTypeId = selected['id']; // Store service type ID
                      // Fetch dynamic fields when a service type is selected
                      fetchDynamicFields(selectedMainCategoryId!, selectedSubCategoryId!, selectedServiceTypeId!);
                    });
                  },
                ),

                const SizedBox(height: 16),

                ..._buildDynamicFields(),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                    ),
                    onPressed: _handleSubmit,
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpacing() {
    return const SizedBox(height: 12);
  }

  List<Widget> _buildDynamicFields() {
    if (dynamicFields.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Center(
            child: Text(
              'No form available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ];
    }

    return dynamicFields.map((field) {

      final validationRules = field['validationRules'];
      final placeholder = validationRules['placeholder'] ?? '';
      final fieldType = field['fieldType'];
      final inputType = field['inputType'];
      final isRequired = validationRules['required'] ?? false;


      // Initialize the field's value in dynamicFieldValues if not already set
      dynamicFieldValues[field['fieldName']] ??= () {
        switch (fieldType) {
          case 'checkbox':
          case 'radio':
            return [];
          default:
            return '';
        }
      }();

      if (fieldType == 'text') {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: field['fieldName'],
              hintText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              errorText: validationErrors[field['fieldName']],
            ),
            keyboardType: inputType == 'number'
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (value) {
              setState(() {
                dynamicFieldValues[field['fieldName']] = value;
                validationErrors[field['fieldName']] = null; // Clear errors on change
              });
            },
          ),
        );
      } else if (fieldType == 'dropdown') {
        final options = validationRules['options'];
        if (options is List) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: field['fieldName'],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: validationErrors[field['fieldName']],
              ),
              items: options
                  .map((option) =>
                  DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  dynamicFieldValues[field['fieldName']] = value;
                  validationErrors[field['fieldName']] = null; // Clear errors on change
                });
              },
            ),
          );
        } else {
          return Text(
            'Invalid options for ${field['fieldName']}',
            style: TextStyle(color: Colors.red),
          );
        }
      } else if (fieldType == 'radio') {
        final options = validationRules['options'];
        if (options is List) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field['fieldName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                MultiSelectDialogField(
                  items: options.map((option) {
                    return MultiSelectItem(option, option);
                  }).toList(),
                  title: Text("Select Options"),
                  selectedColor: Colors.blue,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.blue,
                    ),
                  ),
                  buttonText: Text(
                    "Choose options",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16,
                    ),
                  ),
                  onConfirm: (selectedOptions) {
                    setState(() {
                      dynamicFieldValues[field['fieldName']] = selectedOptions;
                      validationErrors[field['fieldName']] = null; // Clear errors
                    });

                    print('Selected options: $selectedOptions');
                  },
                  initialValue: dynamicFieldValues[field['fieldName']] ?? [],
                ),
              ],
            ),
          );
        } else {
          return Text(
            'Invalid options for ${field['fieldName']}',
            style: TextStyle(color: Colors.red),
          );
        }
      } else if (fieldType == 'checkbox') {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Checkbox(
                value: dynamicFieldValues[field['fieldName']] == true,
                onChanged: (value) {
                  setState(() {
                    dynamicFieldValues[field['fieldName']] = value;
                    validationErrors[field['fieldName']] = null; // Clear validation errors
                  });
                },
              ),
              Expanded(
                child: Text(
                  field['fieldName'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        );
      } else if (fieldType == 'textarea') {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextFormField(
            maxLines: 5,
            decoration: InputDecoration(
              labelText: field['fieldName'],
              hintText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              errorText: validationErrors[field['fieldName']],
            ),
            onChanged: (value) {
              setState(() {
                dynamicFieldValues[field['fieldName']] = value;
                validationErrors[field['fieldName']] = null; // Clear errors
              });
            },
          ),
        );
      } else if (fieldType == 'dob') {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: field['fieldName'],
              hintText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              errorText: validationErrors[field['fieldName']],
            ),
            readOnly: true,
            controller: TextEditingController(
                text: dynamicFieldValues[field['fieldName']]?.toString() ?? ''),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900), // Allow dates from 1900
                lastDate: DateTime(2100), // Allow future dates up to 2100
              );
              if (selectedDate != null) {
                setState(() {
                  dynamicFieldValues[field['fieldName']] =
                  selectedDate.toString().split(' ')[0];
                  validationErrors[field['fieldName']] = null; // Clear errors
                });
              }
            },
          ),
        );
      }

      return SizedBox.shrink(); // Return an empty widget for unsupported field types
    }).toList();
  }


  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBlue,
      ),
    );
  }
}
