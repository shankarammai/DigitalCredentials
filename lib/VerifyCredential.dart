import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'services/secure_storage.dart';
import 'dart:developer' as developer;
import 'Activity.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ChooseIssuer.dart';
import 'widgets/CustomWidget.dart';
import 'package:barcode_widget/barcode_widget.dart';

class VerifyCredential extends StatefulWidget {
  VerifyCredential({Key? key}) : super(key: key);

  @override
  State<VerifyCredential> createState() => _VerifyCredentialState();
}

class _VerifyCredentialState extends State<VerifyCredential> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose Issuer'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                  'Providing my details to the holder so i can only get the data'),
            ],
          ),
        ));
  }
}
