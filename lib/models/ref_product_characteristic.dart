
/// Справочник.ХарактеристикиТоваров
class ProductCharacteristic {
  int id = 0;                     // Инкремент
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String uidProduct = '';          // Ссылка на родителя (Товар)
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования

  ProductCharacteristic();

  ProductCharacteristic.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidProduct = json['uidProduct'] ?? '';
    comment = json['comment'] ?? '';
    dateEdit = DateTime.parse(json['dateEdit'] ?? DateTime.now());
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
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}
