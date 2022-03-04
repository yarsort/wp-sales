import 'package:flutter/material.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/screens/documents/order_customer/order_customer_item.dart';
import 'package:wp_sales/screens/references/contracts/contract_selection.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/system/exchange.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenOrderCustomerList extends StatefulWidget {
  const ScreenOrderCustomerList({Key? key}) : super(key: key);

  @override
  _ScreenOrderCustomerListState createState() =>
      _ScreenOrderCustomerListState();
}

class _ScreenOrderCustomerListState extends State<ScreenOrderCustomerList> {
  int countNewDocuments = 0;
  int countSendDocuments = 0;
  int countTrashDocuments = 0;

  String uidPartner = '';
  String uidContract = '';
  OrderCustomer newOrderCustomer =
      OrderCustomer(); // Шаблонный объект для отборов

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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Новые'),
              Tab(text: 'Отправлено'),
              Tab(text: 'Корзина'),
            ],
          ),
          actions: [
            PopupMenuButton<int>(
              onSelected: (item) {
                // Создание нового заказа
                if (item == 0) {
                  var newOrderCustomer = OrderCustomer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenItemOrderCustomer(
                          orderCustomer: newOrderCustomer),
                    ),
                  );
                }
                if (item == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenExchangeData(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(value: 0, child: Text('Добавить')),
                const PopupMenuItem<int>(value: 1, child: Text('Отправить')),
              ],
            ),
          ],
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
      ),
    );
  }

  loadNewDocuments() {
    // Очистка списка заказов покупателя
    listNewOrdersCustomer.clear();

    // Получение и запись списка заказов покупателей
    for (var message in listDataOrderCustomer) {
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
    for (var message in listDataOrderCustomer) {
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
    for (var message in listDataOrderCustomer) {
      OrderCustomer newOrderCustomer = OrderCustomer.fromJson(message);
      listTrashOrdersCustomer.add(newOrderCustomer);
    }

    // Количество документов в списке
    countTrashDocuments = listTrashOrdersCustomer.length;
  }

  listParameters() {

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
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Период',
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
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Партнер',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ScreenPartnerSelection(
                                  orderCustomer: newOrderCustomer)));
                      setState(() {
                        textFieldPartnerController.text = newOrderCustomer.namePartner;
                      });
                    },
                    icon: const Icon(Icons.people, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        textFieldPartnerController.text = '';
                        newOrderCustomer.uidPartner = '';
                        newOrderCustomer.namePartner = '';
                      });
                    },
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
            controller: textFieldContractController,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Договор (торговая точка)',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ScreenContractSelection(
                                  orderCustomer: newOrderCustomer)));
                      setState(() {
                        textFieldContractController.text = newOrderCustomer.nameContract;
                      });
                    },
                    icon: const Icon(Icons.recent_actors, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        textFieldContractController.text = '';
                        newOrderCustomer.uidContract = '';
                        newOrderCustomer.nameContract = '';
                      });
                    },
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
                      setState(() {
                        textFieldPartnerController.text = '';
                        textFieldContractController.text = '';
                        textFieldPeriodController.text = '';

                        newOrderCustomer.uidPartner = '';
                        newOrderCustomer.namePartner = '';
                        newOrderCustomer.uidContract = '';
                        newOrderCustomer.nameContract = '';
                      });

                      await loadNewDocuments();
                      await loadSendDocuments();
                      await loadTrashDocuments();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 14),
                        Text('Очистить'),
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
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScreenItemOrderCustomer(orderCustomer: orderCustomer),
                    ),
                  );
                  setState(() {
                    loadNewDocuments();
                  });
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
                        Flexible(
                            flex: 1, child: Text(orderCustomer.nameContract)),
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
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(
                                      orderCustomer.dateSending)),
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
                                  Text(doubleToString(orderCustomer.sum) +
                                      ' грн'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(orderCustomer.countItems.toString() +
                                      ' поз'),
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
                tileColor: orderCustomer.numberFrom1C != ''
                    ? Colors.lightGreen[50]
                    : Colors.deepOrange[50],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScreenItemOrderCustomer(orderCustomer: orderCustomer),
                    ),
                  );
                  setState(() {
                    loadSendDocuments();
                  });
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
                        Flexible(
                            flex: 1, child: Text(orderCustomer.nameContract)),
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
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(
                                      orderCustomer.dateSending)),
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
                                  Text(doubleToString(orderCustomer.sum) +
                                      ' грн'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(orderCustomer.countItems.toString() +
                                      ' поз'),
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
                                  Text(shortDateToString(
                                      orderCustomer.dateSendingTo1C)),
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
                                      ? Text(orderCustomer.numberFrom1C)
                                      : const Text('Нет данных!',
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
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScreenItemOrderCustomer(orderCustomer: orderCustomer),
                    ),
                  );
                  setState(() {
                    loadTrashDocuments();
                  });
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
                        Flexible(
                            flex: 1, child: Text(orderCustomer.nameContract)),
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
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(
                                      orderCustomer.dateSending)),
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
                                  Text(doubleToString(orderCustomer.sum) +
                                      ' грн'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(orderCustomer.countItems.toString() +
                                      ' поз'),
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
