
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableContract   = '_ReferenceContract';

/// Справочник.Договоры партнера
class Contract {
  int id = 0;                     // Инкремент
  bool isGroup = false;           // Пометка удаления
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
    isGroup = json['isGroup'] ?? false;
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
    schedulePayment = json['schedulePayment'] ?? 0; // Отсрочка платежа в днях (int)
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isGroup'] = isGroup.toString();
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['uidParent'] = uidParent;
    data['balance'] = balance.toString();
    data['balanceForPayment'] = balanceForPayment.toString();
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

/// Поля для базы данных
class ItemContractFields {
  static final List<String> values = [
    id,                // Инкремент
    isGroup,           // Пометка удаления
    uid,               // UID для 1С и связи с ТЧ
    code,              // Код для 1С
    name,              // Имя партнера
    uidParent,         // Ссылка на группу
    balance,           // Баланс
    balanceForPayment, // Баланс к оплате
    phone,             // Контакты
    address,           // Адрес
    comment,           // Коммментарий
    namePartner,       // Имя партнера
    uidPartner,        // Ссылка на партнера
    uidPrice,          // Ссылка тип цены
    namePrice,         // Имя типа цены
    uidCurrency,       // Ссылка валюты
    nameCurrency,      // Имя валюты
    schedulePayment,   // Отсрочка платежа
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';
  static const String isGroup = 'isGroup';
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String balance = 'balance';
  static const String balanceForPayment = 'balanceForPayment';
  static const String phone = 'phone';
  static const String address = 'address';
  static const String comment = 'comment';
  static const String namePartner = 'namePartner';
  static const String uidPartner = 'uidPartner';
  static const String uidPrice = 'uidPrice';
  static const String namePrice = 'namePrice';
  static const String uidCurrency = 'uidCurrency';
  static const String nameCurrency = 'nameCurrency';
  static const String schedulePayment = 'schedulePayment';
}