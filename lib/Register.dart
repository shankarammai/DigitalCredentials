import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'services/key_generatation.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'services/file_read_write.dart';
import 'services/secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool showDownloadOptions = false;
  bool progressLoading = false;
  bool generateClicked = false;
  TextEditingController _controller = new TextEditingController(text: '');
  var privateKeyPEM, publicKeyPEM, UUID;
  final SecureStorage secureStorage = SecureStorage();

  void _writeJson(String key, dynamic value, dynamic fileSavePath) async {
    developer.log('path: ' +fileSavePath ,
        name: 'Register File');
    File filepath=File(fileSavePath);
    Map<String, dynamic> _json = {};
    String _jsonString;
    // Initialize the local _filePath
    //final _filePath = await _localFile;

    Map<String, dynamic> _newJson = {key: value};
    print('1.(_writeJson) _newJson: $_newJson');

    //2. Update _json by adding _newJson<Map> -> _json<Map>
    _json.addAll(_newJson);
    print('2.(_writeJson) _json(updated): $_json');

    //3. Convert _json ->_jsonString
    _jsonString = jsonEncode(_json);
    print('3.(_writeJson) _jsonString: $_jsonString\n - \n');

    //4. Write _jsonString to the _filePath
    filepath.writeAsString(_jsonString);
  }

  void _save_config_locally() {
    secureStorage
        .containsKeyInSecureData("registered")
        .then((value) => print(value));

    print('downloaded key locally');
    writeToFile('this is test file', 'VC_config_file.txt');

    // Future<String> myfilepath = getFilePath('VC_config_file');
    // myfilepath.then((filelocation) {
    //   _writeJson("Uuid", Uuid, filelocation);
    //   _writeJson("privateKeyPEM", privateKeyPEM, filelocation);
    //   _writeJson("publicKeyPEM", publicKeyPEM, filelocation);
    // });

    // var configDetails = {
    //   "Uuid": Uuid,
    //   "privateKeyPEM": privateKeyPEM,
    //   "publicKeyPEM": publicKeyPEM
    // };
    // dynamic configDetailsString = jsonEncode(configDetails);
    // myfilepath.writeAsString(configDetailsString);
    print('saving file locally done');
  }

  void _save_config() {
    print('Saving Configuration');

    final writeprivate = secureStorage
        .writeSecureData(StorageItem('privateKeyPEM', privateKeyPEM));
    final writepublic = secureStorage
        .writeSecureData(StorageItem('privateKeyPEM', publicKeyPEM));
    final UUID = Uuid();
    var uuid = UUID.v4(); //UUID.v5('publicKeyPEM', publicKeyPEM);
    final writeuuid = secureStorage.writeSecureData(StorageItem('Uuid', uuid));
    Future.wait([writeprivate, writepublic, writeuuid]).then((value) => {
          secureStorage
              .writeSecureData(StorageItem('registered', 'true'))
              .then((value) => {print('config saved in secure storage')})
        });
  }

  Future<List> _generate_keys() async {
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
    _save_config();
    print("Saving Config done!!");
    return [publicKeyPEM, privateKeyPEM];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register',
      theme: ThemeData(primaryColor: Colors.greenAccent),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Your Digital ID'),
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
                        primary: Colors.lightBlue.shade400,
                        minimumSize: Size.fromHeight(50)),
                    child: const Text(
                      'Generate Keys',
                      style: TextStyle(fontSize: 24),
                    ), // <-- Text
                    onPressed: () async {
                      setState(() {
                        progressLoading = true;
                        generateClicked = true;
                      });
                      final generateKey = _generate_keys();
                      generateKey.then((value) => {
                            setState(() {
                              progressLoading = false;
                              showDownloadOptions = true;
                            })
                          });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: (progressLoading)
                        ? const Text('Please Wait...')
                        : const Text(
                            'Key Generation might take some time please wait after pressing on generate keys....'),
                  ),
                ]),
              ),
              Visibility(
                  visible: generateClicked,
                  child: Column(children: <Widget>[
                    Center(
                        child: (progressLoading)
                            ? const SpinKitRotatingCircle(
                                color: Colors.white,
                                size: 50.0,
                              )
                            : const Text('')),
                    TextField(
                      textAlign: TextAlign.center,
                      controller: _controller,
                      minLines: 10,
                      maxLines: 10,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20.0)),
                    ),
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: showDownloadOptions,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
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
                                        _save_config_locally();
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
                                  Navigator.pushNamed(context, '/dashboard');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ])),
            ],
          ),
        ])),
      ),
    );
  }
}
