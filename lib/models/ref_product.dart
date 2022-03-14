
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableProduct   = '_ReferenceProduct';

/// Справочник.Товары
class Product {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String vendorCode = '';         // Артикул товара в 1С
  String uidParent = '';          // Ссылка на группу
  String uidUnit = '';            // Ссылка на единицу измерения
  String nameUnit = '';           // Имя ед. изм.
  String barcode = '';            // Имя ед. изм.
  String comment = '';            // Коммментарий

  Product();

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = json['isGroup'];
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    vendorCode = json['vendorCode'] ?? '';
    uidParent = json['uidParent'] ?? '';
    uidUnit = json['uidUnit'] ?? '';
    nameUnit = json['nameUnit'] ?? '';
    barcode = json['barcode'] ?? '';
    comment = json['comment'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['isGroup'] = isGroup;
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['vendorCode'] = vendorCode;
    data['uidParent'] = uidParent;
    data['uidUnit'] = uidUnit;
    data['nameUnit'] = nameUnit;
    data['barcode'] = barcode;
    data['comment'] = comment;
    return data;
  }
}

/// Поля для базы данных
class ItemProductFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    vendorCode,
    uidParent,
    uidUnit,
    nameUnit,
    barcode,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String vendorCode = 'vendorCode';
  static const String uidParent = 'uidParent';
  static const String uidUnit = 'uidUnit';
  static const String nameUnit = 'nameUnit';
  static const String barcode = 'barcode';
  static const String comment = 'comment';
}