import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(title: const Text('Activity'),backgroundColor: Colors.teal.shade500),
        body: ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) {
              return Card(
                  child: Column(children: <Widget>[Text('title is ${index}')]));
            })
        // ListView(children: [
        //   Column(
        //     children: [Text('activity page')],
        //   )
        // ]),
        );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
