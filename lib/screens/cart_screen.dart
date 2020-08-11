import 'dart:convert';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sunny_paji_da_dhabha/models/address.dart';
import 'package:sunny_paji_da_dhabha/providers/addresses.dart';
import 'package:sunny_paji_da_dhabha/providers/dishes.dart';
import 'package:sunny_paji_da_dhabha/screens/login_screen.dart';
import 'package:http/http.dart' as http;

import 'address_screen.dart';

class CartScreen extends StatefulWidget {
  static const routeName = 'cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  int _type = 0;
  int code = 0;
  int _selected = 0;
  Address _selectedAddress;
  Addresses _addresses;
  Dishes _dishes;
  int extra = 0;
  String userName = "";

  _getUserData(){
    final box = GetStorage();
    if(box.hasData('userData')) {
      final userData = box.read('userData');
      userName = userData[0]['user_name'];
      setState(() {
        code = 1;
      });
    }
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

    _dishes = Provider.of<Dishes>(context);
    _addresses = Provider.of<Addresses>(context);


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

    double calculateDistance(lat1, lon1, lat2, lon2){
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 - c((lat2 - lat1) * p)/2 +
          c(lat1 * p) * c(lat2 * p) *
              (1 - c((lon2 - lon1) * p))/2;
      return 12742 * asin(sqrt(a));
    }

    _checkAddress(){
      double totalDistance = 0;
      totalDistance = calculateDistance(double.parse(_selectedAddress.lat), double.parse(_selectedAddress.longitude), 22.819285, 70.852872);
      if(totalDistance <= 3){
        extra = 0;
      }else{
        extra = 40;
      }
      setState(() {

      });
    }

    Widget _getVegIcon(Color color) {
      return Container(
        height: 18,
        width: 18,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.green),
            color: Colors.white),
        alignment: Alignment.center,
        child: Container(
          height: 10,
          width: 10,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.green),
        ),
      );
    }

    Widget _getAddressCard(Address address){
      return Card(
        child: ListTile(
          title: Text("Pin Code: ${address.user_pincode}"),
          subtitle: Text(address.user_address),
          onTap: (){
            this._selectedAddress = address;
            _selected = 1;
            _checkAddress();
            setState(() {
              Navigator.of(context).pop();
            });
          },
        ),
      );
    }

    _showAddresses(){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: _mediaQuery.height*0.6,
              width: _mediaQuery.width*0.9,
              color: Colors.white,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  Text("Select delivery address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  Expanded(
                    child: ListView(
                      children: _addresses.getAddress().map((e) => _getAddressCard(e)).toList()
                    ),
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
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget _getItem(Map<String, String> item) {
      return Card(
        child: ListTile(
          leading: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  item['dish_img'],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(top: 0, left: 0, child: _getVegIcon(item['dish_isVeg'] == "1"? Colors.green:_color)),
            ],
          ),
          title: Text(item['dish_name']),
          subtitle: Text('₹${item['dish_cost']} * ${item['quantity']} = ${int.parse(item['dish_cost'])*int.parse(item['quantity'])}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (){
                    _dishes.removeItem(item['dish_id']);
                  },
                  child: Icon(
                    Icons.remove,
                    color: _color,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text('${item['quantity']}'),
              SizedBox(
                width: 5,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (){

                    _dishes.addItem(item['dish_id']);
                  },
                  child: Icon(
                    Icons.add,
                    color: _color,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _deliveryCharge(){
      return Row(
        children: [
          Icon(Icons.error_outline, color: _color,),
          SizedBox(width: 5,),
          Expanded(child: Text("Delivery distance is more than 3kms, ₹40 will be charged extra.",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 12),)),
        ],
      );
    }

    Widget _noOrder(){
      return Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network('https://assets10.lottiefiles.com/packages/lf20_MrIjH2.json', width: _mediaQuery.width*0.5),
            Text("Your cart is empty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            RaisedButton(
              color: _color,
              onPressed: (){
                Navigator.of(context).pop(context);
              },
              child: Text("Add Items",style: TextStyle(color: Colors.white),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            )
          ],
        ),
      );
    }

    Widget _getAddressWidget(){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "Delivery Address",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 5,
          ),
          _selected == 1?Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              title: Text("Pin Code: ${_selectedAddress.user_pincode}"),
              subtitle: Text(
                _selectedAddress.user_address, maxLines: 3,overflow: TextOverflow.ellipsis,),
              trailing: Icon(
                Icons.edit,
                color: _color,
              ),
              onTap: () {
                _showAddresses();
              },
            ),
          ):Container(
            width: _mediaQuery.width*0.6,
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: _color,
              onPressed: (){
                _showAddresses();
              },
              child: Text("Select Address", style: TextStyle(color: Colors.white),),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if(extra>0)_deliveryCharge(),
        ],
      );
    }

    void _placeOrder(List items)async{
      _showLoad();
      final box = GetStorage();
      final userData= box.read('userData');
      final userId = userData[0]['user_id'];
      await Firestore.instance.collection('notification').add({
        'title' : 'New Order',
        'body' : '$userName has placed an order',
        'to':'owner',
      }).then((val) async{
        final response = await http.post(
          'https://www.sunnypajidadhabha.in/php/spddUser/trial.php',
          body: {
            'user_id': userId,
            'order_type': _type == 0 ? "Home Delivery" : "Pickup",
            'order_cost': '${_dishes.getTotalCost(_type == 0 ? 0 : extra)}',
            'dish_json': JsonEncoder().convert(items),
            'uaid': _type == 0 ? "0" : _selectedAddress.ua_id.toString(),
          },
        );
        if (response.body.toString() == 'no') {} else {
          _dishes.removeAllCart();
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
      );
    }

    void _showDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Confirm your order"),
            content: new Text("After you click submit, your order will be confirmed.\nPlease pay ₹${_dishes.getTotalCost(_type==0?0:extra)} when order is delivered."),
            actions: <Widget>[
              new FlatButton(
                child: new Text("PLACE ORDER", style: TextStyle(color: _color),),
                onPressed: () {
                    _placeOrder(_dishes.getCartItems());

                },
              ),
            ],
          );
        },
      );
    }

    Widget _noLogin(){
      return Card(
        elevation: 8,
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: _mediaQuery.height*0.03,),
              Text("Login to place order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              RaisedButton(
                color: _color,
                onPressed: (){
                  Navigator.of(context).pushNamed(LoginScreen.routeName);
                },
                child: Text("Login",style: TextStyle(color: Colors.white,fontSize: 18),),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),

              ),
              SizedBox(height: _mediaQuery.height*0.05,)
            ],
          ),
        ),
      );
    }

    Widget _getMain(){
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: _dishes.getCartItems().map((e) {
                      return _getItem(e);
                    }).toList(),
                  ),
                  code == 0?Container():Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: _mediaQuery.width * 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery Type",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                RaisedButton(
                                  color: _type == 0 ? _color : Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _type = 0;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    "Pickup",
                                    style: TextStyle(
                                        color: _type == 0 ? Colors.white : _color),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                RaisedButton(
                                  color: _type == 1 ? _color : Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _type = 1;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text("Home Delivery",
                                      style: TextStyle(
                                          color: _type == 1 ? Colors.white : _color)),
                                ),
                              ],
                            ),
                            if(_type == 1)_getAddressWidget()
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          code== 1?Card(
            margin: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: _mediaQuery.width*0.1),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Text("Total cost = ₹${_dishes.getTotalCost(_type==0?0:extra)}", textAlign: TextAlign.end,style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: Text("Place Order",style: TextStyle(color: Colors.white, fontSize: 18),),
                      color: _color,
                      onPressed: (){
                        if(_type == 1 && _selected == 0){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Select delivery address"),
                                content: Text("Please select delivery address to place order"),
                                actions: [
                                  FlatButton(
                                    child: Text("Okay",style: TextStyle(color: _color),),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        }else {
                          _showDialog();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: _mediaQuery.height*0.04,),
                ],
              ),
            ),
          ):_noLogin()
        ],
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FOOD CART",
          style: TextStyle(color: _color, fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(
          color: Color(0xffc62828),
        ),
        backgroundColor: Colors.white,
        actions: [
          if(_dishes.getCartItems().length > 0)Padding(
            padding: EdgeInsets.only(right: 15),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _dishes.removeAllCart();
                },
                child: Icon(
                  Icons.delete,
                  color: _color,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _dishes.getCartItems().length == 0 ? _noOrder():_getMain(),

    );
  }
}
