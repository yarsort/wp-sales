import 'package:intl/intl.dart';

doubleToString(double sum) {
  var f = NumberFormat("##0.00", "en_US");
  return (f.format(sum).toString());
}

doubleThreeToString(double sum) {
  var f = NumberFormat("##0.000", "en_US");
  return (f.format(sum).toString());
}

shortDateToString(DateTime date) {
  var f = DateFormat('dd.MM.yyyy');
  return (f.format(date).toString());
}

/// Тестовые данные
final listDataOrderCustomer = [
  {
    'id': 1,
    'isDeleted': 0,
    'date': '2022-07-20 20:00:00',
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'uidOrganization': '03704c3a-025e-4d5b-d3f9-9213a338e807',
    'nameOrganization': 'ТОВ "ДистрибьютЦентр"',
    'uidPartner': '',
    'namePartner': 'ТОВ Сертон Сертон Сертон Сертон Сертон Сертон Сертон',
    'uidContract': '',
    'nameContract': 'г. Винница, ул. Винниченка 24',
    'uidPrice': '',
    'sum': 2150.00,
    'dateSending': '2022-07-21 19:00:00',
    'datePaying': '2022-07-22 14:00:00',
    'sendYesTo1C': 0,
    'sendNoTo1C': 0,
    'dateSendingTo1C': '2022-07-21 19:00:00',
    'numberFrom1C': 'КР-ШТ-0103-012',
    'countItems': 10,
  },
  {
    'id': 2,
    'isDeleted': 0,
    'date': '2022-07-20 20:00:00',
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'uidOrganization': '03704c3a-025e-4d5b-d3f9-9213a338e807',
    'nameOrganization': 'ТОВ "ДистрибьютЦентр"',
    'uidPartner': '',
    'namePartner': 'ФОП Великов Сергій',
    'uidContract': '',
    'nameContract':
    'Магазин "На Володарського", г. Днепр, ул. Тараса Шевченка 130Б',
    'uidPrice': '',
    'sum': 10050.00,
    'dateSending': '2022-07-21 19:00:00',
    'datePaying': '2022-07-22 14:00:00',
    'sendYesTo1C': 0,
    'sendNoTo1C': 0,
    'dateSendingTo1C': '2022-07-21 19:00:00',
    'numberFrom1C': 'ЛД-ШТ-0103-024',
    'countItems': 1259,
  },
  {
    'id': 3,
    'isDeleted': 0,
    'date': '2022-07-20 20:00:00',
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'uidOrganization': '03704c3a-025e-4d5b-d3f9-9213a338e807',
    'nameOrganization': 'ТОВ "ДистрибьютЦентр"',
    'uidPartner': '',
    'namePartner': 'ФОП Сергієнко Володимир',
    'uidContract': '',
    'nameContract': 'г. Винница, ул. Шевченка 30',
    'uidPrice': '',
    'sum': 1050.00,
    'dateSending': '2022-07-21 19:00:00',
    'datePaying': '2022-07-22 14:00:00',
    'sendYesTo1C': 0,
    'sendNoTo1C': 0,
    'dateSendingTo1C': '2022-07-21 19:00:00',
    'numberFrom1C': '',
    'countItems': 10,
  },
  {
    'id': 4,
    'isDeleted': 0,
    'date': '2022-07-20 20:00:00',
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'uidOrganization': '03704c3a-025e-4d5b-d3f9-9213a338e807',
    'nameOrganization': 'ТОВ "ДистрибьютЦентр"',
    'uidPartner': '',
    'namePartner': 'ФОП Терманов Дмитро',
    'uidContract': '',
    'nameContract': 'г. Винница, ул. С. Долгрукого 50',
    'uidPrice': '',
    'sum': 250.00,
    'dateSending': '2022-07-21 19:00:00',
    'datePaying': '2022-07-22 14:00:00',
    'sendYesTo1C': 0,
    'sendNoTo1C': 0,
    'dateSendingTo1C': '2022-07-21 19:00:00',
    'numberFrom1C': 'ЛД-ШТ-0103-024',
    'countItems': 9,
  },
  {
    'id': 5,
    'isDeleted': 0,
    'date': '2022-07-20 20:00:00',
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'uidOrganization': '03704c3a-025e-4d5b-d3f9-9213a338e807',
    'nameOrganization': 'ТОВ "ДистрибьютЦентр"',
    'uidPartner': '',
    'namePartner': 'ФОП Терманов Дмитро',
    'uidContract': '',
    'nameContract': 'Магазин "Красуня", г. Винница, ул. С. Долгорукого 50',
    'uidPrice': '',
    'sum': 250.00,
    'dateSending': '2022-07-21 19:00:00',
    'datePaying': '2022-07-22 14:00:00',
    'sendYesTo1C': 0,
    'sendNoTo1C': 0,
    'dateSendingTo1C': '2022-07-21 19:00:00',
    'numberFrom1C': '',
    'countItems': 8,
  },
  {
    'id': 6,
    'isDeleted': 0,
    'date': '2022-07-20 20:00:00',
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'uidOrganization': '03704c3a-025e-4d5b-d3f9-9213a338e807',
    'nameOrganization': 'ТОВ "ДистрибьютЦентр"',
    'uidPartner': '',
    'namePartner': 'ФОП Терманов Дмитро',
    'uidContract': '',
    'nameContract': 'Магазин "Дитячий світ", г. Винница, ул. д. Вороного 100',
    'uidPrice': '',
    'sum': 250.00,
    'dateSending': '2022-07-21 19:00:00',
    'datePaying': '2022-07-22 14:00:00',
    'sendYesTo1C': 0,
    'sendNoTo1C': 0,
    'dateSendingTo1C': '2022-07-21 19:00:00',
    'numberFrom1C': 'ЛД-ШТ-0103-025',
    'countItems': 15,
  }
];

/// Тестовые данные
final listDataOrderCustomerItems = [
  {
    'id': 1,
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'Подовжувач 2 гнізда 5м без з/з LILA 720-0205-203 Lezard',
    'uidUnit': '',
    'nameUnit': 'шт.',
    'count': 3.0,
    'price': 63.67,
    'discount': 0.0,
    'sum': 191.01
  },
  {
    'id': 2,
    'uid': '03704c3a-025e-4d5b-93f9-9213a338e807',
    'name': 'Лампа світл G45 9W E27 4200K LED GLOB Lezard',
    'uidUnit': '',
    'nameUnit': 'шт.',
    'count': 3.0,
    'price': 63.67,
    'discount': 0.0,
    'sum': 191.01
  },
  {
    'id': 3,
    'uid': '03704c3a-025e-4d5b-73f9-9213a338e807',
    'name': 'Прожектор 50W 6400K чорний IP65 230V LL-8050 Feron',
    'uidUnit': '',
    'nameUnit': 'шт.',
    'count': 5.0,
    'price': 261.52,
    'discount': 0.0,
    'sum': 1307.60
  },
  {
    'id': 4,
    'uid': '03704c3a-025e-4d5b-83f9-9213a338e807',
    'name': 'СІП 2х16 кабель',
    'uidUnit': '',
    'nameUnit': 'м.п.',
    'count': 11.0,
    'price': 18.4,
    'discount': 0.0,
    'sum': 1202.4
  },
];

/// Тестовые данные
final listDataPartners = [
  {
    'id': 1,
    'isGroup': false,
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'ФОП Сергеев Алексей',
    'uidParent': '13704c3a-025e-4d5b-b3f9-9213a338e807',
    'balance': 6408.10,
    'balanceForPayment': 0.0,
    'phone': '0988547870',
    'address': 'П.Сагайдачного 32, дом 12',
    'schedulePayment': 0,
  },
  {
    'id': 2,
    'isGroup': false,
    'uid': '13704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'ТОВ "Амагама"',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'balance': 3580.59,
    'balanceForPayment': 1550.0,
    'phone': '(098)8547870',
    'address': 'Магазин "Красуня", г. Винница, ул. С. Долгорукого 50',
    'schedulePayment': 7,
  },
  {
    'id': 3,
    'isGroup': false,
    'uid': '23704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'ТОВ "Промприбор"',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'balance': 564.0,
    'balanceForPayment': 150.0,
    'phone': '0988547870',
    'address': 'П.Сагайдачного 32, дом 12',
    'schedulePayment': 30,
  },
  {
    'id': 4,
    'isGroup': false,
    'uid': '33704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'ТОВ "Агротрейдинг"',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'balance': 195600.0,
    'balanceForPayment': 3600.0,
    'phone': '0988547870',
    'address': 'П.Сагайдачного 32, дом 12',
    'schedulePayment': 10,
  },
];

/// Тестовые данные
final listDataContracts = [
  {
    'id': 1,
    'isGroup': true,
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'Договор поставки',
    'uidParent': '13704c3a-025e-4d5b-b3f9-9213a338e807',
    'balance': 6408.10,
    'balanceForPayment': 0.0,
    'phone': '0988547870',
    'address': 'П.Сагайдачного 32, дом 12',
    'schedulePayment': 0,
    'namePartner': 'ФОП Сергеев Алексей',
    'uidPartner': '03704c3a-025e-4d5b-b3f9-9213a338e807',
  },
  {
    'id': 2,
    'isGroup': false,
    'uid': '13704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'Договор с магазином "Красуня"',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'balance': 3580.59,
    'balanceForPayment': 1550.0,
    'phone': '(098)8547870',
    'address': 'Магазин "Красуня", г. Винница, ул. С. Долгорукого 50',
    'schedulePayment': 7,
    'namePartner': 'ТОВ "Амагама"',
    'uidPartner': '13704c3a-025e-4d5b-b3f9-9213a338e807',
  },
  {
    'id': 3,
    'isGroup': false,
    'uid': '23704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'Договор поставки товаров',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'balance': 564.0,
    'balanceForPayment': 150.0,
    'phone': '0988547870',
    'address': 'П.Сагайдачного 32, дом 12',
    'schedulePayment': 30,
    'namePartner': 'ТОВ "Промприбор"',
    'uidPartner': '23704c3a-025e-4d5b-b3f9-9213a338e807',
  },
  {
    'id': 4,
    'isGroup': false,
    'uid': '33704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'Основной договор с покупателем',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'balance': 195600.0,
    'balanceForPayment': 3600.0,
    'phone': '0988547870',
    'address': 'П.Сагайдачного 32, дом 12',
    'schedulePayment': 10,
    'namePartner': 'ТОВ "Агротрейдинг"',
    'uidPartner': '33704c3a-025e-4d5b-b3f9-9213a338e807',
  },
];

/// Тестовые данные
final listDataOrganizations = [
  {
    'id': 1,
    'isGroup': false,
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'ФОП Сергеев Алексей',
    'uidParent': '13704c3a-025e-4d5b-b3f9-9213a338e807',
    'phone': '0988547870',
    'address': 'г. Винница, ул. С. Долгорукого 50',
  },
  {
    'id': 2,
    'isGroup': false,
    'uid': '13704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'ФОП Никоров Алексей',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'phone': '(098)8547870',
    'address': 'г. Винница, ул. С. Долгорукого 50',
  },
];

/// Тестовые данные
final listDataPrice = [
  {
    'id': 1,
    'isGroup': false,
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'Продажная',
    'uidParent': '13704c3a-025e-4d5b-b3f9-9213a338e807',
  },
  {
    'id': 2,
    'isGroup': false,
    'uid': '13704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'Оптовая',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
  },
];

/// Тестовые данные
final listDataCurrency = [
  {
    'id': 1,
    'isGroup': false,
    'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'грн',
    'uidParent': '13704c3a-025e-4d5b-b3f9-9213a338e807',
  },
  {
    'id': 2,
    'isGroup': false,
    'uid': '13704c3a-025e-4d5b-b3f9-9213a338e807',
    'name': 'usd',
    'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
  },
];