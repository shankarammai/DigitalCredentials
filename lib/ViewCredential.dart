import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart' as cryptolib;
import "package:pointycastle/export.dart" as pointyCastle;
import 'package:verifiable_credentials/services/file_read_write.dart';
import 'package:verifiable_credentials/services/key_generatation.dart';
import 'package:verifiable_credentials/services/secure_storage.dart';



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
  String? publicKeyPEM, privateKeyPEM, Uuid, fileContents,sharedKey;
  RSAPublicKey?  holderPublicKey, issuerPublicKey;
  RSAPrivateKey? holderPrivateKey;



  final SecureStorage secureStorage = SecureStorage();

  _ViewCredentialState(this.credentialDocument);

  Future<String> _getDataFromStorage(String Key) async {
    return (await secureStorage.readSecureData(Key)).toString();
  }

  Future<List> _load_Details() async{
    await _getDataFromStorage('publicKeyPEM').then((value) {
        publicKeyPEM = value.toString();
    });
    await _getDataFromStorage('Uuid').then((value) {
        Uuid = value.toString();
    });
    await _getDataFromStorage('privateKeyPEM').then((value) {
        privateKeyPEM = value.toString();
    });
    await readFile('credentials/'+this.credentialDocument).then((value) {
        fileContents = value.toString();
    });

    return [privateKeyPEM,publicKeyPEM,Uuid,fileContents];

  }

  @override
  void initState() {
    super.initState();
    dynamic _getDetails=_load_Details().whenComplete(() {
      holderPublicKey = cryptolib.RSAKeyParser().parse(this.publicKeyPEM!) as RSAPublicKey;
      holderPrivateKey = cryptolib.RSAKeyParser().parse(this.privateKeyPEM!) as RSAPrivateKey;

      var jsonFile=json.decode(this.fileContents!);
      var data_enc=jsonFile['credentialData']['data'];
      var sharedKey_enc=jsonFile['credentialData']['encryptionKey'];

      //Retrive the sharedKey
      final encryptDecrypt=cryptolib.Encrypter(cryptolib.RSA(publicKey: holderPublicKey,privateKey: holderPrivateKey,encoding: cryptolib.RSAEncoding.PKCS1));
      sharedKey=encryptDecrypt.decrypt(cryptolib.Encrypted.fromBase64(sharedKey_enc));
      print(sharedKey);
      
      final encrypter = cryptolib.Encrypter(cryptolib.AES(cryptolib.Key.fromUtf8(this.sharedKey!),mode:cryptolib.AESMode.cbc));
      String decryptedData=encrypter.decrypt64(data_enc,iv: cryptolib.IV.fromLength(16));
      print(decryptedData);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('View Credential')),
        body: Center(
          child:FutureBuilder<List>(
            future: _load_Details(),
            builder: (
                BuildContext context,
                AsyncSnapshot<List> snapshot,
                ) {
              print(snapshot.connectionState);

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {

                      return ListView(children: [Text((snapshot.data).toString())]);
                } else {
                  return const Text('Empty data');
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          )
        )
    );
  }
}
