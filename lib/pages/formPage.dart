import 'package:driv2/network/formNetwork.dart';
import 'package:flutter/material.dart';


class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  String? incidentType;
  String? rerouting;
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final type = _typeController.text;
    final description = _descriptionController.text;

    if (incidentType != null && rerouting != null && type.isNotEmpty && description.isNotEmpty) {
      sendDataToBackend(
        incidentType: incidentType!,
        type: type,
        description: description,
        rerouting: rerouting == 'Yes',
      ).then((response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form submitted successfully!')),
        );
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
        title: Text('Incident Form'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Incident Type'),
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
                  labelStyle: TextStyle(fontSize: 15, color: Colors.black),
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
                  labelStyle: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
              SizedBox(height: 16.0),
              Text('Do you want rerouting?'),
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
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
