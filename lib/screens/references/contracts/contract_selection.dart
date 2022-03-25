import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/models/ref_contract.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/screens/references/contracts/contract_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenContractSelection extends StatefulWidget {
  final OrderCustomer? orderCustomer;
  final ReturnOrderCustomer? returnOrderCustomer;
  final IncomingCashOrder? incomingCashOrder;

  const ScreenContractSelection(
      {Key? key, this.orderCustomer, this.returnOrderCustomer, this.incomingCashOrder})
      : super(key: key);

  @override
  _ScreenContractSelectionState createState() =>
      _ScreenContractSelectionState();
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
          var newContractItem = Contract();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ScreenContractItem(contractItem: newContractItem),
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

    if (widget.orderCustomer != null) {
      listContracts = await dbReadContractsOfPartner(
          widget.orderCustomer?.uidPartner ?? '');
      tempItems.addAll(listContracts);
    }

    if (widget.returnOrderCustomer != null) {
      listContracts = await dbReadContractsOfPartner(
          widget.returnOrderCustomer?.uidPartner ?? '');
      tempItems.addAll(listContracts);
    }

    if (widget.incomingCashOrder != null) {
      listContracts = await dbReadContractsOfPartner(
          widget.incomingCashOrder?.uidPartner ?? '');
      tempItems.addAll(listContracts);
    }

    setState(() {});
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
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
                        if (widget.orderCustomer != null) {
                          widget.orderCustomer?.uidContract = contractItem.uid;
                          widget.orderCustomer?.nameContract =
                              contractItem.name;

                          if (contractItem.schedulePayment != 0) {
                            DateTime tempDate = DateTime.now().add(
                                Duration(days: contractItem.schedulePayment));
                            widget.orderCustomer?.datePaying = tempDate;
                          }
                        }

                        if (widget.returnOrderCustomer != null) {
                          widget.returnOrderCustomer?.uidContract =
                              contractItem.uid;
                          widget.returnOrderCustomer?.nameContract =
                              contractItem.name;
                        }
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
                                          child: Text(contractItem.address)),
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
                                      Text(
                                          doubleToString(contractItem.balance)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.price_change,
                                          color: Colors.red, size: 20),
                                      const SizedBox(width: 5),
                                      Text(doubleToString(
                                          contractItem.balanceForPayment)),
                                    ],
                                  ),
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
                ));
          },
        ),
      ),
    );
  }
}
