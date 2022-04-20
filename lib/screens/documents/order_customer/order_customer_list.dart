import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/screens/documents/order_customer/order_customer_item.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';
import 'package:wp_sales/screens/exchange/exchange.dart';

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
  OrderCustomer sendOrderCustomer =
  OrderCustomer(); // Шаблонный объект для отборов
  OrderCustomer trashOrderCustomer =
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

  List<OrderCustomer> tempListNewOrdersCustomer = [];
  List<OrderCustomer> tempListSendOrdersCustomer = [];
  List<OrderCustomer> tempListTrashOrdersCustomer = [];

  String uidFilterNewPartner = '';
  String uidFilterSendPartner = '';
  String uidFilterTrashPartner = '';

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
    tempListNewOrdersCustomer.clear();
    countNewDocuments = 0;

    // Отбор по условиям
    if (textFieldNewPeriodController.text.isNotEmpty ||
        textFieldNewPartnerController.text.isNotEmpty) {

      String dateStart = '';
      String dateFinish = '';
      String namePartner = newOrderCustomer.uidPartner;
      String whereString = '';
      List whereList = [];

      if(textFieldNewPeriodController.text.isNotEmpty) {
        String dayStart = textFieldNewPeriodController.text.substring(0,2);
        String monthStart = textFieldNewPeriodController.text.substring(3,5);
        String yearStart = textFieldNewPeriodController.text.substring(6,10);
        dateStart = DateTime.parse('$yearStart-$monthStart-$dayStart').toIso8601String();

        String dayFinish = textFieldNewPeriodController.text.substring(13,15);
        String monthFinish = textFieldNewPeriodController.text.substring(16,18);
        String yearFinish = textFieldNewPeriodController.text.substring(19,23);
        dateFinish = DateTime.parse('$yearFinish-$monthFinish-$dayFinish 23:59:59').toIso8601String();
      }

      // Фильтр: по статусу
      whereList.add('status = 1');

      // Фильтр: по периоду
      if(textFieldNewPeriodController.text.isNotEmpty) {
        whereList.add('(date >= ? AND date <= ?)');
      }

      //Фильтр по партнеру
      if(textFieldNewPartnerController.text.isNotEmpty) {
        whereList.add('uidPartner = ?');
      }

      // Соединим условия отбора
      whereString = whereList.join(' AND ');

      final db = await instance.database;

      // Если есть период и партнер
      if(textFieldNewPeriodController.text.isNotEmpty && textFieldNewPartnerController.text.isNotEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[dateStart,dateFinish,namePartner]);
        listNewOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

      // Если есть период
      if(textFieldNewPeriodController.text.isNotEmpty && textFieldNewPartnerController.text.isEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[dateStart,dateFinish]);
        listNewOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if(textFieldNewPeriodController.text.isEmpty && textFieldNewPartnerController.text.isNotEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[namePartner]);
        listNewOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

    } else {
      listNewOrdersCustomer = await dbReadAllNewOrderCustomer();
    }

    tempListNewOrdersCustomer.addAll(listNewOrdersCustomer);

    // Количество документов в списке
    countNewDocuments = listNewOrdersCustomer.length;

    debugPrint('Количество новых документов: ' + countNewDocuments.toString());
  }

  loadSendDocuments() async {
    // Очистка списка заказов покупателя
    listSendOrdersCustomer.clear();
    tempListSendOrdersCustomer.clear();
    countSendDocuments = 0;

    // Отбор по условиям
    if (textFieldSendPeriodController.text.isNotEmpty ||
        textFieldSendPartnerController.text.isNotEmpty) {

      String dateStart = '';
      String dateFinish = '';
      String namePartner = sendOrderCustomer.uidPartner;
      String whereString = '';
      List whereList = [];

      if(textFieldSendPeriodController.text.isNotEmpty) {
        String dayStart = textFieldSendPeriodController.text.substring(0,2);
        String monthStart = textFieldSendPeriodController.text.substring(3,5);
        String yearStart = textFieldSendPeriodController.text.substring(6,10);
        dateStart = DateTime.parse('$yearStart-$monthStart-$dayStart').toIso8601String();

        String dayFinish = textFieldSendPeriodController.text.substring(13,15);
        String monthFinish = textFieldSendPeriodController.text.substring(16,18);
        String yearFinish = textFieldSendPeriodController.text.substring(19,23);
        dateFinish = DateTime.parse('$yearFinish-$monthFinish-$dayFinish 23:59:59').toIso8601String();
      }

      // Фильтр: по статусу
      whereList.add('status = 2');

      // Фильтр: по периоду
      if(textFieldSendPeriodController.text.isNotEmpty) {
        whereList.add('(date >= ? AND date <= ?)');
      }

      //Фильтр по партнеру
      if(textFieldSendPartnerController.text.isNotEmpty) {
        whereList.add('uidPartner = ?');
      }

      // Соединим условия отбора
      whereString = whereList.join(' AND ');

      final db = await instance.database;

      // Если есть период и партнер
      if(textFieldSendPeriodController.text.isNotEmpty && textFieldSendPartnerController.text.isNotEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[dateStart,dateFinish,namePartner]);
        listSendOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

      // Если есть период
      if(textFieldSendPeriodController.text.isNotEmpty && textFieldSendPartnerController.text.isEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[dateStart,dateFinish]);
        listSendOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if(textFieldNewPeriodController.text.isEmpty && textFieldSendPartnerController.text.isNotEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[namePartner]);
        listSendOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

    } else {
      listSendOrdersCustomer = await dbReadAllSendOrderCustomer();
    }

    // Количество документов в списке
    countSendDocuments = listSendOrdersCustomer.length;

    debugPrint(
        'Количество отправленных документов: ' + countSendDocuments.toString());
  }

  loadTrashDocuments() async {
    // Очистка списка заказов покупателя
    listTrashOrdersCustomer.clear();
    tempListTrashOrdersCustomer.clear();
    countTrashDocuments = 0;

    // Отбор по условиям
    if (textFieldTrashPeriodController.text.isNotEmpty ||
        textFieldTrashPartnerController.text.isNotEmpty) {

      String dateStart = '';
      String dateFinish = '';
      String namePartner = trashOrderCustomer.uidPartner;
      String whereString = '';
      List whereList = [];

      if(textFieldTrashPeriodController.text.isNotEmpty) {
        String dayStart = textFieldTrashPeriodController.text.substring(0,2);
        String monthStart = textFieldTrashPeriodController.text.substring(3,5);
        String yearStart = textFieldTrashPeriodController.text.substring(6,10);
        dateStart = DateTime.parse('$yearStart-$monthStart-$dayStart').toIso8601String();

        String dayFinish = textFieldTrashPeriodController.text.substring(13,15);
        String monthFinish = textFieldTrashPeriodController.text.substring(16,18);
        String yearFinish = textFieldTrashPeriodController.text.substring(19,23);
        dateFinish = DateTime.parse('$yearFinish-$monthFinish-$dayFinish 23:59:59').toIso8601String();
      }

      // Фильтр: по статусу
      whereList.add('status = 3');

      // Фильтр: по периоду
      if(textFieldTrashPeriodController.text.isNotEmpty) {
        whereList.add('(date >= ? AND date <= ?)');
      }

      //Фильтр по партнеру
      if(textFieldTrashPartnerController.text.isNotEmpty) {
        whereList.add('uidPartner = ?');
      }

      // Соединим условия отбора
      whereString = whereList.join(' AND ');

      final db = await instance.database;

      // Если есть период и партнер
      if(textFieldTrashPeriodController.text.isNotEmpty && textFieldTrashPartnerController.text.isNotEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[dateStart,dateFinish,namePartner]);
        listTrashOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

      // Если есть период
      if(textFieldSendPeriodController.text.isNotEmpty && textFieldSendPartnerController.text.isEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[dateStart,dateFinish]);
        listSendOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if(textFieldTrashPeriodController.text.isEmpty && textFieldTrashPartnerController.text.isNotEmpty){
        final result = await db.rawQuery('SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',[namePartner]);
        listTrashOrdersCustomer = result.map((json) => OrderCustomer.fromJson(json)).toList();
      }

    } else {
      listTrashOrdersCustomer = await dbReadAllTrashOrderCustomer();
    }

    // Количество документов в списке
    countTrashDocuments = listTrashOrdersCustomer.length;

    debugPrint(
        'Количество удаленных документов: ' + countTrashDocuments.toString());
  }

  void filterSearchResultsNewDocuments() {
    /// Уберем пробелы
    String query = textFieldNewSearchController.text.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listNewOrdersCustomer.clear();
        listNewOrdersCustomer.addAll(tempListNewOrdersCustomer);
      });
      return;
    }

    List<OrderCustomer> dummySearchList = <OrderCustomer>[];
    dummySearchList.addAll(tempListNewOrdersCustomer);

    if (query.isNotEmpty) {
      List<OrderCustomer> dummyListData = <OrderCustomer>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listNewOrdersCustomer.clear();
        listNewOrdersCustomer.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listNewOrdersCustomer.clear();
        listNewOrdersCustomer.addAll(tempListNewOrdersCustomer);
      });
    }
  }

  void filterSearchResultsSendDocuments() {
    /// Уберем пробелы
    String query = textFieldSendSearchController.text.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listSendOrdersCustomer.clear();
        listSendOrdersCustomer.addAll(tempListSendOrdersCustomer);
      });
      return;
    }

    List<OrderCustomer> dummySearchList = <OrderCustomer>[];
    dummySearchList.addAll(tempListSendOrdersCustomer);

    if (query.isNotEmpty) {
      List<OrderCustomer> dummyListData = <OrderCustomer>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listSendOrdersCustomer.clear();
        listSendOrdersCustomer.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listSendOrdersCustomer.clear();
        listSendOrdersCustomer.addAll(tempListSendOrdersCustomer);
      });
    }
  }

  void filterSearchResultsTrashDocuments() {
    /// Уберем пробелы
    String query = textFieldTrashSearchController.text.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listTrashOrdersCustomer.clear();
        listTrashOrdersCustomer.addAll(tempListTrashOrdersCustomer);
      });
      return;
    }

    List<OrderCustomer> dummySearchList = <OrderCustomer>[];
    dummySearchList.addAll(tempListTrashOrdersCustomer);

    if (query.isNotEmpty) {
      List<OrderCustomer> dummyListData = <OrderCustomer>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listTrashOrdersCustomer.clear();
        listTrashOrdersCustomer.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listTrashOrdersCustomer.clear();
        listTrashOrdersCustomer.addAll(tempListTrashOrdersCustomer);
      });
    }
  }

  listNewParameters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            onSubmitted: (String value) {
              filterSearchResultsNewDocuments();
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
                      filterSearchResultsNewDocuments();
                    },
                    icon: const Icon(Icons.search, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      textFieldNewSearchController.text = '';
                      filterSearchResultsNewDocuments();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
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
                                textPeriod =
                                    shortDateToString(_datePick.start) +
                                        ' - ' +
                                        shortDateToString(_datePick.end);
                                textFieldNewPeriodController.text = textPeriod;
                            }
                            await loadNewDocuments();
                          },
                          icon:
                              const Icon(Icons.date_range, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            textFieldNewPeriodController.text = '';
                            await loadNewDocuments();
                          },
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
                            visibleListNewParameters = false;
                            await loadNewDocuments();
                            setState(() {});
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
                            textFieldNewPartnerController.text = '';
                            textFieldNewContractController.text = '';
                            textFieldNewPeriodController.text = '';
                            newOrderCustomer.uidPartner = '';
                            newOrderCustomer.namePartner = '';
                            newOrderCustomer.uidContract = '';
                            newOrderCustomer.nameContract = '';
                            visibleListNewParameters = false;
                            await loadNewDocuments();
                            setState(() {});
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
            onSubmitted: (String value) {
              filterSearchResultsSendDocuments();
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
                      filterSearchResultsSendDocuments();
                    },
                    icon: const Icon(Icons.search, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      textFieldSendSearchController.text = '';
                      filterSearchResultsSendDocuments();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
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
                              textPeriod = shortDateToString(_datePick.start) +
                                  ' - ' +
                                  shortDateToString(_datePick.end);
                              textFieldSendPeriodController.text = textPeriod;

                              await loadSendDocuments();
                            }
                          },
                          icon:
                              const Icon(Icons.date_range, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            textFieldSendPeriodController.text = '';
                            await loadSendDocuments();
                          },
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
                                            orderCustomer: sendOrderCustomer)));
                            textFieldSendPartnerController.text = sendOrderCustomer.namePartner;
                            await loadSendDocuments();
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            textFieldSendPartnerController.text = '';
                            sendOrderCustomer.uidPartner = '';
                            sendOrderCustomer.namePartner = '';
                            await loadNewDocuments();
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
                            visibleListSendParameters = false;
                            await loadSendDocuments();
                            setState(() {});
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
                            textFieldSendPartnerController.text = '';
                            textFieldSendContractController.text = '';
                            textFieldSendPeriodController.text = '';
                            newOrderCustomer.uidPartner = '';
                            newOrderCustomer.namePartner = '';
                            newOrderCustomer.uidContract = '';
                            newOrderCustomer.nameContract = '';
                            visibleListSendParameters = false;

                            await loadSendDocuments();
                            setState(() {});
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
            onSubmitted: (String value) {
              filterSearchResultsTrashDocuments();
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
                      filterSearchResultsTrashDocuments();
                    },
                    icon: const Icon(Icons.search, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      textFieldTrashSearchController.text = '';
                      filterSearchResultsTrashDocuments();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
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
                              textPeriod =
                                  shortDateToString(_datePick.start) +
                                      ' - ' +
                                      shortDateToString(_datePick.end);
                              textFieldTrashPeriodController.text =
                                  textPeriod;
                            }
                            await loadTrashDocuments();
                            setState(() {});
                          },
                          icon:
                              const Icon(Icons.date_range, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            textFieldTrashPeriodController.text = '';
                            await loadTrashDocuments();
                            setState(() {});
                          },
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
                                            orderCustomer: trashOrderCustomer)));

                            textFieldTrashPartnerController.text = trashOrderCustomer.namePartner;
                            await loadTrashDocuments();
                            setState(() {});
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            textFieldTrashPartnerController.text = '';
                            trashOrderCustomer.uidPartner = '';
                            trashOrderCustomer.namePartner = '';

                            await loadTrashDocuments();
                            setState(() {});
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
                            visibleListTrashParameters = false;
                            await loadTrashDocuments();
                            setState(() {});
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
                            textFieldTrashPartnerController.text = '';
                            textFieldTrashContractController.text = '';
                            textFieldTrashPeriodController.text = '';
                            newOrderCustomer.uidPartner = '';
                            newOrderCustomer.namePartner = '';
                            newOrderCustomer.uidContract = '';
                            newOrderCustomer.nameContract = '';
                            visibleListTrashParameters = false;
                            await loadTrashDocuments();
                            setState(() {});
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
                    const SizedBox(height: 5),
                    if (orderCustomer.comment != '') Row(
                        children: [
                          const Icon(Icons.text_fields,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Text(orderCustomer.comment),
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
                    const SizedBox(height: 5),
                    if (orderCustomer.comment != '') Row(
                        children: [
                          const Icon(Icons.text_fields,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Text(orderCustomer.comment),
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
                    const SizedBox(height: 5),
                    if (orderCustomer.comment != '') Row(
                        children: [
                          const Icon(Icons.text_fields,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Text(orderCustomer.comment),
                        ]),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
