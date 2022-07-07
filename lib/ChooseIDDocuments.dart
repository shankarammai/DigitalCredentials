import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

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
  List files = [];
  File? image;

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
                return Image.file(
                  filepath,
                  height: 150,
                  width: 150,
                );
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
                if(files.length<1){
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('No Files Selected'),
                        content: Text('Please Select files to send'),
                      )
                  );
                  return;
                }

                setState(() {
                  isSending = true;
                });

              },
            )
          ])
        ]));
  }
}
