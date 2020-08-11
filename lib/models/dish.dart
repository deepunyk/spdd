class Dish{
  final dish_name;
  final dish_cost;
  final dish_img;
  final category_id;
  final dish_isVeg;
  final dish_isAvail;
  final category_name;
  int quantity;
  final category_image;
  final dish_isFav;
  final dish_id;

  Dish(
  {this.dish_name,
      this.dish_cost,
      this.dish_img,
      this.category_id,
      this.dish_isVeg,
      this.dish_isAvail,
      this.category_name,
      this.quantity,
      this.category_image,
      this.dish_isFav,this.dish_id});

  Map<String, String>getDish(){
    return {
      'category_id': category_id,
      'category_image': category_image,
      'category_name': category_name,
      'dish_cost': dish_cost,
      'dish_img': dish_img,
      'dish_isAvail': dish_isAvail,
      'dish_isFav': dish_isFav,
      'dish_isVeg': dish_isVeg,
      'dish_name': dish_name,
      'quantity': quantity.toString(),
      'dish_id':dish_id,
    };
  }

}