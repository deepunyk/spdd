import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sunny_paji_da_dhabha/models/address.dart';
import 'package:sunny_paji_da_dhabha/models/dish.dart';
import 'package:sunny_paji_da_dhabha/providers/addresses.dart';
import 'package:sunny_paji_da_dhabha/providers/dishes.dart';
import 'package:sunny_paji_da_dhabha/screens/category_menu_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/main_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/menu_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/order_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/search_screen.dart';

class SplashScreen extends StatefulWidget {

  static const routeName = 'splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Addresses _addresses;
  Dishes _dishes;
  int cnt = 0;


  String userId = "";

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("No internet connection"),
          content: new Text("Please check your internet connection and try again"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Okay", style: TextStyle(color: Theme.of(context).primaryColor),),
              onPressed: () {
                Navigator.of(context).pop();
                _checkInternet();
              },
            ),
          ],
        );
      },
    );
  }

  void _newUpdate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("New update found"),
          content: new Text("Please go to playstore and update the app"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Okay", style: TextStyle(color: Theme.of(context).primaryColor),),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  _checkInternet()async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      _getUserData();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      _getUserData();
    }else{
      _showDialog();
    }
  }

  _getData() async {
    final box = GetStorage();
    final userData= box.read('userData');
    userId = userData[0]['user_id'];
    final response = await http.post(
      'https://www.sunnypajidadhabha.in/php/spddUser/getAll.php',
      body: {
        'user_id': userId,
      },
    );
    if (response.body.toString() == 'no') {
      print("New user");
    } else {
      _addAllData(response);
    }
  }

  _getUserData()async{

    _addresses.clear();
    _dishes.clear();
    final box = GetStorage();
    if(box.hasData('userData')){
      final userData= box.read('userData');
      userId = userData[0]['user_id'];
      _getData();
    }else{
      _getDishes();
    }
  }

  _getDishes()async{
    final response = await http.get(
      'https://www.sunnypajidadhabha.in/php/spddUser/getDishes.php',
    );
    if (response.body.toString() == 'no') {
    } else {
      final userResponse = json.decode(response.body);
      final dishData = userResponse['dish'].cast<Map<String, dynamic>>();
      dishData.map((val) {
        return _dishes.addDish(
          Dish(
            category_id: val['category_id'] as String,
            category_image: val['category_image'] as String,
            category_name: val['category_name'] as String,
            dish_cost: val['dish_cost'] as String,
            dish_img: val['dish_img'] as String,
            dish_isAvail: val['dish_isAvail'] as String,
            dish_isFav: val['dish_isFav'] as String,
            dish_isVeg: val['dish_isVeg'] as String,
            dish_name: val['dish_name'] as String,
            quantity: 0,
            dish_id: val['dish_id'] as String,
          ),);
      }).toList();
      Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
    }
  }

  void _addAllData(http.Response response) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = await packageInfo.version;
    print(version.toString());
    final userResponse = json.decode(response.body);
    final allData = userResponse['allOrders'];
    final userData = allData['userInfo'];
    final dishData = allData['dishes'].cast<Map<String, dynamic>>();
    final addressData = allData['userAddress'].cast<Map<String, dynamic>>();
    final update = allData['update'];
    if(update[0]['updateId'].toString() != version.toString()){
      _newUpdate();
    }else{
      _addUserData(userData, dishData, addressData);
    }

  }

  _addUserData(dynamic userData, List<Map<String, dynamic>> dishData,
      List<Map<String, dynamic>> addressData) async {
    final box = GetStorage();
    box.write('userData', userData);

    _addAddressData(dishData, addressData);
  }

  _addAddressData(List<Map<String, dynamic>> dishData,
      List<Map<String, dynamic>> addressData) {
    addressData.map((val) {
      return _addresses.addAddress(
        Address(
          user_address: val['user_address'] as String,
          user_pincode: val['user_pincode'] as String,
          lat: val['lat'] as String,
          longitude: val['longitude'] as String,
          ua_id: val['ua_id'] as String,
        ),);
    }).toList();
    _addDishData(dishData);
  }

  _addDishData(List<Map<String, dynamic>> dishData,) {
    dishData.map((val) {
      return _dishes.addDish(
        Dish(
          category_id: val['category_id'] as String,
          category_image: val['category_image'] as String,
          category_name: val['category_name'] as String,
          dish_cost: val['dish_cost'] as String,
          dish_img: val['dish_img'] as String,
          dish_isAvail: val['dish_isAvail'] as String,
          dish_isFav: val['dish_isFav'] as String,
          dish_isVeg: val['dish_isVeg'] as String,
          dish_name: val['dish_name'] as String,
          quantity: 0,
          dish_id: val['dish_id'] as String,
        ),);
    }).toList();
    Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery
        .of(context)
        .size;

    _addresses = Provider.of<Addresses>(context);
    _dishes = Provider.of<Dishes>(context);

    if(cnt == 0){
      cnt++;
      _checkInternet();
    }

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(width: _mediaQuery.width * 0.7,
                constraints: BoxConstraints(maxWidth: 800),
                child: Image.asset(
                  'assets/images/main_logo.png', width: _mediaQuery.width * 0.7,)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child:Padding(
              padding: EdgeInsets.only(bottom: _mediaQuery.height*0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpinKitWave(
                    color: Theme.of(context).primaryColor,
                    size: _mediaQuery.width * 0.05,

                  ),
                  SizedBox(height: 10,),
                  Text("Loading", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
