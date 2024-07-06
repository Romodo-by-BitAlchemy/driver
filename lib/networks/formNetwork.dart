import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendDataToBackend({
  required String incidentType,
  required String type,
  required String description,
  required bool rerouting,
  String? reroutingNewVehicleNo, 
  String? reroutingNewDriverNo,  
}) async {
  final url = Uri.parse('http://192.168.8.136:3000/api/issues');

  final body = {
    'incidentType': incidentType,
    'type': type,
    'description': description,
    'rerouting': rerouting,
  };

  if (rerouting) {
    if (reroutingNewVehicleNo == null || reroutingNewDriverNo == null) {
      throw Exception('Both reroutingNewVehicleNo and reroutingNewDriverNo must be provided when rerouting is true.');
    }
    body['reroutingNewVehicleNo'] = reroutingNewVehicleNo;
    body['reroutingNewDriverNo'] = reroutingNewDriverNo;
  }

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(body),
  );

  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Failed to submit form: ${response.body}');
  }
}







