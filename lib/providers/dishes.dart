import 'package:flutter/material.dart';
import 'package:sunny_paji_da_dhabha/models/dish.dart';

class Dishes with ChangeNotifier {
  List<Dish> _dishes = [];

  void addDish(Dish dish) {
    _dishes.add(dish);
  }

  clear(){
    _dishes.clear();
  }

  int getCartQuantity() {
    int count = 0;
    for (var i = 0; i < _dishes.length; i++) {
      if (_dishes[i].quantity > 0) {
        count++;
      }
    }
    getCategories();
    return count;
  }

  List<Map<String, dynamic>> getCategories() {
    List<Map<String,dynamic>> _categories = [];
    List<String> _catName = [];
    _dishes.map((e){
      if(!_catName.contains(e.category_name)) {
        _catName.add(e.category_name);
        _categories.add({
          'name': e.category_name,
          'img': e.category_image,
          'id': e.category_id,
        });
      }
    }).toList();
    return _categories;
  }

  List<String> getCarImages(){
    List<String> _favList = [];

    _dishes.map((e){
      if(e.dish_isFav == "1"){
        _favList.add(e.dish_img);

      }
    }).toList();

    return _favList;
  }

  List<String> getCarTxt(){
    List<String> _favList = [];
    _dishes.map((e){
      if(e.dish_isFav == "1"){
        _favList.add(e.dish_name);
      }
    }).toList();
    return _favList;
  }

  List getMenu() {
    List menu = [];
    _dishes.map((e){
      menu.add(e.getDish());
    }).toList();
    return menu;
  }

  List getSelected(String id) {
    List menu = [];
    _dishes.map((e){
      if(e.category_id == id){
        menu.add(e.getDish());
      }
    }).toList();
    return menu;
  }


  addItem(String id){
    _dishes.map((e) {
      if(e.dish_id == id){
        e.quantity++;
      }
    }).toList();
    notifyListeners();
  }

  removeItem(String id){
    _dishes.map((e) {
      if(e.dish_id == id){
        if(e.quantity!=0){
          e.quantity--;
        }
      }
    }).toList();
    notifyListeners();
  }

  List searchItem(String val){
    List menu = [];
    _dishes.map((e){
      final searchValue = e.dish_name.toString().toUpperCase();
      if(searchValue.contains(val.toUpperCase())){
        menu.add(e.getDish());
      }
    }).toList();
    return menu;
  }

  List getCartItems(){
    List menu = [];
    _dishes.map((e){
      if(e.quantity>0){
        menu.add(e.getDish());
      }
    }).toList();
    return menu;
  }

  String getTotalCost(int num){
    int totalCost = 0;
    _dishes.map((e){
      if(e.quantity>0){
        totalCost += e.quantity * int.parse(e.dish_cost);
      }
    }).toList();
    totalCost += num;
    return totalCost.toString();
  }

  removeAllCart(){
    _dishes.map((e){
      e.quantity = 0;
    }).toList();
    notifyListeners();
  }
}