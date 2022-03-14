
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableAccumProductPrices   = '_AccumProductPrices';

class AccumProductPrice {
  int id = 0;
  String uidPrice = '';
  String uidProduct = '';
  String uidUnit = '';
  double price = 0.0;

  AccumProductPrice();

  AccumProductPrice.fromJson(Map<String, dynamic> json) {
    uidPrice = json["uidPrice"]??'';
    uidProduct = json["uidProduct"]??'';
    uidUnit = json["uidUnit"]??'';
    price = json["price"].toDouble()??0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['uidPrice'] = uidPrice;
    data['uidProduct'] = uidProduct;
    data['uidUnit'] = uidUnit;
    data['price'] = price;
    return data;
  }
}

/// Поля для базы данных
class ItemAccumProductPricesFields {
  static final List<String> values = [
    id,
    uidPrice,
    uidProduct,
    uidUnit,
    price,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String uidPrice = 'uidPrice';
  static const String uidProduct = 'uidProduct';
  static const String uidUnit = 'uidUnit';
  static const String price = 'price';
}