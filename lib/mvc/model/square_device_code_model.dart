class SquareDeviceCodeModel {
  SquareDeviceCodeModel({
    required this.deviceCode,
  });
  late final DeviceCode deviceCode;

  SquareDeviceCodeModel.fromJson(Map<String, dynamic> json){
    deviceCode = DeviceCode.fromJson(json['device_code']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['device_code'] = deviceCode.toJson();
    return data;
  }
}

class DeviceCode {
  DeviceCode({
    required this.id,
    required this.name,
    required this.code,
    required this.productType,
    required this.locationId,
    required this.pairBy,
    required this.createdAt,
    required this.status,
    required this.statusChangedAt,
  });
  late final String id;
  late final String name;
  late final String code;
  late final String productType;
  late final String locationId;
  late final String pairBy;
  late final String createdAt;
  late final String status;
  late final String statusChangedAt;

  DeviceCode.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    code = json['code'];
    productType = json['product_type'];
    locationId = json['location_id'];
    pairBy = json['pair_by'] ?? "";
    createdAt = json['created_at'];
    status = json['status'];
    statusChangedAt = json['status_changed_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['product_type'] = productType;
    data['location_id'] = locationId;
    data['pair_by'] = pairBy;
    data['created_at'] = createdAt;
    data['status'] = status;
    data['status_changed_at'] = statusChangedAt;
    return data;
  }
}