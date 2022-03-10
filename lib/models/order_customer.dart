
///***********************************
/// Название таблиц базы данных
///***********************************
const String tableOrderCustomer   = '_DocumentOrderCustomer';
const String tableItemsOrderCustomer   = '_DocumentOrderCustomer_VT1'; // Товары

/// Документы.ЗаказПокупателя
class OrderCustomer {
  int id = 0;                   // Инкремент
  int status = 0;               // 0 - новый, 1 - отправлено, 2 - удален
  DateTime date = DateTime.now(); // Дата создания заказа
  String uid = '';              // UID для 1С и связи с ТЧ
  String uidOrganization = '';  // Ссылка на организацию
  String nameOrganization = ''; // Имя организации
  String uidPartner = '';       // Ссылка на контрагента
  String namePartner = '';      // Имя контрагента
  String uidContract = '';      // Ссылка на договор контрагента
  String nameContract = '';     // Имя контрагента
  String uidPrice = '';         // Ссылка на тип цены номенклатуры продажи контрагенту
  String namePrice = '';        // Наименование типа цены номенклатуры
  String uidWarehouse = '';     // Ссылка на склад
  String nameWarehouse = '';    // Наименование склада
  String uidCurrency = '';      // Ссылка на валюту заказа
  String nameCurrency = '';     // Наименование валюты заказа
  double sum = 0.0;             // Сумма документа
  String comment = '';          // Комментарий заказа
  DateTime dateSending = DateTime(1900, 1, 1);      // Дата планируемой отгрузки заказа
  DateTime datePaying = DateTime(1900, 1, 1);       // Дата планируемой оплаты заказа
  int sendYesTo1C = 0; // Булево: "Отправлено в 1С" - для фильтрации в списках
  int sendNoTo1C = 0;  // Булево: "Отправлено в 1С" - для фильтрации в списках
  DateTime dateSendingTo1C = DateTime(1900, 1, 1); // Дата отправки заказа в 1С из мобильного устройства
  String numberFrom1C = '';
  int countItems = 0;           // Количество товаров

  OrderCustomer();

  OrderCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'] ?? 0;
    date = DateTime.parse(json['date']);
    uid = json['uid'] ?? '';
    uidOrganization = json['uidOrganization'] ?? '';
    nameOrganization = json['nameOrganization'] ?? '';
    uidPartner = json['uidPartner'] ?? '';
    namePartner = json['namePartner'] ?? '';
    uidContract = json['uidContract'] ?? '';
    nameContract = json['nameContract'] ?? '';
    uidPrice = json['uidPrice'] ?? '';
    namePrice = json['namePrice'] ?? '';
    uidWarehouse = json['uidWarehouse'] ?? '';
    nameWarehouse = json['nameWarehouse'] ?? '';
    uidCurrency = json['uidCurrency'] ?? '';
    nameCurrency = json['nameCurrency'] ?? '';
    sum = json["sum"] ?? 0.0;
    comment = json['comment'] ?? '';
    dateSending = DateTime.parse(json['dateSending']);
    datePaying = DateTime.parse(json['datePaying']);
    sendYesTo1C = json['sendYesTo1C'] ?? 0;
    sendNoTo1C = json['sendNoTo1C'] ?? 0;
    dateSendingTo1C = DateTime.parse(json['dateSendingTo1C']);
    numberFrom1C = json['numberFrom1C'] ?? '';
    countItems = json['countItems'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['status'] = status;
    data['date'] = date.toIso8601String();
    data['uid'] = uid;
    data['uidOrganization'] = uidOrganization;
    data['nameOrganization'] = nameOrganization;
    data['uidPartner'] = uidPartner;
    data['namePartner'] = namePartner;
    data['uidContract'] = uidContract;
    data['nameContract'] = nameContract;
    data['uidPrice'] = uidPrice;
    data['namePrice'] = namePrice;
    data['nameWarehouse'] = nameWarehouse;
    data['uidWarehouse'] = uidWarehouse;
    data['uidCurrency'] = uidCurrency;
    data['nameCurrency'] = nameCurrency;
    data['sum'] = sum;
    data['comment'] = comment;
    data['dateSending'] = dateSending.toIso8601String();
    data['datePaying'] = datePaying.toIso8601String();
    data['sendYesTo1C'] = sendYesTo1C;
    data['sendNoTo1C'] = sendNoTo1C;
    data['dateSendingTo1C'] = dateSendingTo1C.toIso8601String();
    data['numberFrom1C'] = numberFrom1C;
    data['countItems'] = countItems.toString();
    return data;
  }
}

/// Поля для базы данных
class OrderCustomerFields {
  static final List<String> values = [
    id,
    status,
    date,
    uid,
    uidOrganization,
    nameOrganization,
    uidPartner,
    namePartner,
    uidContract,
    nameContract,
    uidPrice,
    namePrice,
    uidWarehouse,
    nameWarehouse,
    uidCurrency,
    nameCurrency,
    sum,
    comment,
    dateSending,
    datePaying,
    sendYesTo1C,
    sendNoTo1C,
    dateSendingTo1C,
    numberFrom1C,
    countItems,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String status = 'status';// 0 - новый, 1 - отправлено, 2 - удален
  static const String date = 'date';// Дата создания заказа
  static const String uid = 'uid';// UID для 1С и связи с ТЧ
  static const String uidOrganization = 'uidOrganization';// Ссылка на организацию
  static const String nameOrganization = 'nameOrganization';// Имя организации
  static const String uidPartner = 'uidPartner';// Ссылка на контрагента
  static const String namePartner = 'namePartner';// Имя контрагента
  static const String uidContract = 'uidContract';// Ссылка на договор контрагента
  static const String nameContract = 'nameContract';// Ссылка на договор контрагента
  static const String uidPrice = 'uidPrice';// Ссылка на тип цены номенклатуры продажи контрагенту
  static const String namePrice = 'namePrice';// Наименование типа цены номенклатуры продажи контрагенту
  static const String uidWarehouse = 'uidWarehouse';// Ссылка на склад
  static const String nameWarehouse = 'nameWarehouse';// Наименование склада
  static const String uidCurrency = 'uidCurrency';// Ссылка на валюту
  static const String nameCurrency = 'nameCurrency';// Наименование валюты
  static const String sum = 'sum';// Сумма документа
  static const String comment = 'comment';// Комментарий
  static const String dateSending = 'dateSending';// Дата планируемой отгрузки заказа
  static const String datePaying = 'datePaying';// Дата планируемой оплаты заказа
  static const String sendYesTo1C = 'sendYesTo1C'; // Булево: "Отправлено в 1С" - для фильтрации в списках
  static const String sendNoTo1C = 'sendNoTo1C';  // Булево: "Отправлено в 1С" - для фильтрации в списках
  static const String dateSendingTo1C = 'dateSendingTo1C'; // Дата отправки заказа в 1С из мобильного устройства
  static const String numberFrom1C = 'numberFrom1C';
  static const String countItems = 'countItems';

}

/// ТЧ Товары, Документы.ЗаказПокупателя
class ItemOrderCustomer {
  int id = 0;                   // Инкремент
  int idOrderCustomer = 0;      // ID владельца ТЧ (документ)
  String uid = '';              // UID для 1С и связи с ТЧ
  String name = '';             // Название товара
  String uidUnit = '';          // Ссылка на единицу измерения товарв
  String nameUnit = '';         // Название единицы измерения
  double count = 0.0;           // Количество товара
  double price = 0.0;           // Цена товара
  double discount = 0.0;        // Скидка/наценка на товар
  double sum = 0.0;             // Сумма товаров

//<editor-fold desc="Data Methods">

  ItemOrderCustomer({
    required this.id,
    required this.idOrderCustomer,
    required this.uid,
    required this.name,
    required this.uidUnit,
    required this.nameUnit,
    required this.count,
    required this.price,
    required this.discount,
    required this.sum,
  });

  ItemOrderCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idOrderCustomer = json['idOrderCustomer'];
    uid = json['uid'];
    name = json['name'];
    uidUnit = json['uidUnit'];
    nameUnit = json['nameUnit'];
    count = json['count'];
    price = json['price'];
    discount = json['discount'];
    sum = json['sum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['idOrderCustomer'] = idOrderCustomer;
    data['uid'] = uid;
    data['name'] = name;
    data['uidUnit'] = uidUnit;
    data['nameUnit'] = nameUnit;
    data['count'] = count;
    data['price'] = price;
    data['discount'] = discount;
    data['sum'] = sum;
    return data;
  }
}

/// Поля для базы данных
class ItemOrderCustomerFields {
  static final List<String> values = [
    id,
    idOrderCustomer,
    uid,
    name,
    uidUnit,
    nameUnit,
    count,
    price,
    discount,
    sum,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String idOrderCustomer = 'idOrderCustomer'; // Ссылка на Заказ покупателя
  static const String uid = 'uid'; // Ссылка на товар
  static const String name = 'name'; // Имя товара
  static const String uidUnit = 'uidUnit'; // Ссылка на ед. изм.
  static const String nameUnit = 'nameUnit';
  static const String count = 'count';
  static const String price = 'price';
  static const String discount = 'discount';
  static const String sum = 'sum';

}