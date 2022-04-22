
/// Справочник.Валюта
class Currency {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String uidParent = '';          // Ссылка на группу
  double course = 0.0;            // Курс валюты
  double multiplicity = 0.0;      // Кратность валюты
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования

  Currency();

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidParent = json['uidParent'] ?? '';
    course = json['course'].toDouble() ?? 0.0;
    multiplicity = json['multiplicity'].toDouble() ?? 0.0;
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
    data['course'] = course;
    data['multiplicity'] = multiplicity;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}
