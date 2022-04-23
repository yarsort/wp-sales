
/// Справочник.Товары
class Product {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String nameForSearch = '';               // Имя для поиска
  String vendorCode = '';         // Артикул товара в 1С
  String uidParent = '';          // Ссылка на группу
  String uidUnit = '';            // Ссылка на единицу измерения
  String nameUnit = '';           // Имя ед. изм.
  String barcode = '';            // Имя ед. изм.
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования

  Product();

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = json['isGroup'];
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    nameForSearch = json['name'].toLowerCase() ?? '';
    vendorCode = json['vendorCode'] ?? '';
    uidParent = json['uidParent'] ?? '';
    uidUnit = json['uidUnit'] ?? '';
    nameUnit = json['nameUnit'] ?? '';
    barcode = json['barcode'] ?? '';
    comment = json['comment'] ?? '';
    dateEdit = DateTime.parse(json['dateEdit'] ?? DateTime.now().toIso8601String());
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
    data['nameForSearch'] = nameForSearch;
    data['vendorCode'] = vendorCode;
    data['uidParent'] = uidParent;
    data['uidUnit'] = uidUnit;
    data['nameUnit'] = nameUnit;
    data['barcode'] = barcode;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}
