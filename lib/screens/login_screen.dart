import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sunny_paji_da_dhabha/screens/about_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/splash_screen.dart';

class LoginScreen extends StatefulWidget {

  static const routeName = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  int _index = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String phoneNumber = "";
  String _verificationId;
  String _otp = "";
  String userName = "";
  AuthCredential _phoneAuthCredential;

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

  _createUser()async{
    if(userName.length<3){
      final snackBar = SnackBar(
        content: Text('Enter a valid name',style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        duration: Duration(seconds: 2),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }else {
      _showLoad();
      final response = await http.post(
        'https://www.sunnypajidadhabha.in/php/spddUser/createUser.php',
        body: {
          'phone': phoneNumber,
          'name':userName,
        },
      );
      if (response.body.toString() == 'no') {
        Navigator.of(context).pop();
      } else {
        final box = GetStorage();
        box.write('userData', [{'user_id': response.body.toString()}]);
        Navigator.of(context).pushNamedAndRemoveUntil(
            SplashScreen.routeName, (route) => false);
      }
    }

  }

  _checkUser()async{
    final response = await http.post(
      'https://www.sunnypajidadhabha.in/php/spddUser/checkUser.php',
      body: {
        'phone': phoneNumber,
      },
    );
    print(response.body.toString());
      if (response.body.toString() == 'no') {
        setState(() {
          _index++;
        });
      } else {
        final box = GetStorage();
        box.write('userData', [{'user_id': response.body.toString()}]);
        Navigator.of(context).pushNamedAndRemoveUntil(
            SplashScreen.routeName, (route) => false);
      }

  }

  _checkUserAuto()async{
    final response = await http.post(
      'https://www.sunnypajidadhabha.in/php/spddUser/checkUser.php',
      body: {
        'phone': phoneNumber,
      },
    );
    print(response.body.toString());
    if (response.body.toString() == 'no') {
      setState(() {
        _index+=2;
      });
    } else {
      final box = GetStorage();
      box.write('userData', [{'user_id': response.body.toString()}]);
      Navigator.of(context).pushNamedAndRemoveUntil(
          SplashScreen.routeName, (route) => false);
    }

  }

  Future<void> submitPhoneNumber() async {
    print(phoneNumber);
    void verificationCompleted(AuthCredential phoneAuthCredential) {
      this._phoneAuthCredential = phoneAuthCredential;
      print('verificationCompleted');

      FirebaseAuth.instance
          .signInWithCredential(phoneAuthCredential)
          .then((user) {
        print('${user.user.phoneNumber}');
        setState(() {
          _checkUserAuto();
        });
      });
    }

    void verificationFailed(AuthException error) {
      print(error.code);
    }

    void codeSent(String verificationId, [int code]) {
      print('codeSent');
      this._verificationId = verificationId;
      setState(() {
        _index++;
      });
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$phoneNumber",
      timeout: Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  submitOTP(){
    _phoneAuthCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _otp);
    FirebaseAuth.instance
        .signInWithCredential(_phoneAuthCredential)
        .then((user) {
      print('${user.user.phoneNumber}');
      setState(() {
        _checkUser();
      });
    })
        .catchError((error) {
      print('${error.toString()}');
    });
  }



  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery
        .of(context)
        .size;
    final _color = Theme
        .of(context)
        .primaryColor;

    Widget _getPhone() {
      return Card(
        key: Key("11"),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: _mediaQuery.width * 0.8,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Container(width: _mediaQuery.width * 0.65,
                  child: Text("Hey there!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.start,)),
              Container(width: _mediaQuery.width * 0.65,
                  child: TextField(decoration: InputDecoration(
                      labelText: 'Enter your phone number'),
                    keyboardType: TextInputType.number,
                  onSubmitted: (val){
                    setState(() {
                      _index++;
                      submitPhoneNumber();
                    });
                  },
                  onChanged: (val){
                    phoneNumber = val;
                  },)),
              SizedBox(height: 10,),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  setState(() {
                    _index++;
                    submitPhoneNumber();
                  });
                },
                color: _color,
                child: Text("Continue", style: TextStyle(color: Colors.white),),
              )
            ],
          ),
        ),
      );
    }

    Widget _getOTP() {
      return Card(
        key: Key("22"),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: _mediaQuery.width * 0.8,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Container(width: _mediaQuery.width * 0.65,
                  child: Text("We have sent OTP to your phone",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.start,)),
              Container(width: _mediaQuery.width * 0.65,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Enter OTP'),
                    keyboardType: TextInputType.number,onChanged: (val){
                    _otp = val;
                  },onSubmitted: (val){
                    setState(() {
                      _index++;
                      submitOTP();
                    });
                  },),
              ),
              SizedBox(height: 10,),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  setState(() {
                    _index++;
                    submitOTP();
                  });

                },
                color: _color,
                child: Text("SUBMIT", style: TextStyle(color: Colors.white),),
              )
            ],
          ),
        ),
      );
    }

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
                  child: Text("What do we call you?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.start,)),
              Container(width: _mediaQuery.width * 0.65,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Enter your name'),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,onChanged: (val){
                      userName = val;
                  },)),
              SizedBox(height: 10,),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  _createUser();
                },
                color: _color,
                child: Text("Continue", style: TextStyle(color: Colors.white),),
              )
            ],
          ),
        ),
      );
    }

    Widget _getLoad() {
      return Column(
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

    List<Widget> _widgets = [_getPhone(),_getLoad(), _getOTP(),_getLoad(),_getName()];

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/images/main_logo.png', width: _mediaQuery.width * 0.6,),
            AnimatedSwitcher(
              child: _widgets[_index],
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
            ),
            Column(
              children: [
                Text("Having trouble signing in?"),
                FlatButton(onPressed: () {
                  Navigator.of(context).pushNamed(AboutScreen.routeName);
                },
                  child: Text("Contact Us", style: TextStyle(color: _color),),)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
