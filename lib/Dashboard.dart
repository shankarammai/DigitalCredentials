import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:verifiable_credentials/DashboardStructure.dart';
import 'package:verifiable_credentials/services/file_read_write.dart';
import 'services/secure_storage.dart';
import 'dart:developer' as developer;
import 'Activity.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ChooseIssuer.dart';
import 'widgets/CustomWidget.dart';
import 'package:http/http.dart' as http;

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
  List cloudCredentails = [];
  List localCredentails = [];
  bool cloudCredentialsLoaded=false;
  bool localCredentialsLoaded=false;

  TextEditingController _textFieldController = TextEditingController();
  final SecureStorage secureStorage = SecureStorage();

  void _download_credential(filename, data) {
    //decode
    //decrypt the credential
    // now save
    dynamic configDetailsString = data;
    writeToFile(configDetailsString, filename + '.json');
    print('Credentail file downloaded');
  }

  Future<Iterable> _getAllLocalCredentials() async {
    dynamic directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    Directory newDirectory = Directory('${directory.path}/credentials');
    List entities = await newDirectory.list().toList();
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
      //getting all the Recently issued documents by issuer
      var url = Uri.parse(
          'https://shankarammai.com.np/VerifiableCredentials/public/api/getMyIssuedCredentials');
      var body = {'userUuid': value.toString()};
      var req = http.MultipartRequest('POST', url);
      req.fields.addAll(body);
      var res = req.send();
      res.then((response) async {
        final resBody = await response.stream.bytesToString();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final myClouddocs = json.decode(resBody);
          cloudCredentialsLoaded=true;
          setState(() {
            Uuid = value.toString();
            cloudCredentails = myClouddocs;
          });
        } else {
          print(response.reasonPhrase);
        }
      });
    });
    print(Uuid);
    super.initState();
    //gettting all the credentials saved locally
    _getAllLocalCredentials().then((value) {
      localCredentialsLoaded=true;
      setState(() {
        localCredentails = value.toList();
      });
    });
    print(localCredentails);
  }
  late BuildContext dialogcontext;
  void show_delete_loading(String id){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogcontext=context;
          bool deleteClicked=false;
          return StatefulBuilder(
              builder: (context,setState){
                return AlertDialog(
                  // The background color
                  backgroundColor: Colors.white,
                  title: Text('Confirmation'),
                  content: Text('Are you sure to delete'),
                  actions: [
                    Column(children: [
                      (deleteClicked)? Center(child:CircularProgressIndicator()):
                      Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                        TextButton(
                            onPressed:(){
                              setState((){
                                deleteClicked=true;
                              });
                              make_delete_request(id);}, //sending API request to delete
                            child: Icon(Icons.check_circle,size: 48,color: Colors.redAccent)),
                        TextButton(
                          onPressed:()=>Navigator.pop(context),
                          child: Icon(Icons.close,size: 48,color: Colors.grey,),)
                      ]),
                      TextButton(
                        onPressed:()=>Navigator.pop(context),
                        child: Text('Close'),)
                    ],
                    ),

                  ],
                );
              });

        });
  }

  void make_delete_request(String id){
    var request = new http.MultipartRequest(
        "POST",
        Uri.parse(
            "https://shankarammai.com.np/VerifiableCredentials/public/api/deleteMyCredential"));
    request.fields['delete_id'] = id;
    request.headers.addAll({"Content-type": "multipart/form-data"});
    var response = request.send();
    response.then((value) {
      response.then((responseback) async {
        final responseString = await responseback.stream.bytesToString();
        print(responseString);
        if (responseback.statusCode == 200) {
          Map responseJson = json.decode(responseString);
          if(responseJson['success']){
            //Removing Loading Screen
            Navigator.pop(dialogcontext);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    const DashboardStructure()));
          }
        }});
    });

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          backgroundColor: Colors.teal.shade500,
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Your  Credentials',
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.restart_alt_rounded,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const DashboardStructure()));
                    },
                  )
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.50,
                width: MediaQuery.of(context).size.width * 0.90,
                child: (!localCredentialsLoaded)? Center(child: CircularProgressIndicator()) :
                (localCredentails.isEmpty)?Center(child:Text('No Saved Credentials Found')):ListView(
                    itemExtent: 150,
                    children: localCredentails.map((credential) {
                      File credentialDoc = credential;
                      int fileIndex = localCredentails.indexOf(credential);
                      return ElevatedCard(
                          credentialName: credentialDoc.path.split('/').last,
                          fileIndex: fileIndex);
                    }).toList()),
              ),
              const Divider(
                color: Colors.grey,
                height: 15,
              ),
              Row(children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Recently Issued Cloud Credentials',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Spacer()
              ]),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.30,
                child:(!cloudCredentialsLoaded)? Center(child: CircularProgressIndicator()) :
                (cloudCredentails.isEmpty)?Center(child:Text('No Issued Credentials Found')):ListView(
                    scrollDirection: Axis.horizontal,
                    children: cloudCredentails.map((credential) {
                      var credData = credential["data"];
                      Map<String, dynamic> credJson = json.decode(credData); //only the credential data sent by issuer
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          color: Colors.grey.shade400,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text('Issued By',
                                    textAlign: TextAlign.left,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Text(credJson['issuer']['name']),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text('Created on',
                                    textAlign: TextAlign.left,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Text(credJson['proof']['created']),
                              SizedBox(
                                  width: 200,
                                  height: 25,
                                  child: Center(
                                    child: Text(''),
                                  )),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      print(credData);
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Document Name'),
                                              content: TextField(
                                                controller:
                                                    _textFieldController,
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
                                                          credData);
                                                      print(_textFieldController
                                                          .text);
                                                          Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                          builder: (context) =>
                                                          const DashboardStructure()));

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
                                    onPressed: () {
                                      show_delete_loading(credential['uuid']);
                                    },
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
