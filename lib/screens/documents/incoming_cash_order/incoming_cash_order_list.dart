import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/screens/documents/incoming_cash_order/incoming_cash_order_item.dart';
import 'package:wp_sales/screens/references/contracts/contract_selection.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenIncomingCashOrderList extends StatefulWidget {
  const ScreenIncomingCashOrderList({Key? key}) : super(key: key);

  @override
  _ScreenIncomingCashOrderListState createState() =>
      _ScreenIncomingCashOrderListState();
}

class _ScreenIncomingCashOrderListState extends State<ScreenIncomingCashOrderList> {
  /// Поля ввода: Поиск
  TextEditingController textFieldNewSearchController = TextEditingController();
  TextEditingController textFieldSendSearchController = TextEditingController();
  TextEditingController textFieldTrashSearchController =
  TextEditingController();

  /// Видимость панелей отбора документов
  bool visibleListNewParameters = false;
  bool visibleListSendParameters = false;
  bool visibleListTrashParameters = false;

  /// Количество документов в списках на текущий момент
  int countNewDocuments = 0;
  int countSendDocuments = 0;
  int countTrashDocuments = 0;

  String uidPartner = '';
  String uidContract = '';
  IncomingCashOrder newIncomingCashOrder =
  IncomingCashOrder(); // Шаблонный объект для отборов

  /// Начало периода отбора
  DateTime startPeriodOrders =
  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// Конец периода отбора
  DateTime finishPeriodOrders = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 23, 59, 59);

  /// Списки документов
  List<IncomingCashOrder> listNewIncomingCashOrder = [];
  List<IncomingCashOrder> listSendIncomingCashOrder = [];
  List<IncomingCashOrder> listTrashIncomingCashOrder = [];

  /// Выбор периода отображения документов в списке
  String textPeriod = '';
  DateTime firstDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDate = DateTime.now();

  /// Поле ввода: Период
  TextEditingController textFieldNewPeriodController = TextEditingController();
  TextEditingController textFieldSendPeriodController = TextEditingController();
  TextEditingController textFieldTrashPeriodController =
  TextEditingController();

  /// Поле ввода: Партнер
  TextEditingController textFieldNewPartnerController = TextEditingController();
  TextEditingController textFieldSendPartnerController =
  TextEditingController();
  TextEditingController textFieldTrashPartnerController =
  TextEditingController();

  /// Поле ввода: Договор или торговая точка
  TextEditingController textFieldNewContractController =
  TextEditingController();
  TextEditingController textFieldSendContractController =
  TextEditingController();
  TextEditingController textFieldTrashContractController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
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
              loadData();
            }, icon: const Icon(Icons.add)),
          ],
        ),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listNewParameters(),
                yesNewDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listSendParameters(),
                yesSendDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listTrashParameters(),
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

  loadData() async {
    await loadNewDocuments();
    await loadSendDocuments();
    await loadTrashDocuments();
    setState(() {});
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

  listNewParameters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            onChanged: (String value) {
              //filterSearchResults(value);
            },
            controller: textFieldNewSearchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Поиск',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        visibleListNewParameters = !visibleListNewParameters;
                      });

                    },
                    icon: const Icon(Icons.search, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        visibleListNewParameters = !visibleListNewParameters;
                      });
                    },
                    icon: visibleListNewParameters
                        ? const Icon(Icons.filter_list, color: Colors.blue)
                        : const Icon(Icons.filter_list, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: visibleListNewParameters,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Text('Параметры отбора:',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),

              /// Period
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: TextField(
                  controller: textFieldNewPeriodController,
                  readOnly: true,
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
                              initialDateRange: DateTimeRange(
                                  start: firstDate, end: lastDate),
                              helpText: 'Выберите период',
                              firstDate: DateTime(2021, 1, 1),
                              lastDate: lastDate,
                            );

                            if (_datePick != null) {
                              setState(() {
                                textPeriod =
                                    shortDateToString(_datePick.start) +
                                        ' - ' +
                                        shortDateToString(_datePick.end);
                                textFieldNewPeriodController.text = textPeriod;
                              });
                            }
                          },
                          icon:
                          const Icon(Icons.date_range, color: Colors.blue),
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
                  controller: textFieldNewPartnerController,
                  readOnly: true,
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
                                    builder: (context) =>
                                        ScreenPartnerSelection(
                                            incomingCashOrder: newIncomingCashOrder)));
                            setState(() {
                              textFieldNewPartnerController.text =
                                  newIncomingCashOrder.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldNewPartnerController.text = '';
                              newIncomingCashOrder.uidPartner = '';
                              newIncomingCashOrder.namePartner = '';
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
                  controller: textFieldNewContractController,
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
                                    builder: (context) =>
                                        ScreenContractSelection(
                                            incomingCashOrder: newIncomingCashOrder)));
                            setState(() {
                              textFieldNewContractController.text =
                                  newIncomingCashOrder.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldNewContractController.text = '';
                              newIncomingCashOrder.uidContract = '';
                              newIncomingCashOrder.nameContract = '';
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
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 40,
                      width: (MediaQuery.of(context).size.width - 49) / 2,
                      child: ElevatedButton(
                          onPressed: () async {
                            await loadNewDocuments();
                            setState(() {
                              visibleListNewParameters = false;
                            });
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
                              backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                          onPressed: () async {
                            await loadNewDocuments();
                            setState(() {
                              textFieldNewPartnerController.text = '';
                              textFieldNewContractController.text = '';
                              textFieldNewPeriodController.text = '';

                              newIncomingCashOrder.uidPartner = '';
                              newIncomingCashOrder.namePartner = '';
                              newIncomingCashOrder.uidContract = '';
                              newIncomingCashOrder.nameContract = '';

                              visibleListNewParameters = false;
                            });
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

              const Divider(),
            ],
          ),
        ),
      ],
    );
  }

  listSendParameters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            onChanged: (String value) {
              //filterSearchResults(value);
            },
            controller: textFieldSendSearchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Поиск',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        visibleListSendParameters = !visibleListSendParameters;
                      });

                    },
                    icon: const Icon(Icons.search, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        visibleListSendParameters = !visibleListSendParameters;
                      });
                    },
                    icon: visibleListSendParameters
                        ? const Icon(Icons.filter_list, color: Colors.blue)
                        : const Icon(Icons.filter_list, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: visibleListSendParameters,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Text('Параметры отбора:',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),

              /// Period
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: TextField(
                  controller: textFieldSendPeriodController,
                  readOnly: true,
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
                              initialDateRange: DateTimeRange(
                                  start: firstDate, end: lastDate),
                              helpText: 'Выберите период',
                              firstDate: DateTime(2021, 1, 1),
                              lastDate: lastDate,
                            );

                            if (_datePick != null) {
                              setState(() {
                                textPeriod =
                                    shortDateToString(_datePick.start) +
                                        ' - ' +
                                        shortDateToString(_datePick.end);
                                textFieldSendPeriodController.text = textPeriod;
                              });
                            }
                          },
                          icon:
                          const Icon(Icons.date_range, color: Colors.blue),
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
                  controller: textFieldSendPartnerController,
                  readOnly: true,
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
                                    builder: (context) =>
                                        ScreenPartnerSelection(
                                            incomingCashOrder: newIncomingCashOrder)));
                            setState(() {
                              textFieldSendPartnerController.text =
                                  newIncomingCashOrder.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldSendPartnerController.text = '';
                              newIncomingCashOrder.uidPartner = '';
                              newIncomingCashOrder.namePartner = '';
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
                  controller: textFieldSendContractController,
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
                                    builder: (context) =>
                                        ScreenContractSelection(
                                            incomingCashOrder: newIncomingCashOrder)));
                            setState(() {
                              textFieldSendContractController.text =
                                  newIncomingCashOrder.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldSendContractController.text = '';
                              newIncomingCashOrder.uidContract = '';
                              newIncomingCashOrder.nameContract = '';
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
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 40,
                      width: (MediaQuery.of(context).size.width - 49) / 2,
                      child: ElevatedButton(
                          onPressed: () async {
                            await loadSendDocuments();
                            setState(() {
                              visibleListSendParameters = false;
                            });
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
                              backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                          onPressed: () async {
                            await loadSendDocuments();
                            setState(() {
                              textFieldSendPartnerController.text = '';
                              textFieldSendContractController.text = '';
                              textFieldSendPeriodController.text = '';

                              newIncomingCashOrder.uidPartner = '';
                              newIncomingCashOrder.namePartner = '';
                              newIncomingCashOrder.uidContract = '';
                              newIncomingCashOrder.nameContract = '';

                              visibleListSendParameters = false;
                            });
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

              const Divider(),
            ],
          ),
        ),
      ],
    );
  }

  listTrashParameters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            onChanged: (String value) {
              //filterSearchResults(value);
            },
            controller: textFieldTrashSearchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Поиск',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        visibleListTrashParameters =
                        !visibleListTrashParameters;
                      });

                    },
                    icon: const Icon(Icons.search, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        visibleListTrashParameters =
                        !visibleListTrashParameters;
                      });
                    },
                    icon: visibleListTrashParameters
                        ? const Icon(Icons.filter_list, color: Colors.blue)
                        : const Icon(Icons.filter_list, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: visibleListTrashParameters,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Text('Параметры отбора:',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),

              /// Period
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: TextField(
                  controller: textFieldTrashPeriodController,
                  readOnly: true,
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
                              initialDateRange: DateTimeRange(
                                  start: firstDate, end: lastDate),
                              helpText: 'Выберите период',
                              firstDate: DateTime(2021, 1, 1),
                              lastDate: lastDate,
                            );

                            if (_datePick != null) {
                              setState(() {
                                textPeriod =
                                    shortDateToString(_datePick.start) +
                                        ' - ' +
                                        shortDateToString(_datePick.end);
                                textFieldTrashPeriodController.text =
                                    textPeriod;
                              });
                            }
                          },
                          icon:
                          const Icon(Icons.date_range, color: Colors.blue),
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
                  controller: textFieldTrashPartnerController,
                  readOnly: true,
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
                                    builder: (context) =>
                                        ScreenPartnerSelection(
                                            incomingCashOrder: newIncomingCashOrder)));
                            setState(() {
                              textFieldTrashPartnerController.text =
                                  newIncomingCashOrder.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldTrashPartnerController.text = '';
                              newIncomingCashOrder.uidPartner = '';
                              newIncomingCashOrder.namePartner = '';
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
                  controller: textFieldTrashContractController,
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
                                    builder: (context) =>
                                        ScreenContractSelection(
                                            incomingCashOrder: newIncomingCashOrder)));
                            setState(() {
                              textFieldTrashContractController.text =
                                  newIncomingCashOrder.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldTrashContractController.text = '';
                              newIncomingCashOrder.uidContract = '';
                              newIncomingCashOrder.nameContract = '';
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
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 40,
                      width: (MediaQuery.of(context).size.width - 49) / 2,
                      child: ElevatedButton(
                          onPressed: () async {
                            await loadTrashDocuments();
                            setState(() {
                              visibleListTrashParameters = false;
                            });
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
                              backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                          onPressed: () async {
                            await loadTrashDocuments();
                            setState(() {
                              textFieldTrashPartnerController.text = '';
                              textFieldTrashContractController.text = '';
                              textFieldTrashPeriodController.text = '';

                              newIncomingCashOrder.uidPartner = '';
                              newIncomingCashOrder.namePartner = '';
                              newIncomingCashOrder.uidContract = '';
                              newIncomingCashOrder.nameContract = '';

                              visibleListTrashParameters = false;
                            });
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

              const Divider(),
            ],
          ),
        ),
      ],
    );
  }

  yesNewDocuments() {

    return ColumnListViewBuilder(
        itemCount: countNewDocuments,
        itemBuilder: (context, index) {
          final incomingCashOrder = listNewIncomingCashOrder[index];
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
                      builder: (context) => ScreenItemIncomingCashOrder(incomingCashOrder: incomingCashOrder),
                    ),
                  );
                  loadData();
                },
                title: Text(incomingCashOrder.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.fact_check,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Text(incomingCashOrder.nameParent),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.recent_actors,
                            color: Colors.blue, size: 20),
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
                                  Text(shortDateToString(incomingCashOrder.date)),
                                ],
                              )
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
                    if (incomingCashOrder.comment != '') Row(
                        children: [
                      const Icon(Icons.text_fields,
                          color: Colors.blue, size: 20),
                      const SizedBox(width: 5),
                      Text(incomingCashOrder.comment),
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
    return ColumnListViewBuilder(
        itemCount: countSendDocuments,
        itemBuilder: (context, index) {
          final incomingCashOrder = listSendIncomingCashOrder[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Card(
              elevation: 3,
              child: ListTile(
                tileColor: incomingCashOrder.numberFrom1C != ''
                    ? Colors.lightGreen[50]
                    : Colors.deepOrange[50],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenItemIncomingCashOrder(incomingCashOrder: incomingCashOrder),
                    ),
                  );
                  loadData();
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
                                  Text(shortDateToString(incomingCashOrder.date)),
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
                                  incomingCashOrder.numberFrom1C != ''
                                      ? const Icon(Icons.numbers,
                                      color: Colors.green, size: 20)
                                      : const Icon(Icons.numbers,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 5),
                                  incomingCashOrder.numberFrom1C != ''
                                      ? Text(shortDateToString(incomingCashOrder.dateSendingTo1C)) :
                                  const Text('Даты нет!',
                                      style: TextStyle(color: Colors.red)),
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
                                  const Text('Номера нет!',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              )
                            ],
                          ))
                    ]),
                    const SizedBox(height: 5),
                    if (incomingCashOrder.comment != '') Row(
                        children: [
                          const Icon(Icons.text_fields,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Text(incomingCashOrder.comment),
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
    return ColumnListViewBuilder(
        itemCount: countTrashDocuments,
        itemBuilder: (context, index) {
          final incomingCashOrder = listTrashIncomingCashOrder[index];
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
                      builder: (context) => ScreenItemIncomingCashOrder(incomingCashOrder: incomingCashOrder),
                    ),
                  );
                  loadData();
                },
                title: Text(incomingCashOrder.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.recent_actors,
                            color: Colors.blue, size: 20),
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
                                  Text(shortDateToString(incomingCashOrder.date)),
                                ],
                              )
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
                    if (incomingCashOrder.comment != '') Row(
                        children: [
                          const Icon(Icons.text_fields,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Text(incomingCashOrder.comment),
                        ]),
                  ],
                ),
              ),
            ),
          );
        });
  }
  
}
