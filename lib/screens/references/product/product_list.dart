import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/import/import_screens.dart';
import 'package:wp_sales/system/widgets.dart';

// Цены товаров
List<AccumProductPrice> listProductPrice = [];

// Остатки товаров
List<AccumProductRest> listProductRest = [];

String pathPictures = '';

String uidPrice = '';

String uidWarehouse = '';

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

  bool showGridView = false;

  bool visibleParameters = true;

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchCatalogController =
      TextEditingController();
  TextEditingController textFieldSearchBoughtController =
      TextEditingController();
  TextEditingController textFieldSearchRecommendController =
      TextEditingController();

  TextEditingController textFieldPriceController = TextEditingController();
  TextEditingController textFieldWarehouseController = TextEditingController();

  // Список товаров для вывода на экран
  List<Product> listProducts = [];

  List<Product> listProductsForListView = [];

  // Список тестовых товаров
  List<Product> listDataProducts = [];

  // Список каталогов для построения иерархии
  List<Product> treeParentItems = [];

  // Список идентификаторов товаров для поиска цен и остатков
  List<String> listProductsUID = [];

  // Текущий выбранный каталог иерархии товаров
  Product parentProduct = Product();

  String? barcode;

  // Количество элементов в автозагрузке списка
  int _currentMax = 0;
  int countLoadItems = 20;

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
              Tab(text: 'Акции'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                showGridView ? gridViewCatalog() : listViewCatalog(),
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

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      barcode = barcodeScanRes;
    });

    Product productItem = await dbReadProductByBarcode(barcodeScanRes);
    if (productItem.id != 0) {
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ScreenAddItem(
      //         listItemDoc: widget.listItemDoc,
      //         orderCustomer: widget.orderCustomer,
      //         returnOrderCustomer: widget.returnOrderCustomer,
      //         listItemReturnDoc: widget.listItemReturnDoc,
      //         product: productItem),
      //   ),
      // );
    } else {
      if (barcodeScanRes == '-1') {
        return;
      }
      showMessage(
          'Товар с штрихкодом: ' + barcodeScanRes + ' не найден!', context);
    }
  }

  fillSetting() async {
    final SharedPreferences prefs = await _prefs;

    uidPrice = prefs.getString('settings_uidPrice') ?? '';
    Price price = await dbReadPriceUID(uidPrice);
    textFieldPriceController.text = price.name;

    uidWarehouse = prefs.getString('settings_uidWarehouse') ?? '';
    Warehouse warehouse = await dbReadWarehouseUID(uidWarehouse);
    textFieldWarehouseController.text = warehouse.name;

    pathPictures = prefs.getString('settings_pathPictures') ?? '';
  }

  renewItem() async {
    final SharedPreferences prefs = await _prefs;
    bool useTestData = prefs.getBool('settings_useTestData')!;

    _currentMax = 0;

    // Главный каталог всегда будет с таким идентификатором
    if (parentProduct.uid == '') {
      parentProduct.uid = '00000000-0000-0000-0000-000000000000';
    }

    /// Очистка данных
    setState(() {
      listProducts.clear();
      listProductsForListView.clear(); // Список для отображения на форме
      listProductsUID.clear();

      /// Получим остатки и цены по найденным товарам
      listProductPrice.clear();
      listProductRest.clear();
    });

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
        String searchString =
            textFieldSearchCatalogController.text.trim().toLowerCase();
        if (searchString.toLowerCase().length >= 3) {
          // Покажем все товары для поиска
          listDataProducts = await dbReadProductsForSearch(searchString);
        } else {
          // Покажем все товары
          listDataProducts = await dbReadAllProducts();
        }
      }

      //debugPrint(
      //    'Реальные данные загружены! ' + listDataProducts.length.toString());
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
        if (newItem.uidParent != '00000000-0000-0000-0000-000000000000') {
          if (newItem.uidParent != parentProduct.uid) {
            continue;
          }
        }
      } else {
        // Без иерархии показывать каталоги нельзя!
        if (newItem.isGroup == 1) {
          continue;
        }
      }

      // Вывод только каталогов
      if (newItem.isGroup == 0) {
        continue;
      }

      // Добавим товар
      listProducts.add(newItem);
    }

    /// Заполним список товаров для отображения на форме
    for (var newItem in listDataProducts) {
      // Выводщ только товаров
      if (newItem.isGroup == 1) {
        continue;
      }

      // Добавим товар
      listProducts.add(newItem);
    }

    await readAdditionalProductsToView();

    setState(() {});
  }

  readAdditionalProductsToView() async {
    /// Получим первые товары на экран
    for (int i = _currentMax; i < _currentMax + countLoadItems; i++) {
      if (i < listProducts.length) {
        listProductsForListView.add(listProducts[i]);
        debugPrint('Добавлен товар: ' + listProducts[i].name);
      }
    }

    _currentMax = _currentMax + countLoadItems;
    _currentMax++; // Для пункта "Показать больше"

    // Добавим пункт "Показать больше"
    if (listProducts.length > listProductsForListView.length) {
      listProductsForListView.add(Product()); // Добавим пустой товар
    }

    /// Получим список товаров для которых надо показать цены и остатки
    for (var itemList in listProductsForListView) {
      // Проверка на каталог. Если товар, то грузим.
      if (itemList.isGroup == 0) {
        listProductsUID.add(itemList.uid); // Добавим для поиска цен и остатков
        //debugPrint('Получение товара: ' + itemList.name);
      }
    }

    ///Нет данных - нет вывода на форму
    if (listProductsUID.isEmpty) {
      debugPrint('Нет товаров для отображения цен и остатков! Товаров: ' +
          listProductsForListView.length.toString());
    } else {
      debugPrint('Есть товары для отображения цен и остатков! Товаров: ' +
          listProductsForListView.length.toString());
    }

    await readPriceAndRests();

    setState(() {});
  }

  readPriceAndRests() async {
    if (listProductsUID.isEmpty) {
      debugPrint('Нет UIDs дл вывода остатков и цен...');
      return;
    }

    // /// Цены товаров
    // List<AccumProductPrice> listProductPriceTemp = await dbReadAccumProductPriceByUIDProducts(listProductsUID);
    // /// Остатки товаров
    // List<AccumProductRest> listProductRestTemp = await dbReadAccumProductRestByUIDProducts(listProductsUID);

    /// Цены товаров
    listProductPrice =
        await dbReadAccumProductPriceByUIDProducts(listProductsUID);

    /// Остатки товаров
    listProductRest =
        await dbReadAccumProductRestByUIDProducts(listProductsUID);

    debugPrint('Цены товаров: ' + listProductPrice.length.toString());
    debugPrint('Остатки товаров: ' + listProductRest.length.toString());

    setState(() {
      debugPrint('Обновлено...');
    });
  }

  listParameters() {
    var validateSearch = false;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            onSubmitted: (String value) async {
              // Выключим иерархический просмотр
              if (showProductHierarchy) {
                showProductHierarchy = false;
                parentProduct = Product();
                treeParentItems.clear();
                showMessage('Иерархия товаров выключена.', context);
              }

              await renewItem();

              if (textFieldSearchCatalogController.text.isNotEmpty) {
                showMessage(
                    'Найдено: ' + listProducts.length.toString() + ' товаров.',
                    context);
              }
            },
            controller: textFieldSearchCatalogController,
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
                      textFieldSearchCatalogController.text = '';
                      renewItem();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () async {
                      scanBarcodeNormal();
                    },
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) async {
                      if (value == 'showProductHierarchy') {
                        setState(() {
                          showProductHierarchy = !showProductHierarchy;
                          parentProduct = Product();
                          treeParentItems.clear();
                          textFieldSearchCatalogController.text = '';
                        });
                        renewItem();
                      }
                      if (value == 'scanProduct') {
                        scanBarcodeNormal();
                      }
                      if (value == 'showParameters') {
                        setState(() {
                          visibleParameters = !visibleParameters;
                        });
                      }
                      if (value == 'showListOrGrid') {
                        setState(() {
                          showGridView = !showGridView;
                        });
                      }
                    },
                    icon: const Icon(Icons.more_vert, color: Colors.blue),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'showProductHierarchy',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.source,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            showProductHierarchy
                                ? const Text('Выключить иерархию')
                                : const Text('Включить иерархию'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'showParameters',
                        child: Row(
                          children: const [
                            Icon(Icons.filter_list, color: Colors.blue),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Отбор'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'showListOrGrid',
                        child: Row(
                          children: [
                            Icon(
                              showGridView ? Icons.view_list : Icons.grid_view,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(showGridView
                                ? 'Отображение "Список"'
                                : 'Отображение "Сетка"'),
                          ],
                        ),
                      ),
                    ],
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
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 0),
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

  listViewCatalog() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 11, 14),
      child: ColumnListViewBuilder(
          itemCount: listProductsForListView.length,
          itemBuilder: (context, index) {
            var productItem = listProductsForListView[index];
            var price = 0.0;
            var countOnWarehouse = 0.0;

            var indexItemPrice = listProductPrice.indexWhere((element) =>
                element.uidProduct == productItem.uid &&
                element.uidPrice == uidPrice);
            if (indexItemPrice >= 0) {
              var itemList = listProductPrice[indexItemPrice];
              price = itemList.price;
            } else {
              price = 0.0;
            }

            var indexItemRest = listProductRest.indexWhere((element) =>
                element.uidProduct == productItem.uid &&
                element.uidWarehouse == uidWarehouse);
            if (indexItemRest >= 0) {
              var itemList = listProductRest[indexItemRest];
              countOnWarehouse = itemList.count;
            } else {
              countOnWarehouse = 0.000;
            }

            return Card(
              elevation: 2,
              child: (productItem.id == 0)
                  ? MoreItemListView(
                      textItem: 'Показать больше',
                      tap: () {
                        // Удалим пункт "Показать больше"
                        _currentMax--; // Для пункта "Показать больше"
                        listProductsForListView
                            .remove(listProductsForListView[index]);
                        readAdditionalProductsToView();
                        setState(() {});
                      },
                    )
                  : (productItem.isGroup == 1)
                      ? DirectoryItemListView(
                          parentProduct: parentProduct,
                          product: productItem,
                          tap: () {
                            if (productItem.uid == parentProduct.uid) {
                              if (treeParentItems.isNotEmpty) {
                                // Назначим нового родителя выхода из узла дерева
                                parentProduct =
                                    treeParentItems[treeParentItems.length - 1];

                                // Удалим старого родителя для будущего узла
                                treeParentItems.remove(treeParentItems[
                                    treeParentItems.length - 1]);
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
                      : ProductItemListView(
                          price: price,
                          countOnWarehouse: countOnWarehouse,
                          product: productItem,
                          tap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ScreenProductItem(productItem: productItem),
                              ),
                            );
                          },
                        ),
            );
          }),
    );
  }

  gridViewCatalog() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 20 / 27,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5),
                itemCount: listProductsForListView.length,
                itemBuilder: (BuildContext ctx, index) {
                  var productItem = listProductsForListView[index];
                  var price = 0.0;
                  var countOnWarehouse = 0.0;

                  var indexItemPrice = listProductPrice.indexWhere((element) =>
                      element.uidProduct == productItem.uid &&
                      element.uidPrice == uidPrice);
                  if (indexItemPrice >= 0) {
                    var itemList = listProductPrice[indexItemPrice];
                    price = itemList.price;
                  } else {
                    price = 0.0;
                  }

                  var indexItemRest = listProductRest.indexWhere((element) =>
                      element.uidProduct == productItem.uid &&
                      element.uidWarehouse == uidWarehouse);
                  if (indexItemRest >= 0) {
                    var itemList = listProductRest[indexItemRest];
                    countOnWarehouse = itemList.count;
                  } else {
                    countOnWarehouse = 0.000;
                  }

                  return Card(
                    elevation: 2,
                    child: (productItem.id == 0)
                        ? MoreItemListView(
                            textItem: 'Показать больше',
                            tap: () {
                              // Удалим пункт "Показать больше"
                              _currentMax--; // Для пункта "Показать больше"
                              listProductsForListView
                                  .remove(listProductsForListView[index]);
                              readAdditionalProductsToView();
                              setState(() {});
                            },
                          )
                        : (productItem.isGroup == 1)
                            ? DirectoryItemGridView(
                                parentProduct: parentProduct,
                                product: productItem,
                                tap: () {
                                  if (productItem.uid == parentProduct.uid) {
                                    if (treeParentItems.isNotEmpty) {
                                      // Назначим нового родителя выхода из узла дерева
                                      parentProduct = treeParentItems[
                                          treeParentItems.length - 1];

                                      // Удалим старого родителя для будущего узла
                                      treeParentItems.remove(treeParentItems[
                                          treeParentItems.length - 1]);
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
                            : ProductItemGridView(
                                price: price,
                                countOnWarehouse: countOnWarehouse,
                                product: productItem,
                                tap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScreenProductItem(
                                          productItem: productItem),
                                    ),
                                  );
                                },
                              ),
                  );
                })),
      ],
    );
  }
}

class DirectoryItemListView extends StatelessWidget {
  final Product parentProduct;
  final Product product;
  final Function tap;
  final Function? popTap;

  const DirectoryItemListView({
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

class MoreItemListView extends StatelessWidget {
  final String textItem;
  final Function tap;

  const MoreItemListView({
    Key? key,
    required this.textItem,
    required this.tap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color.fromRGBO(227, 242, 253, 1.0),
      onTap: () => tap(),
      title: Center(
        child: Text(
          textItem,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
          ),
          maxLines: 2,
        ),
      ),
    );
  }
}

class ProductItemListView extends StatelessWidget {
  final Product product;
  final Function tap;
  final double countOnWarehouse;
  final double price;

  const ProductItemListView({
    Key? key,
    required this.product,
    required this.tap,
    required this.countOnWarehouse,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => tap(),
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
        product.name,
        style: const TextStyle(
          fontSize: 16,
        ),
        //maxLines: 3,
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
                          product.nameUnit,
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
}

class DirectoryItemGridView extends StatelessWidget {
  final Product parentProduct;
  final Product product;
  final Function tap;
  final Function? popTap;

  const DirectoryItemGridView({
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
      title: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class ProductItemGridView extends StatelessWidget {
  final Product product;
  final Function tap;
  final double countOnWarehouse;
  final double price;

  const ProductItemGridView({
    Key? key,
    required this.product,
    required this.tap,
    required this.countOnWarehouse,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String pathImage = '';

    /// Картинки в Интернете. Путь + UID товара + '.jpg'
    if (pathPictures.isNotEmpty) {
      if (pathPictures.endsWith('/') == false) {
        pathPictures = pathPictures + '/';
      }
      pathImage = pathPictures + product.uid + '.jpg';
    } else {
      pathImage = '';
    }

    return GestureDetector(
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(4.0)),
            child: CachedNetworkImage(
              height: 120,
              fit: BoxFit.fill,
              placeholder: (context, url) => const Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 2,))),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.wallpaper, color: Colors.grey),
              imageUrl: pathImage,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
            child: Text(
              product.name.trim(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: false,
              style: const TextStyle(
                fontSize: 14,
              ),
              //maxLines: 3,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.price_change,
                        color: Colors.blue, size: 20),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      doubleToString(price) + ' грн',
                      style: price > 0
                          ? const TextStyle(fontSize: 12, color: Colors.blue)
                          : const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.gite, color: Colors.blue, size: 20),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      doubleThreeToString(countOnWarehouse) +
                          ' ' +
                          product.nameUnit,
                      style: countOnWarehouse > 0
                          ? const TextStyle(fontSize: 12, color: Colors.blue)
                          : const TextStyle(fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
