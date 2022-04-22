
/// Справочник.Склады
class Warehouse {
  int id = 0;                     // Инкремент
  int isGroup = 0;           // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя партнера
  String uidParent = '';          // Ссылка на группу
  String phone = '';              // Контакты
  String address = '';            // Адрес
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования

  Warehouse();

  Warehouse.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidParent = json['uidParent'] ?? '';
    phone = json['phone'] ?? '';
    address = json['address'] ?? '';
    comment = json['comment'] ?? '';
    dateEdit = DateTime.parse(json['dateEdit'] ?? DateTime.now().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['isGroup'] = 0;
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['uidParent'] = uidParent;
    data['phone'] = phone;
    data['address'] = address;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}
