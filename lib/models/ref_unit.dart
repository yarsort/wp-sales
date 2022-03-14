
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableUnit   = '_ReferenceUnit';

/// Справочник.ЕдиницыИзмерения
class Unit {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String uidParent = '';          // Ссылка на группу
  double multiplicity = 0.0;      // Кратность
  String comment = '';            // Коммментарий

  Unit();

  Unit.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidParent = json['uidParent'] ?? '';
    multiplicity = json['multiplicity'] ?? 1.0;
    comment = json['comment'] ?? '';
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
    data['multiplicity'] = multiplicity;
    data['comment'] = comment;
    return data;
  }
}

/// Поля для базы данных
class ItemUnitFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidParent,
    multiplicity,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String multiplicity = 'multiplicity';
  static const String comment = 'comment';

}