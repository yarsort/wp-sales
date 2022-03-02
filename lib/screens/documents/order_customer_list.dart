import 'package:flutter/material.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/screens/documents/order_customer_item.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenListOrderCustomer extends StatefulWidget {
  const ScreenListOrderCustomer({Key? key}) : super(key: key);

  @override
  _ScreenListOrderCustomerState createState() =>
      _ScreenListOrderCustomerState();
}

class _ScreenListOrderCustomerState extends State<ScreenListOrderCustomer> {
  int countNewDocuments = 0;
  int countSendDocuments = 0;
  int countTrashDocuments = 0;

  DateTime startPeriodOrders =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime finishPeriodOrders = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 23, 59, 59);

  List<OrderCustomer> listNewOrdersCustomer = [];
  List<OrderCustomer> listSendOrdersCustomer = [];
  List<OrderCustomer> listTrashOrdersCustomer = [];

  /// Выбор периода отображения документов в списке
  String textPeriod = '';
  DateTime firstDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDate = DateTime.now();

  /// Поле ввода: Период
  TextEditingController textFieldPeriodController = TextEditingController();

  /// Поле ввода: Партнер
  TextEditingController textFieldPartnerController = TextEditingController();

  /// Поле ввода: Договор или торговая точка
  TextEditingController textFieldContractController = TextEditingController();

  /// Панель параметров отбора
  bool expandedExpansionTile = false;

  /// Тестовые данные
  final messageList = [
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
      'sum': '2150.00',
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
      'sum': '10050.00',
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
      'sum': '1050.00',
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
      'sum': '250.00',
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
      'sum': '250.00',
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
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'ЛД-ШТ-0103-025',
      'countItems': 15,
    }
  ];

  @override
  void initState() {
    loadNewDocuments();
    loadSendDocuments();
    loadTrashDocuments();
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Заказы покупателей'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.filter_list,
                    size: 26.0,
                  ),
                )),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.filter_1), text: 'Новые'),
              Tab(icon: Icon(Icons.filter_2), text: 'Отправленые'),
              Tab(icon: Icon(Icons.filter_none), text: 'Корзина'),
            ],
          ),
        ),
        drawer: const MainDrawer(),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                countNewDocuments == 1 ? noDocuments() : yesNewDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                countSendDocuments == 1 ? noDocuments() : yesSendDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                countTrashDocuments == 1 ? noDocuments() : yesTrashDocuments(),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var newOrderCustomer = OrderCustomer();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScreenItemOrderCustomer(orderCustomer: newOrderCustomer),
              ),
            );
          },
          tooltip: '+',
          child: const Text(
            "+",
            style: TextStyle(fontSize: 30),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  loadNewDocuments() {
    // Очистка списка заказов покупателя
    listNewOrdersCustomer.clear();

    // Получение и запись списка заказов покупателей
    for (var message in messageList) {
      OrderCustomer newOrderCustomer = OrderCustomer.fromJson(message);
      listNewOrdersCustomer.add(newOrderCustomer);
    }

    // Количество документов в списке
    countNewDocuments = listNewOrdersCustomer.length;
  }

  loadSendDocuments() {
    // Очистка списка заказов покупателя
    listSendOrdersCustomer.clear();

    // Получение и запись списка заказов покупателей
    for (var message in messageList) {
      OrderCustomer newOrderCustomer = OrderCustomer.fromJson(message);
      listSendOrdersCustomer.add(newOrderCustomer);
    }

    // Количество документов в списке
    countSendDocuments = listSendOrdersCustomer.length;
  }

  loadTrashDocuments() {
    // Очистка списка заказов покупателя
    listTrashOrdersCustomer.clear();

    // Получение и запись списка заказов покупателей
    for (var message in messageList) {
      OrderCustomer newOrderCustomer = OrderCustomer.fromJson(message);
      listTrashOrdersCustomer.add(newOrderCustomer);
    }

    // Количество документов в списке
    countTrashDocuments = listTrashOrdersCustomer.length;
  }

  listParameters() {
    var validatePeriod = false;

    return ExpansionTile(
      key: const Key('ExpansionTileParameters'),
      initiallyExpanded: expandedExpansionTile,
      title: const Text('Параметры отбора'),
      children: [
        /// Period
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            controller: textFieldPeriodController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Период',
              errorText: validatePeriod ? 'Вы не указали период!' : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min, //
                children: [
                  IconButton(
                    onPressed: () async {
                      var _datePick = await showDateRangePicker(
                        context: context,
                        initialDateRange:
                            DateTimeRange(start: firstDate, end: lastDate),
                        helpText: 'Выберите период',
                        firstDate: DateTime(2021, 1, 1),
                        lastDate: lastDate,
                      );

                      if (_datePick != null) {
                        setState(() {
                          validatePeriod = false;
                          textPeriod = shortDateToString(_datePick.start) +
                              ' - ' +
                              shortDateToString(_datePick.end);
                          textFieldPeriodController.text = textPeriod;
                        });
                      }
                    },
                    icon: const Icon(Icons.date_range, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Partner
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldPartnerController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Партнер',
              errorText: validatePeriod ? 'Вы не указали партнера!' : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.people, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Contract
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldPartnerController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Договор (торговая точка)',
              errorText: validatePeriod
                  ? 'Вы не указали договор (торговую точку)!'
                  : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.recent_actors, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Button refresh
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 40,
                width: (MediaQuery.of(context).size.width - 49) / 2,
                child: ElevatedButton(
                    onPressed: () async {
                      if (textFieldPeriodController.text.isEmpty) {
                        expandedExpansionTile = false;
                        setState(() {
                          validatePeriod = true;
                        });
                        return;
                      } else {
                        expandedExpansionTile = false;
                        setState(() {
                          validatePeriod = false;
                        });
                      }
                      await loadNewDocuments();
                      await loadSendDocuments();
                      await loadTrashDocuments();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.update, color: Colors.white),
                        SizedBox(width: 14),
                        Text('Заполнить')
                      ],
                    )),
              ),
              const SizedBox(
                width: 14,
              ),
              SizedBox(
                height: 40,
                width: (MediaQuery.of(context).size.width - 35) / 2,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: () async {
                      if (textFieldPeriodController.text.isEmpty) {
                        setState(() {
                          validatePeriod = true;
                        });
                        return;
                      } else {
                        setState(() {
                          validatePeriod = false;
                        });
                      }
                      await loadNewDocuments();
                      await loadSendDocuments();
                      await loadTrashDocuments();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 14),
                        Text('Очистить отбор'),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  yesNewDocuments() {

    return ColumnBuilder(
        itemCount: countNewDocuments,
        itemBuilder: (context, index) {
          final orderCustomer = listNewOrdersCustomer[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Card(
              elevation: 3,
              child: ListTile(
                //tileColor: Colors.cyan[50],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenItemOrderCustomer(orderCustomer: orderCustomer),
                    ),
                  );
                },
                title: Text(orderCustomer.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.domain, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(flex: 1, child: Text(orderCustomer.nameContract)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(orderCustomer.date)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(orderCustomer.dateSending)),
                                ],
                              )
                            ],
                          )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(orderCustomer.sum) + ' грн'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(orderCustomer.countItems.toString() + ' поз'),
                                ],
                              )
                            ],
                          ))
                    ]),
                  ],
                ),
              ),
            ),
          );
        });
  }

  yesSendDocuments() {
    // Отображение списка заказов покупателя
    return ColumnBuilder(
        itemCount: countSendDocuments,
        itemBuilder: (context, index) {
          final orderCustomer = listSendOrdersCustomer[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Card(
              elevation: 3,
              child: ListTile(
                tileColor: Colors.lightGreen[50],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenItemOrderCustomer(orderCustomer: orderCustomer),
                    ),
                  );
                },
                title: Text(orderCustomer.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.domain, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(flex: 1, child: Text(orderCustomer.nameContract)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(orderCustomer.date)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(orderCustomer.dateSending)),
                                ],
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(orderCustomer.sum) + ' грн'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(orderCustomer.countItems.toString() + ' поз'),
                                ],
                              ),
                            ],
                          ))
                    ]),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.more_time,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(orderCustomer.dateSendingTo1C)),
                                ],
                              )
                            ],
                          )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  orderCustomer.numberFrom1C != ''
                                      ? const Icon(Icons.repeat_one,
                                      color: Colors.green, size: 20)
                                      : const Icon(Icons.repeat_one,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 5),
                                  orderCustomer.numberFrom1C != ''
                                      ? Text(orderCustomer.numberFrom1C) :
                                      const Text('Нет данных!',
                                        style: TextStyle(color: Colors.red)),
                                ],
                              )
                            ],
                          ))
                    ]),
                  ],
                ),
              ),
            ),
          );
        });
  }

  yesTrashDocuments() {
    // Отображение списка заказов покупателя
    return ColumnBuilder(
        itemCount: countTrashDocuments,
        itemBuilder: (context, index) {
          final orderCustomer = listTrashOrdersCustomer[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Card(
              elevation: 3,
              child: ListTile(
                tileColor: Colors.deepOrange[50],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenItemOrderCustomer(orderCustomer: orderCustomer),
                    ),
                  );
                },
                title: Text(orderCustomer.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.domain, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(flex: 1, child: Text(orderCustomer.nameContract)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(orderCustomer.date)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(orderCustomer.dateSending)),
                                ],
                              )
                            ],
                          )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(orderCustomer.sum) + ' грн'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(orderCustomer.countItems.toString() + ' поз'),
                                ],
                              )
                            ],
                          ))
                    ]),
                  ],
                ),
              ),
            ),
          );
        });
  }

  noDocuments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            'Заказов не обнаружено!',
            style: TextStyle(fontSize: 25, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
