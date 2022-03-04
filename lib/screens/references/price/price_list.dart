import 'package:flutter/material.dart';
import 'package:wp_sales/models/price.dart';
import 'package:wp_sales/screens/references/price/price_item.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenPriceList extends StatefulWidget {
  const ScreenPriceList({Key? key}) : super(key: key);

  @override
  _ScreenPriceListState createState() => _ScreenPriceListState();
}

class _ScreenPriceListState extends State<ScreenPriceList> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Price> tempItems = [];
  List<Price> listPrices = [];

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
        title: const Text('Тип цены'),
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var newItem = Price();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenPriceItem(priceItem: newItem),
            ),
          );
        },
        tooltip: 'Добавить тип цены',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() {
    // Очистка списка заказов покупателя
    listPrices.clear();
    tempItems.clear();

    // Получение и запись списка заказов покупателей
    for (var message in listDataOrganizations) {
      Price newItem = Price.fromJson(message);
      listPrices.add(newItem);
      tempItems.add(newItem); // Как шаблон
    }
  }

  void filterSearchResults(String query) {

    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listPrices.clear();
        listPrices.addAll(tempItems);
      });
      return;
    }

    List<Price> dummySearchList = <Price>[];
    dummySearchList.addAll(listPrices);

    if (query.isNotEmpty) {

      List<Price> dummyListData = <Price>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        // /// Поиск по адресу
        // if (item.address.toLowerCase().contains(query.toLowerCase())) {
        //   dummyListData.add(item);
        // }
        // /// Поиск по номеру телефона
        // if (item.phone.toLowerCase().contains(query.toLowerCase())) {
        //   dummyListData.add(item);
        // }
      }
      setState(() {
        listPrices.clear();
        listPrices.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listPrices.clear();
        listPrices.addAll(tempItems);
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
          itemCount: listPrices.length,
          itemBuilder: (context, index) {
            var priceItem = listPrices[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Card(
                elevation: 2,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenPriceItem(priceItem: priceItem),
                        ),
                      );
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
