import 'package:flutter/material.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/currency.dart';
import 'package:wp_sales/screens/references/currency/currency_item.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenCurrencyList extends StatefulWidget {
  const ScreenCurrencyList({Key? key}) : super(key: key);

  @override
  _ScreenCurrencyListState createState() => _ScreenCurrencyListState();
}

class _ScreenCurrencyListState extends State<ScreenCurrencyList> {
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
      drawer: const MainDrawer(),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newItem = Currency();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenCurrencyItem(currencyItem: newItem),
            ),
          );
          setState(() {
            renewItem();
          });
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

    listCurrency =
        await DatabaseHelper.instance.readAllCurrency();
    tempItems.addAll(listCurrency);

    setState(() {});

    // // Получение и запись списка заказов покупателей
    // for (var message in listDataCurrency) {
    //   Currency newItem = Currency.fromJson(message);
    //   listCurrency.add(newItem);
    //   tempItems.add(newItem); // Как шаблон
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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenCurrencyItem(currencyItem: currencyItem),
                        ),
                      );
                      setState(() {
                        renewItem();
                      });
                    },
                    title: Text(currencyItem.name),
                  ),
                ) 
              );            
          },
        ),
      ),
    );
  }
}
