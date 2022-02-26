
// Документы
const String tableDocOrderCustomer   = 'tableDocOrderCustomer';      // Заказы покупателя

///***********************************
/// Описание таблиц базы данных
///***********************************

class DocOrderCustomerFields {
  static final List<String> values = [
    id,
    isDeleted,
    date,
    uid,
    uidOrganization,
    uidPartner,
    namePartner,
    uidContract,
    uidPrice,
    sum,
    dateSending,
    datePaying,
    sendYesTo1C,
    sendNoTo1C,
    dateSendingTo1C,
    numberFrom1C,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isDeleted = 'isDeleted';// Пометка удаления
  static const String date = 'date';// Дата создания заказа
  static const String uid = 'uid';// UID для 1С и связи с ТЧ
  static const String uidOrganization = 'uidOrganization';// Ссылка на организацию
  static const String uidPartner = 'uidPartner';// Ссылка на контрагента
  static const String namePartner = 'namePartner';// Имя контрагента
  static const String uidContract = 'uidContract';// Ссылка на договор контрагента
  static const String uidPrice = 'uidPrice';// Ссылка на тип цены номенклатуры продажи контрагенту
  static const String sum = 'sum';// Сумма документа
  static const String dateSending = 'dateSending';// Дата планируемой отгрузки заказа
  static const String datePaying = 'dateSending';// Дата планируемой оплаты заказа
  static const String sendYesTo1C = 'sendYesTo1C'; // Булево: "Отправлено в 1С" - для фильтрации в списках
  static const String sendNoTo1C = 'sendNoTo1C';  // Булево: "Отправлено в 1С" - для фильтрации в списках
  static const String dateSendingTo1C = 'sendNoTo1C'; // Дата отправки заказа в 1С из мобильного устройства
  static const String numberFrom1C = 'numberFrom1C';

}
