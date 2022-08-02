import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart' as cryptolib;
import "package:pointycastle/export.dart" as pointyCastle;
import 'package:verifiable_credentials/services/file_read_write.dart';
import 'package:verifiable_credentials/services/key_generatation.dart';
import 'package:verifiable_credentials/services/secure_storage.dart';
import 'dart:developer' as developer;

class ViewCredential extends StatefulWidget {
  final String credentailDocument;
  const ViewCredential({Key? key, required this.credentailDocument})
      : super(key: key);

  @override
  State<ViewCredential> createState() =>
      _ViewCredentialState(this.credentailDocument);
}

class _ViewCredentialState extends State<ViewCredential> {
  final String credentialDocument;
  late String publicKeyPEM,
      privateKeyPEM,
      Uuid,
      fileContents,
      sharedKey,
      credentialData;
  RSAPublicKey? holderPublicKey, issuerPublicKey;
  RSAPrivateKey? holderPrivateKey;
  List selectedFields = [];
  late Map<String, dynamic> credentialDataJson, credentialDocumentJson;

  final SecureStorage secureStorage = SecureStorage();

  _ViewCredentialState(this.credentialDocument);

  Future<String> _getDataFromStorage(String Key) async {
    return (await secureStorage.readSecureData(Key)).toString();
  }

  Future<List> _load_Details() async {
    await _getDataFromStorage('publicKeyPEM').then((value) {
      publicKeyPEM = value.toString();
    });
    await _getDataFromStorage('Uuid').then((value) {
      Uuid = value.toString();
    });
    await _getDataFromStorage('privateKeyPEM').then((value) {
      privateKeyPEM = value.toString();
    });
    await readFile('credentials/' + this.credentialDocument).then((value) {
      fileContents = value.toString();
    });

    return [privateKeyPEM, publicKeyPEM, Uuid, fileContents];
  }

  @override
  void initState() {
    super.initState();
    dynamic _getDetails = _load_Details().whenComplete(() {
      holderPublicKey =
          cryptolib.RSAKeyParser().parse(this.publicKeyPEM) as RSAPublicKey;
      holderPrivateKey =
          cryptolib.RSAKeyParser().parse(this.privateKeyPEM) as RSAPrivateKey;

      credentialDocumentJson = json.decode(this.fileContents);
      var data_enc = credentialDocumentJson['credentialData']['data'];
      var sharedKey_enc =
          credentialDocumentJson['credentialData']['encryptionKey'];

      //Retrive the sharedKey
      final encryptDecrypt = cryptolib.Encrypter(cryptolib.RSA(
          publicKey: holderPublicKey,
          privateKey: holderPrivateKey,
          encoding: cryptolib.RSAEncoding.PKCS1));
      sharedKey =
          encryptDecrypt.decrypt(cryptolib.Encrypted.fromBase64(sharedKey_enc));
      print(sharedKey);

      final encrypter = cryptolib.Encrypter(cryptolib.AES(
          cryptolib.Key.fromUtf8(this.sharedKey),
          mode: cryptolib.AESMode.cbc));
      final base64encData = cryptolib.Encrypted.fromBase64(data_enc);
      final iv = 'ThisIsASecuredBlock'.substring(0, 16);
      credentialData =
          encrypter.decrypt(base64encData, iv: cryptolib.IV.fromUtf8(iv));
      print(credentialData);


      // setState(() {});
    });
  }

  _show_selected_qr() {

    var sendData = credentialDocumentJson;
    //get all the fields then encrypt it
    //Only show selected Fields
    Map<String, dynamic> credentialData_map = Map();
    Map<String, dynamic> selectiveProofsToShow = Map();

    credentialDataJson.forEach((key, value) {
      if(selectedFields.contains(key)){
        credentialData_map[key]=value;
        Map<String, dynamic> selectiveProofsValues = credentialDocumentJson["credentialData"]['selectiveFieldsproof'];
        selectiveProofsToShow[key]=selectiveProofsValues[key];
        credentialData_map[key]=value;
      }
    });

    sendData.remove('credentialData');

    //Encrypting information
    //random String
    String verifierEnckey = String.fromCharCodes(
        List.generate(16, (index) => Random().nextInt(33) + 89));
    final encrypter = cryptolib.Encrypter(cryptolib.AES(
        cryptolib.Key.fromUtf8(verifierEnckey),
        mode: cryptolib.AESMode.cbc));
    final iv = 'ThisIsASecuredBlock'.substring(0, 16);
    String enc_Credential =
        encrypter.encrypt(json.encode(credentialData_map), iv: cryptolib.IV.fromUtf8(iv)).base64;

    dynamic credentailDetails = {'data': enc_Credential,'selectiveFieldsproof':selectiveProofsToShow};
    sendData.remove("credentialData");
    sendData['credentialData']=credentailDetails;





    CollectionReference showCredentials =
    FirebaseFirestore.instance.collection('ShowCredential');
    showCredentials.add(sendData).then((value) => {
      Navigator.of(context)
          .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        /*
     * decryptionKey = key to decrypt the encrypted data
     * documentId = document ID firebase, or API key
     * QRtype= full => all credentail, individual => individual fields
     * */
        Map<String, dynamic> dataForQR = {
          'decryptionKey': verifierEnckey,
          'documentId': value.id,
          'QRtype': 'individual'
        };
        return AlertDialog(
          title: Text('Scan this QR'),
          content: Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: BarcodeWidget(
                barcode: Barcode.qrCode(
                    errorCorrectLevel: BarcodeQRCorrectionLevel
                        .high), // Barcode type and settings
                data: jsonEncode(dataForQR), // Content
                width: 200,
                height: 200,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('DONE'),
            ),
          ],
        );
      }))
    });

  }

  _show_full_qr() {
    Map<String,dynamic> sendData = new Map.from(credentialDocumentJson);
    sendData.remove('credentialData');
    Map<String, dynamic> credentialData_map = Map();

    //Encrypting information
    //random String
    String verifierEnckey = String.fromCharCodes(
        List.generate(16, (index) => Random().nextInt(33) + 89));
    final encrypter = cryptolib.Encrypter(cryptolib.AES(
        cryptolib.Key.fromUtf8(verifierEnckey),
        mode: cryptolib.AESMode.cbc));
    final iv = 'ThisIsASecuredBlock'.substring(0, 16);
    String enc_Credential =
        encrypter.encrypt(credentialData, iv: cryptolib.IV.fromUtf8(iv)).base64;

    dynamic credentailDetails = {'data': enc_Credential};
    credentialData_map['credentialData'] = credentailDetails;
    sendData.addAll(credentialData_map);

    CollectionReference showCredentials =
        FirebaseFirestore.instance.collection('ShowCredential');
    showCredentials.add(sendData).then((value) => {
          Navigator.of(context)
              .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
            /*
     * decryptionKey = key to decrypt the encrypted data
     * documentId = document ID firebase, or API key
     * QRtype= full => all credentail, individual => individual fields
     * */
            Map<String, dynamic> dataForQR = {
              'decryptionKey': verifierEnckey,
              'documentId': value.id,
              'QRtype': 'full'
            };
            return AlertDialog(
              title: Text('Scan this QR'),
              content: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  child: BarcodeWidget(
                    barcode: Barcode.qrCode(
                        errorCorrectLevel: BarcodeQRCorrectionLevel
                            .high), // Barcode type and settings
                    data: jsonEncode(dataForQR), // Content
                    width: 200,
                    height: 200,
                  )),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('DONE'),
                ),
              ],
            );
          }))
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('View Credential')),
        body: ListView(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                onPressed: _show_selected_qr,
                child: const Text('Show Selected '),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                onPressed: _show_full_qr,
                child: const Text('Show Full '),
              ),
            ],
          ),
          FutureBuilder<List>(
            future: _load_Details(),
            builder: (
              BuildContext context,
              AsyncSnapshot<List> snapshot,
            ) {
              print(snapshot.connectionState);

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  credentialDataJson = json.decode((this.credentialData));
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: credentialDataJson.entries.map((e) {
                        return Wrap(
                          children: [
                            Divider(
                              height: 30.0,
                              color: Colors.grey[800],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                    value: this.selectedFields.contains(e.key),
                                    onChanged: (newValue) {
                                      if (newValue == true) {
                                        setState(() {
                                          this.selectedFields.add(e.key);
                                        });
                                      } else {
                                        setState(() {
                                          this.selectedFields.remove(e.key);
                                        });
                                      }
                                      print(this.selectedFields);
                                    }),
                                Text(
                                  e.key.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.orange,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              e.value,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Colors.black,
                                letterSpacing: 2.0,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        );
                      }).toList());
                } else {
                  return const Text('Empty data');
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          )
        ]));
  }
}
