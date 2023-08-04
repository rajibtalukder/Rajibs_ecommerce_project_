import 'Ingredient_list_model.dart';

class ProductionUnitItemModel {
  String id;
  String sl;
  Ingrediant itemInfo;
  int qty;
  String unit;
  double price;

  ProductionUnitItemModel(
      {
        required this.id,
        required this.sl,
      required this.itemInfo,
      required this.qty,
      required this.unit,
      required this.price});

  Map<String, dynamic> toJson() => {
    "id":id,
    "ingredient":itemInfo.id,
    "quantity":qty,
    "unit": unit,
    "price":price
  };
}

