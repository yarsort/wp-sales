/// Документы.ВозвратЗаказПокупателя
class ReturnOrderCustomer {
  int id = 0;                   // Инкремент
  int status = 1;               // 1 - новый, 2 - отправлено, 3 - удален
  DateTime date = DateTime.now(); // Дата создания возврата заказа
  String uid = '';              // UID для 1С и связи с ТЧ
  String uidParent = '';        // UID заказа покупателя, по которому возврат
  String nameParent = '';       // Имя главного документа
  String uidSettlementDocument = ''; // UID документа расчета
  String nameSettlementDocument = ''; // Имя документа расчета
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
  String coordinates = '';      // Координаты создания записи
  DateTime dateSending = DateTime(1900, 1, 1);      // Дата планируемой отгрузки заказа
  DateTime datePaying = DateTime(1900, 1, 1);       // Дата планируемой оплаты заказа
  int sendYesTo1C = 0; // Булево: "Отправлено в 1С" - для фильтрации в списках
  int sendNoTo1C = 0;  // Булево: "Отправлено в 1С" - для фильтрации в списках
  DateTime dateSendingTo1C = DateTime(1900, 1, 1); // Дата отправки заказа в 1С из мобильного устройства
  String numberFrom1C = '';
  int countItems = 0;           // Количество товаров

  ReturnOrderCustomer();

  allSum (ReturnOrderCustomer orderCustomer, List<ItemReturnOrderCustomer> items) {
    /// Сумма документа
    double allSum = 0.0;
    for (var item in items) {
      allSum = allSum + item.sum;
    }
    orderCustomer.sum = allSum;
  }

  allCount (ReturnOrderCustomer orderCustomer, List<ItemReturnOrderCustomer> items) {
    /// Количество строк товаров документа
    orderCustomer.countItems = items.length;
  }

  ReturnOrderCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'] ?? 0;
    date = DateTime.parse(json['date']);
    uid = json['uid'] ?? '';
    uidParent = json['uidParent'] ?? '';
    nameParent = json['nameParent'] ?? '';
    uidSettlementDocument = json['uidSettlementDocument'] ?? '';
    nameSettlementDocument = json['nameSettlementDocument'] ?? '';
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
    coordinates = json['coordinates'] ?? '';
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
    data['uidParent'] = uidParent.isNotEmpty?uidParent:'00000-0000-0000-0000-000000000000000';
    data['nameParent'] = nameParent;
    data['uidOrganization'] = uidOrganization.isNotEmpty?uidOrganization:'00000-0000-0000-0000-000000000000000';
    data['nameOrganization'] = nameOrganization;
    data['uidPartner'] = uidPartner.isNotEmpty?uidPartner:'00000-0000-0000-0000-000000000000000';
    data['namePartner'] = namePartner;
    data['uidContract'] = uidContract.isNotEmpty?uidContract:'00000-0000-0000-0000-000000000000000';
    data['nameContract'] = nameContract;
    data['uidSettlementDocument'] = uidSettlementDocument.isNotEmpty?uidSettlementDocument:'00000-0000-0000-0000-000000000000000';
    data['nameSettlementDocument'] = nameSettlementDocument;
    data['uidPrice'] = uidPrice.isNotEmpty?uidPrice:'00000-0000-0000-0000-000000000000000';
    data['namePrice'] = namePrice;
    data['uidWarehouse'] = uidWarehouse.isNotEmpty?uidWarehouse:'00000-0000-0000-0000-000000000000000';
    data['nameWarehouse'] = nameWarehouse;
    data['uidCurrency'] = uidCurrency.isNotEmpty?uidCurrency:'00000-0000-0000-0000-000000000000000';
    data['nameCurrency'] = nameCurrency;
    data['sum'] = sum;
    data['comment'] = comment;
    data['coordinates'] = coordinates;
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

/// ТЧ Товары, Документы.ВозвратЗаказаПокупателя
class ItemReturnOrderCustomer {
  int id = 0;                   // Инкремент
  int idReturnOrderCustomer = 0;// ID владельца ТЧ (документ)
  String uid = '';              // UID для 1С и связи с ТЧ
  String name = '';             // Название товара
  String uidUnit = '';          // Ссылка на единицу измерения товарв
  String nameUnit = '';         // Название единицы измерения
  double count = 0.0;           // Количество товара
  double price = 0.0;           // Цена товарв
  double discount = 0.0;        // Скидка/наценка на товар
  double sum = 0.0;             // Сумма товаров

//<editor-fold desc="Data Methods">

  ItemReturnOrderCustomer({
    required this.id,
    required this.idReturnOrderCustomer,
    required this.uid,
    required this.name,
    required this.uidUnit,
    required this.nameUnit,
    required this.count,
    required this.price,
    required this.discount,
    required this.sum,
  });

  allSum (ReturnOrderCustomer returnOrderCustomer, List<ItemReturnOrderCustomer> items) {
    /// Сумма документа
    double allSum = 0.0;
    for (var item in items) {
      allSum = allSum + item.sum;
    }
    returnOrderCustomer.sum = allSum;
  }

  allCount (ReturnOrderCustomer returnOrderCustomer, List<ItemReturnOrderCustomer> items) {
    /// Количество строк товаров документа
    returnOrderCustomer.countItems = items.length;
  }

  ItemReturnOrderCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idReturnOrderCustomer = json['idReturnOrderCustomer'];
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
    data['idReturnOrderCustomer'] = idReturnOrderCustomer;
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
