import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sunny_paji_da_dhabha/providers/dishes.dart';

class SearchScreen extends StatefulWidget {

  static const routeName = 'search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  Dishes _dishes;
  String _searchValue = "";

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
              Image.network(
                item['dish_img'],
                fit: BoxFit.cover,
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

    Widget _getList(){
      if(_dishes.searchItem(_searchValue).length>0){
        return ListView(
            children:
            _dishes.searchItem(_searchValue).map((e) {
              return _getItem(e);
            }).toList()
        );
      }else{
        return Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network('https://assets10.lottiefiles.com/packages/lf20_MrIjH2.json', width: _mediaQuery.width*0.5),
              Text("No items found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            ],
          ),
        );
      }

    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color(0xffc62828),
        ),
        title: TextField(autofocus: true,onChanged: (val){
          _searchValue = val;
          setState(() {

          });
        },),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.search,
              color: _color,
            ),
          ),
        ],
      ),
      body: _getList()

    );
  }
}
