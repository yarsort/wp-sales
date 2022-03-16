
/// Справочник.Договоры партнера
class Contract {
  int id = 0;                     // Инкремент
  int isGroup = 0;                // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String code = '';               // Код для 1С
  String name = '';               // Имя партнера
  String uidParent = '';          // Ссылка на группу
  double balance = 0.0;           // Баланс
  double balanceForPayment = 0.0; // Баланс к оплате
  String phone = '';              // Контакты
  String address = '';            // Адрес
  String comment = '';            // Коммментарий
  String namePartner = '';        // Имя партнера
  String uidPartner = '';         // Ссылка на партнера
  String uidPrice = '';           // Ссылка тип цены
  String namePrice = '';          // Имя типа цены
  String uidCurrency = '';        // Ссылка валюты
  String nameCurrency = '';       // Имя валюты
  int schedulePayment = 0;        // Отсрочка платежа

  Contract();

  Contract.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    isGroup = 0;
    uid = json['uid'] ?? '';
    code = json['code'] ?? '';
    name = json['name'] ?? '';
    uidParent = json['uidParent'] ?? '';
    balance = json['balance'] ?? 0.0;
    balanceForPayment = json['balanceForPayment'] ?? 0.0;
    phone = json['phone'] ?? '';
    address = json['address'] ?? '';
    comment = json['comment'] ?? '';
    uidPartner = json['uidPartner'] ?? '';
    namePartner = json['namePartner'] ?? '';
    uidPrice = json['uidPrice'] ?? '';
    namePrice = json['namePrice'] ?? '';
    uidCurrency = json['uidCurrency'] ?? '';
    nameCurrency = json['nameCurrency'] ?? '';
    schedulePayment = json['schedulePayment']; // Отсрочка платежа в днях (int)
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
    data['uidParent'] = uidParent;
    data['balance'] = balance;
    data['balanceForPayment'] = balanceForPayment;
    data['phone'] = phone;
    data['address'] = address;
    data['comment'] = comment;
    data['uidPartner'] = uidPartner;
    data['namePartner'] = namePartner;
    data['uidPrice'] = uidPrice;
    data['namePrice'] = namePrice;
    data['uidCurrency'] = uidCurrency;
    data['nameCurrency'] = nameCurrency;
    data['schedulePayment'] = schedulePayment;
    return data;
  }
}