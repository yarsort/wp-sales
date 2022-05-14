import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';

class ScreenAddItem extends StatefulWidget {
  final List<ItemReturnOrderCustomer>? listItemReturnDoc;
  final ReturnOrderCustomer? returnOrderCustomer;

  final List<ItemOrderCustomer>? listItemDoc;
  final OrderCustomer? orderCustomer;

  final int? indexItem;

  final Product product;

  const ScreenAddItem({
    Key? key,
    this.listItemReturnDoc,
    this.returnOrderCustomer,
    this.listItemDoc,
    this.orderCustomer,
    this.indexItem,
    required this.product,
  }) : super(key: key);

  @override
  State<ScreenAddItem> createState() => _ScreenAddItemState();
}

class _ScreenAddItemState extends State<ScreenAddItem> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool visibleImage = true;

  String pathImage = '';

  List<AccumProductPrice> listAccumProductPrice = [];
  List<AccumProductRest> listAccumProductRest = [];

  List listPrices = [];
  List listRests = [];
  List<Unit> listUnits = [];

  Unit selectedUnit = Unit(); // Выбранная едиица измерения
  double countOnWarehouse = 0.0;
  double price = 0.0;

  /// Поле ввода: Product name
  TextEditingController textFieldProductNameController =
      TextEditingController();

  /// Поле ввода: Unit name
  TextEditingController textFieldUnitNameController = TextEditingController();

  /// Поле ввода: Warehouse name
  TextEditingController textFieldWarehouseNameController =
      TextEditingController();

  /// Поле ввода: Warehouse value
  TextEditingController textFieldWarehouseController = TextEditingController();

  /// Поле ввода: Price name
  TextEditingController textFieldPriceNameController = TextEditingController();

  /// Поле ввода: Price value
  TextEditingController textFieldPriceController = TextEditingController();

  /// Поле ввода: Sum value
  TextEditingController textFieldSumController = TextEditingController();

  /// Поле ввода: Count
  TextEditingController textFieldCountController = TextEditingController();

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
          title: const Text('Подбор товара'),
          bottom: TabBar(
            onTap: (index) {
              FocusScope.of(context).unfocus();
            },
            tabs: const [
              Tab(text: 'Главная'),
              Tab(text: 'Картинки'),
              Tab(text: 'Прочее'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                /// Product name
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 21, 14, 7),
                  child: TextField(
                    maxLines: 3,
                    readOnly: true,
                    controller: textFieldProductNameController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: Colors.blueGrey,
                      ),
                      labelText: 'Товар',
                    ),
                  ),
                ),

                /// Unit name
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                  child: TextField(
                    readOnly: true,
                    controller: textFieldUnitNameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                      labelText: 'Единица измерения',
                      suffixIcon: PopupMenuButton<Unit>(
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (Unit value) {
                          setState(() {
                            selectedUnit = value;
                            textFieldUnitNameController.text =
                                selectedUnit.name +
                                    ' (к: ' +
                                    selectedUnit.multiplicity.toString() +
                                    ', вес: ' +
                                    selectedUnit.weight.toString() +
                                    ')';
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return listUnits
                              .map<PopupMenuItem<Unit>>((Unit value) {
                            return PopupMenuItem(
                                child: Text(value.name), value: value);
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),

                // /// Price name
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                //   child: TextField(
                //     readOnly: true,
                //     controller: textFieldPriceNameController,
                //     decoration: const InputDecoration(
                //       contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                //       border: OutlineInputBorder(),
                //       labelStyle: TextStyle(
                //         color: Colors.blueGrey,
                //       ),
                //       labelText: 'Тип цены',
                //     ),
                //   ),
                // ),
                //
                // /// Warehouse name
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                //   child: TextField(
                //     readOnly: true,
                //     controller: textFieldWarehouseNameController,
                //     decoration: const InputDecoration(
                //       contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                //       border: OutlineInputBorder(),
                //       labelStyle: TextStyle(
                //         color: Colors.blueGrey,
                //       ),
                //       labelText: 'Склад',
                //     ),
                //   ),
                // ),

                Row(
                  children: [
                    /// Price
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                        child: TextField(
                          readOnly: true,
                          controller: textFieldPriceController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Colors.blueGrey,
                            ),
                            labelText: 'Цена',
                          ),
                        ),
                      ),
                    ),

                    /// Sum
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
                        child: TextField(
                          readOnly: true,
                          controller: textFieldSumController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Colors.blueGrey,
                            ),
                            labelText: 'Сумма',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    /// Count on Warehouse
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                        child: TextField(
                          readOnly: true,
                          controller: textFieldWarehouseController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            border: const OutlineInputBorder(),
                            labelStyle: const TextStyle(
                              color: Colors.blueGrey,
                            ),
                            labelText: 'Остаток (${widget.product.nameUnit})',
                          ),
                        ),
                      ),
                    ),

                    /// Count to document
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
                        child: TextField(
                          autofocus: true,
                          onChanged: (value) {
                            //calculateCount();
                          },
                          onSubmitted: (value) {
                            calculateCount();
                          },
                          onTap: () {
                            // Выделим текст после фокусировки
                            textFieldCountController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: textFieldCountController.text.length,
                            );
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          controller: textFieldCountController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,3}'))
                          ],
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            border: const OutlineInputBorder(),
                            labelStyle: const TextStyle(
                              color: Colors.blueGrey,
                            ),
                            labelText: 'Количество',
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Отнять
                                IconButton(
                                  onPressed: () {
                                    minusCountOnForm();
                                    calculateCount();

                                    // Выделим текст после фокусировки
                                    textFieldCountController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: textFieldCountController.text.length,
                                    );
                                  },
                                  icon: const Icon(Icons.remove,
                                      color: Colors.blue),
                                  //icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                                // Добавить
                                IconButton(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 1, 1, 1),
                                  onPressed: () {
                                    plusCountOnForm();
                                    calculateCount();

                                    // Выделим текст после фокусировки
                                    textFieldCountController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: textFieldCountController.text.length,
                                    );
                                  },
                                  icon:
                                      const Icon(Icons.add, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 7, 7, 14),
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red)),
                              onPressed: () async {
                                // Закроем окно
                                Navigator.of(context).pop();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [Text('Отменить')],
                              )),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(7, 7, 14, 14),
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue)),
                              onPressed: () async {
                                // Добавим товар в заказ покупателя
                                if (widget.orderCustomer != null) {
                                  bool result = await addProductToOrderCustomer();
                                  if (result == false) {
                                    return;
                                  }
                                }

                                // Добавим товар в возврат товаров от покупателя
                                if (widget.returnOrderCustomer != null) {
                                  bool result = await addProductToReturnOrderCustomer();
                                  if (result == false) {
                                    return;
                                  }
                                }

                                // Закроем окно
                                Navigator.of(context).pop();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Добавить'),
                                ],
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ListView(
              children: [
                /// Картинки товара
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 21, 14, 7),
                  child: SizedBox(
                    child: CachedNetworkImage(
                      height: 300,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => const Center(
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 2,))),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.wallpaper, color: Colors.grey, size: 50,),
                      imageUrl: pathImage,
                    ),
                  ),
                )
              ],
            ),
            ListView(
              children: [
                nameGroup(nameGroup: 'Цены'),
                listViewPrices(),
                nameGroup(nameGroup: 'Остатки'),
                listViewRests(),
              ],
            )
          ],
        ),
      ),
    );
  }

  renewItem() async {
    listPrices.clear();
    listRests.clear();

    textFieldProductNameController.text = widget.product.name;

    /// Картинки в Интернете. Путь + UID товара + '.jpg'
    final SharedPreferences prefs = await _prefs;
    String pathPictures = prefs.getString('settings_pathPictures')??'';
    if (pathPictures.isNotEmpty) {
      if(pathPictures.endsWith('/') == false){
        pathPictures = pathPictures + '/';
      }
      pathImage = pathPictures + widget.product.uid + '.jpg';
    } else {
      pathImage = '';
    }
    debugPrint(pathImage);

    String uidProduct = widget.product.uid;
    String uidWarehouse = '';
    String nameWarehouse = '';

    String uidPrice = '';
    String namePrice = '';

    /// Получим все типы цен и все остатки по выбранному товару
    List<String> listProductsUID = [];
    listProductsUID.add(uidProduct);

    listAccumProductPrice =
        await dbReadAccumProductPriceByUIDProducts(listProductsUID);
    listAccumProductRest =
        await dbReadAccumProductRestByUIDProducts(listProductsUID);
    listUnits =
        await dbReadUnitsProduct(uidProduct);

    // Посортируем что бы штуки были первыми
    listUnits.sort((a, b) => b.name.compareTo(a.name));

    /// Получение данных по ценам
    for (var listItem in listAccumProductPrice) {
      var data = {};
      var priceType = await dbReadPriceUID(listItem.uidPrice);
      data['name'] = priceType.name;
      data['price'] = listItem.price;
      listPrices.add(data);
    }

    /// Получение данных по остаткам
    for (var listItem in listAccumProductRest) {
      var data = {};
      var warehouseType = await dbReadWarehouseUID(listItem.uidWarehouse);
      data['name'] = warehouseType.name;
      data['count'] = listItem.count;
      listRests.add(data);
    }

    /// Заполним отборы типы цены и склада из документа, если он есть
    if (widget.orderCustomer != null) {
      namePrice = widget.orderCustomer?.namePrice ?? '';
      uidPrice = widget.orderCustomer?.uidPrice ?? '';
      nameWarehouse = widget.orderCustomer?.nameWarehouse ?? '';
      uidWarehouse = widget.orderCustomer?.uidWarehouse ?? '';
    }
    if (widget.returnOrderCustomer != null) {
      namePrice = widget.returnOrderCustomer?.namePrice ?? '';
      uidPrice = widget.returnOrderCustomer?.uidPrice ?? '';
      nameWarehouse = widget.returnOrderCustomer?.nameWarehouse ?? '';
      uidWarehouse = widget.returnOrderCustomer?.uidWarehouse ?? '';
    }

    textFieldPriceNameController.text = namePrice;
    textFieldWarehouseNameController.text = nameWarehouse;

    /// Остаток на складе.
    countOnWarehouse = await dbReadProductRest(
        uidWarehouse: uidWarehouse,
        uidProduct: uidProduct,
        uidProductCharacteristic: '');

    textFieldWarehouseController.text = doubleThreeToString(countOnWarehouse);

    /// Цена товара.
    price = await dbReadProductPrice(
        uidPrice: uidPrice,
        uidProduct: uidProduct,
        uidProductCharacteristic: '');

    textFieldPriceController.text = doubleToString(price);

    /// Вывод единицы измерения
    if (listUnits.isNotEmpty) {
      for (var itemUnit in listUnits) {
        if(itemUnit.uid == widget.product.uidUnit) {
          selectedUnit = itemUnit;
        }
      }
      // Если не установили основную единицу измерения, тогда беем первую из списка
      if (selectedUnit.uid == '') {
        selectedUnit = listUnits[0];
      }

      // Вывод на форму
      textFieldUnitNameController.text = selectedUnit.name +
          ' (к: ' +
          selectedUnit.multiplicity.toString() +
          ', вес: ' +
          selectedUnit.weight.toString() +
          ')';
    }

    /// Заказ покупателя
    // Подставим количесто из заказа, если оно есть.
    if (widget.listItemDoc != null) {
      // Если нашли товар в списке товаров заказа.
      if (widget.indexItem != null) {

        var itemList = widget.listItemDoc?[widget.indexItem!];

        // Подставим единицу измерения
        var indexUnitItem = listUnits.indexWhere((element) =>
        element.uid == itemList?.uidUnit);

        if (indexUnitItem >= 0) {
          selectedUnit = listUnits[indexUnitItem];

          // Вывод на форму
          textFieldUnitNameController.text = selectedUnit.name +
              ' (к: ' +
              selectedUnit.multiplicity.toString() +
              ', вес: ' +
              selectedUnit.weight.toString() +
              ')';
        }

        // Подставим из заказа количество
        double count = itemList?.count ?? 0.0;
        double sum = price * (itemList?.count ?? 0.0) * selectedUnit.multiplicity;

        textFieldCountController.text = doubleThreeToString(count);
        textFieldSumController.text = doubleToString(sum);

      } else {

        double count = 0.0;
        double sum = 0.0;

        for (var itemUnit in listUnits) {
          var indexUnitItem = widget.listItemDoc?.indexWhere((element) =>
          element.uidUnit == itemUnit.uid);

          if (indexUnitItem! >= 0) {
            selectedUnit = itemUnit;

            // Вывод на форму
            textFieldUnitNameController.text = selectedUnit.name +
                ' (к: ' +
                selectedUnit.multiplicity.toString() +
                ', вес: ' +
                selectedUnit.weight.toString() +
                ')';

            // Подставим из заказа количество
            var itemList = widget.listItemDoc?[indexUnitItem];
            count = itemList?.count ?? 0.0;
            sum = price * (itemList?.count ?? 0.0) * selectedUnit.multiplicity;

            textFieldCountController.text = doubleThreeToString(count);
            textFieldSumController.text = doubleToString(sum);
          }
        }

        // Подставим 1 единицу
        if (count == 0) {
          textFieldCountController.text = doubleThreeToString(1.0);
          textFieldSumController.text = doubleToString(price);
        }

      }

      // Выделим текст после фокусировки
      textFieldCountController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textFieldCountController.text.length,
      );
    }

    if (widget.listItemReturnDoc != null) {
      // Если нашли товар в списке товаров заказа.
      if (widget.indexItem != null) {

        var itemList = widget.listItemReturnDoc?[widget.indexItem!];

        // Подставим единицу измерения
        var indexUnitItem = listUnits.indexWhere((element) =>
        element.uid == itemList?.uidUnit);

        if (indexUnitItem >= 0) {
          selectedUnit = listUnits[indexUnitItem];

          // Вывод на форму
          textFieldUnitNameController.text = selectedUnit.name +
              ' (к: ' +
              selectedUnit.multiplicity.toString() +
              ', вес: ' +
              selectedUnit.weight.toString() +
              ')';
        }

        // Подставим из заказа количество
        double count = itemList?.count ?? 0.0;
        double sum = price * (itemList?.count ?? 0.0) * selectedUnit.multiplicity;

        textFieldCountController.text = doubleThreeToString(count);
        textFieldSumController.text = doubleToString(sum);

      } else {

        double count = 0.0;
        double sum = 0.0;

        for (var itemUnit in listUnits) {
          var indexUnitItem = widget.listItemReturnDoc?.indexWhere((element) =>
          element.uidUnit == itemUnit.uid);

          if (indexUnitItem! >= 0) {
            selectedUnit = itemUnit;

            // Вывод на форму
            textFieldUnitNameController.text = selectedUnit.name +
                ' (к: ' +
                selectedUnit.multiplicity.toString() +
                ', вес: ' +
                selectedUnit.weight.toString() +
                ')';

            // Подставим из заказа количество
            var itemList = widget.listItemReturnDoc?[indexUnitItem];
            count = itemList?.count ?? 0.0;
            sum = price * (itemList?.count ?? 0.0) * selectedUnit.multiplicity;

            textFieldCountController.text = doubleThreeToString(count);
            textFieldSumController.text = doubleToString(sum);
          }
        }

        // Подставим 1 единицу
        if (count == 0) {
          textFieldCountController.text = doubleThreeToString(1.0);
          textFieldSumController.text = doubleToString(price);
        }

      }
    }

    setState(() {});
  }

  calculateCount() {
    var count = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));

    var price = double.parse(
        doubleThreeToString(double.parse(textFieldPriceController.text)));

    textFieldCountController.text = doubleThreeToString(count);
    textFieldSumController.text = doubleToString(count * price);
  }

  plusCountOnForm() {
    if (textFieldCountController.text.trim() == '') {
      textFieldCountController.text = doubleThreeToString(1.0);
      return;
    }

    var value = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));
    value = value + 1.0;

    if (value < 0.000) {
      value = 0.000;
    }
    textFieldCountController.text = doubleThreeToString(value);
  }

  minusCountOnForm() {
    var value = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));
    value = value - 1.0;
    if (value <= 0.000) {
      value = 1.000;
    }
    textFieldCountController.text = doubleThreeToString(value);
  }

  Future<bool> addProductToOrderCustomer() async {

    final SharedPreferences prefs = await _prefs;

    // Получим количество товара, которое добавляем
    var value = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));

    /// Добавление товаров в заказе покупателя
    if (widget.listItemDoc != null) {

      // Контроль добавления товара, если на остатке его нет
      bool deniedAddProductWithoutRest = prefs.getBool('settings_deniedAddProductWithoutRest')!;
      if(deniedAddProductWithoutRest){
        if(value * selectedUnit.multiplicity > countOnWarehouse){
          showErrorMessage('Товара недостаточно на остатке!', context);
          return false;
        }
      }

      // Найдем индекс строки товара в заказе по товару который добавляем
      var indexItem = widget.listItemDoc?.indexWhere((element) =>
              element.uid == widget.product.uid &&
              element.uidUnit == selectedUnit.uid) ??
          -1;

      // Если нашли товар в списке товаров заказа
      if (indexItem >= 0) {
        var itemList = widget.listItemDoc?[indexItem];
        itemList?.count = value;
        itemList?.sum = itemList.price * itemList.count * selectedUnit.multiplicity;
      } else {
        // Добавим новый товар в заказ
        var priceProduct = double.parse(
            doubleThreeToString(double.parse(textFieldPriceController.text)));

        ItemOrderCustomer itemOrderCustomer = ItemOrderCustomer(
            id: 0,
            idOrderCustomer: widget.orderCustomer?.id ?? 0,
            uid: widget.product.uid,
            name: widget.product.name,
            uidUnit: selectedUnit.uid,
            nameUnit: selectedUnit.name,
            count: value,
            price: priceProduct,
            discount: 0.0,
            sum: priceProduct * value * selectedUnit.multiplicity);

        widget.listItemDoc?.add(itemOrderCustomer);
      }
    }

    return true;
  }

  Future<bool> addProductToReturnOrderCustomer() async {
    // Получим количество товара, которое добавляем
    var value = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));

    // Найдем индекс строки товара в заказе по товару который добавляем
    var indexItem = widget.listItemReturnDoc?.indexWhere((element) =>
            element.uid == widget.product.uid &&
            element.uidUnit == selectedUnit.uid) ??
        -1;

    // Если нашли товар в списке товаров заказа
    if (indexItem >= 0) {
      var itemList = widget.listItemReturnDoc?[indexItem];
      itemList?.count = value;
      itemList?.sum = itemList.price * itemList.count * selectedUnit.multiplicity;
    } else {
      // Добавим новый товар в заказ
      var priceProduct = double.parse(
          doubleThreeToString(double.parse(textFieldPriceController.text)));

      ItemReturnOrderCustomer itemReturnOrderCustomer = ItemReturnOrderCustomer(
          id: 0,
          idReturnOrderCustomer: widget.returnOrderCustomer?.id ?? 0,
          uid: widget.product.uid,
          name: widget.product.name,
          uidUnit: selectedUnit.uid,
          nameUnit: selectedUnit.name,
          count: value,
          price: priceProduct,
          discount: 0.0,
          sum: priceProduct * value * selectedUnit.multiplicity);

      widget.listItemReturnDoc?.add(itemReturnOrderCustomer);
    }

    return true;
  }

  listViewPrices() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listPrices.length,
        itemBuilder: (context, index) {
          var itemList = listPrices[index];
          return Card(
            elevation: 2,
            child: ListTile(
              title: Text(itemList['name']),
              subtitle: Row(
                children: [
                  const Text('Цена: '),
                  Text(doubleToString(itemList['price'])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  listViewRests() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listRests.length,
        itemBuilder: (context, index) {
          var itemList = listRests[index];
          return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Card(
                elevation: 2,
                child: ListTile(
                  title: Text(itemList['name']),
                  subtitle: Row(
                    children: [
                      const Text('Остаток: '),
                      Text(doubleThreeToString(itemList['count'])),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}
