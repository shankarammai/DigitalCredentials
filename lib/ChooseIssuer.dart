import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class ChooseIssuer extends StatefulWidget {
  ChooseIssuer({Key? key}) : super(key: key);

  @override
  State<ChooseIssuer> createState() => _ChooseIssuerState();
}

class _ChooseIssuerState extends State<ChooseIssuer> {
  String name = "";
  String issuserPublicKeyPEM = "";
  String documentAPI = "";
  List<String> issuers = ['DVLA', 'GOV UK'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            SearchField(
                suggestions:
                    issuers.map((e) => SearchFieldListItem(e)).toList()),
            ElevatedButton(
              onPressed: () {},
              child: Text('Continue'),
            )
          ],
        )
      ],
    );
  }
}
