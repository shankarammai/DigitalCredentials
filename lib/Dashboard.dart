import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:verifiable_credentials/services/file_read_write.dart';
import 'services/secure_storage.dart';
import 'dart:developer' as developer;
import 'Activity.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ChooseIssuer.dart';
import 'widgets/CustomWidget.dart';

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
  List cloudCredentails = ['{"ss":"a"}'];
  List localCredentails = [];
  TextEditingController _textFieldController = TextEditingController();
  final SecureStorage secureStorage = SecureStorage();

  void _download_credential(filename, data) {
    //decode
    //decrypt the credential
    // now save
    dynamic configDetailsString = jsonEncode(data);
    writeToFile(configDetailsString, filename + '.json');
    print('Credentail file downloaded');
  }

  Future<Iterable> _getAllLocalCredentials() async {
    dynamic directory =Platform.isAndroid  ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
    Directory newDirectory=Directory('${directory.path}/credentials');
    List entities= await newDirectory.list().toList();
    return entities.whereType<File>();
  }

  @override
  void initState() {
    secureStorage.readSecureData("publicKeyPEM").then((value) {
      setState(() {
        publicKeyPEM = value.toString();
      });

    });
    secureStorage.readSecureData("privateKeyPEM").then((value) {
      setState(() {
        privateKeyPEM = value.toString();
      });

    });
    secureStorage.readSecureData("Uuid").then((value) {
      setState(() {
        Uuid = value.toString();
      });

    });
    print("Dashboard ");
    print(publicKeyPEM);
    print(Uuid);
    super.initState();
    _getAllLocalCredentials().then((value) {
      setState(() {localCredentails=value.toList();});
    });
    print(localCredentails);



    FirebaseFirestore.instance
        .collection('issuedDocuments')
        .where('holderUuid', isEqualTo: Uuid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> docData = {'id': doc.id, 'data': data};
        cloudCredentails.add(docData);
        print(cloudCredentails);
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.50,
                width: MediaQuery.of(context).size.width * 0.95,
                child: ListView(
                    itemExtent: 150,
                    children:localCredentails.map((credential) {
                            File credentialDoc=credential;
                            int fileIndex=localCredentails.indexOf(credential);
                              return ElevatedCard(credentialName: credentialDoc.path.split('/').last,fileIndex:fileIndex);
                    }).toList()
                    ),
              ),
              const Divider(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: cloudCredentails.map((credential) {
                      return Card(

                          child: Column(
                        children: [
                          const SizedBox(
                            width: 200,
                            height: 150,
                            child: Center(child: Text('Elevated Card')),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  shape: CircleBorder(),
                                ),
                                child: const Icon(
                                  Icons.download,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  var text = '''{
            "issuer": {
              "uuid": "",
              "publicKey": "",
              "name": "", //optional
              "website": ""
            },
            "credentialSubject": {
              "uuid": "",
              "publicKey": ""
            },
            "proof": {
              "type": "",
              "created": "",
              "proofValue": ""
            },
            "credentialData": {
              "data": "",
              "encryptionKey": "",
              "encryptionType": "",
              "fields": [],
              "selectiveFieldsproof": {
                "field1": "",
                "field2": ""
              }
            }
          }
          ''';
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Document Name'),
                                          content: TextField(
                                            controller: _textFieldController,
                                            decoration: InputDecoration(
                                                hintText:
                                                    "Enter Document Name"),
                                          ),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              child: Text('Save'),
                                              onPressed: () {
                                                setState(() {
                                                  _download_credential(
                                                      "credentials/" +
                                                          _textFieldController
                                                              .text,
                                                      "data");
                                                  print(_textFieldController
                                                      .text);
                                                  Navigator.pop(context);
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  shape: CircleBorder(),
                                ),
                                child: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ));
                    }).toList()),
              ),
            ],
          ),
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
