import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_doc_incoming_cash_order.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/import/import_db.dart';
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

class _ScreenIncomingCashOrderListState
    extends State<ScreenIncomingCashOrderList> {
  /// Поля ввода: Поиск
  TextEditingController textFieldNewSearchController = TextEditingController();
  TextEditingController textFieldSendSearchController = TextEditingController();
  TextEditingController textFieldTrashSearchController =
      TextEditingController();

  /// Видимость панелей отбора документов
  bool visibleListNewParameters = false;
  bool visibleListSendParameters = false;
  bool visibleListTrashParameters = false;

  String uidPartner = '';
  String uidContract = '';
  IncomingCashOrder newIncomingCashOrder =
      IncomingCashOrder(); // Шаблонный объект для отборов
  IncomingCashOrder sendIncomingCashOrder =
      IncomingCashOrder(); // Шаблонный объект для отборов
  IncomingCashOrder trashIncomingCashOrder =
      IncomingCashOrder(); // Шаблонный объект для отборов

  /// Начало периода отбора
  DateTime startPeriodDocs =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// Конец периода отбора
  DateTime finishPeriodDocs = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 23, 59, 59);

  DateTime startPeriodDocsToday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// Конец периода отбора
  DateTime finishPeriodDocsToday = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 23, 59, 59);

  /// Списки документов
  List<IncomingCashOrder> listNewIncomingCashOrder = [];
  List<IncomingCashOrder> listSendIncomingCashOrder = [];
  List<IncomingCashOrder> listTrashIncomingCashOrder = [];

  List<IncomingCashOrder> tempListNewIncomingCashOrder = [];
  List<IncomingCashOrder> tempListSendIncomingCashOrder = [];
  List<IncomingCashOrder> tempListTrashIncomingCashOrder = [];

  /// Количество
  int countNewDocs = 0;
  TextEditingController textFieldCountNewDocsController =
      TextEditingController();
  int countSendDocs = 0;
  TextEditingController textFieldCountSendDocsController =
      TextEditingController();
  int countTrashDocs = 0;
  TextEditingController textFieldCountTrashDocsController =
      TextEditingController();

  /// Количество за сутки
  int countNewDocsToday = 0;
  TextEditingController textFieldCountNewDocsTodayController =
      TextEditingController();
  int countSendDocsToday = 0;
  TextEditingController textFieldCountSendDocsTodayController =
      TextEditingController();
  int countTrashDocsToday = 0;
  TextEditingController textFieldCountTrashDocsTodayController =
      TextEditingController();

  /// Суммы
  double sumNewDocs = 0.0;
  TextEditingController textFieldSumNewDocsController = TextEditingController();
  double sumSendDocs = 0.0;
  TextEditingController textFieldSumSendDocsController =
      TextEditingController();
  double sumTrashDocs = 0.0;
  TextEditingController textFieldSumTrashDocsController =
      TextEditingController();

  /// Суммы за сутки
  double sumNewDocsToday = 0.0;
  TextEditingController textFieldSumNewDocsTodayController =
      TextEditingController();
  double sumSendDocsToday = 0.0;
  TextEditingController textFieldSumSendDocsTodayController =
      TextEditingController();
  double sumTrashDocsToday = 0.0;
  TextEditingController textFieldSumTrashDocsTodayController =
      TextEditingController();

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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var newIncomingCashOrder = IncomingCashOrder();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScreenItemIncomingCashOrder(
                    incomingCashOrder: newIncomingCashOrder),
              ),
            );
            await loadNewDocuments();
            await calculateNewDocuments();
            setState(() {});
          },
          tooltip: '+',
          child: const Text(
            "+",
            style: TextStyle(fontSize: 30),
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listNewParameters(),
                yesNewDocuments(),
                //countTrashDocuments == 0 ? noDocuments() : yesNewDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listSendParameters(),
                yesSendDocuments(),
                //countSendDocuments == 0 ? noDocuments() : yesSendDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listTrashParameters(),
                yesTrashDocuments(),
                //countTrashDocuments == 0 ? noDocuments() : yesTrashDocuments(),
              ],
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  loadData() async {
    await loadNewDocuments();
    await loadSendDocuments();
    await loadTrashDocuments();
    calculateNewDocuments();
    setState(() {});
  }

  loadNewDocuments() async {
    // Очистка списка заказов покупателя
    listNewIncomingCashOrder.clear();
    tempListNewIncomingCashOrder.clear();

    String namePartner = newIncomingCashOrder.uidPartner;
    String whereString = '';
    List whereList = [];

    // textFieldNewPeriodController.text =
    //     shortDateToString(startPeriodDocs) +
    //         ' - ' +
    //         shortDateToString(finishPeriodDocs);

    // Отбор по условиям
    if (textFieldNewPeriodController.text.isNotEmpty ||
        textFieldNewPartnerController.text.isNotEmpty) {
      if (textFieldNewPeriodController.text.isNotEmpty) {
        String dayStart = textFieldNewPeriodController.text.substring(0, 2);
        String monthStart = textFieldNewPeriodController.text.substring(3, 5);
        String yearStart = textFieldNewPeriodController.text.substring(6, 10);

        startPeriodDocs = DateTime.parse('$yearStart-$monthStart-$dayStart');

        String dayFinish = textFieldNewPeriodController.text.substring(13, 15);
        String monthFinish =
            textFieldNewPeriodController.text.substring(16, 18);
        String yearFinish = textFieldNewPeriodController.text.substring(19, 23);

        finishPeriodDocs =
            DateTime.parse('$yearFinish-$monthFinish-$dayFinish 23:59:59');
      }

      debugPrint('Период документов: НОВЫЕ...');
      debugPrint('Начало периода: ' + startPeriodDocs.toString());
      debugPrint('Конец периода: ' + finishPeriodDocs.toString());

      // Фильтр: по статусу
      whereList.add('status = 1');

      // Фильтр: по периоду
      if (textFieldNewPeriodController.text.isNotEmpty) {
        whereList.add('(date >= ? AND date <= ?)');
      }

      //Фильтр по партнеру
      if (textFieldNewPartnerController.text.isNotEmpty) {
        whereList.add('uidPartner = ?');
      }

      // Соединим условия отбора
      whereString = whereList.join(' AND ');

      final db = await instance.database;

      // Если есть период и партнер
      if (textFieldNewPeriodController.text.isNotEmpty &&
          textFieldNewPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
              namePartner
            ]);
        listNewIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }

      // Если есть период
      if (textFieldNewPeriodController.text.isNotEmpty &&
          textFieldNewPartnerController.text.isEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String()
            ]);
        listNewIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if (textFieldNewPeriodController.text.isEmpty &&
          textFieldNewPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESC',
            [namePartner]);
        listNewIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }
    } else {
      listNewIncomingCashOrder = await dbReadAllNewIncomingCashOrder();
    }

    // Для возврата из поиска
    tempListNewIncomingCashOrder.addAll(listNewIncomingCashOrder);

    // Количество документов в списке
    var countNewDocuments = listNewIncomingCashOrder.length;

    debugPrint('Количество новых документов: ' + countNewDocuments.toString());
  }

  loadSendDocuments() async {
    // Очистка списка заказов покупателя
    listSendIncomingCashOrder.clear();
    tempListSendIncomingCashOrder.clear();

    String namePartner = sendIncomingCashOrder.uidPartner;
    String whereString = '';
    List whereList = [];

    textFieldSendPeriodController.text = shortDateToString(startPeriodDocs) +
        ' - ' +
        shortDateToString(finishPeriodDocs);

    // Отбор по условиям
    if (textFieldSendPeriodController.text.isNotEmpty ||
        textFieldSendPartnerController.text.isNotEmpty) {
      if (textFieldSendPeriodController.text.isNotEmpty) {
        String dayStart = textFieldSendPeriodController.text.substring(0, 2);
        String monthStart = textFieldSendPeriodController.text.substring(3, 5);
        String yearStart = textFieldSendPeriodController.text.substring(6, 10);
        startPeriodDocs = DateTime.parse('$yearStart-$monthStart-$dayStart');

        String dayFinish = textFieldSendPeriodController.text.substring(13, 15);
        String monthFinish =
            textFieldSendPeriodController.text.substring(16, 18);
        String yearFinish =
            textFieldSendPeriodController.text.substring(19, 23);
        finishPeriodDocs =
            DateTime.parse('$yearFinish-$monthFinish-$dayFinish 23:59:59');
      }

      debugPrint('Период документов: ОТПРАВЛЕНО...');
      debugPrint('Начало периода: ' + startPeriodDocs.toString());
      debugPrint('Конец периода: ' + finishPeriodDocs.toString());

      // Фильтр: по статусу
      whereList.add('status = 2');

      // Фильтр: по периоду
      if (textFieldSendPeriodController.text.isNotEmpty) {
        whereList.add('(date >= ? AND date <= ?)');
      }

      //Фильтр по партнеру
      if (textFieldSendPartnerController.text.isNotEmpty) {
        whereList.add('uidPartner = ?');
      }

      // Соединим условия отбора
      whereString = whereList.join(' AND ');

      final db = await instance.database;

      // Если есть период и партнер
      if (textFieldSendPeriodController.text.isNotEmpty &&
          textFieldSendPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
              namePartner
            ]);
        listSendIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }

      // Если есть период
      if (textFieldSendPeriodController.text.isNotEmpty &&
          textFieldSendPartnerController.text.isEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String()
            ]);
        listSendIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if (textFieldSendPeriodController.text.isEmpty &&
          textFieldSendPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESC',
            [namePartner]);
        listSendIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }
    } else {
      listSendIncomingCashOrder = await dbReadAllSendIncomingCashOrder();
    }

    // Для возврата из поиска
    tempListSendIncomingCashOrder.addAll(listSendIncomingCashOrder);

    // Количество документов в списке
    var countSendDocuments = listSendIncomingCashOrder.length;

    debugPrint(
        'Количество отправленных документов: ' + countSendDocuments.toString());
  }

  loadTrashDocuments() async {
    // Очистка списка заказов покупателя
    listTrashIncomingCashOrder.clear();
    tempListTrashIncomingCashOrder.clear();

    // textFieldTrashPeriodController.text =
    //     shortDateToString(startPeriodDocs) +
    //         ' - ' +
    //         shortDateToString(finishPeriodDocs);

    String namePartner = trashIncomingCashOrder.uidPartner;
    String whereString = '';
    List whereList = [];

    // Отбор по условиям
    if (textFieldTrashPeriodController.text.isNotEmpty ||
        textFieldTrashPartnerController.text.isNotEmpty) {
      if (textFieldTrashPeriodController.text.isNotEmpty) {
        String dayStart = textFieldTrashPeriodController.text.substring(0, 2);
        String monthStart = textFieldTrashPeriodController.text.substring(3, 5);
        String yearStart = textFieldTrashPeriodController.text.substring(6, 10);
        startPeriodDocs = DateTime.parse('$yearStart-$monthStart-$dayStart');

        String dayFinish =
            textFieldTrashPeriodController.text.substring(13, 15);
        String monthFinish =
            textFieldTrashPeriodController.text.substring(16, 18);
        String yearFinish =
            textFieldTrashPeriodController.text.substring(19, 23);
        finishPeriodDocs =
            DateTime.parse('$yearFinish-$monthFinish-$dayFinish 23:59:59');
      }

      debugPrint('Период документов: КОРЗИНА...');
      debugPrint('Начало периода: ' + startPeriodDocs.toString());
      debugPrint('Конец периода: ' + finishPeriodDocs.toString());

      // Фильтр: по статусу
      whereList.add('status = 3');

      // Фильтр: по периоду
      if (textFieldTrashPeriodController.text.isNotEmpty) {
        whereList.add('(date >= ? AND date <= ?)');
      }

      //Фильтр по партнеру
      if (textFieldTrashPartnerController.text.isNotEmpty) {
        whereList.add('uidPartner = ?');
      }

      // Соединим условия отбора
      whereString = whereList.join(' AND ');

      final db = await instance.database;

      // Если есть период и партнер
      if (textFieldTrashPeriodController.text.isNotEmpty &&
          textFieldTrashPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
              namePartner
            ]);
        listTrashIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }

      // Если есть период
      if (textFieldTrashPeriodController.text.isNotEmpty &&
          textFieldTrashPartnerController.text.isEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String()
            ]);
        listSendIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if (textFieldTrashPeriodController.text.isEmpty &&
          textFieldTrashPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date DESCx',
            [namePartner]);
        listTrashIncomingCashOrder =
            result.map((json) => IncomingCashOrder.fromJson(json)).toList();
      }
    } else {
      listTrashIncomingCashOrder = await dbReadAllTrashIncomingCashOrder();
    }

    // Для возврата из поиска
    tempListTrashIncomingCashOrder.addAll(listTrashIncomingCashOrder);

    // Количество документов в списке
    var countTrashDocuments = listTrashIncomingCashOrder.length;

    debugPrint(
        'Количество удаленных документов: ' + countTrashDocuments.toString());
  }

  calculateNewDocuments() async {

    sumNewDocsToday = 0.0;
    sumSendDocsToday = 0.0;
    sumTrashDocsToday = 0.0;

    countNewDocsToday = 0;
    countSendDocsToday = 0;
    countTrashDocsToday = 0;

    sumNewDocs = 0.0;
    sumSendDocs = 0.0;
    sumTrashDocs = 0.0;

    countNewDocs = 0;
    countSendDocs = 0;
    countTrashDocs = 0;

    // Начало текущего дня
    DateTime dateA =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Конец текущего дня
    DateTime dateB = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 23, 59, 59);

    /// Новые
    for (var itemDoc in tempListNewIncomingCashOrder) {
      countNewDocs++;
      sumNewDocs = sumNewDocs + itemDoc.sum;
      // Подсчет за период
      DateTime dateC = itemDoc.date;
      if (dateA.isBefore(dateC) && dateB.isAfter(dateC)) {
        sumNewDocsToday = sumNewDocsToday + itemDoc.sum;
        countNewDocsToday++;
      }
    }

    /// Отправленные
    for (var itemDoc in tempListSendIncomingCashOrder) {
      countSendDocs++;
      sumSendDocs = sumSendDocs + itemDoc.sum;
      // Подсчет за период
      DateTime dateC = itemDoc.date;
      if (dateA.isBefore(dateC) && dateB.isAfter(dateC)) {
        //dateC is between dateA and dateB
        sumSendDocsToday = sumSendDocsToday + itemDoc.sum;
        countSendDocsToday++;
      }
    }

    /// Удаленные
    for (var itemDoc in tempListTrashIncomingCashOrder) {
      countTrashDocs++;
      sumTrashDocs = sumTrashDocs + itemDoc.sum;
      // Подсчет за период
      DateTime dateC = itemDoc.date;
      if (dateA.isBefore(dateC) && dateB.isAfter(dateC)) {
        sumTrashDocsToday = sumTrashDocsToday + itemDoc.sum;
        countTrashDocsToday++;
      }
    }

    /// Количество
    textFieldCountNewDocsController.text = countNewDocs.toString();
    textFieldCountNewDocsTodayController.text = countNewDocsToday.toString();
    textFieldCountSendDocsController.text = countSendDocs.toString();
    textFieldCountSendDocsTodayController.text = countSendDocsToday.toString();
    textFieldCountTrashDocsController.text = countTrashDocs.toString();
    textFieldCountTrashDocsTodayController.text =
        countTrashDocsToday.toString();

    /// Сумма
    textFieldSumNewDocsController.text = doubleToString(sumNewDocs);
    textFieldSumNewDocsTodayController.text = doubleToString(sumNewDocsToday);
    textFieldSumSendDocsController.text = doubleToString(sumSendDocs);
    textFieldSumSendDocsTodayController.text = doubleToString(sumSendDocsToday);
    textFieldSumTrashDocsController.text = doubleToString(sumTrashDocs);
    textFieldSumTrashDocsTodayController.text =
        doubleToString(sumTrashDocsToday);

    setState(() {});
  }

  deleteTrashDocuments() async {
    // Попробуем удалить документы из корзины
    await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text('Очистить корзину?'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        for (var item in listTrashIncomingCashOrder) {
                          dbDeleteIncomingCashOrder(item.id);
                        }
                        showMessage('Корзина очищена!', context);
                        Navigator.of(context).pop(true);
                      },
                      child: const SizedBox(
                          width: 60, child: Center(child: Text('Да')))),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                      },
                      child: const SizedBox(
                        width: 60,
                        child: Center(child: Text('Нет')),
                      )),
                ],
              ),
            ],
          );
        });
  }

  void filterSearchResultsNewDocuments() {
    /// Уберем пробелы
    String query = textFieldNewSearchController.text.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listNewIncomingCashOrder.clear();
        listNewIncomingCashOrder.addAll(tempListNewIncomingCashOrder);
      });
      return;
    }

    List<IncomingCashOrder> dummySearchList = <IncomingCashOrder>[];
    dummySearchList.addAll(tempListNewIncomingCashOrder);

    if (query.isNotEmpty) {
      List<IncomingCashOrder> dummyListData = <IncomingCashOrder>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listNewIncomingCashOrder.clear();
        listNewIncomingCashOrder.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listNewIncomingCashOrder.clear();
        listNewIncomingCashOrder.addAll(tempListNewIncomingCashOrder);
      });
    }
  }

  void filterSearchResultsSendDocuments() {
    /// Уберем пробелы
    String query = textFieldSendSearchController.text.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listSendIncomingCashOrder.clear();
        listSendIncomingCashOrder.addAll(tempListSendIncomingCashOrder);
      });
      return;
    }

    List<IncomingCashOrder> dummySearchList = <IncomingCashOrder>[];
    dummySearchList.addAll(tempListSendIncomingCashOrder);

    if (query.isNotEmpty) {
      List<IncomingCashOrder> dummyListData = <IncomingCashOrder>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listSendIncomingCashOrder.clear();
        listSendIncomingCashOrder.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listSendIncomingCashOrder.clear();
        listSendIncomingCashOrder.addAll(tempListSendIncomingCashOrder);
      });
    }
  }

  void filterSearchResultsTrashDocuments() {
    /// Уберем пробелы
    String query = textFieldTrashSearchController.text.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listTrashIncomingCashOrder.clear();
        listTrashIncomingCashOrder.addAll(tempListTrashIncomingCashOrder);
      });
      return;
    }

    List<IncomingCashOrder> dummySearchList = <IncomingCashOrder>[];
    dummySearchList.addAll(tempListTrashIncomingCashOrder);

    if (query.isNotEmpty) {
      List<IncomingCashOrder> dummyListData = <IncomingCashOrder>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listTrashIncomingCashOrder.clear();
        listTrashIncomingCashOrder.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listTrashIncomingCashOrder.clear();
        listTrashIncomingCashOrder.addAll(tempListTrashIncomingCashOrder);
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
                      setState(() {
                        visibleListNewParameters = !visibleListNewParameters;
                      });
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

        /// Скрытые отборы
        Visibility(
          visible: visibleListNewParameters,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameGroup(nameGroup: 'Параметры отбора'),

              /// Количество документов
              Row(
                children: [
                  /// Count
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                      child: TextField(
                        controller: textFieldCountNewDocsController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Количество (период)',
                        ),
                      ),
                    ),
                  ),

                  /// Count (today)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
                      child: TextField(
                        controller: textFieldCountNewDocsTodayController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Количество (сегодня)',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// Сумма документов
              Row(
                children: [
                  /// Sum
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                      child: TextField(
                        controller: textFieldSumNewDocsController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Сумма (период)',
                        ),
                      ),
                    ),
                  ),

                  /// Sum (today)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
                      child: TextField(
                        controller: textFieldSumNewDocsTodayController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Сумма (сегодня)',
                        ),
                      ),
                    ),
                  ),
                ],
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
                              startPeriodDocs = _datePick.start;
                              finishPeriodDocs = _datePick.end;

                              textFieldNewPeriodController.text =
                                  shortDateToString(startPeriodDocs) +
                                      ' - ' +
                                      shortDateToString(finishPeriodDocs);
                              setState(() {});
                            }
                          },
                          icon:
                              const Icon(Icons.date_range, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            startPeriodDocs = startPeriodDocsToday;
                            finishPeriodDocs = finishPeriodDocsToday;

                            textFieldNewPeriodController.text =
                                shortDateToString(startPeriodDocs) +
                                    ' - ' +
                                    shortDateToString(finishPeriodDocs);
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
                                            incomingCashOrder:
                                                newIncomingCashOrder)));
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

              /// Button refresh
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width - 28,
                      child: ElevatedButton(
                          onPressed: () async {
                            filterSearchResultsNewDocuments();
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
              nameGroup(nameGroup: 'Параметры отбора'),

              /// Количество документов
              Row(
                children: [
                  /// Count
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                      child: TextField(
                        controller: textFieldCountSendDocsController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Количество (период)',
                        ),
                      ),
                    ),
                  ),

                  /// Count (today)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
                      child: TextField(
                        controller: textFieldCountSendDocsTodayController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Количество (сегодня)',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// Сумма документов
              Row(
                children: [
                  /// Sum
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                      child: TextField(
                        controller: textFieldSumSendDocsController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Сумма (период)',
                        ),
                      ),
                    ),
                  ),

                  /// Sum (today)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
                      child: TextField(
                        controller: textFieldSumSendDocsTodayController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Сумма (сегодня)',
                        ),
                      ),
                    ),
                  ),
                ],
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
                              startPeriodDocs = _datePick.start;
                              finishPeriodDocs = _datePick.end;

                              textFieldSendPeriodController.text =
                                  shortDateToString(startPeriodDocs) +
                                      ' - ' +
                                      shortDateToString(finishPeriodDocs);
                            }
                            setState(() {});
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
                                            incomingCashOrder:
                                                newIncomingCashOrder)));
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

              /// Button refresh
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width - 28,
                      child: ElevatedButton(
                          onPressed: () async {
                            visibleListSendParameters = false;
                            await loadSendDocuments();
                            await calculateNewDocuments();
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
              nameGroup(nameGroup: 'Параметры отбора'),

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
                              startPeriodDocs = _datePick.start;
                              finishPeriodDocs = _datePick.end;

                              textFieldTrashPeriodController.text =
                                  shortDateToString(startPeriodDocs) +
                                      ' - ' +
                                      shortDateToString(finishPeriodDocs);
                            }
                            setState(() {});
                          },
                          icon:
                              const Icon(Icons.date_range, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            startPeriodDocs = startPeriodDocsToday;
                            finishPeriodDocs = finishPeriodDocsToday;

                            textFieldTrashPeriodController.text =
                                shortDateToString(startPeriodDocs) +
                                    ' - ' +
                                    shortDateToString(finishPeriodDocs);
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
                                            incomingCashOrder:
                                                newIncomingCashOrder)));
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

              /// Button refresh
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width - 28,
                      child: ElevatedButton(
                          onPressed: () async {
                            visibleListTrashParameters = false;
                            await loadTrashDocuments();
                            await calculateNewDocuments();
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
                  ],
                ),
              ),

              /// Button Delete all
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width - 28,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.grey)),
                          onPressed: () async {
                            await deleteTrashDocuments();
                            await loadTrashDocuments();
                            visibleListTrashParameters = false;
                            setState(() {});
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(width: 14),
                              Text('Очистить корзину'),
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
        itemCount: listNewIncomingCashOrder.length,
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
                      builder: (context) => ScreenItemIncomingCashOrder(
                          incomingCashOrder: incomingCashOrder),
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
                        Flexible(
                            flex: 1,
                            child: Text(incomingCashOrder.nameContract)),
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
                                  Text(shortDateToString(
                                      incomingCashOrder.date)),
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
                                  Text(doubleToString(incomingCashOrder.sum) +
                                      ' грн'),
                                ],
                              ),
                            ],
                          ))
                    ]),
                    const SizedBox(height: 5),
                    if (incomingCashOrder.comment != '')
                      Row(children: [
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
        itemCount: listSendIncomingCashOrder.length,
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
                      builder: (context) => ScreenItemIncomingCashOrder(
                          incomingCashOrder: incomingCashOrder),
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
                        Flexible(
                            flex: 1,
                            child: Text(incomingCashOrder.nameContract)),
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
                                  Text(shortDateToString(
                                      incomingCashOrder.date)),
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
                                  Text(doubleToString(incomingCashOrder.sum) +
                                      ' грн'),
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
                                      ? Text(shortDateToString(
                                          incomingCashOrder.dateSendingTo1C))
                                      : const Text('Даты нет!',
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
                                      ? Text(incomingCashOrder.numberFrom1C)
                                      : const Text('Номера нет!',
                                          style: TextStyle(color: Colors.red)),
                                ],
                              )
                            ],
                          ))
                    ]),
                    const SizedBox(height: 5),
                    if (incomingCashOrder.comment != '')
                      Row(children: [
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
        itemCount: listTrashIncomingCashOrder.length,
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
                      builder: (context) => ScreenItemIncomingCashOrder(
                          incomingCashOrder: incomingCashOrder),
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
                        Flexible(
                            flex: 1,
                            child: Text(incomingCashOrder.nameContract)),
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
                                  Text(shortDateToString(
                                      incomingCashOrder.date)),
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
                                  Text(doubleToString(incomingCashOrder.sum) +
                                      ' грн'),
                                ],
                              ),
                            ],
                          ))
                    ]),
                    const SizedBox(height: 5),
                    if (incomingCashOrder.comment != '')
                      Row(children: [
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
