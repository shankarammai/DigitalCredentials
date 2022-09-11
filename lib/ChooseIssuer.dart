import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

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
    issuerNameController.text = selectedValue.item["name"];
    issuerAPIController.text = selectedValue.item["documentAPI"];
    issuerPublicKeyPEMController.text =
        selectedValue.item["publicKeyPEM"];
  }

  Future<List> fetchData() async {
    final response =
    await http.get(Uri.parse('https://shankarammai.com.np/VerifiableCredentials/public/api/getIssuers'));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);//.cast<Map<String, dynamic>>();
      return parsed;
    } else {
      throw Exception('Failed to load issuers from API');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData().then((value) {
      print(value);
      setState(() {
        value.forEach((element) {
          issuersDetail.add(element);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Issuer'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade500,
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
                              SearchFieldListItem(e['name'], item: e))
                        .toList(),
                    onSuggestionTap: (selectedValue) {
                      // print(selectedValue);
                      var snackBar = const SnackBar(content: Text('Selected'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      _loadSelectedToFields(selectedValue);
                    }),
              ),
              Row(
                  children: <Widget>[
                    Expanded(
                        child: Divider(thickness: 2,)
                    ),
                    Padding(padding:const EdgeInsets.only(left: 8.0,right: 8.0) ,child:Text(
                      'OR',
                      textAlign: TextAlign.left,
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),

                    Expanded(
                        child: Divider(thickness: 2,)
                    ),
                  ]
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: issuerNameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Type Issuer Name'))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: issuerAPIController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Provide Issuer API Link'))),
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
