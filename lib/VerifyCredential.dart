import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:encrypt/encrypt.dart' as cryptolib;
import 'package:cool_alert/cool_alert.dart';
import 'package:http/http.dart' as http;

class VerifyCredential extends StatefulWidget {
  VerifyCredential({Key? key}) : super(key: key);

  @override
  State<VerifyCredential> createState() => _VerifyCredentialState();
}

class _VerifyCredentialState extends State<VerifyCredential> {
  String scanBarcode = '';
  QRViewController? controller;
  Barcode? result;
  bool showCamera = true;
  bool showWidgets = false;
  late Map jsonQR;
  late Map credentialDoc;
  String? decryptionKey;
  String? presentedCredentialData;
  List<Widget> documentWidgets = [];

  void scanQR(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        showCamera = false;
        try {
          jsonQR = json.decode(event.code.toString());

          //get the id and key
          String documentId = jsonQR['docLink'];
          decryptionKey = (jsonQR['decryptionKey']);
          String QRtype = jsonQR['QRtype'];
          print('Document Id >>>>>>>>>>>>>>' + documentId);
          //get data from service provider

          final response = http.get(Uri.parse(documentId));
          response.then((responseback)  {
            if(responseback.statusCode==200){
              final responseJson = json.decode(responseback.body);
              credentialDoc=jsonDecode(responseJson["data"]);
              print(credentialDoc);
              print(credentialDoc['credentialData']);
                //decrypt it
                final encrypter = cryptolib.Encrypter(cryptolib.AES(
                    cryptolib.Key.fromUtf8(this.decryptionKey.toString()),
                    mode: cryptolib.AESMode.cbc));
                final base64encData = cryptolib.Encrypted.fromBase64(
                    credentialDoc['credentialData']['data']);
                final iv = 'ThisIsASecuredBlock'.substring(0, 16);
                presentedCredentialData = encrypter.decrypt(base64encData,
                    iv: cryptolib.IV.fromUtf8(iv));
                print(presentedCredentialData);

                //Make widget to show the credentails
                Map<String, dynamic> credentialDataJson =
                json.decode(presentedCredentialData!);
                documentWidgets = [];

                credentialDataJson.forEach((key, value) {
                  documentWidgets
                      .add(Divider(height: 30.0, color: Colors.grey[800]));
                  documentWidgets.add(Text(
                    key.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.orange,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                      fontSize: 20.0,
                    ),
                  ));

                  documentWidgets.add(Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black,
                      letterSpacing: 2.0,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ));
                });
                documentWidgets.add(
                  ElevatedButton(
                    child: const Text('Verify Document'),
                    onPressed: () {
                      var verifierPublicKey = cryptolib.RSAKeyParser()
                          .parse(credentialDoc['issuer']['publicKey'])
                      as RSAPublicKey;
                      var signer = cryptolib.Signer(cryptolib.RSASigner(
                          cryptolib.RSASignDigest.SHA256,
                          publicKey: verifierPublicKey));
                      bool signResult=false;
                      if(QRtype=='full') {
                        signResult = signer.verify64(
                            presentedCredentialData!,
                            credentialDoc['proof']['proofValue']);
                        print(credentialDoc['proof']['proofValue']);
                        print("Signature Result >> " + signResult.toString());
                      }
                      if(QRtype=='individual') {
                        signResult=true;
                        Map<String,dynamic> proofs=Map.from(credentialDoc['credentialData']['selectiveFieldsproof']);
                        proofs.forEach((key, value) {
                          signResult = signResult && signer.verify64(
                              credentialDataJson[key],
                              value);
                          print("Signature Result >> " + key  + " >" + signResult.toString());
                        });
                      }

                      if (signResult) {
                        CoolAlert.show(
                          context: context,
                          animType: CoolAlertAnimType.rotate,
                          title: "Verified",
                          type: CoolAlertType.success,
                          widget: Text(
                              'Issued by: ' + credentialDoc['issuer']['name']),
                          //Retrive from Database to check whose public key is it
                        );
                      } else {
                        CoolAlert.show(
                          context: context,
                          animType: CoolAlertAnimType.rotate,
                          title: "Invalid",
                          type: CoolAlertType.error,
                          text: "Signature Not Valid",
                        );
                      }
                    },
                  ),
                );
                documentWidgets.add(SizedBox(height: 80));

                setState(() {});

            }
            // if response status is not 200
            else{
              showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Error  '),
                    content: Text('Something went wrong with provider'),
                  )
              );
            }
          });

        } catch (e) {
          print(e);
          scanBarcode = "Invalid QR for this application";
          showCamera = false;
          showWidgets = true;
        }
        print(documentWidgets);

        scanBarcode = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Credential'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(children: [
          Column(
            children: [
              Text(this.scanBarcode),
              Visibility(
                  visible: showCamera,
                  child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width - 100,
                      child:
                          QRView(key: GlobalKey(), onQRViewCreated: scanQR))),
              Column(children: documentWidgets)
            ],
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            showCamera = true;
            documentWidgets = [];
          });
        },
        icon: Icon(
          Icons.qr_code_scanner,
          size: 29,
        ),
        backgroundColor: Colors.cyan,
        label: const Text('Start Scan'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
