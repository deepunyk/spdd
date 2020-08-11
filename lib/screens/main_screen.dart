import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sunny_paji_da_dhabha/screens/account_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/category_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/order_screen.dart';

class MainScreen extends StatefulWidget {

  static const routeName = 'main';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _selectedIndex = 1;
  final List<Widget> _pages = [OrderScreen(), CategoryScreen(),AccountScreen()];

  void _selectPage(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    final box = GetStorage();
    if(box.hasData('userData')){
      final userData= box.read('userData');
      final userPhone = userData[0]['user_phone'];
      fbm.subscribeToTopic(userPhone.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        index: 1,
        height: 50.0,
        items: <Widget>[
          Icon(Icons.history, size: 30),
          Icon(Icons.restaurant_menu, size: 30),
          Icon(Icons.person, size: 30),
        ],
        color: Color(0xfffff3f3),
        buttonBackgroundColor: Color(0xfffff3f3),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 400),
        onTap: (index) {
          _selectPage(index);
        },
      ),
      body: _pages[_selectedIndex],
    );
  }
}
