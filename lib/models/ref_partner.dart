
/// Справочник.Партнеры
class Partner {
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
  DateTime dateEdit = DateTime.now(); // Дата редактирования
  int schedulePayment = 0;        // Отсрочка платежа

  Partner();

  Partner.fromJson(Map<String, dynamic> json) {
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
    dateEdit = DateTime.parse(json['dateEdit'] ?? DateTime.now().toIso8601String());
    schedulePayment = json['schedulePayment'] ?? 0; // Отсрочка платежа в днях (int)
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != 0) {
      data['id'] = id;
    }
    data['isGroup'] = 0;
    data['uid'] = uid;
    data['code'] = code;
    data['name'] = name;
    data['uidParent'] = uidParent;
    data['balance'] = balance;
    data['balanceForPayment'] = balanceForPayment;
    data['phone'] = phone;
    data['address'] = address;
    data['comment'] = comment;
    data['dateEdit'] = dateEdit.toIso8601String();
    data['schedulePayment'] = schedulePayment;
    return data;
  }
}
