
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableCurrency   = '_ReferenceCurrency';

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

  Currency();

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidParent = json['uidParent'] ?? '';
    course = json['course'] ?? 0.0;
    multiplicity = json['multiplicity'] ?? 0.0;
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
    data['course'] = course;
    data['multiplicity'] = multiplicity;
    data['comment'] = comment;
    return data;
  }
}

/// Поля для базы данных
class ItemCurrencyFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidParent,
    course,
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
  static const String course = 'course';
  static const String multiplicity = 'multiplicity';
  static const String comment = 'comment';

}