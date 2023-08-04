import 'dart:convert';

RidersModel ridersModelFromJson(String str) => RidersModel.fromJson(json.decode(str));
Data riderFromJson(String str) => Data.fromJson(json.decode(str));

class RidersModel {
  RidersModel({
     this.data,
     this.meta,
  });
  late final List<Data>? data;

  late final Meta? meta;

  RidersModel.fromJson(Map<String, dynamic> json){
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
    meta = Meta.fromJson(json['meta']);
  }

  /*Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['data'] = data.map((e)=>e.toJson()).toList();
    _data['links'] = links.toJson();
    _data['meta'] = meta.toJson();
    return _data;
  }*/
}

class Data {
  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.firstName,
    this.lastName,
  });
  late final int id;
  late final String? name;
  late final String? firstName;
  late final String? lastName;
  late final String? email;
  late final String phone;

  Data.fromJson(Map<String, dynamic> json){
    id = json['data']['id'];
    name = json['data']['name'];
    firstName = json['data']['first_name'];
    lastName = json['data']['last_name'];
    email = json['data']['email'];
    phone = json['data']['phone'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['email'] = email;
    _data['phone'] = phone;
    return _data;
  }
}


class Meta {
  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });
  late final int currentPage;
  late final int from;
  late final int lastPage;
  late final String path;
  late final int perPage;
  late final int to;
  late final int total;

  Meta.fromJson(Map<String, dynamic> json){
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['current_page'] = currentPage;
    _data['from'] = from;
    _data['last_page'] = lastPage;
    _data['path'] = path;
    _data['per_page'] = perPage;
    _data['to'] = to;
    _data['total'] = total;
    return _data;
  }
}