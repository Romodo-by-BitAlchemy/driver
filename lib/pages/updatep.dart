import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateDriverScreen extends StatefulWidget {
  final String driverEmail;

  const UpdateDriverScreen({super.key, required this.driverEmail});

  @override
  // ignore: library_private_types_in_public_api
  _UpdateDriverScreenState createState() => _UpdateDriverScreenState();
}

class _UpdateDriverScreenState extends State<UpdateDriverScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _licenseNoController = TextEditingController();
  final TextEditingController _licenseExpireDateController = TextEditingController();
  final TextEditingController _medicalIssuesController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  String? _errorMessage;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  Future<void> _fetchDriverDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? driverJson = prefs.getString('driver');

    if (driverJson != null) {
      try {
        final data = jsonDecode(driverJson);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _nicController.text = data['nic'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _contactNoController.text = data['contactNo'] ?? '';
          _licenseNoController.text = data['licenseNo'] ?? '';
          _selectedGender = data['gender'] ?? _genderOptions.first;
          _dobController.text = data['dob'] ?? '';
          _licenseExpireDateController.text = data['licenseExpireDate'] ?? '';
          _medicalIssuesController.text = data['medicalIssues'] ?? '';
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to parse driver details: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to load driver details';
      });
    }
  }

  void _handleCancel() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void initState() {
    super.initState();
    _fetchDriverDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Driver Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextField(_firstNameController, 'First Name'),
                _buildTextField(_lastNameController, 'Last Name'),
                _buildTextField(_nicController, 'NIC'),
                _buildTextField(_usernameController, 'Username'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(_contactNoController, 'Contact No'),
                _buildDropdownButtonFormField('Gender', _genderOptions, _selectedGender, (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }),
                _buildDatePickerField(context, _dobController, 'Date of Birth'),
                _buildTextField(_licenseNoController, 'License No'),
                _buildDatePickerField(context, _licenseExpireDateController, 'License Expire Date'),
                _buildTextField(_medicalIssuesController, 'Medical Issues'),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleCancel,
                    // ignore: sort_child_properties_last
                    child: const Text('CANCEL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildDropdownButtonFormField(String label, List<String> options, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              controller.text = picked.toIso8601String().split('T')[0];
            });
          }
        },
      ),
    );
  }
}
