import 'package:flutter/material.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/price.dart';
import 'package:wp_sales/models/product.dart';
import 'package:wp_sales/models/warehouse.dart';

class ScreenProductSelection extends StatefulWidget {

  final List? listItemDoc;
  final Price? price;
  final Warehouse? warehouse;

  const ScreenProductSelection({Key? key, this.listItemDoc, this.price, this.warehouse}) : super(key: key);

  @override
  _ScreenProductSelectionState createState() => _ScreenProductSelectionState();
}

class _ScreenProductSelectionState extends State<ScreenProductSelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchCatalogController = TextEditingController();
  TextEditingController textFieldSearchBoughtController = TextEditingController();
  TextEditingController textFieldSearchRecommendController = TextEditingController();

  List<Product> tempItems = [];
  List<Product> listProducts = [];

  @override
  void initState() {
    super.initState();
    renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Заказы покупателей'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Каталог'),
              Tab(text: 'Купленные'),
              Tab(text: 'Рекомендации'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                searchTextFieldCatalog(),
                listViewCatalog(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: const [

              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: const [

              ],
            ),
          ],
        ),
      ),
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

  void filterSearchCatalogResults(String query) {

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

  searchTextFieldCatalog() {
    var validateSearch = false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
      child: TextField(
        onChanged: (String value) {
          filterSearchCatalogResults(value);
        },
        controller: textFieldSearchCatalogController,
        
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
                  var value = textFieldSearchCatalogController.text;
                  filterSearchCatalogResults(value);
                },
                icon: const Icon(Icons.search, color: Colors.blue),
              ),
              IconButton(
                onPressed: () async {
                  textFieldSearchCatalogController.text = '';
                  var value = textFieldSearchCatalogController.text;
                  filterSearchCatalogResults(value);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  listViewCatalog() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 0, 9, 14),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: listProducts.length,
          itemBuilder: (context, index) {
            var productItem = listProducts[index];
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
