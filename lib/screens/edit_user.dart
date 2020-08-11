import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sunny_paji_da_dhabha/screens/splash_screen.dart';

class EditUser extends StatefulWidget {

  static const routeName = 'editUser';

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {

  String userId = "";
  String userName = "";
  String userPhone = "";
  bool _isLoad = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _getUserData(){
    final box = GetStorage();
    print(box.read('userData'));
    final userData= box.read('userData');
    userId = userData[0]['user_id'];
    userName = userData[0]['user_name'];
    userPhone = userData[0]['user_phone'];
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserData();
  }

  _updateUser() async {
    if(userName.length<3){
      final snackBar = SnackBar(
        content: Text('Enter a valid name',style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        duration: Duration(seconds: 2),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }else {
      setState(() {
        _isLoad = true;
      });
      final response = await http.post(
        'https://www.sunnypajidadhabha.in/php/spddUser/editUser.php',
        body: {
          'user_id': userId,
          'name': userName,
        },
      );
      if (response.body.toString() == 'no') {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            SplashScreen.routeName, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final _mediaQuery = MediaQuery
        .of(context)
        .size;
    final _color = Theme
        .of(context)
        .primaryColor;

    Widget _getName() {
      return Card(
        key: Key("33"),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: _mediaQuery.width * 0.8,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Container(width: _mediaQuery.width * 0.65,
                  child: TextFormField(initialValue: userName,
                    decoration: InputDecoration(labelText: 'Enter your name'),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                  onChanged: (val){
                    userName = val;
                  },
                    onFieldSubmitted: (val){
                      _updateUser();
                    },
                  autofocus: true,),),
              SizedBox(height: 10,),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  _updateUser();
                },
                color: _color,
                child: Text("Update", style: TextStyle(color: Colors.white),),
              )
            ],
          ),
        ),
      );
    }

    Widget _getLoad() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitWave(
            color: _color,
            size: _mediaQuery.width * 0.1,

          ),
          SizedBox(height: 10,),
          Text("Please wait", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),)
        ],
      );
    }


    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Edit User",
          style: TextStyle(color: _color, fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(
          color: Color(0xffc62828),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        child: _isLoad?_getLoad():Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/images/main_logo.png', width: _mediaQuery.width * 0.6,),
            _getName(),
          ],
        ),
      ),
    );
  }
}
