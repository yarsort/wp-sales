import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_doc_return_order_customer.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/screens/documents/return_order_customer/return_order_customer_item.dart';
import 'package:wp_sales/screens/references/contracts/contract_selection.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenReturnOrderCustomerList extends StatefulWidget {
  const ScreenReturnOrderCustomerList({Key? key}) : super(key: key);

  @override
  _ScreenReturnOrderCustomerListState createState() =>
      _ScreenReturnOrderCustomerListState();
}

class _ScreenReturnOrderCustomerListState
    extends State<ScreenReturnOrderCustomerList> {
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
  ReturnOrderCustomer newReturnOrderCustomer =
      ReturnOrderCustomer(); // Шаблонный объект для отборов
  ReturnOrderCustomer sendReturnOrderCustomer =
      ReturnOrderCustomer(); // Шаблонный объект для отборов
  ReturnOrderCustomer trashReturnOrderCustomer =
      ReturnOrderCustomer(); // Шаблонный объект для отборов

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
  List<ReturnOrderCustomer> listNewReturnOrdersCustomer = [];
  List<ReturnOrderCustomer> listSendReturnOrdersCustomer = [];
  List<ReturnOrderCustomer> listTrashReturnOrdersCustomer = [];

  List<ReturnOrderCustomer> tempListNewReturnOrdersCustomer = [];
  List<ReturnOrderCustomer> tempListSendReturnOrdersCustomer = [];
  List<ReturnOrderCustomer> tempListTrashReturnOrdersCustomer = [];

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

  void loadData() async {
    await loadNewDocuments();
    await loadSendDocuments();
    await loadTrashDocuments();
    calculateNewDocuments();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Возвраты покупателей'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Новые'),
              Tab(text: 'Отправлено'),
              Tab(text: 'Корзина'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var newReturnOrderCustomer = ReturnOrderCustomer();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScreenItemReturnOrderCustomer(
                    returnOrderCustomer: newReturnOrderCustomer),
              ),
            );
            await loadNewDocuments();
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
    listNewReturnOrdersCustomer.clear();
    tempListNewReturnOrdersCustomer.clear();

    // textFieldNewPeriodController.text = shortDateToString(startPeriodDocs) +
    //     ' - ' +
    //     shortDateToString(finishPeriodDocs);

    String namePartner = newReturnOrderCustomer.uidPartner;
    String whereString = '';
    List whereList = [];

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
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
              namePartner
            ]);
        listNewReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }

      // Если есть период
      if (textFieldNewPeriodController.text.isNotEmpty &&
          textFieldNewPartnerController.text.isEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
            ]);
        listNewReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if (textFieldNewPeriodController.text.isEmpty &&
          textFieldNewPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESC',
            [namePartner]);
        listNewReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }
    } else {
      listNewReturnOrdersCustomer = await dbReadAllNewReturnOrderCustomer();
    }

    // Для возврата из поиска
    tempListNewReturnOrdersCustomer.addAll(listNewReturnOrdersCustomer);

    // Количество документов в списке
    var countNewDocuments = listNewReturnOrdersCustomer.length;

    debugPrint('Количество новых документов: ' + countNewDocuments.toString());
  }

  loadSendDocuments() async {
    // Очистка списка заказов покупателя
    listSendReturnOrdersCustomer.clear();
    tempListSendReturnOrdersCustomer.clear();

    textFieldSendPeriodController.text = shortDateToString(startPeriodDocs) +
        ' - ' +
        shortDateToString(finishPeriodDocs);

    String namePartner = sendReturnOrderCustomer.uidPartner;
    String whereString = '';
    List whereList = [];

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
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
              namePartner
            ]);
        listSendReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }

      // Если есть период
      if (textFieldSendPeriodController.text.isNotEmpty &&
          textFieldSendPartnerController.text.isEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
            ]);
        listSendReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if (textFieldNewPeriodController.text.isEmpty &&
          textFieldSendPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESC',
            [namePartner]);
        listSendReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }
    } else {
      listSendReturnOrdersCustomer = await dbReadAllSendReturnOrderCustomer();
    }

    // Для возврата из поиска
    tempListSendReturnOrdersCustomer.addAll(listSendReturnOrdersCustomer);

    // Количество документов в списке
    var countSendDocuments = listSendReturnOrdersCustomer.length;

    debugPrint(
        'Количество отправленных документов: ' + countSendDocuments.toString());
  }

  loadTrashDocuments() async {
    // Очистка списка заказов покупателя
    listTrashReturnOrdersCustomer.clear();
    tempListTrashReturnOrdersCustomer.clear();

    // textFieldTrashPeriodController.text = shortDateToString(startPeriodDocs) +
    //     ' - ' +
    //     shortDateToString(finishPeriodDocs);

    String namePartner = trashReturnOrderCustomer.uidPartner;
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
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
              namePartner
            ]);
        listTrashReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }

      // Если есть период
      if (textFieldSendPeriodController.text.isNotEmpty &&
          textFieldSendPartnerController.text.isEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESC',
            [
              startPeriodDocs.toIso8601String(),
              finishPeriodDocs.toIso8601String(),
            ]);
        listTrashReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }

      // Если есть период и партнер
      if (textFieldTrashPeriodController.text.isEmpty &&
          textFieldTrashPartnerController.text.isNotEmpty) {
        final result = await db.rawQuery(
            'SELECT * FROM $tableReturnOrderCustomer WHERE $whereString ORDER BY date DESCx',
            [namePartner]);
        listTrashReturnOrdersCustomer =
            result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
      }
    } else {
      listTrashReturnOrdersCustomer = await dbReadAllTrashReturnOrderCustomer();
    }

    // Для возврата из поиска
    tempListTrashReturnOrdersCustomer.addAll(listTrashReturnOrdersCustomer);

    // Количество документов в списке
    var countTrashDocuments = listTrashReturnOrdersCustomer.length;

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
    for (var itemDoc in tempListNewReturnOrdersCustomer) {
      countNewDocs++;
      sumNewDocs = sumNewDocs + itemDoc.sum;
      // Подсчет за сегодня
      DateTime dateC = itemDoc.date;
      if (dateA.isBefore(dateC) && dateB.isAfter(dateC)) {
        sumNewDocsToday = sumNewDocsToday + itemDoc.sum;
        countNewDocsToday++;
      }
    }

    /// Отправленные
    for (var itemDoc in tempListSendReturnOrdersCustomer) {
      countSendDocs++;
      sumSendDocs = sumSendDocs + itemDoc.sum;
      // Подсчет за сегодня
      DateTime dateC = itemDoc.date;
      if (dateA.isBefore(dateC) && dateB.isAfter(dateC)) {
        //dateC is between dateA and dateB
        sumSendDocsToday = sumSendDocsToday + itemDoc.sum;
        countSendDocsToday++;
      }
    }

    /// Удаленные
    for (var itemDoc in tempListTrashReturnOrdersCustomer) {
      countTrashDocs++;
      sumTrashDocs = sumTrashDocs + itemDoc.sum;
      // Подсчет за сегодня
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
                        for (var item in listTrashReturnOrdersCustomer) {
                          dbDeleteReturnOrderCustomer(item.id);
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
        listNewReturnOrdersCustomer.clear();
        listNewReturnOrdersCustomer.addAll(tempListNewReturnOrdersCustomer);
      });
      return;
    }

    List<ReturnOrderCustomer> dummySearchList = <ReturnOrderCustomer>[];
    dummySearchList.addAll(tempListNewReturnOrdersCustomer);

    if (query.isNotEmpty) {
      List<ReturnOrderCustomer> dummyListData = <ReturnOrderCustomer>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listNewReturnOrdersCustomer.clear();
        listNewReturnOrdersCustomer.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listNewReturnOrdersCustomer.clear();
        listNewReturnOrdersCustomer.addAll(tempListNewReturnOrdersCustomer);
      });
    }
  }

  void filterSearchResultsSendDocuments() {
    /// Уберем пробелы
    String query = textFieldSendSearchController.text.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listSendReturnOrdersCustomer.clear();
        listSendReturnOrdersCustomer.addAll(tempListSendReturnOrdersCustomer);
      });
      return;
    }

    List<ReturnOrderCustomer> dummySearchList = <ReturnOrderCustomer>[];
    dummySearchList.addAll(tempListSendReturnOrdersCustomer);

    if (query.isNotEmpty) {
      List<ReturnOrderCustomer> dummyListData = <ReturnOrderCustomer>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listSendReturnOrdersCustomer.clear();
        listSendReturnOrdersCustomer.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listSendReturnOrdersCustomer.clear();
        listSendReturnOrdersCustomer.addAll(tempListSendReturnOrdersCustomer);
      });
    }
  }

  void filterSearchResultsTrashDocuments() {
    /// Уберем пробелы
    String query = textFieldTrashSearchController.text.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listTrashReturnOrdersCustomer.clear();
        listTrashReturnOrdersCustomer.addAll(tempListTrashReturnOrdersCustomer);
      });
      return;
    }

    List<ReturnOrderCustomer> dummySearchList = <ReturnOrderCustomer>[];
    dummySearchList.addAll(tempListTrashReturnOrdersCustomer);

    if (query.isNotEmpty) {
      List<ReturnOrderCustomer> dummyListData = <ReturnOrderCustomer>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listTrashReturnOrdersCustomer.clear();
        listTrashReturnOrdersCustomer.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listTrashReturnOrdersCustomer.clear();
        listTrashReturnOrdersCustomer.addAll(tempListTrashReturnOrdersCustomer);
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
                                            returnOrderCustomer:
                                                newReturnOrderCustomer)));
                            setState(() {
                              textFieldNewPartnerController.text =
                                  newReturnOrderCustomer.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldNewPartnerController.text = '';
                              newReturnOrderCustomer.uidPartner = '';
                              newReturnOrderCustomer.namePartner = '';
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
                                            returnOrderCustomer:
                                                newReturnOrderCustomer)));
                            setState(() {
                              textFieldNewContractController.text =
                                  newReturnOrderCustomer.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldNewContractController.text = '';
                              newReturnOrderCustomer.uidContract = '';
                              newReturnOrderCustomer.nameContract = '';
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
                            visibleListNewParameters = false;
                            await loadNewDocuments();
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
                          onPressed: () async {
                            startPeriodDocs = startPeriodDocsToday;
                            finishPeriodDocs = finishPeriodDocsToday;

                            textFieldSendPeriodController.text =
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
                                            returnOrderCustomer:
                                                newReturnOrderCustomer)));
                            setState(() {
                              textFieldSendPartnerController.text =
                                  newReturnOrderCustomer.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldSendPartnerController.text = '';
                              newReturnOrderCustomer.uidPartner = '';
                              newReturnOrderCustomer.namePartner = '';
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
                                            returnOrderCustomer:
                                                newReturnOrderCustomer)));
                            setState(() {
                              textFieldSendContractController.text =
                                  newReturnOrderCustomer.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldSendContractController.text = '';
                              newReturnOrderCustomer.uidContract = '';
                              newReturnOrderCustomer.nameContract = '';
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
                                            returnOrderCustomer:
                                                newReturnOrderCustomer)));
                            setState(() {
                              textFieldTrashPartnerController.text =
                                  newReturnOrderCustomer.namePartner;
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldTrashPartnerController.text = '';
                              newReturnOrderCustomer.uidPartner = '';
                              newReturnOrderCustomer.namePartner = '';
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
                                            returnOrderCustomer:
                                                newReturnOrderCustomer)));
                            setState(() {
                              textFieldTrashContractController.text =
                                  newReturnOrderCustomer.nameContract;
                            });
                          },
                          icon: const Icon(Icons.recent_actors,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldTrashContractController.text = '';
                              newReturnOrderCustomer.uidContract = '';
                              newReturnOrderCustomer.nameContract = '';
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
        itemCount: listNewReturnOrdersCustomer.length,
        itemBuilder: (context, index) {
          final returnOrderCustomer = listNewReturnOrdersCustomer[index];
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
                      builder: (context) => ScreenItemReturnOrderCustomer(
                          returnOrderCustomer: returnOrderCustomer),
                    ),
                  );
                  loadData();
                },
                title: Text(returnOrderCustomer.namePartner),
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
                            child: Text(returnOrderCustomer.nameContract)),
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
                                  Text(shortDateToString(
                                      returnOrderCustomer.date)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(
                                      returnOrderCustomer.dateSending)),
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
                                  Text(doubleToString(returnOrderCustomer.sum) +
                                      ' грн'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(returnOrderCustomer.countItems
                                          .toString() +
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
    return ColumnListViewBuilder(
        itemCount: listSendReturnOrdersCustomer.length,
        itemBuilder: (context, index) {
          final returnOrderCustomer = listSendReturnOrdersCustomer[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Card(
              elevation: 3,
              child: ListTile(
                tileColor: returnOrderCustomer.numberFrom1C != ''
                    ? Colors.lightGreen[50]
                    : Colors.deepOrange[50],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenItemReturnOrderCustomer(
                          returnOrderCustomer: returnOrderCustomer),
                    ),
                  );
                  loadData();
                },
                title: Text(returnOrderCustomer.namePartner),
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
                            child: Text(returnOrderCustomer.nameContract)),
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
                                  Text(shortDateToString(
                                      returnOrderCustomer.date)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(
                                      returnOrderCustomer.dateSending)),
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
                                  Text(doubleToString(returnOrderCustomer.sum) +
                                      ' грн'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(returnOrderCustomer.countItems
                                          .toString() +
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
                                      returnOrderCustomer.dateSendingTo1C)),
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
                                  returnOrderCustomer.numberFrom1C != ''
                                      ? const Icon(Icons.repeat_one,
                                          color: Colors.green, size: 20)
                                      : const Icon(Icons.repeat_one,
                                          color: Colors.red, size: 20),
                                  const SizedBox(width: 5),
                                  returnOrderCustomer.numberFrom1C != ''
                                      ? Text(returnOrderCustomer.numberFrom1C)
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
    return ColumnListViewBuilder(
        itemCount: listTrashReturnOrdersCustomer.length,
        itemBuilder: (context, index) {
          final returnOrderCustomer = listTrashReturnOrdersCustomer[index];
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
                      builder: (context) => ScreenItemReturnOrderCustomer(
                          returnOrderCustomer: returnOrderCustomer),
                    ),
                  );
                  loadData();
                },
                title: Text(returnOrderCustomer.namePartner),
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
                            child: Text(returnOrderCustomer.nameContract)),
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
                                  Text(shortDateToString(
                                      returnOrderCustomer.date)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(
                                      returnOrderCustomer.dateSending)),
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
                                  Text(doubleToString(returnOrderCustomer.sum) +
                                      ' грн'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(returnOrderCustomer.countItems
                                          .toString() +
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
