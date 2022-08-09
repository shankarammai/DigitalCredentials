import 'package:flutter/material.dart';
import 'package:verifiable_credentials/Activity.dart';
import 'package:verifiable_credentials/ViewCredential.dart';

class ElevatedCard extends StatelessWidget {
  final String credentialName;
  final int fileIndex;
  ElevatedCard({Key? key, required this.credentialName , required this.fileIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List colorsPallate=[
      Colors.blue.shade500,
      Colors.indigoAccent,
      Colors.green.shade500,
      Colors.blueGrey.shade500,
      Colors.purple.shade500,
      Colors.lightGreen.shade500
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: SizedBox(
            width: 300,
            height: 100,
            child: Center(child:
            Text(this.credentialName.split('.').first,
                style: TextStyle(fontWeight: FontWeight.w400,color: Colors.white)
            )),

          ),
          color: colorsPallate[(this.fileIndex+1)%6],
        ),

      );
  }
}
