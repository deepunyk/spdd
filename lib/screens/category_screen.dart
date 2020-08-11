import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:sunny_paji_da_dhabha/providers/dishes.dart';
import 'package:sunny_paji_da_dhabha/screens/category_menu_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/menu_screen.dart';
import 'package:sunny_paji_da_dhabha/screens/search_screen.dart';

import 'cart_screen.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = 'category';

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  Dishes _dishes;
  int code = 0;
  int _cur = 0;
  CarouselController _controller = CarouselController();

  List<String> _carImg = [];
  List<String> _carText = [];

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context).size;
    final _color = Theme.of(context).primaryColor;
    _dishes = Provider.of<Dishes>(context);

    if(code == 0){
      _dishes.getCarImages().map((e) => _carImg.add(e)).toList();
      _dishes.getCarTxt().map((e) => _carText.add(e)).toList();
      code++;
    }

    Widget _getCounter(int code) {
      return Container(
        width: _cur == code?_mediaQuery.height*0.015:_mediaQuery.height * 0.01,
        height: _cur == code?_mediaQuery.height*0.015:_mediaQuery.height * 0.01,
        margin: EdgeInsets.only(right: _mediaQuery.width*0.01),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              _cur == code
                  ? BoxShadow(
                  color: Theme.of(context).accentColor,
                  blurRadius: 3,
                  spreadRadius: 1)
                  : BoxShadow(),
            ]),
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _controller.animateToPage(code);
              },
            ),
          ),
        ),
      );
    }

    Widget _getCarCard(int num) {
      return Stack(
        children: [
          Positioned.fill(
            child: FadeInImage(
              image: CachedNetworkImageProvider(_carImg[num]),
              placeholder: AssetImage('assets/images/main_logo.png'),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
                decoration: BoxDecoration(
                    color: Color(0x99c62828),
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(10))),
                padding:
                    EdgeInsets.only(left: 15, bottom: 6, right: 10, top: 6),
                child: Text(
                  "Paji's Special",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 18),
                )),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
                decoration: BoxDecoration(
                    color: Color(0x99c62828),
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(10))),
                padding:
                    EdgeInsets.only(left: 25, bottom: 10, right: 10, top: 6),
                child: Text(
                  "${_carText[num]}",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 20),
                )),
          ),

        ],
      );
    }

    Widget _getCatCard(Map<String, dynamic> category) {
      return Card(
        margin: EdgeInsets.symmetric(
            horizontal: _mediaQuery.width * 0.02, vertical: _mediaQuery.height*0.01),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.red,
              onTap: (){
                final box = GetStorage();
                box.write('catKey', category['id']);
                box.write('catName', category['name']);
                Navigator.of(context).pushNamed(CategoryMenuScreen.routeName);
              },
              child: Container(
                height: _mediaQuery.height*0.1,
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: FadeInImage(
                          image: CachedNetworkImageProvider(category['img']),
                          placeholder: AssetImage('assets/images/main_logo.png'),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0x40c62828),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding:
                              EdgeInsets.only(left: _mediaQuery.width*0.03, top: 5,bottom: _mediaQuery.height*0.01, right: _mediaQuery.width*0.03),
                          child: Text(
                            category['name'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,shadows: [Shadow(color: Colors.black,blurRadius: 3,),]),textAlign: TextAlign.start,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pushNamed(MenuScreen.routeName);
        },
        child: Icon(Icons.restaurant_menu),
      ),
      appBar: AppBar(
        title: Text(
            "Sunny Paji Da Dhaba",
          style: TextStyle(color: _color, fontWeight: FontWeight.w600),
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
                child: _dishes.getCartQuantity()==0?Icon(
                  Icons.shopping_cart,
                  color: _color,
                ):Badge(
                  badgeColor: _color,
                  badgeContent: Text(
                    _dishes.getCartQuantity().toString(),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: _mediaQuery.height*0.25,
              width: double.infinity,
              child: Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                        carouselController: _controller,
                        scrollPhysics: BouncingScrollPhysics(),
                        height: _mediaQuery.height * 0.25,
                        initialPage: 0,
                        viewportFraction: 1,
                        autoPlayInterval: Duration(seconds: 3),
                        onPageChanged: (val, _) {
                          setState(() {
                            _cur = val;
                          });
                        },
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false),
                    items:[
                          for(int i = 0; i < _carImg.length;i++)_getCarCard(i)
                    ]
                  ),
                  Positioned(
                    right: _mediaQuery.width * 0.08,
                    bottom: _mediaQuery.height * 0.01,
                    child: Row(
                      children: [for(int i = 0; i< _dishes.getCarImages().length;i++)_getCounter(i)],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: _mediaQuery.height * 0.01,
            ),
            Text(
              "Categories",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: _mediaQuery.height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _mediaQuery.width*0.01),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                shrinkWrap: true,
                childAspectRatio: 1.4,
                children: List.generate(_dishes.getCategories().length, (index) {
                  return _getCatCard(_dishes.getCategories()[index]);
                },),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
