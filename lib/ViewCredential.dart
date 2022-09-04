import 'dart:convert';
import 'dart:io';
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
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import 'Activity.dart';

class ViewCredential extends StatefulWidget {
  final String credentailDocument;
  const ViewCredential({Key? key, required this.credentailDocument})
      : super(key: key);

  @override
  State<ViewCredential> createState() =>
      _ViewCredentialState(this.credentailDocument);
}

class _ViewCredentialState extends State<ViewCredential> {
  List allcreatedQR=[];
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

    secureStorage.containsKeyInSecureData(this.credentialDocument).then((value) async {
     if(value){
       await _getDataFromStorage(this.credentialDocument).then((value) {
         allcreatedQR = json.decode(value);
       });
     }
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
  download_credential(credentialDoc, String credentialDocument,type){
    dynamic downloadDetailsString = jsonEncode(credentialDoc);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    writeToFile(downloadDetailsString, "/downloads/" +credentialDocument.split('.').first +type + formattedDate +'.json');
    print('Downloaded');

  }
  _show_selected_qr() async {
    var sendData = credentialDocumentJson;
    //get all the fields then encrypt it
    //Only show selected Fields
    Map<String, dynamic> credentialData_map = Map();
    Map<String, dynamic> selectiveProofsToShow = Map();

    credentialDataJson.forEach((key, value) {
      if (selectedFields.contains(key)) {
        credentialData_map[key] = value;
        Map<String, dynamic> selectiveProofsValues =
            credentialDocumentJson["credentialData"]['selectiveFieldsproof'];
        selectiveProofsToShow[key] = selectiveProofsValues[key];
        credentialData_map[key] = value;
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
    String enc_Credential = encrypter
        .encrypt(json.encode(credentialData_map), iv: cryptolib.IV.fromUtf8(iv))
        .base64;

    dynamic credentailDetails = {
      'data': enc_Credential,
      'selectiveFieldsproof': selectiveProofsToShow
    };
    sendData.remove("credentialData");
    sendData['credentialData'] = credentailDetails;

    var request = new http.MultipartRequest(
        "POST",
        Uri.parse(
            "https://shankarammai.com.np/VerifiableCredentials/public/api/saveShowCredential"));
    request.fields['data'] = json.encode(sendData);
    request.headers.addAll({"Content-type": "multipart/form-data"});
    var response = request.send();
    print("Request Sent!");
    response.then((response) async {
      final responseString = await response.stream.bytesToString();
      print(responseString);
      if (response.statusCode == 200) {
        Map responseJson = json.decode(responseString);

          /*
     * decryptionKey = key to decrypt the encrypted data
     * docLink = document ID firebase, or API key
     * QRtype= full => all credentail, individual => individual fields
     * */
          Map<String, dynamic> dataForQR = {
            'decryptionKey': verifierEnckey,
            'docLink':
                "https://shankarammai.com.np/VerifiableCredentials/public/api/showCredential/" +
                    responseJson["docId"],
            'QRtype': 'individual'
          };
          showDialog(
            barrierColor: Colors.white24,
              barrierLabel: 'label',
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
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
                        onPressed: (){
                          // Map<String,dynamic> credentialDocToDownload =Map();
                              var credentialDocToDownload= credentialDocumentJson;
                          credentialDocToDownload.remove('credentialData');
                          dynamic credentialDataToDownload = {
                            'data': credentialData_map,
                            'selectiveFieldsproof': selectiveProofsToShow
                          };;
                          credentialDocToDownload["credentialData"]=credentialDataToDownload;
                          download_credential(credentialDocToDownload,this.credentialDocument,'individual');
                        },
                        child: Text('Download For Web'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('DONE'),
                      ),
                      
                    ],
                  )
          );
          //Save the ID to see who accessed it.
              allcreatedQR.add(responseJson["docId"]);
              secureStorage.deleteSecureData(this.credentialDocument);
              secureStorage.writeSecureData(StorageItem(credentialDocument, json.encode(allcreatedQR)));
      }
    });
  }

  _show_full_qr() {
    Map<String, dynamic> sendData = new Map.from(credentialDocumentJson);
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

    var request = new http.MultipartRequest(
        "POST",
        Uri.parse(
            "https://shankarammai.com.np/VerifiableCredentials/public/api/saveShowCredential"));
    request.fields['data'] = json.encode(sendData);
    request.headers.addAll({"Content-type": "multipart/form-data"});
    var response = request.send();
    print("Request Sent!");
    response.then((response) async {
      final responseString = await response.stream.bytesToString();
      print(responseString);
      if (response.statusCode == 200) {
        Map responseJson = json.decode(responseString);
          /*
     * decryptionKey = key to decrypt the encrypted data
     * documentId = document ID firebase, or API key
     * QRtype= full => all credentail, individual => individual fields
     * */
          Map<String, dynamic> dataForQR = {
            'decryptionKey': verifierEnckey,
            'docLink':
                "https://shankarammai.com.np/VerifiableCredentials/public/api/showCredential/" +
                    responseJson["docId"],
            'QRtype': 'full'
          };
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
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
                      onPressed: (){
                        // Map<String,dynamic> credentialDocToDownload =Map();
                        var credentialDocToDownload= credentialDocumentJson;
                        credentialDocToDownload.remove('credentialData');
                        dynamic credentialDataToDownload = {
                          'data': credentialDataJson,
                        };;
                        credentialDocToDownload["credentialData"]=credentialDataToDownload;
                        download_credential(credentialDocToDownload,this.credentialDocument,'full');
                      },
                      child: Text('Download For Web'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('DONE'),
                    ),
                  ],
                ));
        //Save the ID to see who accessed it.
        allcreatedQR.add(responseJson["docId"]);
        secureStorage.deleteSecureData(this.credentialDocument);
        secureStorage.writeSecureData(StorageItem(credentialDocument, json.encode(allcreatedQR)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('View Credential'),
            backgroundColor: Colors.teal.shade500),
        body: ListView(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                onPressed: _show_selected_qr,
                label: Text('Selected fields QR'),
                icon: Icon(Icons.qr_code_2_rounded),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                onPressed: _show_full_qr,
                label: Text('Full credential QR'),
                icon: Icon(Icons.qr_code_2_rounded),
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Activity(allcreatedQR: allcreatedQR))
              );
              },
            label: Text('Activities'),
            icon: Icon(Icons.format_line_spacing_sharp),
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
                              height: 8.0,
                              color: Colors.grey[800],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0),
                                  child: Text(
                                    e.key.toString(),
                                    style: TextStyle(
                                      letterSpacing: 1.0,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Checkbox(
                                      value:
                                          this.selectedFields.contains(e.key),
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
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                e.value,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
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
          ),
        ]));
  }
}
