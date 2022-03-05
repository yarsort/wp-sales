import 'package:flutter/material.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/currency.dart';
import 'package:wp_sales/screens/references/currency/currency_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenCurrencySelection extends StatefulWidget {

  final OrderCustomer orderCustomer;

  const ScreenCurrencySelection({Key? key, required this.orderCustomer}) : super(key: key);

  @override
  _ScreenCurrencySelectionState createState() => _ScreenCurrencySelectionState();
}

class _ScreenCurrencySelectionState extends State<ScreenCurrencySelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Currency> tempItems = [];
  List<Currency> listPrice = [];

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

  void renewItem() {
    // Очистка списка заказов покупателя
    listPrice.clear();
    tempItems.clear();

    // Получение и запись списка
    for (var message in listDataOrganizations) {
      Currency newPrice = Currency.fromJson(message);
      listPrice.add(newPrice);
      tempItems.add(newPrice); // Как шаблон
    }
  }

  void filterSearchResults(String query) {

    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listPrice.clear();
        listPrice.addAll(tempItems);
      });
      return;
    }

    List<Currency> dummySearchList = <Currency>[];
    dummySearchList.addAll(listPrice);

    if (query.isNotEmpty) {

      List<Currency> dummyListData = <Currency>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listPrice.clear();
        listPrice.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listPrice.clear();
        listPrice.addAll(tempItems);
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
        textInputAction: TextInputAction.continueAction,
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
          itemCount: listPrice.length,
          itemBuilder: (context, index) {
            var priceItem = listPrice[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        widget.orderCustomer.uidPrice = priceItem.uid;
                        widget.orderCustomer.namePrice = priceItem.name;
                      });
                      Navigator.pop(context);
                    },
                    title: Text(priceItem.name),
                  ),
                )
            );
          },
        ),
      ),
    );
  }
}
