import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/models/accum_partner_depts.dart';
import 'package:wp_sales/models/ref_contract.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

import 'screens/references/contracts/contract_item.dart';

class ScreenHomePage extends StatefulWidget {
  const ScreenHomePage({Key? key}) : super(key: key);

  @override
  State<ScreenHomePage> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends State<ScreenHomePage> {
  List<Contract> listForPaymentContracts = [];
  double balance = 0.0;
  double balanceForPayment = 0.0;

  @override
  void initState() {
    super.initState();
    renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                nameGroup('Балансы контрактов (к оплате)'),
                debtsCard(),
                //nameGroup('Документы на отправку'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  renewItem() async {
    balance = 0.0;
    balanceForPayment = 0.0;
    listForPaymentContracts.clear();

    List<AccumPartnerDept> listAllDebts = await dbReadAllAccumPartnerDeptForPayment();
    List<AccumPartnerDept> listDebts = [];

    // Свернем долги по договору
    for (var itemDebts in listAllDebts) {

      // Ищем контракт в списке и увеличиваем баланс по каждому из них
      var indexItem = listDebts.indexWhere((element) => element.uidContract == itemDebts.uidContract);

      // Если нашли долг в списке отобранных, иначе добавим новую апись в список
      if (indexItem >= 0) {
        var itemList = listDebts[indexItem];
        itemList.balance = itemList.balance + itemDebts.balance;
        itemList.balanceForPayment = itemList.balanceForPayment + itemDebts.balanceForPayment;
      } else {
        listDebts.add(itemDebts);
      }
    }

    // Сортируем временный список долгов по балансу на оплату
    listDebts.sort((a, b) => b.balanceForPayment.compareTo(a.balanceForPayment));

    // Отобразим только 10 штук на экране, а остальные посуммируем
    var limitCount = 10;
    for (var itemDebts in listDebts) {
      Contract itemContract = await dbReadContractUID(itemDebts.uidContract);

      // Получить баланс заказа
      Map debts = await dbReadSumAccumPartnerDeptByContract(
          uidContract: itemDebts.uidContract);

      itemContract.balance = debts['balance'];
      itemContract.balanceForPayment = debts['balanceForPayment'];

      balance = balance + debts['balance'];
      balanceForPayment = balanceForPayment + debts['balanceForPayment'];

      if (limitCount == 0) {
        continue;
      }

      // Добавим в список для отображения на форме
      listForPaymentContracts.add(itemContract);
      limitCount--;
    }

    setState(() {});
  }

  nameGroup(String nameGroup) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
      child: Text(nameGroup,
          style: const TextStyle(
              fontSize: 16, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
    );
  }

  balanceCard() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
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
            height: 120,
            width: MediaQuery.of(context).size.width / 2 - 22,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(100, 181, 246, 1.0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      // bottomLeft: Radius.circular(5),
                      // bottomRight: Radius.circular(5)
                    ),
                  ),
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2 - 18,
                  child: const Center(
                    child: Text(
                      'Баланс',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Icon(
                      Icons.balance,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '₴ ' + doubleToString(balance),
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Container(
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
            height: 120,
            width: MediaQuery.of(context).size.width / 2 - 22,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(100, 181, 246, 1.0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      //bottomLeft: Radius.circular(5),
                      //bottomRight: Radius.circular(5)
                    ),
                  ),
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2 - 18,
                  child: const Center(
                    child: Text(
                      'Баланс к оплате',
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Icon(
                      Icons.balance,
                      color: Colors.red,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '₴ ' + doubleToString(balanceForPayment),
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  debtsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
      child: ColumnBuilder(
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
                                      Flexible(child: Text(contractItem.name)),
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
                                      Flexible(child: Text(contractItem.address)),
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
                                      Text(doubleToString(contractItem.balance)),
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
                                      Text(contractItem.schedulePayment.toString()),
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
