
class AccumPartnerDept {
  int id = 0;
  int idRegistrar = 0;
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
    idRegistrar = json["idRegistrar"]??0;
    uidOrganization = json["uidOrganization"]??'';
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
    data['idRegistrar'] = idRegistrar;
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
