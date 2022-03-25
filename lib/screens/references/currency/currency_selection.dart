import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_ref_currency.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/models/ref_currency.dart';
import 'package:wp_sales/screens/references/currency/currency_item.dart';

class ScreenCurrencySelection extends StatefulWidget {
  final OrderCustomer? orderCustomer;
  final ReturnOrderCustomer? returnOrderCustomer;
  final IncomingCashOrder? incomingCashOrder;

  const ScreenCurrencySelection(
      {Key? key,
      this.orderCustomer,
      this.returnOrderCustomer,
      this.incomingCashOrder})
      : super(key: key);

  @override
  _ScreenCurrencySelectionState createState() =>
      _ScreenCurrencySelectionState();
}

class _ScreenCurrencySelectionState extends State<ScreenCurrencySelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Currency> tempItems = [];
  List<Currency> listCurrency = [];

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
        title: const Text('Валюты'),
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
          var newItem = Currency();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenCurrencyItem(currencyItem: newItem),
            ),
          );
        },
        tooltip: 'Добавить валюту',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    // Очистка списка заказов покупателя
    listCurrency.clear();
    tempItems.clear();

    listCurrency = await dbReadAllCurrency();
    tempItems.addAll(listCurrency);

    setState(() {});

    // // Получение и запись списка
    // for (var message in listDataOrganizations) {
    //   Currency newPrice = Currency.fromJson(message);
    //   listPrice.add(newPrice);
    //   tempItems.add(newPrice); // Как шаблон
    // }
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listCurrency.clear();
        listCurrency.addAll(tempItems);
      });
      return;
    }

    List<Currency> dummySearchList = <Currency>[];
    dummySearchList.addAll(listCurrency);

    if (query.isNotEmpty) {
      List<Currency> dummyListData = <Currency>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listCurrency.clear();
        listCurrency.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listCurrency.clear();
        listCurrency.addAll(tempItems);
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
          itemCount: listCurrency.length,
          itemBuilder: (context, index) {
            var currencyItem = listCurrency[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        if (widget.orderCustomer != null) {
                          widget.orderCustomer?.uidCurrency = currencyItem.uid;
                          widget.orderCustomer?.nameCurrency = currencyItem.name;
                        }
                        if (widget.returnOrderCustomer != null) {
                          widget.returnOrderCustomer?.uidCurrency = currencyItem.uid;
                          widget.returnOrderCustomer?.nameCurrency = currencyItem.name;
                        }
                        if (widget.incomingCashOrder != null) {
                          widget.incomingCashOrder?.uidCurrency = currencyItem.uid;
                          widget.incomingCashOrder?.nameCurrency = currencyItem.name;
                        }
                      });
                      Navigator.pop(context);
                    },
                    title: Text(currencyItem.name),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
