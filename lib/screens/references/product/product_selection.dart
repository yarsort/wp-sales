import 'package:flutter/material.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/product.dart';
import 'package:wp_sales/screens/references/product/product_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenProductSelection extends StatefulWidget {

  final OrderCustomer orderCustomer;

  const ScreenProductSelection({Key? key, required this.orderCustomer}) : super(key: key);

  @override
  _ScreenProductSelectionState createState() => _ScreenProductSelectionState();
}

class _ScreenProductSelectionState extends State<ScreenProductSelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Product> tempItems = [];
  List<Product> listProduct = [];

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
        title: const Text('Подбор товаров'),
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
          var newItem = Product();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenProductItem(productItem: newItem),
            ),
          );
        },
        tooltip: 'Добавить товар',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() {
    // Очистка списка заказов покупателя
    listProduct.clear();
    tempItems.clear();

    // Получение и запись списка
    for (var message in listDataOrganizations) {
      Product newProduct = Product.fromJson(message);
      listProduct.add(newProduct);
      tempItems.add(newProduct); // Как шаблон
    }
  }

  void filterSearchResults(String query) {

    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listProduct.clear();
        listProduct.addAll(tempItems);
      });
      return;
    }

    List<Product> dummySearchList = <Product>[];
    dummySearchList.addAll(listProduct);

    if (query.isNotEmpty) {

      List<Product> dummyListData = <Product>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listProduct.clear();
        listProduct.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listProduct.clear();
        listProduct.addAll(tempItems);
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
          itemCount: listProduct.length,
          itemBuilder: (context, index) {
            var productItem = listProduct[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    onTap: () {
                      // setState(() {
                      //   widget.orderCustomer.uid = productItem.uid;
                      //   widget.orderCustomer.nameProduct = productItem.name;
                      // });
                      //Navigator.pop(context);
                    },
                    title: Text(productItem.name),
                  ),
                )
            );
          },
        ),
      ),
    );
  }
}
