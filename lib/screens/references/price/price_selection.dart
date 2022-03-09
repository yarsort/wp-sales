import 'package:flutter/material.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/price.dart';
import 'package:wp_sales/screens/references/price/price_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenPriceSelection extends StatefulWidget {

  final OrderCustomer orderCustomer;

  const ScreenPriceSelection({Key? key, required this.orderCustomer}) : super(key: key);

  @override
  _ScreenPriceSelectionState createState() => _ScreenPriceSelectionState();
}

class _ScreenPriceSelectionState extends State<ScreenPriceSelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Price> tempItems = [];
  List<Price> listPrice = [];

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
        title: const Text('Тип цены'),
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

  void renewItem() async {
    // Очистка списка заказов покупателя
    listPrice.clear();
    tempItems.clear();

    listPrice =
        await DatabaseHelper.instance.readAllPrices();
    tempItems.addAll(listPrice);

    setState(() {});

    // // Получение и запись списка заказов покупателей
    // for (var message in listDataPrice) {
    //   Price newItem = Price.fromJson(message);
    //   listPrices.add(newItem);
    //   tempItems.add(newItem); // Как шаблон
    // }
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

    List<Price> dummySearchList = <Price>[];
    dummySearchList.addAll(listPrice);

    if (query.isNotEmpty) {

      List<Price> dummyListData = <Price>[];

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
