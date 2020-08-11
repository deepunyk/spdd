import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:sunny_paji_da_dhabha/providers/dishes.dart';
import 'package:sunny_paji_da_dhabha/screens/search_screen.dart';

import 'cart_screen.dart';

class CategoryMenuScreen extends StatefulWidget {


  static const routeName = 'categoryMenu';

  @override
  _CategoryMenuScreenState createState() => _CategoryMenuScreenState();
}

class _CategoryMenuScreenState extends State<CategoryMenuScreen> {
  Dishes _dishes;
  String categoryId = "";
  String categoryName = "";
  final box = GetStorage();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryId = box.read('catKey');
    categoryName = box.read('catName');
  }

  @override
  Widget build(BuildContext context) {

    final _mediaQuery = MediaQuery.of(context).size;
    final _color = Theme.of(context).primaryColor;
    _dishes = Provider.of<Dishes>(context);

    Widget _getVegIcon() {
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
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green),
        ),
      );
    }

    Widget _getItem(Map<String, String> item) {
      return Card(
        child: ListTile(
          leading: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: item['dish_img'],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(top: 0, left: 0, child: _getVegIcon()),
            ],
          ),
          title: Text(item['dish_name']),
          subtitle: Text('₹${item['dish_cost']}'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$categoryName",
          style: TextStyle(color: _color, fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(
          color: Color(0xffc62828),
        ),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                child:_dishes.getCartQuantity()==0?Icon(
                  Icons.shopping_cart,
                  color: _color,
                ):Badge(
                  badgeColor: _color,
                  badgeContent: Text(
                    "${_dishes.getCartQuantity()}",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  position: BadgePosition.topRight(top: 2),
                  child: Icon(
                    Icons.shopping_cart,
                    color: _color,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  Navigator.of(context).pushNamed(SearchScreen.routeName);
                },
                child: Icon(
                  Icons.search,
                  color: _color,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GroupedListView<dynamic, String>(
        elements: _dishes.getSelected(categoryId),
        groupBy: (element) => element['category_name'],
        groupSeparatorBuilder: (String groupByValue) => Padding(
            padding: EdgeInsets.only(
                left: _mediaQuery.width * 0.03, top: _mediaQuery.height * 0.01),
            child: Text(
              groupByValue,
              style: TextStyle(
                  color: _color, fontWeight: FontWeight.w500, fontSize: 18),
            )),
        itemBuilder: (context, dynamic element) => _getItem(element),
        order: GroupedListOrder.ASC,
      ),
    );
  }
}
