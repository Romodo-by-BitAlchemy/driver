// pages/formPage.dart
import 'package:reporting_issues/networks/formNetwork.dart';
import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  String? incidentType;
  String? rerouting;
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _formSubmitted = false; // State variable to track form submission

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final type = _typeController.text;
    final description = _descriptionController.text;

    if (incidentType != null &&
        rerouting != null &&
        type.isNotEmpty &&
        description.isNotEmpty) {
      sendDataToBackend(
        incidentType: incidentType!,
        type: type,
        description: description,
        rerouting: rerouting == 'Yes',
      ).then((response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form submitted successfully!')),
        );
        setState(() {
          _formSubmitted = true; // Set the state variable to true
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit the form: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issues Form'),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 179, 177, 177).withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: _formSubmitted
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Form submitted successfully.'),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 50.0,
                              vertical: 15.0,
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Close the form page
                          },
                          child: Text('Back'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Issues Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: [
                            RadioListTile<String>(
                              title: Text('Accident'),
                              value: 'Accident',
                              groupValue: incidentType,
                              onChanged: (value) {
                                setState(() {
                                  incidentType = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: Text('Malfunction'),
                              value: 'Malfunction',
                              groupValue: incidentType,
                              onChanged: (value) {
                                setState(() {
                                  incidentType = value;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _typeController,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Do you want rerouting?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('Yes'),
                                value: 'Yes',
                                groupValue: rerouting,
                                onChanged: (value) {
                                  setState(() {
                                    rerouting = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('No'),
                                value: 'No',
                                groupValue: rerouting,
                                onChanged: (value) {
                                  setState(() {
                                    rerouting = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 50.0,
                                vertical: 15.0,
                              ),
                              textStyle: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            onPressed: _submitForm,
                            child: Text('Submit'),
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
