import 'dart:convert';

AddMenuModel addMenuModelFromJson(String str) => AddMenuModel.fromJson(json.decode(str));

class AddMenuModel {
  AddMenuModel({
    required this.categories,
    required this.mealPeriods,
    required this.addons,
    required this.allergies,
    required this.ingredients,
    required this.suppliers,
    required this.banks,
  });
  late final List<Categories> categories;
  late final List<MealPeriods> mealPeriods;
  late final List<Addons> addons;
  late final List<Allergies> allergies;
  late final List<Ingredients> ingredients;
  late final List<Suppliers> suppliers;
  late final List<Banks> banks;

  AddMenuModel.fromJson(Map<String, dynamic> json){
    categories = List.from(json['categories']).map((e)=>Categories.fromJson(e)).toList();
    mealPeriods = List.from(json['meal_periods']).map((e)=>MealPeriods.fromJson(e)).toList();
    addons = List.from(json['addons']).map((e)=>Addons.fromJson(e)).toList();
    allergies = List.from(json['allergies']).map((e)=>Allergies.fromJson(e)).toList();
    ingredients = List.from(json['ingredients']).map((e)=>Ingredients.fromJson(e)).toList();
    suppliers = List.from(json['suppliers']).map((e)=>Suppliers.fromJson(e)).toList();
    banks = List.from(json['banks']).map((e)=>Banks.fromJson(e)).toList();
  }

}

class Categories {
  Categories({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Categories.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}

class MealPeriods {
  MealPeriods({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  MealPeriods.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}

class Addons {
  Addons({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Addons.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}

class Allergies {
  Allergies({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Allergies.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}

class Ingredients {
  Ingredients({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity ,
    required this.expireDate ,
  });
  late final int id;
  late final String name;
  late String price;
  late String expireDate;
  late String unitName;
  late int quantity;


  Ingredients.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    price = json['purchase_price'];
    unitName = json['unit_name'];
    quantity = 1;
    expireDate = '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['unit_price'] = price;
    _data['expire_date'] = expireDate;
    _data['quantity_amount'] = quantity;
    return _data;
  }
}

class Suppliers {
  Suppliers({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Suppliers.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}

class Banks {
  Banks({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Banks.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}