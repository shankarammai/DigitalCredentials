import 'package:flutter/material.dart';
import 'package:verifiable_credentials/Activity.dart';
import 'package:verifiable_credentials/ViewCredential.dart';

class ElevatedCard extends StatelessWidget {
  final String credentialName;
  final int fileIndex;
  ElevatedCard({Key? key, required this.credentialName , required this.fileIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List colorsPallate=[Colors.blueAccent,
      Colors.cyanAccent.shade700,
      Colors.green,
      Colors.blueGrey,
      Colors.deepPurple,
      Colors.indigoAccent
    ];
      return GestureDetector(
      onTap: () {
        print('Card Clicked');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewCredential(credentailDocument: this.credentialName))
        );
      },
        child: Card(
          child: SizedBox(
            width: 300,
            height: 100,
            child: Center(child: Text(this.credentialName.split('.').first)),

          ),
          color: colorsPallate[(this.fileIndex+1)%6],
        ),

      );
  }
}
