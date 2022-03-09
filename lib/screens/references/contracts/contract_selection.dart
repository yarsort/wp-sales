import 'package:flutter/material.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/contract.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/partner.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/screens/references/partners/partner_item.dart';

class ScreenContractSelection extends StatefulWidget {

  final OrderCustomer orderCustomer;

  const ScreenContractSelection({Key? key, required this.orderCustomer}) : super(key: key);

  @override
  _ScreenContractSelectionState createState() => _ScreenContractSelectionState();
}

class _ScreenContractSelectionState extends State<ScreenContractSelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Contract> tempItems = [];
  List<Contract> listContracts = [];

  @override
  void initState() {
    renewItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Договоры партнера'),
      ),
      //drawer: const MainDrawer(),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var newPartnerItem = Partner();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenPartnerItem(partnerItem: newPartnerItem),
            ),
          );
        },
        tooltip: 'Добавить договор',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    // Очистка списка заказов покупателя
    listContracts.clear();
    tempItems.clear();

    listContracts =
        await DatabaseHelper.instance.readAllContracts();
    tempItems.addAll(listContracts);

    setState(() {});

    // // Получение и запись списка заказов покупателей
    // for (var message in listDataContracts) {
    //   Contract newContract = Contract.fromJson(message);
    //   listContracts.add(newContract);
    //   tempItems.add(newContract); // Как шаблон
    // }
  }

  void filterSearchResults(String query) {

    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listContracts.clear();
        listContracts.addAll(tempItems);
      });
      return;
    }

    List<Contract> dummySearchList = <Contract>[];
    dummySearchList.addAll(listContracts);

    if (query.isNotEmpty) {

      List<Contract> dummyListData = <Contract>[];

      for (var item in dummySearchList) {
        /// Поиск по имени партнера
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        /// Поиск по адресу
        if (item.address.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        /// Поиск по номеру телефона
        if (item.phone.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listContracts.clear();
        listContracts.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listContracts.clear();
        listContracts.addAll(tempItems);
      });
    }
  }

  searchTextField() {
    var validateSearch = false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
      child: TextField(
        onChanged: (String value) {
          filterSearchResults(value);
        },
        controller: textFieldSearchController,
        
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelStyle: const TextStyle(
            color: Colors.blueGrey,
          ),
          labelText: 'Поиск',
          errorText: validateSearch ? 'Вы не указали строку поиска!' : null,
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  var value = textFieldSearchController.text;
                  filterSearchResults(value);
                },
                icon: const Icon(Icons.search, color: Colors.blue),
              ),
              IconButton(
                onPressed: () async {
                  textFieldSearchController.text = '';
                  var value = textFieldSearchController.text;
                  filterSearchResults(value);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  listViewItems() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 0, 9, 14),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: listContracts.length,
          itemBuilder: (context, index) {
            var contractItem = listContracts[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        widget.orderCustomer.uidContract = contractItem.uid;
                        widget.orderCustomer.nameContract = contractItem.name;
                      });
                      Navigator.pop(context);
                    },
                    title: Text(contractItem.name),
                    subtitle: Column(
                      children: [
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Text(contractItem.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.home, color: Colors.blue, size: 20),
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
                                      const Icon(Icons.price_change, color: Colors.green, size: 20),
                                      const SizedBox(width: 5),
                                      Text(doubleToString(contractItem.balance)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.price_change, color: Colors.red, size: 20),
                                      const SizedBox(width: 5),
                                      Text(doubleToString(contractItem.balanceForPayment)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, color: Colors.blue,size: 20),
                                      const SizedBox(width: 5),
                                      Text(contractItem.schedulePayment.toString()),
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
                )
            );
          },
        ),
      ),
    );
  }
}
