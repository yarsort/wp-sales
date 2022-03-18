import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/screens/documents/incoming_cash_order/incoming_cash_order_item.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenIncomingCashOrderList extends StatefulWidget {
  const ScreenIncomingCashOrderList({Key? key}) : super(key: key);

  @override
  _ScreenIncomingCashOrderListState createState() =>
      _ScreenIncomingCashOrderListState();
}

class _ScreenIncomingCashOrderListState extends State<ScreenIncomingCashOrderList> {
  int countNewDocuments = 0;
  int countSendDocuments = 0;
  int countTrashDocuments = 0;

  DateTime startPeriodOrders =
  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime finishPeriodOrders = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 23, 59, 59);

  List<IncomingCashOrder> listNewIncomingCashOrder = [];
  List<IncomingCashOrder> listSendIncomingCashOrder = [];
  List<IncomingCashOrder> listTrashIncomingCashOrder = [];

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
          title: const Text('ПКО (оплаты)'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Новые'),
              Tab(text: 'Отправленые'),
              Tab(text: 'Корзина'),
            ],
          ),
          actions: [
            IconButton(onPressed: () async {
              var newIncomingCashOrder = IncomingCashOrder();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenItemIncomingCashOrder(
                      incomingCashOrder: newIncomingCashOrder),
                ),
              );
              await loadNewDocuments();
              setState(() {});
            }, icon: const Icon(Icons.add)),
          ],
        ),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                yesNewDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                yesSendDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                yesTrashDocuments(),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var newIncomingCashOrder = IncomingCashOrder();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScreenItemIncomingCashOrder(incomingCashOrder: newIncomingCashOrder),
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

  loadNewDocuments() async {
    // Очистка списка заказов покупателя
    listNewIncomingCashOrder.clear();
    countNewDocuments = 0;

    listNewIncomingCashOrder = await dbReadAllNewIncomingCashOrder();

    // Количество документов в списке
    countNewDocuments = listNewIncomingCashOrder.length;

    debugPrint('Количество новых документов: ' + countNewDocuments.toString());
  }

  loadSendDocuments() async {
    // Очистка списка заказов покупателя
    listSendIncomingCashOrder.clear();
    countSendDocuments = 0;

    listSendIncomingCashOrder = await dbReadAllSendIncomingCashOrder();

    // Количество документов в списке
    countSendDocuments = listSendIncomingCashOrder.length;

    debugPrint(
        'Количество отправленных документов: ' + countSendDocuments.toString());
  }

  loadTrashDocuments() async {
    // Очистка списка заказов покупателя
    listTrashIncomingCashOrder.clear();
    countTrashDocuments = 0;

    listTrashIncomingCashOrder = await dbReadAllTrashIncomingCashOrder();

    // Количество документов в списке
    countTrashDocuments = listTrashIncomingCashOrder.length;

    debugPrint(
        'Количество удаленных документов: ' + countTrashDocuments.toString());
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
            
            decoration: InputDecoration(
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
            
            decoration: InputDecoration(
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
          final incomingCashOrder = listNewIncomingCashOrder[index];
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
                      builder: (context) => ScreenItemIncomingCashOrder(incomingCashOrder: incomingCashOrder),
                    ),
                  );
                },
                title: Text(incomingCashOrder.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.domain, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(flex: 1, child: Text(incomingCashOrder.nameContract)),
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
                                  const Icon(Icons.recent_actors,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(incomingCashOrder.nameContract),
                                ],
                              )
                            ],
                          )),
                      Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(incomingCashOrder.sum) + ' грн'),
                                ],
                              ),
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
          final incomingCashOrder = listSendIncomingCashOrder[index];
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
                      builder: (context) => ScreenItemIncomingCashOrder(incomingCashOrder: incomingCashOrder),
                    ),
                  );
                },
                title: Text(incomingCashOrder.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.domain, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(flex: 1, child: Text(incomingCashOrder.nameContract)),
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
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(incomingCashOrder.nameCashbox),
                                ],
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(incomingCashOrder.sum) + ' грн'),
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
                                  Text(shortDateToString(incomingCashOrder.dateSendingTo1C)),
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
                                  incomingCashOrder.numberFrom1C != ''
                                      ? const Icon(Icons.repeat_one,
                                      color: Colors.green, size: 20)
                                      : const Icon(Icons.repeat_one,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 5),
                                  incomingCashOrder.numberFrom1C != ''
                                      ? Text(incomingCashOrder.numberFrom1C) :
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
          final incomingCashOrder = listTrashIncomingCashOrder[index];
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
                      builder: (context) => ScreenItemIncomingCashOrder(incomingCashOrder: incomingCashOrder),
                    ),
                  );
                },
                title: Text(incomingCashOrder.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.domain, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(flex: 1, child: Text(incomingCashOrder.nameContract)),
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
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(incomingCashOrder.nameCashbox),
                                ],
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(incomingCashOrder.sum) + ' грн'),
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
                                  Text(shortDateToString(incomingCashOrder.dateSendingTo1C)),
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
                                  incomingCashOrder.numberFrom1C != ''
                                      ? const Icon(Icons.repeat_one,
                                      color: Colors.green, size: 20)
                                      : const Icon(Icons.repeat_one,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 5),
                                  incomingCashOrder.numberFrom1C != ''
                                      ? Text(incomingCashOrder.numberFrom1C) :
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
  
}
