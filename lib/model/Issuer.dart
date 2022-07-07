import 'package:cloud_firestore/cloud_firestore.dart';
class Issuer{
 String id;
 String name;
 String publicKeyPEM;
 String documentAPI;

 final CollectionReference issuerList=FirebaseFirestore.instance.collection('issuer');

 Issuer({
  this.id='',
  required this.name,
  required this.publicKeyPEM,
  required this.documentAPI,
});

 Future getIssuserList() async{

  try{
   issuerList.doc(id).get().then((value) => print(value));
  }
  catch(e){
   print(e.toString());
   return;
  }


 }
}