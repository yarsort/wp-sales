import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/ref_cashbox.dart';
import 'package:wp_sales/screens/references/cashbox/cashbox_item.dart';

class ScreenCashboxSelection extends StatefulWidget {
  final OrderCustomer? orderCustomer;
  final IncomingCashOrder? incomingCashOrder;

  const ScreenCashboxSelection({Key? key, this.orderCustomer, this.incomingCashOrder})
      : super(key: key);

  @override
  _ScreenCashboxSelectionState createState() => _ScreenCashboxSelectionState();
}

class _ScreenCashboxSelectionState extends State<ScreenCashboxSelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Cashbox> tempItems = [];
  List<Cashbox> listCashboxes = [];

  @override
  void initState() {
    super.initState();
    renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Кассы'),
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
          var newItem = Cashbox();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenCashboxItem(cashboxItem: newItem),
            ),
          );
        },
        tooltip: 'Добавить кассу',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    // Очистка списка заказов покупателя
    listCashboxes.clear();
    tempItems.clear();

    // Временные данные
    List<Cashbox> tListCashboxes = [];
    String tUidOrganization = '';

    // Получение данных: Заказ покупателя
    if (widget.orderCustomer != null) {
      tUidOrganization = widget.orderCustomer?.uidOrganization??'';
      tListCashboxes = await dbReadCashboxByUIDOrganization(tUidOrganization);
    }

    // Получение данных: Оплата товаров
    if (widget.incomingCashOrder != null) {
      tUidOrganization = widget.incomingCashOrder?.uidOrganization??'';
      tListCashboxes = await dbReadCashboxByUIDOrganization(tUidOrganization);
    }

    // Фильтрация по организации из документа
    for (var itemCashbox in tListCashboxes) {
      if (itemCashbox.uidOrganization != tUidOrganization) {
        continue;
      }
      listCashboxes.add(itemCashbox);
      tempItems.add(itemCashbox);
    }

    setState(() {});
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listCashboxes.clear();
        listCashboxes.addAll(tempItems);
      });
      return;
    }

    List<Cashbox> dummySearchList = <Cashbox>[];
    dummySearchList.addAll(listCashboxes);

    if (query.isNotEmpty) {
      List<Cashbox> dummyListData = <Cashbox>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listCashboxes.clear();
        listCashboxes.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listCashboxes.clear();
        listCashboxes.addAll(tempItems);
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
          itemCount: listCashboxes.length,
          itemBuilder: (context, index) {
            var cashboxItem = listCashboxes[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        if (widget.orderCustomer != null) {
                          widget.orderCustomer?.uidCashbox = cashboxItem.uid;
                          widget.orderCustomer?.nameCashbox = cashboxItem.name;
                        }
                        if (widget.incomingCashOrder != null) {
                          widget.incomingCashOrder?.uidCashbox = cashboxItem.uid;
                          widget.incomingCashOrder?.nameCashbox = cashboxItem.name;
                        }
                      });
                      Navigator.pop(context);
                    },
                    title: Text(cashboxItem.name),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
