import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_accum_product_prices.dart';
import 'package:wp_sales/db/db_accum_product_rests.dart';
import 'package:wp_sales/db/db_ref_product.dart';
import 'package:wp_sales/models/accum_product_prices.dart';
import 'package:wp_sales/models/accum_product_rests.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/ref_product.dart';
import 'package:wp_sales/screens/references/product/add_item.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenProductSelectionTreeView extends StatefulWidget {
  List<ItemOrderCustomer> listItemDoc = [];
  OrderCustomer orderCustomer = OrderCustomer();

  ScreenProductSelectionTreeView(
      {Key? key, required this.listItemDoc, required this.orderCustomer})
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

  // Список товаров для возвращения из поиска
  List<Product> tempItems = [];

  // Список товаров для вывода на экран
  List<Product> listProducts = [];

  // Список тестовых товаров
  List<Product> listDataProducts = [];

  // Список каталогов для построения иерархии
  List<Product> treeParentItems = [];

  // Список идентификаторов товаров для поиска цен и остатков
  List<String> listProductsUID = [];

  // Цены товаров
  List<AccumProductPrice> listProductPrice = [];

  // Остатки товаров
  List<AccumProductRest> listProductRest = [];

  // Текущий выбранный каталог иерархии товаров
  Product parentProduct = Product();

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
          title: const Text('Подбор товаров'),
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
                listViewCatalogTree(),
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
    bool useTestData = prefs.getBool('settings_useTestData')!;

    // Главный каталог всегда будет стаким идентификатором
    if (parentProduct.uid == '') {
      parentProduct.uid = '00000000-0000-0000-0000-000000000000';
    }

    // Очистка списка заказов покупателя
    listProducts.clear();
    tempItems.clear();
    listProductsUID.clear();

    ///Первым в список добавим каталог товаров, если он есть
    if (parentProduct.uid != '00000000-0000-0000-0000-000000000000') {
      listProducts.add(parentProduct);
    }

    /// Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataProduct) {
        Product newItem = Product.fromJson(message);

        /// Добавим товар
        listDataProducts.add(newItem);
      }
      //showMessage('Тестовые данные загружены!');
    } else {
      /// Загрузка данных из БД
      listDataProducts =
          await dbReadProductsByParent(parentProduct.uid);
      debugPrint(
          'Реальные данные загружены! ' + listDataProducts.length.toString());
    }

    for (var newItem in listDataProducts) {
      // Пропустим сам каталог, потому что он добавлен первым до заполнения
      if (newItem.uid == parentProduct.uid) {
        continue;
      }
      // Если у товара родитель не является текущим выбранным каталогом
      if (newItem.uidParent != parentProduct.uid) {
        continue;
      }
      // Добавим товар
      listProducts.add(newItem);
      listProductsUID.add(newItem.uid); // Добавим для поиска цен и остатков
    }

    // /// Временная проверка на удаление товаров, которые не принадлежат каталогу товаров
    // /// Возможно они попали по ошибке назначения UID родителя
    // if (parentProduct.uid != '') {
    //   var tempLength = listProducts.length - 1;
    //   while (tempLength > 0) {
    //     if (listProducts[tempLength].uidParent != parentProduct.uid) {
    //       listProducts.remove(listProducts[tempLength]);
    //     }
    //     tempLength--;
    //   }
    // }

    /// Сортировка списка: сначала каталоги, потом элементы
    listProducts.sort((b, a) => a.isGroup.compareTo(b.isGroup));

    /// Поместим найденные товары в группу для возврата из поиска
    tempItems.addAll(listProducts);

    setState(() {});
  }

  void filterSearchCatalogResults(String query) async {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length <= 2) {
      setState(() {
        listProducts.clear();
        listProducts.addAll(tempItems);
      });
      return;
    }

    List<Product> dummySearchList =
        await dbReadProductsForSearch(query);

    if (query.isNotEmpty) {
      List<Product> dummyListData = <Product>[];

      for (var item in dummySearchList) {
        /// Группы в поиске не отображать
        if (item.isGroup == 1) {
          return;
        }

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
                  parentProduct = Product();
                  treeParentItems.clear();

                  textFieldSearchCatalogController.text = '';
                  renewItem();
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  listViewCatalogTree() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 11, 14),
      child: ColumnBuilder(
          itemCount: listProducts.length,
          itemBuilder: (context, index) {
            var productItem = listProducts[index];

            return Card(
              elevation: 2,
              child: (productItem.isGroup == 1)
                  ? DirectoryItem(
                      parentProduct: parentProduct,
                      product: productItem,
                      tap: () {
                        if (productItem.uid == parentProduct.uid) {
                          if (treeParentItems.isNotEmpty) {
                            // Назначим нового родителя выхода из узла дерева
                            parentProduct =
                                treeParentItems[treeParentItems.length - 1];

                            // Удалим старого родителя для будущего узла
                            treeParentItems.remove(
                                treeParentItems[treeParentItems.length - 1]);
                          } else {
                            // Отправим дерево на его самый главный узел
                            parentProduct = Product();
                          }
                          renewItem();
                        } else {
                          treeParentItems.add(parentProduct);
                          parentProduct = productItem;
                          renewItem();
                        }
                      },
                      popTap: () {},
                    )
                  : ProductItem(
                      uidPrice: widget.orderCustomer.uidPrice,
                      uidWarehouse: widget.orderCustomer.uidWarehouse,
                      product: productItem,
                      tap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScreenAddItem(
                                listItemDoc: widget.listItemDoc,
                                orderCustomer: widget.orderCustomer,
                                product: productItem),
                          ),
                        );
                      },
                      popTap: () {},
                    ),
            );
          }),
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
      minLeadingWidth: 20,
      leading: const Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: Icon(
          Icons.folder,
          color: Colors.blue,
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(
          fontSize: 16,
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

class ProductItem extends StatefulWidget {
  final Product product;
  final String uidPrice;
  final String uidWarehouse;
  final Function tap;
  final Function? popTap;

  const ProductItem({
    Key? key,
    required this.product,
    required this.uidPrice,
    required this.uidWarehouse,
    required this.tap,
    this.popTap,
  }) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  double countOnWarehouse = 0.0;
  double price = 0.0;

  @override
  void initState() {
    super.initState();
    renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => widget.tap(),
      //onLongPress: popTap == null ? null : popTap,
      contentPadding: const EdgeInsets.all(0),
      leading: const Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: Icon(
          Icons.file_copy,
          color: Colors.grey,
        ),
      ),
      title: Text(
        widget.product.name,
        style: const TextStyle(
          fontSize: 16,
        ),
        maxLines: 2,
      ),
      subtitle: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      doubleToString(price) + ' грн',
                      style: price > 0
                          ? const TextStyle(fontSize: 15, color: Colors.blue)
                          : const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      doubleThreeToString(countOnWarehouse) +
                          ' ' +
                          widget.product.nameUnit,
                      style: countOnWarehouse > 0
                          ? const TextStyle(fontSize: 15, color: Colors.blue)
                          : const TextStyle(fontSize: 15),
                    ),
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

  renewItem() async {
    price = await dbReadProductPrice(
        uidPrice: widget.uidPrice, uidProduct: widget.product.uid);

    countOnWarehouse = await dbReadProductRest(
        uidWarehouse: widget.uidWarehouse, uidProduct: widget.product.uid);

    setState(() {});
  }
}
