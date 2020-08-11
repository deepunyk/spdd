import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:sunny_paji_da_dhabha/screens/splash_screen.dart';

class AddressScreen extends StatefulWidget {
  static const routeName = 'address';

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {

  LatLng userPosition = LatLng(13.3366806, 74.7494914);
  String userAddress = "";
  String url = "http://coastella.in/coastellausers/php/editUserAddress.php";
  String postalCode = "";
  Completer<GoogleMapController> _controller = Completer();
  bool _isLoad = false;

  Future<void> _getCurrentUserLocation() async {
    final hasPermission = await Location().hasPermission();
    final hasService = await Location().serviceEnabled();

    if (hasPermission == PermissionStatus.granted && hasService) {
      final userLocation = await Location().getLocation().catchError((er) {
        print("Errorrr" + er);
      });
      final GoogleMapController controller = await _controller.future;
      setState(() {
        userPosition = LatLng(userLocation.latitude, userLocation.longitude);
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: userPosition, zoom: 16),
          ),
        );
        _getAddress(userPosition);
      });
    } else if (hasPermission == PermissionStatus.granted && !hasService) {
      await Location().requestService();
      _getCurrentUserLocation();
    } else {
      await Location().requestPermission().then((value) {
        if (value == PermissionStatus.denied) {
          final alert = AlertDialog(
            title: Text("Permission Denied"),
            content: Text(
                "Your home location will be displayed to the retailer for home delivery service."),
            actions: <Widget>[
              FlatButton(
                child: Text("Deny"),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text("Give Permission"),
                onPressed: _getCurrentUserLocation,
              ),
            ],
          );
          showDialog(
              context: context,
              builder: (ctx) {
                return alert;
              });
        } else {
          _getCurrentUserLocation();
        }
      });
    }
  }

  _getAddress(LatLng latLng) async {
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    postalCode = placemark[0].postalCode;
    setState(() {
      userAddress = placemark[0].name +
          " " +
          placemark[0].subLocality +
          " " +
          placemark[0].locality;
    });
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

  _addAddress() async {
    setState(() {
      _isLoad = true;
    });
    _showLoad();
    final box = GetStorage();
    print(box.read('userData'));
    final userData= box.read('userData');
    final userId = userData[0]['user_id'];
    final response = await http.post(
      'https://www.sunnypajidadhabha.in/php/spddUser/addAddress.php',
      body: {
        'user_id': userId,
        'user_address': userAddress,
        'latitude':userPosition.latitude.toString(),
        'longitude':userPosition.longitude.toString(),
        'user_pincode':postalCode.toString(),
      },
    );
    if (response.body.toString() == 'no') {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(SplashScreen.routeName, (route) => false);
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Out of range"),
          content: new Text("Service is currently unavailable in this area."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Okay", style: TextStyle(color: Theme.of(context).accentColor),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _checkAddress(){
    if(postalCode == '363642' || postalCode == '363641'){
      _addAddress();
    }else{
      _showDialog();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentUserLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _color = Theme.of(context).primaryColor;
    final _mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color(0xffc62828),
        ),
        title: Text(
          "Select your location",
          style: TextStyle(color: _color),
        ),
        elevation: 5,
      ),
      body: Builder(builder: (ctx) {
        return Stack(
          children: <Widget>[
            GoogleMap(
              mapToolbarEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: userPosition,
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("user"),
                  position: userPosition,
                  draggable: true,
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (val) {
                setState(() {
                  userPosition = val;
                  _getAddress(val);
                });
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.only(right: _mediaQuery.width * 0.025),
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(360),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(360),
                            child: Material(
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {
                                  _getCurrentUserLocation();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(
                                      _mediaQuery.height * 0.008),
                                  child: Icon(
                                    Icons.my_location,
                                    color: _color,
                                    size: _mediaQuery.height * 0.035,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: _mediaQuery.width * 0.07),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: _mediaQuery.height * 0.02,
                            ),
                            Text(
                              "Your address :",
                              style: TextStyle(fontSize: 18, color: _color),
                            ),
                            TextField(
                              maxLines: 2,
                              style: TextStyle(fontSize: 16),
                              controller: TextEditingController()
                                ..text = userAddress,
                              onChanged: (val) {
                                userAddress = val;
                              },
                            ),
                            SizedBox(
                              height: _mediaQuery.height * 0.01,
                            ),
                            Text(
                              "Pin Code :",
                              style: TextStyle(fontSize: 18, color: _color),
                            ),
                            TextField(
                              maxLines: 1,
                              style: TextStyle(fontSize: 16),
                              controller: TextEditingController()
                                ..text = postalCode,
                              onChanged: (val) {
                                postalCode = val;
                              },
                            ),
                            SizedBox(
                              height: _mediaQuery.height * 0.01,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                onPressed: () {
                                  _checkAddress();
                                },
                                color: _color,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "Add Address",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: _mediaQuery.height * 0.02,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
