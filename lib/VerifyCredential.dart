import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'services/secure_storage.dart';
import 'dart:developer' as developer;
import 'Activity.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ChooseIssuer.dart';
import 'widgets/CustomWidget.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class VerifyCredential extends StatefulWidget {
  VerifyCredential({Key? key}) : super(key: key);

  @override
  State<VerifyCredential> createState() => _VerifyCredentialState();
}


class _VerifyCredentialState extends State<VerifyCredential> {
  String _scanBarcode = 'Unknown';
  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

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
                  'Providing my details to the holder'),
              BarcodeWidget(
                barcode: Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high), // Barcode type and settings
                data: 'https://pub.dev/packages/barcode_widget', // Content
                width: 200,
                height: 200,
              ),
              ElevatedButton(
                onPressed: () {
                  scanQR();
                },
                child: const Text('Click Here to Read Data'),
              ),

            ],
          ),
        ));
  }
}
