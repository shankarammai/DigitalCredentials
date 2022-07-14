import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:verifiable_credentials/services/secure_storage.dart';






class ChooseIDDocuments extends StatefulWidget {
  final String issuerName;
  final String issuerPublicKeyPEM;
  final String documentAPI;
  ChooseIDDocuments(
      {Key? key,
      required this.documentAPI,
      required this.issuerName,
      required this.issuerPublicKeyPEM})
      : super(key: key);

  @override
  State<ChooseIDDocuments> createState() {
    return _ChooseIDDocumentsState(
        this.documentAPI, this.issuerName, this.issuerPublicKeyPEM);
  }
}

class _ChooseIDDocumentsState extends State<ChooseIDDocuments> {
  final String issuerName;
  final String issuerPublicKeyPEM;
  final String documentAPI;
  bool isSending = false;
  List<File> files = [];
  File? image;
  var holderPublicKeyPEM, holderUuid;
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    secureStorage.readSecureData("publicKeyPEM").then((value) {
      holderPublicKeyPEM = value.toString();
    });
    secureStorage.readSecureData("Uuid").then((value) {
      holderUuid = value.toString();
    });
  }

  _ChooseIDDocumentsState(
      this.documentAPI, this.issuerName, this.issuerPublicKeyPEM);

  Future _pickPicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imagepath = File(image.path);
    setState(() {
      files.add(imagepath);
    });
    print(files);
  }

  Future _takePicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    final imagepath = File(image.path);
    setState(() {
      files.add(imagepath);
    });
    print(files);
  }

  _send_documents() async {
    var request =new http.MultipartRequest("POST", Uri.parse(this.documentAPI));
    request.fields['holderPublicKeyPEM'] = this.holderPublicKeyPEM;
    request.fields['holderUuid'] = this.holderUuid;
    request.fields['totalFiles'] = files.length.toString();
    request.fields['returnAPI'] = 'this Will be the return API for credentials';
    Map<String, String> headers = {"Content-type": "multipart/form-data"};

    ///Adding all the image files
    for( var i = 0 ; i < files.length; i++ ) {
      File file=files[0];
      http.MultipartFile multipartFile= await http.MultipartFile.fromPath('file'+i.toString(),file.path);
      request.files.add(multipartFile);
    }
    request.headers.addAll(headers);

    try {
      var response = request.send();
      print("Request Sent!");
      response.then((response) async {
        final responseString=await response.stream.bytesToString();
        print(responseString);
        if (response.statusCode == 200){
          // final decodedResponse= jsonDecode(responseString);
          showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Request Sent'),
                content: Icon(Icons.verified_sharp,color: Colors.greenAccent),
              ));
          setState(() {
            isSending = false;
          });
        }
        else{
          print('error response');
          setState(() {
            isSending = false;
          });
          showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Error'),
                content: Icon(Icons.error_outlined,color: Colors.redAccent),
              ));
        }

      });
    } catch (err) {
      print(err);
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: const Text('Select ID Documents'), centerTitle: true),
        body: ListView(children: <Widget>[
          Column(children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  _pickPicture();
                },
                icon: const Icon(
                  Icons.image_rounded,
                  size: 24.0,
                ),
                label: const Text('Choose Picture'),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _takePicture();
                },
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  size: 24.0,
                ),
                label: const Text('Take Picture'),
              )
            ]),
            Wrap(
              spacing: 2.0, // gap between adjacent chips
              runSpacing: 5.0, // gap between lines
              children: files.map((filepath) {
                return InteractiveViewer(
                    child: Image.file(
                  filepath,
                  height: 150,
                  width: 150,
                ));
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              child: isSending
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 15),
                          Text("Please Wait ..")
                        ])
                  : const Text('Send Document'),
              onPressed: () {
                if (files.length < 1) {
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text('No Files Selected'),
                            content: Text('Please Select files to send'),
                          ));
                  return;
                }
                setState(() {
                  isSending = true;
                });
                _send_documents();

              },
            )
          ])
        ]));
  }
}
