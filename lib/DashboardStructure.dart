import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'services/secure_storage.dart';
import 'dart:developer' as developer;
import 'Activity.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ChooseIssuer.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  String privateKeyPEM = "";
  String publicKeyPEM = "";
  String Uuid = "";
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    secureStorage.readSecureData("publicKeyPEM").then((value) {
      publicKeyPEM = value.toString();
    });
    secureStorage.readSecureData("privateKeyPEM").then((value) {
      privateKeyPEM = value.toString();
    });
    secureStorage.readSecureData("Uuid").then((value) {
      Uuid = value.toString();
    });
    print("Dashboard ");
    print(publicKeyPEM);
    print(Uuid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: Center(child: Text('Dashboard')));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  final SecureStorage secureStorage = SecureStorage();

  PageController _pageController = PageController();
  List<Widget> _screens = [DashboardPage(), Activity()];

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          children: _screens,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
        ),
        floatingActionButton: SpeedDial(
          marginBottom: 10, //margin bottom
          icon: Icons.menu, //icon on Floating action button
          activeIcon: Icons.close, //icon when menu is expanded on button
          backgroundColor: Colors.deepOrangeAccent, //background color of button
          foregroundColor: Colors.white, //font color, icon color in button
          activeBackgroundColor:
              Colors.deepPurpleAccent, //background color when menu is expanded
          activeForegroundColor: Colors.white,
          buttonSize: 56.0, //button size
          visible: true,
          closeManually: false,
          curve: Curves.bounceIn,
          overlayOpacity: 0.1,
          onOpen: () => print('OPENING DIAL'), // action when menu opens
          onClose: () => print('DIAL CLOSED'), //action when menu closes

          elevation: 8.0, //shadow elevation of button
          shape: const CircleBorder(), //shape of button

          children: [
            SpeedDialChild(
              //speed dial child
              child: Icon(Icons.add),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              label: 'Add ID',
              labelStyle: const TextStyle(fontSize: 18.0, color: Colors.white),
              onTap: () {
                print('Add Id Document');
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ChooseIssuer()));
              },
              onLongPress: () => print('FIRST CHILD LONG PRESS'),
            ),
            SpeedDialChild(
              child: const Icon(Icons.camera_alt_outlined),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: 'Verify Document',
              labelStyle: const TextStyle(fontSize: 18.0, color: Colors.white),
              onTap: () {
                print('SECOND CHILD');
              },
              onLongPress: () => print('SECOND CHILD LONG PRESS'),
            ),
            SpeedDialChild(
              child: const Icon(Icons.keyboard_voice),
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              label: 'Third Menu Child',
              labelStyle: const TextStyle(fontSize: 18.0, color: Colors.white),
              onTap: () {
                print('THIRD CHILD');
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ChooseIssuer()));
              },
              onLongPress: () => print('THIRD CHILD LONG PRESS'),
            ),

            //add more menu item children here
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_timeline_outlined),
              label: 'Activities',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
