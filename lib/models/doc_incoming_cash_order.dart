/// Документы.ПриходныйКассовыйОрдер
class IncomingCashOrder {
  int id = 0;                   // Инкремент
  int status = 1;               // 1 - новый, 2 - отправлено, 3 - удален
  DateTime date = DateTime.now(); // Дата создания заказа
  String uid = '';              // UID для 1С и связи с ТЧ
  String uidParent = '';        // UID для 1С с главным документом
  String nameParent = '';       // Имя главного документа
  String uidSettlementDocument = ''; // UID документа расчета
  String nameSettlementDocument = ''; // Имя документа расчета
  String uidOrganization = '';  // Ссылка на организацию
  String nameOrganization = ''; // Имя организации
  String uidPartner = '';       // Ссылка на контрагента
  String namePartner = '';      // Имя контрагента
  String uidContract = '';      // Ссылка на договор контрагента
  String nameContract = '';     // Имя контрагента
  String uidCurrency = '';      // Ссылка на валюту заказа
  String nameCurrency = '';     // Наименование валюты заказа
  String uidCashbox = '';       // Ссылка на кассу
  String nameCashbox = '';      // Наименование кассы
  double sum = 0.0;             // Сумма документа
  String comment = '';          // Комментарий заказа
  String coordinates = '';      // Координаты создания записи
  int sendYesTo1C = 0; // Булево: "Отправлено в 1С" - для фильтрации в списках
  int sendNoTo1C = 0;  // Булево: "Не отправлять в 1С" - для фильтрации в списках
  DateTime dateSendingTo1C = DateTime(1900, 1, 1); // Дата отправки заказа в 1С из мобильного устройства
  String numberFrom1C = '';

  IncomingCashOrder();

  IncomingCashOrder.fromJson(Map<String, dynamic> json) {
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
    uidCurrency = json['uidCurrency'] ?? '';
    nameCurrency = json['nameCurrency'] ?? '';
    uidCashbox = json['uidCashbox'] ?? '';
    nameCashbox = json['nameCashbox'] ?? '';
    sum = json["sum"] ?? 0.0;
    comment = json['comment'] ?? '';
    coordinates = json['coordinates'] ?? '';
    sendYesTo1C = json['sendYesTo1C'] ?? 0;
    sendNoTo1C = json['sendNoTo1C'] ?? 0;
    dateSendingTo1C = DateTime.parse(json['dateSendingTo1C']);
    numberFrom1C = json['numberFrom1C'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['status'] = status;
    data['date'] = date.toIso8601String();
    data['uid'] = uid;
    data['uidParent'] = uidParent;
    data['nameParent'] = nameParent;
    data['uidSettlementDocument'] = uidSettlementDocument;
    data['nameSettlementDocument'] = nameSettlementDocument;
    data['uidOrganization'] = uidOrganization;
    data['nameOrganization'] = nameOrganization;
    data['uidPartner'] = uidPartner;
    data['namePartner'] = namePartner;
    data['uidContract'] = uidContract;
    data['nameContract'] = nameContract;
    data['uidCurrency'] = uidCurrency;
    data['nameCurrency'] = nameCurrency;
    data['uidCashbox'] = uidCashbox;
    data['nameCashbox'] = nameCashbox;
    data['sum'] = sum;
    data['comment'] = comment;
    data['coordinates'] = coordinates;
    data['sendYesTo1C'] = sendYesTo1C;
    data['sendNoTo1C'] = sendNoTo1C;
    data['dateSendingTo1C'] = dateSendingTo1C.toIso8601String();
    data['numberFrom1C'] = numberFrom1C;
    return data;
  }
}