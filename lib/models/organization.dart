
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableOrganization   = '_ReferenceOrganization';

/// Справочник.Организации
class Organization {
  int id = 0;                     // Инкремент
  bool isGroup = false;           // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя партнера
  String uidParent = '';          // Ссылка на группу
  String phone = '';              // Контакты
  String address = '';            // Адрес
  String comment = '';            // Коммментарий

  Organization();

  Organization.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = json['isGroup'] ?? false;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidParent = json['uidParent'] ?? '';
    phone = json['phone'] ?? '';
    address = json['address'] ?? '';
    comment = json['comment'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isGroup'] = isGroup.toString();
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['uidParent'] = uidParent;
    data['phone'] = phone;
    data['address'] = address;
    data['comment'] = comment;
    return data;
  }
}

/// Поля для базы данных
class ItemOrganizationFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidParent,
    phone,
    address,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String phone = 'phone';
  static const String address = 'address';
  static const String comment = 'comment';

}