
class AccumProductRest {
  int id = 0;
  int idRegistrar = 0;
  String uidWarehouse = '';
  String uidProduct = '';
  String uidProductCharacteristic = '';
  String uidUnit = '';
  double count = 0.0;

  AccumProductRest();

  AccumProductRest.fromJson(Map<String, dynamic> json) {
    idRegistrar = json["idRegistrar"]??0;
    uidWarehouse = json["uidWarehouse"]??'';
    uidProduct = json["uidProduct"]??'';
    uidProductCharacteristic = json["uidProductCharacteristic"]??'';
    uidUnit = json["uidUnit"]??'';
    count = json["count"].toDouble()??0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['idRegistrar'] = idRegistrar;
    data['uidWarehouse'] = uidWarehouse;
    data['uidProduct'] = uidProduct;
    data['uidProductCharacteristic'] = uidProductCharacteristic;
    data['uidUnit'] = uidUnit;
    data['count'] = count;
    return data;
  }
}
