import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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

  //Choosing picture from gallery
  Future _pickPicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imagepath = File(image.path);
    setState(() {
      files.add(imagepath);
    });
    print(files);
  }

  //Taking picture
  Future _takePicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    final imagepath = File(image.path);
    setState(() {
      files.add(imagepath);
    });
    print(files);
  }

  //Sending document to the issuer
  _send_documents() async {
    try {
    var request =new http.MultipartRequest("POST", Uri.parse(this.documentAPI));
    request.fields['holderPublicKeyPEM'] = this.holderPublicKeyPEM;
    request.fields['holderUuid'] = this.holderUuid;
    request.fields['totalFiles'] = files.length.toString();
    request.fields['returnAPI'] = 'https://shankarammai.com.np/VerifiableCredentials/api/sendCredential';
    Map<String, String> headers = {"Content-type": "multipart/form-data"};

    ///Adding all the image files
    for( var i = 0 ; i < files.length; i++ ) {
      File file=files[0];
      http.MultipartFile multipartFile= await http.MultipartFile.fromPath('file'+i.toString(),file.path);
      request.files.add(multipartFile);
    }
    request.headers.addAll(headers);


      var response = request.send();
      print("Request Sent!");
      response.then((response) async {
        //Removing Loading Alert
        Navigator.pop(context);
        final responseString=await response.stream.bytesToString();
        print(responseString);
        if (response.statusCode == 200){
           final decodedResponse= json.decode(responseString);
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Request Sent'),
                content: Icon(Icons.check_circle,color: Colors.greenAccent,size: 48,),
                actions: [ TextButton(
                    onPressed:()=>Navigator.pop(context),
                    child: Text('Close'),)],
              )
          );
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
              )

          );
        }

      });
    } on FormatException catch (ex){
      setState(() {
        isSending = false;
      });
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Error'),
            content: Icon(Icons.error_outlined,color: Colors.redAccent),
          )
      );
    }
    catch (err) {
      print(err);
      setState(() {
        isSending = false;
      });
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Error'),
            content: Icon(Icons.error_outlined,color: Colors.redAccent),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: const Text('Select ID Documents'), centerTitle: true,backgroundColor: Colors.teal.shade500,),
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
              child: isSending ? const Text('Sending') : const Text('Send Documents'),
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
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) {
                      return Dialog(
                        // The background color
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              // The loading indicator
                              CircularProgressIndicator(),
                              SizedBox(
                                height: 15,
                              ),
                              // Some text
                              Text('Loading...')
                            ],
                          ),
                        ),
                      );
                    });

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
