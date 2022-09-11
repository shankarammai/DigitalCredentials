import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'services/key_generatation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'services/file_read_write.dart';
import 'services/secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool showDownloadOptions = false;
  bool generateClicked = false;
  TextEditingController _controller = new TextEditingController(text: '');
  var privateKeyPEM, publicKeyPEM, UUIDNumber;
  final SecureStorage secureStorage = SecureStorage();
  //Creating credentials folder to save credential documents
  void _create_credentials_folder() async{
    dynamic directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final Directory _CredentialDirFolder = Directory('${directory.path}/credentials/');
    //create the credentials folder
      final Directory _appDocDirNewFolder =
      await _CredentialDirFolder.create(recursive: true);
  }
//saving config into a file
  void _save_config_to_file(
      [String saveLocation = "VerifiableCredentails_config.json"]) {
    var configDetails = {
      "Uuid": UUIDNumber,
      "privateKeyPEM": privateKeyPEM,
      "publicKeyPEM": publicKeyPEM
    };
    dynamic configDetailsString = jsonEncode(configDetails);
    writeToFile(configDetailsString, saveLocation);
    print('saving file locally done');
  }
  //saving config in secure storage
  void _save_config() {
    print('Saving Configuration');

    final writeprivate = secureStorage
        .writeSecureData(StorageItem('privateKeyPEM', privateKeyPEM));
    final writepublic = secureStorage
        .writeSecureData(StorageItem('publicKeyPEM', publicKeyPEM));
    final UUID = Uuid();
    UUIDNumber = UUID.v4(); //UUID.v5('publicKeyPEM', publicKeyPEM);
    final writeuuid =
        secureStorage.writeSecureData(StorageItem('Uuid', UUIDNumber));
    Future.wait([writeprivate, writepublic, writeuuid]).then((value) => {
          secureStorage
              .writeSecureData(StorageItem('registered', 'true'))
              .then((value) {
            print('config saved in secure storage');
          })
        });
  }
  //Generating keys
  Future<List>_generate_keys() async {
    print("Generating keys");
    // Generating Keys
    final keypair = CryptoUtils.generateRSAKeyPair();
    final publicKey = keypair.publicKey as RSAPublicKey; // to get public
    final privateKey =
        keypair.privateKey as RSAPrivateKey; // to get the private key
    publicKeyPEM = CryptoUtils.encodeRSAPublicKeyToPem(publicKey);
    privateKeyPEM = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
    _controller.clear();
    _controller.text = privateKeyPEM;
    //Key Generation Completed
    print("Key done!!");
    // Key Generation Completed
    return [publicKeyPEM, privateKeyPEM];
  }

  //Action when generate button is clicked
  void _generate_btn_clicked(){

    setState((){
      generateClicked = true;
    });
    print('generate keys clicked');
    Future.delayed(const Duration(milliseconds: 500), () {
      _generate_keys().then((value) {
        _save_config();
        _save_config_to_file();
        _create_credentials_folder();
        setState(() {
          showDownloadOptions = true;
          generateClicked = false;
        });
      });
    });




      }

   //UI to build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register',
      theme: ThemeData(primaryColor: Colors.greenAccent),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Your Digital ID'),
          backgroundColor: Colors.teal.shade500,
        ),
        body: Center(
            child: ListView(children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrangeAccent,
                        minimumSize: Size.fromHeight(50)),
                    child: (!generateClicked)? Text(
                            'Generate Keys',
                            style: TextStyle(fontSize: 24),
                          )
                        :Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 15),
                          Text("Please Wait ..")
                        ]), // <-- Text
                    onPressed: _generate_btn_clicked,
                                        ),
                ]),
              ),
                    Visibility(
                      // maintainSize: true,
                      // maintainAnimation: true,
                      // maintainState: true,
                      visible: showDownloadOptions,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextField(
                            textAlign: TextAlign.center,
                            controller: _controller,
                            minLines: 10,
                            maxLines: 10,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(20.0)),
                          ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  FloatingActionButton.extended(
                                      icon: const Icon(
                                        Icons.download,
                                        size: 24.0,
                                      ),
                                      backgroundColor: Colors.blueGrey,
                                      onPressed: () {
                                        //Todo: Save to downloads folder
                                        _save_config_to_file(
                                            "VerifiableCredentails_config_backup.json");
                                        var snackBar = SnackBar(
                                            content: Text('Config Saved'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                      label: const Text('Save Config as File')),
                                ]),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.lightBlue.shade400,
                                    minimumSize: Size.fromHeight(50)),
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(fontSize: 24),
                                ), // <-- Text
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/dashboard');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )

            ],
          ),
        ])),
      ),
    );
  }
}
