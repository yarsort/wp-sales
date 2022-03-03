
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableOrganization   = 'tableOrganization';

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

  //int sendNoTo1C = 0;  // Булево: "Отправлено в 1С" - для фильтрации в списках
  //DateTime dateSendingTo1C = DateTime(1900, 1, 1); // Дата отправки заказа в 1С из мобильного устройства

//<editor-fold desc="Data Methods">

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
