
/// Справочник.Магазин (Торгова точка)
class Store {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя
  String uidOrganization = '';    // Ссылка на организацию
  String uidPartner = '';         // Ссылка на партнер
  String uidContract = '';        // Ссылка на контракт
  String uidPrice = '';           // Ссылка на тип цены продажи
  String address = '';            // Адрес магазина
  String comment = '';            // Коммментарий
  DateTime dateEdit = DateTime.now(); // Дата редактирования

  Store();

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidOrganization = json['uidOrganization'] ?? '';
    uidPartner = json['uidPartner'] ?? '';
    uidContract = json['uidContract'] ?? '';
    uidPrice = json['uidPrice'] ?? '';
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
    data['uidOrganization'] = uidOrganization;
    data['uidPartner'] = uidPartner;
    data['uidContract'] = uidContract;
    data['uidPrice'] = uidPrice;
    data['address'] = address;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    return data;
  }
}
