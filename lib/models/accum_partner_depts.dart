///***********************************
/// Название таблиц базы данных
///***********************************
const String tableAccumPartnerDebts   = '_AccumPartnerDebts';

class AccumPartnerDept {
  int id = 0;
  String uidOrganization = '';
  String uidPartner = '';
  String uidContract = '';
  String uidDoc = '';
  String nameDoc = '';
  String numberDoc = '';
  DateTime dateDoc = DateTime(1900, 1, 1);
  double balanceForPayment = 0.0;
  double balance = 0.0;

  AccumPartnerDept();

  AccumPartnerDept.fromJson(Map<String, dynamic> json) {
    uidOrganization = json["uidOrganization"]??'';
    uidPartner = json["uidPartner"]??'';
    uidContract = json["uidContract"]??'';
    uidDoc = json["uidDoc"]??'';
    nameDoc = json["nameDoc"]??'';
    numberDoc = json["numberDoc"]??'';
    dateDoc = DateTime.parse(json['dateDoc']);
    balanceForPayment = json["balanceForPayment"].toDouble()??0.0;
    balance = json["balance"].toDouble()??0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['uidOrganization'] = uidOrganization;
    data['uidPartner'] = uidPartner;
    data['uidContract'] = uidContract;
    data['uidDoc'] = uidDoc;
    data['nameDoc'] = nameDoc;
    data['numberDoc'] = numberDoc;
    data['dateDoc'] = dateDoc.toIso8601String();
    data['balance'] = balance;
    data['balanceForPayment'] = balanceForPayment;
    return data;
  }
}

/// Поля для базы данных
class ItemAccumPartnerDeptFields {
  static final List<String> values = [
    id,
    uidOrganization,
    uidPartner,
    uidContract,
    uidDoc,
    nameDoc,
    numberDoc,
    dateDoc,
    balance,
    balanceForPayment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String uidOrganization = 'uidOrganization';
  static const String uidPartner = 'uidPartner';
  static const String uidContract = 'uidContract';
  static const String uidDoc = 'uidDoc';
  static const String nameDoc = 'nameDoc';
  static const String numberDoc = 'numberDoc';
  static const String dateDoc = 'dateDoc';
  static const String balance = 'balance';
  static const String balanceForPayment = 'balanceForPayment';

}