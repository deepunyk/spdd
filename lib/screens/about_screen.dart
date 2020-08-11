import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:websafe_svg/websafe_svg.dart';

class AboutScreen extends StatefulWidget {
  static const routeName = 'about';

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context).size;
    final _color = Theme.of(context).primaryColor;

    _getAbout() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          Text("The pure authentic punjabi restaurant distinctively Punjabi cuisine with rich buttery flavour along with extensive vegetarian dishes.", style: TextStyle(),)
        ],
      );
    }

    _getSocialMedia() {
      return Column(
        children: [
          Text(
            "Social Media Links",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: _mediaQuery.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    const url =
                        'https://www.facebook.com/sunny_paji_da_dhaba_morbi-113239343786483/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: WebsafeSvg.asset('assets/icons/fb_icon.svg',
                      color: _color,
                      height: _mediaQuery.width * 0.1,
                      width: _mediaQuery.width * 0.1),
                ),
              ),
              SizedBox(
                width: _mediaQuery.width * 0.05,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    const url =
                        'https://instagram.com/sunny_paji_da_dhaba_morbi?igshid=1mqmnxkb7wo7j';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: WebsafeSvg.asset('assets/icons/ig_icon.svg',
                      color: _color,
                      height: _mediaQuery.width * 0.1,
                      width: _mediaQuery.width * 0.1),
                ),
              ),
            ],
          )
        ],
      );
    }

    _getAddress() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dhaba Address",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "So ordi main road , nr ppw post office , opp. Royal bakery  morbi- address",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Icon(Icons.location_on,color: _color,size: _mediaQuery.width*0.1,),
                  onTap: () async {
                    const url =
                        'https://www.google.com/maps?q=22.81928825378418,70.85287475585938&z=17&hl=en';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              )
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(color: _color, fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(
          color: Color(0xffc62828),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: _mediaQuery.width * 0.08),
          child: Column(
            children: [
              SizedBox(
                height: _mediaQuery.height * 0.01,
              ),
              Image.asset(
                'assets/images/main_logo.png',
                width: _mediaQuery.width * 0.7,
              ),
              _getAbout(),
              SizedBox(height: _mediaQuery.height*0.02,),
              _getAddress(),
              SizedBox(height: _mediaQuery.height*0.02,),
              RaisedButton(
                onPressed: (){
                  launch("tel://+917567067567");
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                color: _color,
                child: Text("Call Us", style: TextStyle(color: Colors.white,fontSize: 16),),
              ),
              SizedBox(height: _mediaQuery.height*0.02,),
              _getSocialMedia()
            ],
          ),
        ),
      ),
    );
  }
}
