
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableAccumProductRests   = '_AccumProductRests';

class AccumProductRest {
  int id = 0;
  String uidWarehouse = '';
  String uidProduct = '';
  String uidUnit = '';
  double count = 0.0;

  AccumProductRest();

  AccumProductRest.fromJson(Map<String, dynamic> json) {
    uidWarehouse = json["uidPrice"]??'';
    uidProduct = json["uidProduct"]??'';
    uidUnit = json["uidUnit"]??'';
    count = json["price"].toDouble()??0.0;
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

/// Поля для базы данных
class ItemAccumProductRestsFields {
  static final List<String> values = [
    id,
    uidWarehouse,
    uidProduct,
    uidUnit,
    count,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String uidWarehouse = 'uidWarehouse';
  static const String uidProduct = 'uidProduct';
  static const String uidUnit = 'uidUnit';
  static const String count = 'count';
}