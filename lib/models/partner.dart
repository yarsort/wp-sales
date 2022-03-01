
///***********************************
/// Название таблиц базы данных
///***********************************

/// Справочник.Партнеры
class Partner {
  int id = 0;                     // Инкремент
  bool isGroup = false;           // Пометка удаления
  String uid = '';                // UID для 1С и связи с ТЧ
  String name = '';               // Имя партнера
  String uidParent = '';          // Ссылка на группу
  double balance = 0.0;           // Баланс
  double balanceForPayment = 0.0; // Баланс к оплате
  String phone = '';              // Контакты
  String address = '';            // Адрес
  int schedulePayment = 0;        // Отсрочка платежа

  //int sendNoTo1C = 0;  // Булево: "Отправлено в 1С" - для фильтрации в списках
  //DateTime dateSendingTo1C = DateTime(1900, 1, 1); // Дата отправки заказа в 1С из мобильного устройства

//<editor-fold desc="Data Methods">

  Partner({
    required this.id,
    required this.isGroup,
    required this.uid,
    required this.name,
    required this.uidParent,
    required this.balance,
    required this.balanceForPayment,
    required this.phone,
    required this.address,
    required this.schedulePayment,
  });

  Partner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isGroup = json['isGroup'];
    uid = json['uid'];
    name = json['name'];
    uidParent = json['uidParent'];
    balance = json['balance'];
    balanceForPayment = json['balanceForPayment'];
    phone = json['phone'];
    address = json['address'];
    schedulePayment = json['schedulePayment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isGroup'] = isGroup.toString();
    data['uid'] = uid;
    data['name'] = name;
    data['uidParent'] = uidParent;
    data['balance'] = balance.toString();
    data['balanceForPayment'] = balanceForPayment.toString();
    data['phone'] = phone;
    data['address'] = address;
    data['schedulePayment'] = schedulePayment;
    return data;
  }
}
