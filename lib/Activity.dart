import 'dart:convert';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Activity extends StatefulWidget {
  final List allcreatedQR;
  Activity({Key? key, required this.allcreatedQR}) : super(key: key);

  @override
  State<Activity> createState() {
    return _ActivityState(this.allcreatedQR);
  }
}

class _ActivityState extends State<Activity>
    with AutomaticKeepAliveClientMixin {
  final List allcreatedQR;
  List allQRdata = [];
  _ActivityState(this.allcreatedQR);

  void load_all_activities() async {
    var request = new http.MultipartRequest(
        "POST",
        Uri.parse(
            "https://shankarammai.com.np/VerifiableCredentials/public/api/showActivities"));
    request.fields['uuids'] = json.encode(allcreatedQR);
    request.headers.addAll({"Content-type": "multipart/form-data"});
    var response = request.send();
    response.then((responseback) async {
      final resBody = await responseback.stream.bytesToString();
      if (responseback.statusCode >= 200 && responseback.statusCode < 300) {
        List responseBackJSon = json.decode(resBody);
        setState(() {
          allQRdata = responseBackJSon;
        });
      } else {
        print('error');
      }
    });
  }

  @override
  void initState() {
    load_all_activities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
            title: const Text('Activity'),
            backgroundColor: Colors.teal.shade500),
        body: ListView(children: [
          Column(
            children: allQRdata.map((e) {
              List accessedby = json.decode(e['accessed_by']);
              return Column(children: [
                Divider(),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'QR UUID '),
                      TextSpan(
                        text: '${e['uuid']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    child: SizedBox(
                        width: 300,
                        height: 50,
                        child: Center(
                            child: Column(
                          children: [
                            Text(
                              'Total Accessed',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(accessedby.length.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold))
                          ],
                        ))),
                    color: Colors.orangeAccent,
                  )
                ])
              ]);
            }).toList(),
          ),
        ]));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
