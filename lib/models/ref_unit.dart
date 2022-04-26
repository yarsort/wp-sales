
/// Справочник.ЕдиницыИзмерения
class Unit {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String uidProduct = '';         // Ссылка на товар
  double multiplicity = 0.0;      // Кратность
  double weight = 0.0;            // Вес
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования

  Unit();

  Unit.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidProduct = json['uidProduct'] ?? '';
    multiplicity = json['multiplicity'].toDouble() ?? 1.0;
    weight = json['weight'].toDouble() ?? 0.0;
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
    data['uidProduct'] = uidProduct;
    data['multiplicity'] = multiplicity;
    data['weight'] = weight;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}
