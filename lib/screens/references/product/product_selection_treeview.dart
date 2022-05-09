import 'dart:async';

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

// Список избранных товаров, которые ранее покупал клиент
List<Product> listFavouriteProducts = [];

String uidPrice = '';

String uidWarehouse = '';

class ScreenProductSelectionTreeView extends StatefulWidget {
  final List<ItemOrderCustomer>? listItemDoc;
  final OrderCustomer? orderCustomer;
  final List<ItemReturnOrderCustomer>? listItemReturnDoc;
  final ReturnOrderCustomer? returnOrderCustomer;

  const ScreenProductSelectionTreeView(
      {Key? key,
      this.listItemDoc,
      this.orderCustomer,
      this.listItemReturnDoc,
      this.returnOrderCustomer})
      : super(key: key);

  @override
  _ScreenProductSelectionTreeViewState createState() =>
      _ScreenProductSelectionTreeViewState();
}

class _ScreenProductSelectionTreeViewState
    extends State<ScreenProductSelectionTreeView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final StreamController<int> _controller = StreamController<int>();

  bool loadingData = false;

  bool showProductHierarchy = true;

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchCatalogController =
      TextEditingController();
  TextEditingController textFieldSearchBoughtController =
      TextEditingController();
  TextEditingController textFieldSearchRecommendController =
      TextEditingController();

  // Список товаров, которые ранее покупал клиент
  List<Product> listPurchasedProducts = [];

  // Список идентификаторов товаров для поиска цен и остатков
  List<String> listPurchasedProductsUID = [];

  // Список идентификаторов избранных товаров для поиска цен и остатков
  List<String> listFavouriteProductsUID = [];

  // Список товаров для вывода на экран
  List<Product> listProducts = [];

  List<Product> listProductsForListView = [];

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

  String? barcode;

  // Количество элементов в автозагрузке списка
  int _currentMax = 0;
  int countLoadItems = 20;

  @override
  void initState() {
    super.initState();
    startLoad();
    renewPurchasedItem();
    renewFavouriteItem();
    readPriceAndRests();

    // Переобновление главного виджета
    _controller.stream.listen((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    saveSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              await saveSettings();
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: const Text('Подбор товаров'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Каталог'),
              Tab(text: 'Акции'),
              Tab(text: 'Неликвид'),
              Tab(text: 'Избранное'),
              Tab(text: 'Купленное'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Scrollbar(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  searchTextFieldCatalog(),
                  listViewCatalog(),
                ],
              ),
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: const [
                //listViewPurchasedProducts(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: const [
                //listViewPurchasedProducts(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listViewFavouriteProducts(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listViewPurchasedProducts(),
              ],
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
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScreenAddItem(
              listItemDoc: widget.listItemDoc,
              orderCustomer: widget.orderCustomer,
              returnOrderCustomer: widget.returnOrderCustomer,
              listItemReturnDoc: widget.listItemReturnDoc,
              product: productItem),
        ),
      );
    } else {
      if (barcodeScanRes == '-1') {
        return;
      }
      showMessage(
          'Товар с штрихкодом: ' + barcodeScanRes + ' не найден!', context);
    }
  }

  startLoad() async {
    await loadSettings();
    await renewItem();
  }

  loadSettings() async {
    if (widget.orderCustomer != null) {
      uidPrice = widget.orderCustomer?.uidPrice ?? '';
    }
    if (widget.returnOrderCustomer != null) {
      uidPrice = widget.returnOrderCustomer?.uidPrice ?? '';
    }

    if (widget.orderCustomer != null) {
      uidWarehouse = widget.orderCustomer?.uidWarehouse ?? '';
    }
    if (widget.returnOrderCustomer != null) {
      uidWarehouse = widget.returnOrderCustomer?.uidWarehouse ?? '';
    }

    if (widget.orderCustomer != null) {
      uidPrice = widget.orderCustomer?.uidPrice ?? '';
    }
    if (widget.returnOrderCustomer != null) {
      uidPrice = widget.returnOrderCustomer?.uidPrice ?? '';
    }

    if (widget.orderCustomer != null) {
      uidWarehouse = widget.orderCustomer?.uidWarehouse ?? '';
    }
    if (widget.returnOrderCustomer != null) {
      uidWarehouse = widget.returnOrderCustomer?.uidWarehouse ?? '';
    }

    /// Восстановление последнего выбранного каталога
    final SharedPreferences prefs = await _prefs;

    // Очистим дерево каталогов иерархии
    treeParentItems.clear();

    // Восстановим иерархию списка
    String stringList = prefs.getString('settings_treeParentProductFromSetting')??'';
    List<String> tempListTreeParentProductFromSettings = stringList.split(',');

    for (var item in tempListTreeParentProductFromSettings) {
      Product product = await dbReadProductUID(item);
      parentProduct = product;
      treeParentItems.add(product);
      debugPrint('Каталог: ' + product.name);
    }

    // Из иерархии надо удалить последний элемент, так как он есть в parentPartner
    if(treeParentItems.isNotEmpty) {
      treeParentItems.removeAt(treeParentItems.length-1);
    }

    debugPrint('Восстановление иерархии каталога: ' + tempListTreeParentProductFromSettings.length.toString());

    /// Восстановим список товаров "Избранное"
    String stringListFavourite = prefs.getString('settings_listFavouriteProductsUID')??'';
    listFavouriteProductsUID = stringListFavourite.split(',');

    debugPrint('Товаров Избранного: ' + listFavouriteProductsUID.length.toString());
  }

  saveSettings() async {

    final SharedPreferences prefs = await _prefs;

    /// Сохранение последнего выбранного каталога
    // Запишем дерево иерархии
    List<String> tempListTreeParentProductFromSettings = [];
    for (var item in treeParentItems) {
      tempListTreeParentProductFromSettings.add(item.uid);
    }

    // Запишем текущий каталог
    if (parentProduct.uid != '00000000-0000-0000-0000-000000000000') {
      tempListTreeParentProductFromSettings.add(parentProduct.uid);
    }

    prefs.setString('settings_treeParentProductFromSetting',
        tempListTreeParentProductFromSettings.join(','));

    debugPrint('Сохранение иерархии каталога: ' + tempListTreeParentProductFromSettings.length.toString());

    /// Запишем список товаров "Избранное". Метод не очень, но пока что будет так. :)
    // Ради интереса так делаю.
    listFavouriteProductsUID.clear();
    for (var itemFavourite in listFavouriteProducts) {
      listFavouriteProductsUID.add(itemFavourite.uid);
    }

    prefs.setString('settings_listFavouriteProductsUID',
        listFavouriteProductsUID.join(','));
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

    /// Получение остатков для товаров: Общий список
    if (listProductsUID.isNotEmpty) {
      // Цены товаров
      listProductPrice
          .addAll(await dbReadAccumProductPriceByUIDProducts(listProductsUID));

      // Остатки товаров
      listProductRest
          .addAll(await dbReadAccumProductRestByUIDProducts(listProductsUID));

      debugPrint('Цены товаров Общие: ' + listProductsUID.length.toString());
      debugPrint('Остатки товаров Общие: ' + listProductsUID.length.toString());
    }

    /// Получение остатков для товаров: Избранное
    if (listFavouriteProductsUID.isNotEmpty){

      // Цены товаров
      listProductPrice.addAll(
          await dbReadAccumProductPriceByUIDProducts(listFavouriteProductsUID));

      // Остатки товаров
      listProductRest.addAll(
          await dbReadAccumProductRestByUIDProducts(listFavouriteProductsUID));

      debugPrint('Цены товаров Избранное: ' + listFavouriteProductsUID.length.toString());
      debugPrint('Остатки товаров Избранное: ' + listFavouriteProductsUID.length.toString());
    }

    /// Получение остатков для товаров: Купленные
    if (listPurchasedProductsUID.isNotEmpty) {

      /// Цены товаров
      listProductPrice.addAll(
          await dbReadAccumProductPriceByUIDProducts(listPurchasedProductsUID));

      /// Остатки товаров
      listProductRest.addAll(
          await dbReadAccumProductRestByUIDProducts(listPurchasedProductsUID));

      debugPrint('Цены товаров Купленные: ' + listFavouriteProductsUID.length.toString());
      debugPrint('Остатки товаров Купленные: ' + listFavouriteProductsUID.length.toString());
    }

    setState(() {});
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
      dummySearchList.clear();

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

      // Добавим товар
      listProducts.add(newItem);
    }

    await readAdditionalProductsToView();

    setState(() {});
  }

  renewPurchasedItem() async {
    String uidPartner = '';

    listPurchasedProductsUID.clear();

    if (widget.orderCustomer != null) {
      listPurchasedProducts.clear();
      if (widget.orderCustomer?.uidPartner == '') {
        return;
      }
      uidPartner = widget.orderCustomer?.uidPartner ?? '';
    }

    if (widget.returnOrderCustomer != null) {
      listPurchasedProducts.clear();
      if (widget.returnOrderCustomer?.uidPartner == '') {
        return;
      }
      uidPartner = widget.returnOrderCustomer?.uidPartner ?? '';
    }

    if (uidPartner == '') {
      return;
    }

    // Получим список товаров из заказов покупателя, которые он покупал ранее
    List<OrderCustomer> listOrders =
        await dbReadOrderCustomerUIDPartner(uidPartner);

    for (var itemOrder in listOrders) {
      // Получим товары заказа
      List<ItemOrderCustomer> listItemsOrder =
          await dbReadItemsOrderCustomer(itemOrder.id);

      // Найдем UID товара, который продавали клиенту и если его нет в списке, то добавим
      for (var itemItemOrder in listItemsOrder) {
        var indexUnitItem = listPurchasedProductsUID.indexWhere((element) =>
        element == itemItemOrder.uid);

        if (indexUnitItem < 0) {
          listPurchasedProductsUID.add(itemItemOrder.uid);
        }
      }
    }

    // Найдем объекты <Product> по их UID для отображения в списке
    if (listPurchasedProductsUID.isNotEmpty) {
      for (var uidProduct in listPurchasedProductsUID) {
        Product product = await dbReadProductUID(uidProduct);
        if (product.id != 0) {
          listPurchasedProducts.add(product);
        }
      }
    }

    // Посортируем товары по названию
    listPurchasedProducts.sort((a, b) => a.name.compareTo(b.name));

    debugPrint('Количество ранее купленных товаров: ' +
        listPurchasedProducts.length.toString());

    setState(() {});
  }

  renewFavouriteItem() async {

    final SharedPreferences prefs = await _prefs;

    listFavouriteProductsUID.clear();
    listFavouriteProducts.clear();

    // Восстановим список товаров "Избранное"
    String stringList = prefs.getString('settings_listFavouriteProductsUID')??'';
    listFavouriteProductsUID = stringList.split(',');

    // Найдем объекты <Product> по их UID для отображения в списке
    if (listFavouriteProductsUID.isNotEmpty) {
      for (var uidProduct in listFavouriteProductsUID) {
        if(uidProduct == ''){
          continue;
        }
        Product product = await dbReadProductUID(uidProduct);
        if (product.id != 0) {
          listFavouriteProducts.add(product);
        }
      }
    }

    // Посортируем товары по названию
    listFavouriteProducts.sort((a, b) => a.name.compareTo(b.name));

    debugPrint('Количество товаров "Избранное": ' +
        listFavouriteProducts.length.toString());

    setState(() {});
  }

  searchTextFieldCatalog() {
    var validateSearch = false;
    return Padding(
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

          if (textFieldSearchCatalogController.text.isEmpty) {
            showMessage(
                'Товаров с таким словом не найдено...',context);
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
              // IconButton(
              //   onPressed: () async {
              //     renewItem();
              //   },
              //   icon: const Icon(Icons.search, color: Colors.blue),
              // ),
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
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.blue,
                ),
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
                },
                icon: const Icon(Icons.more_vert, color: Colors.blue),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                  // PopupMenuItem<String>(
                  //   value: 'scanProduct',
                  //   child: Row(
                  //     children: const [
                  //       Icon(
                  //         Icons.qr_code_scanner,
                  //         color: Colors.blue,
                  //       ),
                  //       SizedBox(
                  //         width: 10,
                  //       ),
                  //       Text('Сканировать товар'),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                  ? MoreItem(
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
                      : ProductItem(
                          controller: _controller,
                          price: price,
                          countOnWarehouse: countOnWarehouse,
                          product: productItem,
                          tap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScreenAddItem(
                                    listItemDoc: widget.listItemDoc,
                                    orderCustomer: widget.orderCustomer,
                                    returnOrderCustomer:
                                        widget.returnOrderCustomer,
                                    listItemReturnDoc: widget.listItemReturnDoc,
                                    product: productItem),
                              ),
                            );
                          },
                        ),
            );
          }),
    );
  }

  listViewPurchasedProducts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 11, 14),
      child: ColumnListViewBuilder(
          itemCount: listPurchasedProducts.length,
          itemBuilder: (context, index) {
            var productItem = listPurchasedProducts[index];

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
              child: ProductItem(
                controller: _controller,
                price: price,
                countOnWarehouse: countOnWarehouse,
                product: productItem,
                tap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenAddItem(
                          listItemDoc: widget.listItemDoc,
                          orderCustomer: widget.orderCustomer,
                          returnOrderCustomer: widget.returnOrderCustomer,
                          listItemReturnDoc: widget.listItemReturnDoc,
                          product: productItem),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }

  listViewFavouriteProducts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 11, 14),
      child: ColumnListViewBuilder(
          itemCount: listFavouriteProducts.length,
          itemBuilder: (context, index) {
            var productItem = listFavouriteProducts[index];

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
              child: ProductItem(
                controller: _controller,
                price: price,
                countOnWarehouse: countOnWarehouse,
                product: productItem,
                tap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenAddItem(
                          listItemDoc: widget.listItemDoc,
                          orderCustomer: widget.orderCustomer,
                          returnOrderCustomer: widget.returnOrderCustomer,
                          listItemReturnDoc: widget.listItemReturnDoc,
                          product: productItem),
                    ),
                  );
                },
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

class MoreItem extends StatelessWidget {
  final String textItem;
  final Function tap;

  const MoreItem({
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

class ProductItem extends StatefulWidget {
  final StreamController<int> controller;
  final Product product;
  final Function tap;
  final double countOnWarehouse;
  final double price;

  const ProductItem({
    Key? key,
    required this.controller,
    required this.product,
    required this.tap,
    required this.countOnWarehouse,
    required this.price,
  }) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    bool isFavourite = false;
    var indexItemPrice = listFavouriteProducts
        .indexWhere((element) => element.uid == widget.product.uid);
    if (indexItemPrice >= 0) {
      isFavourite = true;
    }

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
        //maxLines: 2,
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
                      doubleToString(widget.price) + ' грн',
                      style: widget.price > 0
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
                      doubleThreeToString(widget.countOnWarehouse) +
                          ' ' +
                          widget.product.nameUnit,
                      style: widget.countOnWarehouse > 0
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
      trailing: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: () {
                  var indexItemPrice = listFavouriteProducts.indexWhere(
                      (element) => element.uid == widget.product.uid);
                  if (indexItemPrice >= 0) {
                    listFavouriteProducts.removeAt(indexItemPrice);
                    showMessage('Удалено из "Избранное"', context);
                  } else {
                    listFavouriteProducts.add(widget.product);
                    showMessage('Добавлено в "Избранное"', context);
                  }
                  setState(() {
                    widget.controller.add(1);
                  });
                },
                child: !isFavourite
                    ? const Icon(Icons.star)
                    : const Icon(
                        Icons.star,
                        color: Colors.blue,
                      )),
            const Icon(Icons.navigate_next),
          ],
        ),
      ),
    );
  }
}
