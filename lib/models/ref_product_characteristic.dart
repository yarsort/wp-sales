
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableProductCharacteristic   = '_ReferenceProductCharacteristic';

/// Справочник.ХарактеристикиТоваров
class ProductCharacteristic {
  int id = 0;                     // Инкремент
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String uidProduct = '';          // Ссылка на родителя (Товар)
  String comment = '';            // Коммментарий

  ProductCharacteristic();

  ProductCharacteristic.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidProduct = json['uidProduct'] ?? '';
    comment = json['comment'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['uidProduct'] = uidProduct;
    data['comment'] = comment;
    return data;
  }
}

/// Поля для базы данных
class ItemProductCharacteristicFields {
  static final List<String> values = [
    id,
    uid,
    code,
    name,
    uidProduct,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidProduct = 'uidProduct';
  static const String comment = 'comment';

}