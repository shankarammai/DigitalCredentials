import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'services/secure_storage.dart';
import 'dart:developer' as developer;
import 'Activity.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ChooseIssuer.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin {
  String privateKeyPEM = "";
  String publicKeyPEM = "";
  String Uuid = "";
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    secureStorage.readSecureData("publicKeyPEM").then((value) {
      publicKeyPEM = value.toString();
    });
    secureStorage.readSecureData("privateKeyPEM").then((value) {
      privateKeyPEM = value.toString();
    });
    secureStorage.readSecureData("Uuid").then((value) {
      Uuid = value.toString();
    });
    print("Dashboard ");
    print(publicKeyPEM);
    print(Uuid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: Center(child: Text('Dashboard')));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}