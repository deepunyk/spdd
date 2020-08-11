import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sunny_paji_da_dhabha/providers/dishes.dart';
import 'package:sunny_paji_da_dhabha/screens/about_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/menu_screen.dart';
import 'package:http/http.dart' as http;

class OrderScreen extends StatefulWidget {
  static const routeName = 'order';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  bool _isLoad = true;
  String userId = "";
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _orderDish = [];
  List<Map<String, dynamic>> _completeOrder = [];
  List<Map<String, dynamic>> _progressOrder = [];

  int code = 0;

  _getUserData() {
    final box = GetStorage();
    if (box.hasData('userData')) {
      final userData = box.read('userData');
      _getOrders();
      setState(() {
        code = 1;
      });
    }
  }

  _getOrders() async {
    setState(() {
      _isLoad = true;
    });
    final box = GetStorage();
    final userData = box.read('userData');
    userId = userData[0]['user_id'];
    final response = await http.post(
      'https://www.sunnypajidadhabha.in/php/spddUser/getOrders.php',
      body: {
        'user_id': userId,
      },
    );
    if (response.body.toString() == 'no') {
      setState(() {
        _isLoad = false;
      });
    } else {
      final userResponse = json.decode(response.body);
      final allData = userResponse['allOrders'];
      _orders = allData['orders'].cast<Map<String, dynamic>>();
      _orderDish = allData['orderDish'].cast<Map<String, dynamic>>();
      _orders.map((e) {
        if (e['order_status'] == 'Delivered') {
          _completeOrder.add(e);
        } else {
          _progressOrder.add(e);
        }
      }).toList();
      setState(() {
        _isLoad = false;
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

    String _getOrderText(String id) {
      String orderText = "";
      int cnt = 0;
      _orderDish.map((e) {
        if (e['order_id'] == id) {
          if (cnt == 0) {
            orderText += e['dish_name'];
            cnt++;
          } else {
            orderText += ", " + e['dish_name'];
          }
        }
      }).toList();
      return orderText;
    }

    String getOrderTextAll(String id) {
      String orderText = "";
      int cnt = 0;
      _orderDish.map((e) {
        if (e['order_id'] == id) {
          if (cnt == 0) {
            orderText += e['dish_name'];
            orderText += " * " + e['orderDish_quantity'];
            cnt++;
          } else {
            orderText += "\n" + e['dish_name'];
            orderText += " * " + e['orderDish_quantity'];
          }
        }
      }).toList();
      return orderText;
    }

    _showOrderDetail(Map<String,dynamic> order){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Order Details",style: TextStyle(color: _color,fontWeight: FontWeight.w500, fontSize: 18),),
                Container(margin: EdgeInsets.symmetric(vertical: 10),height: 2,width: _mediaQuery.width*0.6,color: _color,),
                Text(getOrderTextAll(order['order_id']), textAlign: TextAlign.center,),
                Text("Order Status: ${order['order_status']}", style: TextStyle(color: Colors.black54, fontSize: 14),),
                Text("Order Type: ${order['orderType']}",style: TextStyle(color: Colors.black54, fontSize: 14),),
                Container(margin: EdgeInsets.symmetric(vertical: 10),height: 2,width: _mediaQuery.width*0.6,color: _color,),
                Text("Total cost: ₹${order['order_cost']}",style: TextStyle(color: _color,fontWeight: FontWeight.w500, fontSize: 18)),
                RaisedButton(child: Text("Close",style: TextStyle(color: Colors.white),),onPressed: (){Navigator.of(context).pop();},color: _color,)
              ],
            ),
          );
        },
      );
    }

    Widget _getCurrentCard(Map<String, dynamic> item) {
      return Card(
        child: ListTile(
          title: Text(
            "${_getOrderText(item['order_id'])}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
              "Status : ${item['order_status']}\nType: ${'${item['orderType']}'}"),
          trailing: Text("Cost: ₹${item['order_cost']}"),
          isThreeLine: true,
          onTap: (){
            _showOrderDetail(item);
          },
        ),
      );
    }

    Widget _getDoneCard(Map<String, dynamic> item) {
      return Card(
        child: ListTile(
          title: Text(
            "${_getOrderText(item['order_id'])}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
              "Status : ${item['order_status']}\nType: ${'${item['orderType']}'}"),
          trailing: Text("Cost: ₹${item['order_cost']}"),
          isThreeLine: true,
          onTap: (){
            _showOrderDetail(item);
          },
        ),
      );
    }

    Widget _getOrders() {
      return Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Text(
                    "Order in Progress",
                    style: TextStyle(fontSize: 20),
                  )),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 2,
                width: _mediaQuery.width * 0.9,
                color: _color,
              ),
              SizedBox(
                height: 10,
              ),
              _progressOrder.length == 0
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("No Orders", style: TextStyle(fontSize: 18)),
                    )
                  : Container(
                      child: ListView.builder(
                        itemCount: _progressOrder.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new Column(
                            children: <Widget>[
                              _getCurrentCard(_progressOrder[index])
                            ],
                          );
                        },
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Completed Orders",
                    style: TextStyle(fontSize: 20),
                  )),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 2,
                width: _mediaQuery.width * 0.9,
                color: _color,
              ),
              SizedBox(
                height: 10,
              ),
              _completeOrder.length == 0
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "No Orders",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : Container(
                      child: ListView.builder(
                        itemCount: _completeOrder.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new Column(
                            children: <Widget>[
                              _getDoneCard(_completeOrder[index])
                            ],
                          );
                        },
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                      ),
                    ),
            ],
          ),
        ),
      );
    }

    Widget _noOrder() {
      return Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_MrIjH2.json',
                width: _mediaQuery.width * 0.5),
            Text(
              "No Orders Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            RaisedButton(
              color: _color,
              onPressed: () {
                Navigator.of(context).pushNamed(MenuScreen.routeName);
              },
              child: Text(
                "Place Order",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            )
          ],
        ),
      );
    }

    Widget _getLoad() {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWave(
              color: _color,
              size: _mediaQuery.width * 0.1,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Please wait",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            )
          ],
        ),
      );
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "ORDERS",
            style: TextStyle(color: _color, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 15),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).pushNamed(AboutScreen.routeName);
                    },
                    child: Icon(
                      Icons.help,
                      color: _color,
                    ),
                  ),
                ))
          ],
        ),
        body: code == 0
            ? _noOrder()
            : _isLoad
                ? _getLoad()
                : _orders.length == 0 ? _noOrder() : _getOrders());
  }
}
