
class AccumProductRest {
  int id = 0;
  String uidWarehouse = '';
  String uidProduct = '';
  String uidUnit = '';
  double count = 0.0;

  AccumProductRest();

  AccumProductRest.fromJson(Map<String, dynamic> json) {
    uidWarehouse = json["uidWarehouse"]??'';
    uidProduct = json["uidProduct"]??'';
    uidUnit = json["uidUnit"]??'';
    count = json["count"].toDouble()??0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['uidWarehouse'] = uidWarehouse;
    data['uidProduct'] = uidProduct;
    data['uidUnit'] = uidUnit;
    data['count'] = count;
    return data;
  }
}
