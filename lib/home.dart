import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_screens.dart';
import 'package:wp_sales/system/widgets.dart';

import 'import/import_model.dart';
import 'screens/references/contracts/contract_item.dart';

class ScreenHomePage extends StatefulWidget {
  const ScreenHomePage({Key? key}) : super(key: key);

  @override
  State<ScreenHomePage> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends State<ScreenHomePage> {
  DateTime currentBackPressTime = DateTime.now();

  List<Contract> listForPaymentContracts = [];
  double balance = 0.0;
  double balanceForPayment = 0.0;

  double sumOrderCustomerToday = 0.0;
  double sumIncomingCashOrderToday = 0.0;

  int countNewOrderCustomer = 0;
  int countSendOrderCustomer = 0;
  int countNewIncomingCashOrder = 0;
  int countSendIncomingCashOrder = 0;

  bool loadingData = false;

  @override
  void initState() {
    super.initState();
    renewItem();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      showMessage('Для выхода нажмите кнопку "Назад" еще раз.', context);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('WP Sales'),
          actions: [
            IconButton(
                onPressed: () async {
                  await renewItem();
                  setState(() {});
                },
                icon: const Icon(Icons.refresh)),
          ],
        ),
        drawer: const MainDrawer(),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  //nameGroup('Статистика (общая)'),
                  balanceCard(),
                  //nameGroup('Балансы контрактов (к оплате)'),
                  debtsCard(),
                  //nameGroup('Документы на отправку'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  renewItem() async {
    setState(() {
      loadingData = true;
    });

    balance = 0.0;
    balanceForPayment = 0.0;
    listForPaymentContracts.clear();

    List<AccumPartnerDept> listAllDebts =
        await dbReadAllAccumPartnerDeptForPayment();
    List<AccumPartnerDept> listDebts = [];

    // Свернем долги по договору
    for (var itemDebts in listAllDebts) {
      // Ищем контракт в списке и увеличиваем баланс по каждому из них
      var indexItem = listDebts.indexWhere(
          (element) => element.uidContract == itemDebts.uidContract);

      // Если нашли долг в списке отобранных, иначе добавим новую апись в список
      if (indexItem >= 0) {
        var itemList = listDebts[indexItem];
        itemList.balance = itemList.balance + itemDebts.balance;
        itemList.balanceForPayment =
            itemList.balanceForPayment + itemDebts.balanceForPayment;
      } else {
        listDebts.add(itemDebts);
      }
    }

    // Сортируем временный список долгов по балансу на оплату
    listDebts
        .sort((a, b) => b.balanceForPayment.compareTo(a.balanceForPayment));

    // Отобразим только 10 штук на экране, а остальные посуммируем
    var limitCount = 10;
    for (var itemDebts in listDebts) {
      Contract itemContract = await dbReadContractUID(itemDebts.uidContract);

      // Получить баланс заказа
      Map debts = await dbReadSumAccumPartnerDeptByContract(
          uidContract: itemDebts.uidContract);

      itemContract.balance = debts['balance'];
      itemContract.balanceForPayment = debts['balanceForPayment'];

      if (limitCount == 0) {
        continue;
      }

      // Добавим в список для отображения на форме
      listForPaymentContracts.add(itemContract);
      limitCount--;
    }

    // Прочитаем сумму всех долгов
    var debts = await dbReadAllAccumPartnerDept();
    for (var debt in debts) {
      balance = balance + debt.balance;
      balanceForPayment = balanceForPayment + debt.balanceForPayment;
    }

    // Суммы документов
    await readSumDocumentToday();

    // Прочитаем количество документов
    await readCountDocuments();

    if (mounted) {
      setState(() {
        loadingData = false;
      });
    }
  }

  readCountDocuments() async {
    countSendOrderCustomer = await dbGetCountSendOrderCustomer();
    countSendIncomingCashOrder = await dbGetCountSendIncomingCashOrder();
  }

  readSumDocumentToday() async {
    String whereString = '';
    List whereList = [];

    String dayStart = DateTime.now().toString().substring(8, 10);
    String monthStart = DateTime.now().toString().substring(5, 7);
    String yearStart = DateTime.now().toString().substring(0, 4);

    String dayFinish = DateTime.now().toString().substring(8, 10);
    String monthFinish = DateTime.now().toString().substring(5, 7);
    String yearFinish = DateTime.now().toString().substring(0, 4);

    String dateStart =
        DateTime.parse('$yearStart-$monthStart-$dayStart').toIso8601String();
    String dateFinish =
        DateTime.parse('$yearFinish-$monthFinish-$dayFinish 23:59:59')
            .toIso8601String();

    // Фильтр: по статусу
    whereList.add('status = 1');
    whereList.add('(date >= ? AND date <= ?)');

    // Соединим условия отбора
    whereString = whereList.join(' AND ');

    // Очистка данных
    sumIncomingCashOrderToday = 0.0;
    sumIncomingCashOrderToday = 0.0;
    countNewOrderCustomer = 0;
    countNewIncomingCashOrder = 0;

    // Экземпляр базы даных
    final db = await instance.database;

    // Запрос на заказ покупателя
    final resultOrderCustomer = await db.rawQuery(
        'SELECT * FROM $tableOrderCustomer WHERE $whereString ORDER BY date ASC',
        [dateStart, dateFinish]);
    List<OrderCustomer> listSendOrdersCustomer = resultOrderCustomer
        .map((json) => OrderCustomer.fromJson(json))
        .toList();
    for (var orderCustomer in listSendOrdersCustomer) {
      sumOrderCustomerToday = sumOrderCustomerToday + orderCustomer.sum;
      countNewOrderCustomer = countNewOrderCustomer + 1;
    }

    // Запрос на оплаты
    final resultIncomingCashOrder = await db.rawQuery(
        'SELECT * FROM $tableIncomingCashOrder WHERE $whereString ORDER BY date ASC',
        [dateStart, dateFinish]);
    List<OrderCustomer> listSendIncomingCashOrder = resultIncomingCashOrder
        .map((json) => OrderCustomer.fromJson(json))
        .toList();
    for (var incomingCashOrder in listSendIncomingCashOrder) {
      sumIncomingCashOrderToday =
          sumIncomingCashOrderToday + incomingCashOrder.sum;
      countNewIncomingCashOrder = countNewIncomingCashOrder + 1;
    }
  }

  nameGroup(String nameGroup) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 7, 7, 0),
      child: Text(nameGroup,
          style: const TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold)),
    );
  }

  balanceCard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 10,
              child: Card(
                color: Colors.blue.shade500,
                elevation: 3,
                child: ListTile(
                  title: const Center(
                      child: Text(
                    'Баланс',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Center(
                        child: Text('₴ ' + doubleToString(balance),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 10,
              child: Card(
                color: Colors.blue.shade500,
                elevation: 3,
                child: ListTile(
                  title: const Center(
                      child: Text(
                    'Баланс к оплате',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Text('₴ ' + doubleToString(balanceForPayment),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 10,
              child: Card(
                color: Colors.blue.shade300,
                elevation: 3,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenOrderCustomerList()));
                  },
                  title: const Center(
                      child: Text(
                    'Заказы (шт)',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Center(
                        child: Text(
                            countNewOrderCustomer.toString() +
                                ' из ' +
                                countSendOrderCustomer.toString(),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black45)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 10,
              child: Card(
                color: Colors.blue.shade300,
                elevation: 3,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenIncomingCashOrderList()));
                  },
                  title: const Center(
                      child: Text(
                    'ПКО (шт)',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Text(
                          countNewIncomingCashOrder.toString() +
                              ' из ' +
                              countSendIncomingCashOrder.toString(),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black45)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 10,
              child: Card(
                color: Colors.blue.shade200,
                elevation: 3,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenOrderCustomerList()));
                  },
                  title: const Center(
                      child: Text(
                    'Заказы (грн)',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Center(
                        child: Text(doubleToString(sumOrderCustomerToday),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black45)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 10,
              child: Card(
                color: Colors.blue.shade200,
                elevation: 3,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenIncomingCashOrderList()));
                  },
                  title: const Center(
                      child: Text(
                    'ПКО (грн)',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Text(doubleToString(sumIncomingCashOrderToday),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black45)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  debtsCard() {
    return loadingData
        ? const SizedBox(
            height: 100, child: Center(child: CircularProgressIndicator()))
        : listForPaymentContracts.isNotEmpty
            ? ColumnListViewBuilder(
                itemCount: listForPaymentContracts.length,
                itemBuilder: (context, index) {
                  Contract contractItem = listForPaymentContracts[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Card(
                      color: Colors.blue.shade50,
                      elevation: 3,
                      child: ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScreenContractItem(
                                  contractItem: contractItem),
                            ),
                          );
                          await renewItem();
                        },
                        title: Text(contractItem.namePartner,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue)),
                        subtitle: Column(
                          children: [
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              color: Colors.blue, size: 20),
                                          const SizedBox(width: 5),
                                          Flexible(
                                              child: Text(contractItem.name)),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone,
                                              color: Colors.blue, size: 20),
                                          const SizedBox(width: 5),
                                          Text(contractItem.phone),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.home,
                                              color: Colors.blue, size: 20),
                                          const SizedBox(width: 5),
                                          Flexible(
                                              child:
                                                  Text(contractItem.address)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.price_change,
                                              color: Colors.green, size: 20),
                                          const SizedBox(width: 5),
                                          Text(doubleToString(
                                              contractItem.balance)),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.price_change,
                                              color: Colors.red, size: 20),
                                          const SizedBox(width: 5),
                                          Text(doubleToString(
                                              contractItem.balanceForPayment)),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.schedule,
                                              color: Colors.blue, size: 20),
                                          const SizedBox(width: 5),
                                          Text(contractItem.schedulePayment
                                              .toString()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const Center(
                child: Text(
                  'Балансы партнёров для оплат не обнаружены',
                  style: TextStyle(color: Colors.grey,
                  fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            );
  }

  debtsCardOld() {
    return loadingData
        ? const SizedBox(
            height: 100, child: Center(child: CircularProgressIndicator()))
        : Padding(
            padding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
            child: ColumnListViewBuilder(
                itemCount: listForPaymentContracts.length,
                itemBuilder: (context, index) {
                  Contract contractItem = listForPaymentContracts[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ScreenContractItem(contractItem: contractItem),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 2,
                              offset: Offset(1, 1), // Shadow position
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(100, 181, 246, 1.0),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                  // bottomLeft: Radius.circular(5),
                                  // bottomRight: Radius.circular(5)
                                ),
                              ),
                              //height: 40,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  contractItem.namePartner,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                color: Colors.blue, size: 20),
                                            const SizedBox(width: 5),
                                            Flexible(
                                                child: Text(contractItem.name)),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone,
                                                color: Colors.blue, size: 20),
                                            const SizedBox(width: 5),
                                            Text(contractItem.phone),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.home,
                                                color: Colors.blue, size: 20),
                                            const SizedBox(width: 5),
                                            Flexible(
                                                child:
                                                    Text(contractItem.address)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.price_change,
                                                color: Colors.green, size: 20),
                                            const SizedBox(width: 5),
                                            Text(doubleToString(
                                                contractItem.balance)),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.price_change,
                                                color: Colors.red, size: 20),
                                            const SizedBox(width: 5),
                                            Text(doubleToString(contractItem
                                                .balanceForPayment)),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule,
                                                color: Colors.blue, size: 20),
                                            const SizedBox(width: 5),
                                            Text(contractItem.schedulePayment
                                                .toString()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
  }
}
