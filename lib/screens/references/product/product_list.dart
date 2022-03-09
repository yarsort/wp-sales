import 'package:flutter/material.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/product.dart';
import 'package:wp_sales/screens/references/product/product_item.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenProductList extends StatefulWidget {
  const ScreenProductList({Key? key}) : super(key: key);

  @override
  _ScreenProductListState createState() => _ScreenProductListState();
}

class _ScreenProductListState extends State<ScreenProductList> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Product> tempItems = [];
  List<Product> listProducts = [];

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
        title: const Text('Товары'),
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
          var newItem = Product();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenProductItem(productItem: newItem),
            ),
          );
          setState(() {
            renewItem();
          });
        },
        tooltip: 'Добавить товар',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    // Очистка списка заказов покупателя
    listProducts.clear();
    tempItems.clear();

    listProducts =
    await DatabaseHelper.instance.readAllProducts();

    tempItems.addAll(listProducts);
  }

  void filterSearchResults(String query) {

    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listProducts.clear();
        listProducts.addAll(tempItems);
      });
      return;
    }

    List<Product> dummySearchList = <Product>[];
    dummySearchList.addAll(listProducts);

    if (query.isNotEmpty) {

      List<Product> dummyListData = <Product>[];

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
        listProducts.clear();
        listProducts.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listProducts.clear();
        listProducts.addAll(tempItems);
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
          itemCount: listProducts.length,
          itemBuilder: (context, index) {
            var productItem = listProducts[index];

            double countOnWarehouses = 0.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Card(
                elevation: 2,
                  child: ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenProductItem(productItem: productItem),
                        ),
                      );
                      setState(() {
                        renewItem();
                      });
                    },
                    title: Text(productItem.name),
                    subtitle: Column(
                      children: [
                        const Divider(),
                        Row(children: [
                          Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.code,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Text(productItem.vendorCode),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.document_scanner,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Text(productItem.barcode),
                                    ],
                                  )
                                ],
                              )),
                          Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.ad_units,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Text(productItem.nameUnit),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.account_balance,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Text(doubleThreeToString(countOnWarehouses)),
                                    ],
                                  )
                                ],
                              ))
                        ]),
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
