import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:verifiable_credentials/VerifyCredential.dart';
import 'services/secure_storage.dart';
import 'dart:developer' as developer;
import 'Activity.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ChooseIssuer.dart';
import 'Dashboard.dart';


class DashboardStructure extends StatefulWidget {
  const DashboardStructure({Key? key}) : super(key: key);

  @override
  State<DashboardStructure> createState() => _DashboardStructureState();
}

class _DashboardStructureState extends State<DashboardStructure> {
  int _selectedIndex = 0;
  final SecureStorage secureStorage = SecureStorage();

  PageController _pageController = PageController();
  List<Widget> _screens = [Dashboard(), Activity()];

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
              child: const Icon(Icons.qr_code_scanner),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: 'Verify Document',
              labelStyle: const TextStyle(fontSize: 18.0, color: Colors.white),
              onTap: () {
                print('Verify  Document');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VerifyCredential()));
              },
              onLongPress: () => print('SECOND CHILD LONG PRESS'),
            ),
            SpeedDialChild(
              //speed dial child
              child: const Icon(Icons.add),
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
