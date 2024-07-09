import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:drivchat/page/driverChatPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(DriverApp());
}

class DriverApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DriverChatPage(passengerName: 'passenger_unique_user_id'),
    );
  }
}
