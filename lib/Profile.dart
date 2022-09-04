import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:verifiable_credentials/services/secure_storage.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final SecureStorage secureStorage = SecureStorage();
  late String publicKeyPEM, privateKeyPEM, uuid;
  TextEditingController publicKeyPEMController= TextEditingController();
  TextEditingController privatePEMController= TextEditingController();
  TextEditingController uuidController= TextEditingController();


  @override
  void initState(){
    super.initState();
    secureStorage.readSecureData("publicKeyPEM").then((value) {
      setState(() {
        publicKeyPEM = value.toString();
        publicKeyPEMController.text=publicKeyPEM;
      });
    });
    secureStorage.readSecureData("privateKeyPEM").then((value) {
      setState(() {
        privateKeyPEM = value.toString();
        privatePEMController.text=privateKeyPEM;

      });
    });
    secureStorage.readSecureData("Uuid").then((value) {
      setState(() {
        uuid = value.toString();
        uuidController.text=uuid;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            centerTitle: true,
            backgroundColor: Colors.teal.shade500,

          ),
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: publicKeyPEMController,
                readOnly: true,
                minLines: 10,
                maxLines: 10,
                decoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('My Public Key'))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                minLines: 10,
                maxLines: 10,
                readOnly: true,
                controller: privatePEMController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('My Private Key'))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                readOnly: true,
                controller: uuidController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('My UUID'))),
          ),
        ],)
      ),
    );
  }
}
