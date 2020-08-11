import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sunny_paji_da_dhabha/models/address.dart';
import 'package:sunny_paji_da_dhabha/providers/addresses.dart';
import 'package:sunny_paji_da_dhabha/screens/address_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/edit_user.dart';
import 'package:sunny_paji_da_dhabha/screens/login_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/splash_screen.dart';
import 'package:http/http.dart'as http;

import 'about_screen.dart';

class AccountScreen extends StatefulWidget {

  static const routeName = 'account';

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {


  Addresses _addresses;
  String userId = "";
  String userName = "";
  String userPhone = "";
  int code = 0;

  _getUserData(){
    final box = GetStorage();
    if(box.hasData('userData')) {
      final userData = box.read('userData');
      userId = userData[0]['user_id'];
      userName = userData[0]['user_name'];
      userPhone = userData[0]['user_phone'];
      setState(() {
        code = 1;
      });
    }
  }

  _showLoad(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 100,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitWave(size: 15,color: Theme.of(context).primaryColor,),
                Text("Please wait")
              ],
            ),
          ),
        );
      },
    );
  }


  _deleteAddress(String uaID)async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete Address"),
          content: new Text("Do you want to permanently delete this address?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No", style: TextStyle(color: Theme.of(context).accentColor),),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes", style: TextStyle(color: Theme.of(context).accentColor),),
              onPressed: () async{
                _showLoad();
                final response = await http.post(
                  'https://www.sunnypajidadhabha.in/php/spddUser/deleteAddress.php',
                  body: {
                    'ua_id': uaID,
                  },
                );
                if (response.body.toString() == 'no') {
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(SplashScreen.routeName, (route) => false);
                }
              },
            ),
          ],
        );
      },
    );

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {

    final _mediaQuery = MediaQuery.of(context).size;
    final _color = Theme.of(context).primaryColor;
    _addresses = Provider.of<Addresses>(context);

    Widget _getAddressCard(Address address){
      return Card(
        child: ListTile(
          title: Text("Pin Code: ${address.user_pincode}"),
          subtitle: Text(address.user_address),
          trailing: Material(color: Colors.transparent,child: InkWell(onTap: (){_deleteAddress(address.ua_id);},child: Icon(Icons.delete, color: _color,))),
        ),
      );
    }

    Widget _getAccount(){
      return SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.symmetric(horizontal: _mediaQuery.width*0.01),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: _mediaQuery.width*0.08, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name",style: TextStyle(color: _color,fontWeight: FontWeight.w500),),
                    Text(userName,style: TextStyle(fontSize: 18,),),
                    SizedBox(height: 8,),
                    Text("Phone",style: TextStyle(color: _color,fontWeight: FontWeight.w500),),
                    Text("+91$userPhone",style: TextStyle(fontSize: 18,),),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          color: _color,
                          onPressed: (){
                            Navigator.of(context).pushNamed(EditUser.routeName);
                          },
                          child: Text("Edit", style: TextStyle(color: Colors.white),),
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          color: _color,
                          onPressed: (){
                            final box = GetStorage();
                            box.remove('userData');
                            Navigator.of(context).pushNamedAndRemoveUntil(SplashScreen.routeName, (route) => false);
                          },
                          child: Text("Sign Out", style: TextStyle(color: Colors.white),),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text("Address list",style: TextStyle(color: _color,fontWeight: FontWeight.w500, fontSize: 18)),
            SizedBox(height: 10,),
            ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: _addresses.getAddress().map((e) => _getAddressCard(e)).toList()
            ),
            Container(
              width: _mediaQuery.width*0.6,
              child: RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                color: _color,
                onPressed: (){
                  Navigator.of(context).pushNamed(AddressScreen.routeName);
                },
                child: Text("Add Address", style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        ),
      );
    }

    Widget _noLogin(){
      return Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network('https://assets1.lottiefiles.com/private_files/lf30_fNsrpZ.json', width: _mediaQuery.width*0.5),
            Text("Login to place order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            RaisedButton(
              color: _color,
              onPressed: (){
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
              child: Text("Login",style: TextStyle(color: Colors.white),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            )
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "ACCOUNT",
          style: TextStyle(color: _color, fontWeight: FontWeight.w600),
        ),

        backgroundColor: Colors.white,
        actions: [
          Padding(padding: EdgeInsets.only(right: 15),child: Material(color: Colors.transparent,child: InkWell(onTap: (){
            Navigator.of(context).pushNamed(AboutScreen.routeName);
          },child: Icon(Icons.help,color: _color,))))
        ],
      ),
      body: code == 0?_noLogin():_getAccount()
    );
  }
}
