import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:sunny_paji_da_dhabha/providers/addresses.dart';
import 'package:sunny_paji_da_dhabha/providers/dishes.dart';
import 'package:sunny_paji_da_dhabha/screens/about_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/account_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/address_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/cart_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/category_menu_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/category_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/edit_user.dart';
import 'package:sunny_paji_da_dhabha/screens/login_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/main_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/menu_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/order_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/search_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/splash_screen.dart';

void main() async{
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx)=>Dishes(),
        ),
        ChangeNotifierProvider(
          create: (ctx)=>Addresses(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xffc62828),
          accentColor: Color(0xffc62828),
          fontFamily: 'Poppins',
        ),
        home: SplashScreen(),
        routes: {
          AboutScreen.routeName: (ctx) => AboutScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          AccountScreen.routeName: (ctx) => AccountScreen(),
          MainScreen.routeName: (ctx) => MainScreen(),
          OrderScreen.routeName: (ctx) => OrderScreen(),
          SplashScreen.routeName: (ctx) => SplashScreen(),
          MenuScreen.routeName: (ctx) => MenuScreen(),
          SearchScreen.routeName: (ctx) => SearchScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          CategoryScreen.routeName: (ctx) => CategoryScreen(),
          AddressScreen.routeName: (ctx) => AddressScreen(),
          EditUser.routeName: (ctx) => EditUser(),
          CategoryMenuScreen.routeName: (ctx) => CategoryMenuScreen(),
        },
      ),
    );
  }
}
