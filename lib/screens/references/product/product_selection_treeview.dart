import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/price.dart';
import 'package:wp_sales/models/product.dart';
import 'package:wp_sales/models/warehouse.dart';
import 'package:wp_sales/system/system.dart';

class ScreenProductSelectionTreeView extends StatefulWidget {
  List<ItemOrderCustomer> listItemDoc = [];
  Price price = Price();
  Warehouse warehouse = Warehouse();

  ScreenProductSelectionTreeView(
      {Key? key,
      required this.listItemDoc,
      required this.price,
      required this.warehouse})
      : super(key: key);

  @override
  _ScreenProductSelectionTreeViewState createState() =>
      _ScreenProductSelectionTreeViewState();
}

class _ScreenProductSelectionTreeViewState
    extends State<ScreenProductSelectionTreeView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchCatalogController =
      TextEditingController();
  TextEditingController textFieldSearchBoughtController =
      TextEditingController();
  TextEditingController textFieldSearchRecommendController =
      TextEditingController();

  List<Product> tempItems = [];
  List<Product> listProducts = [];

  Product parentProduct = Product();
  Product parentParentProduct = Product();

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
          title: const Text('Товары (иерархия)'),
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
              children: const [],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: const [],
            ),
          ],
        ),
      ),
    );
  }

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(textMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void renewItem() async {
    final SharedPreferences prefs = await _prefs;
    //bool useTestData = prefs.getBool('settings_useTestData')!;

    bool useTestData = true;

    showMessage('Тестовые данные загружены!');

    // Очистка списка заказов покупателя
    listProducts.clear();
    tempItems.clear();

    // Первым в список добавим каталог товаров, если он есть
    // if (parentProduct.uid != '') {
    //   listProducts.add(parentProduct);
    // }

    // Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataProduct) {
        Product newItem = Product.fromJson(message);
        if (newItem.uid != parentProduct.uid && parentProduct.uid != '') {
          continue;
        }
        listProducts.add(newItem);
      }
      showMessage('Тестовые данные загружены!');
    } else {
      listProducts = await DatabaseHelper.instance.readAllProducts();
      showMessage('Реальные данные загружены!');
    }

    // Временная проверка на удаление товаров, которые не принадлежат каталогу товаров

    // Если выбран каталог
    if (parentProduct.uid != '') {

      var tempLength = listProducts.length;
      while (tempLength > 0) {
        if (listProducts[tempLength].uidParent != parentProduct.uid) {
          listProducts.remove(listProducts[tempLength]);
        }
        tempLength--;
      }
    }

    tempItems.addAll(listProducts);

    setState(() {});
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 0, 9, 14),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listProducts.length,
        itemBuilder: (context, index) {
          double price = 123.56;
          double countOnWarehouses = 561.0;

          var productItem = listProducts[index];
          return Card(
            elevation: 2,
            child: (productItem.isGroup == 1)
                ? DirectoryItem(
                    parentProduct: parentProduct,
                    product: productItem,
                    tap: () {
                      if (productItem.uid == parentProduct.uid) {
                        parentProduct = parentParentProduct;
                        renewItem();
                      } else {
                        parentParentProduct = parentProduct;
                        parentProduct = productItem;
                        renewItem();
                      }
                      setState(() {});
                    },
                    popTap: () {},
                  )
                : ProductItem(
                    product: productItem,
                    tap: () {},
                    popTap: () {},
                  ),
          );
        },
      ),
    );
  }
}

class DirectoryItem extends StatelessWidget {
  final Product parentProduct;
  final Product product;
  final Function tap;
  final Function? popTap;

  const DirectoryItem({
    Key? key,
    required this.parentProduct,
    required this.product,
    required this.tap,
    this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => tap(),
      //onLongPress: popTap == null ? null : popTap,
      contentPadding: const EdgeInsets.all(0),
      leading: const SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: Icon(
            Icons.folder,
            color: Colors.blue,
          ),
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(
          fontSize: 14,
        ),
        maxLines: 2,
      ),
      trailing: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: product.uid != parentProduct.uid
            ? const Icon(Icons.navigate_next)
            : const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;
  final Function tap;
  final Function? popTap;

  const ProductItem({
    Key? key,
    required this.product,
    required this.tap,
    this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => tap(),
      //onLongPress: popTap == null ? null : popTap,
      contentPadding: const EdgeInsets.all(0),
      leading: const SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: Icon(
            Icons.file_copy,
            color: Colors.grey,
          ),
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(
          fontSize: 14,
        ),
        maxLines: 2,
      ),
      subtitle: Column(
        children: [
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      doubleToString(0),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'грн',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(doubleThreeToString(0) + ' ' + product.nameUnit),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
      trailing: const Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}
