import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/screens/documents/order_customer/order_customer_item.dart';
import 'package:wp_sales/screens/references/contracts/contract_selection.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenOrderCustomerList extends StatefulWidget {
  const ScreenOrderCustomerList({Key? key}) : super(key: key);

  @override
  _ScreenOrderCustomerListState createState() =>
      _ScreenOrderCustomerListState();
}

class _ScreenOrderCustomerListState extends State<ScreenOrderCustomerList> {
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
  OrderCustomer newOrderCustomer =
      OrderCustomer(); // Шаблонный объект для отборов

  /// Начало периода отбора
  DateTime startPeriodOrders =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// Конец периода отбора
  DateTime finishPeriodOrders = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 23, 59, 59);

  /// Списки документов
  List<OrderCustomer> listNewOrdersCustomer = [];
  List<OrderCustomer> listSendOrdersCustomer = [];
  List<OrderCustomer> listTrashOrdersCustomer = [];

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

  void loadData() async {
    await loadNewDocuments();
    await loadSendDocuments();
    await loadTrashDocuments();
    setState(() {});
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
            IconButton(onPressed: () async {
              var newOrderCustomer = OrderCustomer();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenItemOrderCustomer(
                      orderCustomer: newOrderCustomer),
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
                listNewParameters(),
                yesNewDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listSendParameters(),
                yesSendDocuments()
                //countSendDocuments == 0 ? noDocuments() : yesSendDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listTrashParameters(),
                yesTrashDocuments()
                //countTrashDocuments == 0 ? noDocuments() : yesTrashDocuments(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  loadNewDocuments() async {
    // Очистка списка заказов покупателя
    listNewOrdersCustomer.clear();
    countNewDocuments = 0;

    listNewOrdersCustomer = await dbReadAllNewOrderCustomer();

    // Количество документов в списке
    countNewDocuments = listNewOrdersCustomer.length;

    debugPrint('Количество новых документов: ' + countNewDocuments.toString());
  }

  loadSendDocuments() async {
    // Очистка списка заказов покупателя
    listSendOrdersCustomer.clear();
    countSendDocuments = 0;

    listSendOrdersCustomer = await dbReadAllSendOrderCustomer();

    // Количество документов в списке
    countSendDocuments = listSendOrdersCustomer.length;

    debugPrint(
        'Количество отправленных документов: ' + countSendDocuments.toString());
  }

  loadTrashDocuments() async {
    // Очистка списка заказов покупателя
    listTrashOrdersCustomer.clear();
    countTrashDocuments = 0;

    listTrashOrdersCustomer = await dbReadAllTrashOrderCustomer();

    // Количество документов в списке
    countTrashDocuments = listTrashOrdersCustomer.length;

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
                                            orderCustomer: newOrderCustomer)));
                            setState(() {
                              textFieldNewPartnerController.text =
                                  newOrderCustomer.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldNewPartnerController.text = '';
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
                                            orderCustomer: newOrderCustomer)));
                            setState(() {
                              textFieldNewContractController.text =
                                  newOrderCustomer.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldNewContractController.text = '';
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

                              newOrderCustomer.uidPartner = '';
                              newOrderCustomer.namePartner = '';
                              newOrderCustomer.uidContract = '';
                              newOrderCustomer.nameContract = '';

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
                                            orderCustomer: newOrderCustomer)));
                            setState(() {
                              textFieldSendPartnerController.text =
                                  newOrderCustomer.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldSendPartnerController.text = '';
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
                                            orderCustomer: newOrderCustomer)));
                            setState(() {
                              textFieldSendContractController.text =
                                  newOrderCustomer.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldSendContractController.text = '';
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

                              newOrderCustomer.uidPartner = '';
                              newOrderCustomer.namePartner = '';
                              newOrderCustomer.uidContract = '';
                              newOrderCustomer.nameContract = '';

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
                                            orderCustomer: newOrderCustomer)));
                            setState(() {
                              textFieldTrashPartnerController.text =
                                  newOrderCustomer.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldTrashPartnerController.text = '';
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
                                            orderCustomer: newOrderCustomer)));
                            setState(() {
                              textFieldTrashContractController.text =
                                  newOrderCustomer.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldTrashContractController.text = '';
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

                              newOrderCustomer.uidPartner = '';
                              newOrderCustomer.namePartner = '';
                              newOrderCustomer.uidContract = '';
                              newOrderCustomer.nameContract = '';

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
    return ColumnBuilder(
        itemCount: listNewOrdersCustomer.length,
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
                 loadData();
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
        itemCount: listSendOrdersCustomer.length,
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
                  loadData();
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
        itemCount: listTrashOrdersCustomer.length,
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
                  loadData();
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
}
