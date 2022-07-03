import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Dashboard.dart';
import 'Register.dart';
import 'package:flutter/foundation.dart';
import 'services/secure_storage.dart';
import 'dart:developer' as developer;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Verifiable Credential';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      routes: {
        '/register': (BuildContext context) => Register(),
        '/dashboard': (BuildContext context) => Dashboard(),
      },
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _count = 0;
  String _title = "Verifiable Credential";
  bool _isRegistered = false;

  // Create storage
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    //Load from Storage, check if is registered for the first time,
    //if yes then navigate to the Dashboard otherwise show register page
    secureStorage.containsKeyInSecureData('registered').then((value) {
      _isRegistered = value;
      if (_isRegistered) {
        developer.log('isRegistered: ' + _isRegistered.toString(),
            name: 'Main File');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
                developer.log('isRegistered: ' + _isRegistered.toString(),
            name: 'Main File');
        Navigator.pushReplacementNamed(context, '/register');
      }
      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Loading')),
    );
  }
}
