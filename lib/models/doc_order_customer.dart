
/// Документы.ЗаказПокупателя
class OrderCustomer {
  int id = 0;                   // Инкремент
  int status = 1;               // 0 - новый, 1 - отправлено, 2 - удален
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
  String uidCashbox = '';      // Ссылка на кассу
  String nameCashbox = '';     // Наименование кассы
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
    uidCashbox = json['uidCashbox'] ?? '';
    nameCashbox = json['nameCashbox'] ?? '';
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


  allSum (OrderCustomer orderCustomer, List<ItemOrderCustomer> items) {
    /// Сумма документа
    double allSum = 0.0;
    for (var item in items) {
      allSum = allSum + item.sum;
    }
    orderCustomer.sum = allSum;
  }

  allCount (OrderCustomer orderCustomer, List<ItemOrderCustomer> items) {
    /// Количество строк товаров документа
    orderCustomer.countItems = items.length;
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
    data['uidCashbox'] = uidCashbox;
    data['nameCashbox'] = nameCashbox;
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
