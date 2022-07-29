import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ChooseIDDocuments.dart';

class ChooseIssuer extends StatefulWidget {
  ChooseIssuer({Key? key}) : super(key: key);

  @override
  State<ChooseIssuer> createState() => _ChooseIssuerState();
}

class _ChooseIssuerState extends State<ChooseIssuer> {
  final Stream<QuerySnapshot> _issuers =
      FirebaseFirestore.instance.collection('Issuers').snapshots();
  String name = "";
  String issuserPublicKeyPEM = "";
  String documentAPI = "";
  List issuersDetail = [];
  TextEditingController issuerNameController = TextEditingController();
  TextEditingController issuerAPIController = TextEditingController();
  TextEditingController issuerPublicKeyPEMController = TextEditingController();

  void _loadSelectedToFields(selectedValue) {
    print(selectedValue.item);
    issuerNameController.text = selectedValue.item["data"]["name"];
    issuerAPIController.text = selectedValue.item["data"]["documentAPI"];
    issuerPublicKeyPEMController.text =
        selectedValue.item["data"]["publicKeyPEM"];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('Issuers')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> docData = {'id': doc.id, 'data': data};
        issuersDetail.add(docData);
        print(issuersDetail);
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Issuer'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchField(
                    searchInputDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Search for known Issuers')),
                    suggestions: issuersDetail
                        .map((e) =>
                            SearchFieldListItem(e['data']['name'], item: e))
                        .toList(),
                    onSuggestionTap: (selectedValue) {
                      // print(selectedValue);
                      var snackBar = const SnackBar(content: Text('Selected'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      _loadSelectedToFields(selectedValue);
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: issuerNameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Issuer Name'))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: issuerAPIController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Issuer API Link'))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    minLines: 10,
                    maxLines: 10,
                    controller: issuerPublicKeyPEMController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Public Key of Issuer'))),
              ),
              ElevatedButton(
                onPressed: () {
                  if(issuerNameController.text=='' && issuerAPIController.text=='' && issuerPublicKeyPEMController.text==''){
                    showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          title: Text('Empty Fileds  '),
                          content: Text('All fields should be filled'),
                        )
                    );
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChooseIDDocuments(
                                issuerName: issuerNameController.text,
                                issuerPublicKeyPEM:
                                    issuerPublicKeyPEMController.text,
                                documentAPI: issuerAPIController.text,
                              ))
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
