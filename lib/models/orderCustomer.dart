
///***********************************
/// Название таблиц базы данных
///***********************************

/// Документы.ЗаказПокупателя
class OrderCustomer {
  int id = 0;                   // Инкремент
  int isDeleted = 0;            // Пометка удаления
  DateTime date = DateTime.now(); // Дата создания заказа
  String uid = '';              // UID для 1С и связи с ТЧ
  String uidOrganization = '';  // Ссылка на организацию
  String uidPartner = '';       // Ссылка на контрагента
  String namePartner = '';       // Имя контрагента
  String uidContract = '';      // Ссылка на договор контрагента
  String uidPrice = '';         // Ссылка на тип цены номенклатуры продажи контрагенту
  double sum = 0.0;             // Сумма документа
  DateTime dateSending = DateTime(1900, 1, 1);      // Дата планируемой отгрузки заказа
  DateTime datePaying = DateTime(1900, 1, 1);       // Дата планируемой оплаты заказа

  // У документа будут табличные части
  // Товары - товары и услуги продаваемые в заказе клиенту

  // Техническая информация
  int sendYesTo1C = 0; // Булево: "Отправлено в 1С" - для фильтрации в списках
  int sendNoTo1C = 0;  // Булево: "Отправлено в 1С" - для фильтрации в списках
  DateTime dateSendingTo1C = DateTime(1900, 1, 1); // Дата отправки заказа в 1С из мобильного устройства
  String numberFrom1C = '';

//<editor-fold desc="Data Methods">

  OrderCustomer({
    required this.id,
    required this.isDeleted,
    required this.date,
    required this.uid,
    required this.uidOrganization,
    required this.uidPartner,
    required this.namePartner,
    required this.uidContract,
    required this.uidPrice,
    required this.sum,
    required this.dateSending,
    required this.datePaying,
    required this.sendYesTo1C,
    required this.sendNoTo1C,
    required this.dateSendingTo1C,
    required this.numberFrom1C,
  });

  OrderCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isDeleted = json['isDeleted'];
    date = DateTime.parse(json['date']);
    uid = json['uid'];
    uidOrganization = json['uidOrganization'];
    uidPartner = json['uidPartner'];
    namePartner = json['namePartner'];
    uidContract = json['uidContract'];
    uidPrice = json['uidPrice'];
    sum = double.parse(json['sum']);
    dateSending = DateTime.parse(json['dateSending']);
    datePaying = DateTime.parse(json['datePaying']);
    sendYesTo1C = json['sendYesTo1C'];
    sendNoTo1C = json['sendNoTo1C'];
    dateSendingTo1C = DateTime.parse(json['dateSendingTo1C']);
    numberFrom1C = json['numberFrom1C'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isDeleted'] = isDeleted.toString();
    data['date'] = date.toIso8601String();
    data['uid'] = uid;
    data['uidOrganization'] = uidOrganization;
    data['uidPartner'] = uidPartner;
    data['namePartner'] = namePartner;
    data['uidContract'] = uidContract;
    data['uidPrice'] = uidPrice;
    data['sum'] = sum.toString();
    data['dateSending'] = dateSending.toIso8601String();
    data['datePaying'] = datePaying.toIso8601String();
    data['sendYesTo1C'] = sendYesTo1C;
    data['sendNoTo1C'] = sendNoTo1C;
    data['dateSendingTo1C'] = dateSendingTo1C.toIso8601String();
    data['numberFrom1C'] = numberFrom1C;
    return data;
  }
}