import 'package:flutter/material.dart';
import 'package:sunny_paji_da_dhabha/models/address.dart';

class Addresses with ChangeNotifier {
  List<Address> _addresses = [];

  void addAddress(Address address){
    _addresses.add(address);
  }

  List<Address> getAddress(){
    print(_addresses.length.toString());
    return [..._addresses];
  }

  clear(){
    _addresses.clear();
  }

}