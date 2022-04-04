import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/import/import_screens.dart';
import 'package:wp_sales/system/widgets.dart';

// Цены товаров
List<AccumProductPrice> listProductPrice = [];

// Остатки товаров
List<AccumProductRest> listProductRest = [];

class ScreenProductList extends StatefulWidget {
  const ScreenProductList({
    Key? key,
  }) : super(key: key);

  @override
  _ScreenProductListState createState() => _ScreenProductListState();
}

class _ScreenProductListState extends State<ScreenProductList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool showProductHierarchy = true;

  bool visibleParameters = false;
  String uidWarehouse = '';
  String uidPrice = '';

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchCatalogController =
      TextEditingController();
  TextEditingController textFieldSearchBoughtController =
      TextEditingController();
  TextEditingController textFieldSearchRecommendController =
      TextEditingController();

  TextEditingController textFieldPriceController = TextEditingController();
  TextEditingController textFieldWarehouseController = TextEditingController();

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

  // Весь список товаров для работы поиска
  List<Product> dummySearchList = [];

  // Текущий выбранный каталог иерархии товаров
  Product parentProduct = Product();

  @override
  void initState() {
    super.initState();
    fillSetting();
    renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Товары'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Каталог'),
              //Tab(text: 'Купленные'),
              Tab(text: 'Акции'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                listViewCatalogTree(),
              ],
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

  fillSetting() async {
    final SharedPreferences prefs = await _prefs;

    uidPrice = prefs.getString('settings_uidPrice') ?? '';
    Price price = await dbReadPriceUID(uidPrice);
    textFieldPriceController.text = price.name;

    uidWarehouse = prefs.getString('settings_uidWarehouse') ?? '';
    Warehouse warehouse = await dbReadWarehouseUID(uidWarehouse);
    textFieldWarehouseController.text = warehouse.name;
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
    dummySearchList.clear();

    ///Первым в список добавим каталог товаров, если он есть
    if (showProductHierarchy) {
      if (parentProduct.uid != '00000000-0000-0000-0000-000000000000') {
        listProducts.add(parentProduct);
      }
    }

    /// Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataProduct) {
        Product newItem = Product.fromJson(message);

        /// Добавим товар
        listDataProducts.add(newItem);
      }
    } else {
      /// Загрузка данных из БД
      if (showProductHierarchy) {
        // Покажем товары текущего родителя
        listDataProducts = await dbReadProductsByParent(parentProduct.uid);
      } else {
        // Покажем все товары
        listDataProducts = await dbReadAllProducts();
      }

      debugPrint(
          'Реальные данные загружены! ' + listDataProducts.length.toString());
    }

    /// Заполним для поиска товаров
    for (var itemList in listDataProducts) {
      if (itemList.isGroup == 1) {
        continue;
      }
      dummySearchList.add(itemList);
    }

    /// Сортировка списка: сначала каталоги, потом элементы
    listDataProducts.sort((a, b) => a.name.compareTo(b.name));
    listDataProducts.sort((b, a) => a.isGroup.compareTo(b.isGroup));

    /// Заполним список товаров для отображения на форме
    for (var newItem in listDataProducts) {
      // Пропустим сам каталог, потому что он добавлен первым до заполнения
      if (newItem.uid == parentProduct.uid) {
        continue;
      }

      // Если надо показывать иерархию элементов
      if (showProductHierarchy) {
        // Если у товара родитель не является текущим выбранным каталогом
        if (newItem.uidParent != parentProduct.uid) {
          continue;
        }
      } else {
        // Без иерархии показывать каталоги нельзя!
        if (newItem.isGroup == 1) {
          continue;
        }
      }

      // Добавим товар
      listProducts.add(newItem);

      // Добавим товар для получения остатков и цен
      if (newItem.isGroup == 0) {
        listProductsUID.add(newItem.uid); // Добавим для поиска цен и остатков
      }
    }

    /// Поместим найденные товары в группу для возврата из поиска
    tempItems.addAll(listProducts);

    /// Получим остатки и цены по найденным товарам
    await readPriceAndRests();

    setState(() {});
  }

  readPriceAndRests() async {

    listProductPrice.clear();
    listProductRest.clear();

    //Нет данных - нет вывода на форму
    if (listProductsUID.isEmpty) {
      return;
    }

    // Цены товаров
    listProductPrice =
        await dbReadAccumProductPriceByUIDProducts(listProductsUID);

    // debugPrint('Цены товаров: '+listProductPrice.length.toString());

    // Остатки товаров
    listProductRest =
        await dbReadAccumProductRestByUIDProducts(listProductsUID);

    // debugPrint('Остатки товаров: '+listProductRest.length.toString());
    // debugPrint(listProductRest.join(', '));

  }

  void filterSearchCatalogResults(String query) async {
    /// Уберем пробелы
    query = query.trim();

    /// Если нечего искать, то заполним
    if (query.isNotEmpty) {
      listProducts.clear();
    } else {
      listProducts.clear();
      listProducts.addAll(dummySearchList);
      return;
    }

    List<Product> dummyListData = [];

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

    ///  Заполним список найденными или всеми товарами
    if (dummyListData.isNotEmpty) {
      listProducts.clear();
      listProducts.addAll(dummyListData);
    } else {
      listProducts.clear();
      listProducts.addAll(dummySearchList);
    }

    /// Обновим данные формы
    setState(() {});
  }

  listParameters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            onChanged: (String value) {
              filterSearchCatalogResults(value);
            },
            controller: textFieldSearchCatalogController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Поиск',
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
                      renewItem();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        showProductHierarchy = !showProductHierarchy;
                        parentProduct = Product();
                        treeParentItems.clear();
                        textFieldSearchCatalogController.text = '';
                      });
                      renewItem();
                    },
                    icon: const Icon(Icons.source, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        visibleParameters = !visibleParameters;
                      });
                    },
                    icon: visibleParameters
                        ? const Icon(Icons.filter_list, color: Colors.red)
                        : const Icon(Icons.filter_list, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: visibleParameters,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Warehouse
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: TextField(
                  controller: textFieldWarehouseController,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    border: const OutlineInputBorder(),
                    labelStyle: const TextStyle(
                      color: Colors.blueGrey,
                    ),
                    labelText: 'Склад',
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            var orderCustomer = OrderCustomer();
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ScreenWarehouseSelection(
                                            orderCustomer: orderCustomer)));

                            setState(() {
                              textFieldWarehouseController.text =
                                  orderCustomer.nameWarehouse;
                              uidWarehouse = orderCustomer.uidWarehouse;

                              // Очистим иерархию
                              parentProduct = Product();
                              treeParentItems.clear();

                              if (textFieldPriceController.text != '') {
                                visibleParameters = false;
                              }

                              renewItem();
                            });
                          },
                          icon: const Icon(Icons.people, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldWarehouseController.text = '';
                              uidWarehouse = '';

                              // Очистим иерархию
                              parentProduct = Product();
                              treeParentItems.clear();

                              if (textFieldPriceController.text != '') {
                                visibleParameters = false;
                              }

                              renewItem();
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Price
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                child: TextField(
                  controller: textFieldPriceController,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    border: const OutlineInputBorder(),
                    labelStyle: const TextStyle(
                      color: Colors.blueGrey,
                    ),
                    labelText: 'Тип цены',
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            var orderCustomer = OrderCustomer();
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScreenPriceSelection(
                                        orderCustomer: orderCustomer)));
                            setState(() {
                              textFieldPriceController.text =
                                  orderCustomer.namePrice;
                              uidPrice = orderCustomer.uidPrice;

                              // Очистим иерархию
                              parentProduct = Product();
                              treeParentItems.clear();

                              if (textFieldWarehouseController.text != '') {
                                visibleParameters = false;
                              }

                              renewItem();
                            });
                          },
                          icon: const Icon(Icons.request_quote,
                              color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              textFieldPriceController.text = '';
                              uidPrice = '';

                              // Очистим иерархию
                              parentProduct = Product();
                              treeParentItems.clear();

                              if (textFieldWarehouseController.text != '') {
                                visibleParameters = false;
                              }
                              renewItem();
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(),
            ],
          ),
        ),
      ],
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
                      uidPriceProductItem: uidPrice,
                      uidWarehouseProductItem: uidWarehouse,
                      product: productItem,
                      tap: () {},
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
      tileColor: product.uid != parentProduct.uid
          ? null
          : const Color.fromRGBO(227, 242, 253, 1.0),
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
  final String uidPriceProductItem;
  final String uidWarehouseProductItem;
  final Function tap;
  final Function? popTap;

  const ProductItem({
    Key? key,
    required this.product,
    required this.uidPriceProductItem,
    required this.uidWarehouseProductItem,
    required this.tap,
    this.popTap,
  }) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  double countOnWarehouse = 0.0;
  double price = 0.0;
  String uidPrice = '';
  String uidWarehouse = '';

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
          color: Color.fromRGBO(144, 202, 249, 1.0),
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
                flex: 2,
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
                flex: 2,
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
    var indexItemPrice = listProductPrice.indexWhere((element) =>
        element.uidProduct == widget.product.uid &&
        element.uidPrice == widget.uidPriceProductItem);
    if (indexItemPrice >= 0) {
      var itemList = listProductPrice[indexItemPrice];
      price = itemList.price;
    } else {
      price = 0.0;
    }

    var indexItemRest = listProductRest.indexWhere((element) =>
    element.uidProduct == widget.product.uid &&
        element.uidWarehouse == widget.uidWarehouseProductItem);
    if (indexItemRest >= 0) {
      var itemList = listProductRest[indexItemRest];
      countOnWarehouse = itemList.count;
    } else {
      countOnWarehouse = 0.000;
    }

    //debugPrint('Товар: '+widget.product.name+'. Цена: '+price.toString()+'. Остаток: '+countOnWarehouse.toString());

    if (mounted) {
      setState(() {
        // Your state change code goes here
      });
    }
  }
}
