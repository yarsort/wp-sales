import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
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

  // Array of button
  final List<String> buttons = [
    'C',
    ' ',
    '%',
    'Del',
    '7',
    '8',
    '9',
    '/',
    '4',
    '5',
    '6',
    'x',
    '1',
    '2',
    '3',
    '-',
    '.',
    '0',
    '=',
    '+',
  ];

  /// Калькулятор :)
  Size get preferredSize => const Size.fromHeight(280);
  var userInput = '';
  var answer = '';
  TextEditingController textFieldResultController = TextEditingController();

  final FocusNode _nodePrice = FocusNode();
  final FocusNode _nodeDiscount = FocusNode();
  final FocusNode _nodeCount = FocusNode();

  bool visibleImage = true;

  String pathImage = '';

  List<AccumProductPrice> listAccumProductPrice = [];
  List<AccumProductRest> listAccumProductRest = [];

  List listPrices = [];
  List listRests = [];
  List<Unit> listUnits = [];

  Unit selectedUnit = Unit(); // Выбранная едиица измерения
  double countOnWarehouse = 0.0;

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

  /// Поле ввода: Discount value
  TextEditingController textFieldDiscountController = TextEditingController();

  /// Поле ввода: Sum value
  TextEditingController textFieldSumController = TextEditingController();

  /// Поле ввода: Count
  TextEditingController textFieldCountController = TextEditingController();

  bool deniedEditPrice = true; // Запретить изменять цену в документах
  bool deniedEditDiscount = true; // Запретить изменять скидку в документах

  @override
  void initState() {
    super.initState();
    fillData();
  }

  @override
  void dispose() {
    _nodeCount.dispose();
    _nodeDiscount.dispose();
    _nodePrice.dispose();
    super.dispose();
  }

  fillData() async {
    final SharedPreferences prefs = await _prefs;

    // Получим разрешение на редактирование цены
    deniedEditPrice = prefs.getBool('settings_deniedEditPrice') ??
        true; // Запретить изменять тип цены в документах

    // Получим разрешение на редактирование скидки
    deniedEditDiscount = prefs.getBool('settings_deniedEditDiscount') ??
        true; // Запретить изменять тип цены в документах

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
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                /// Product name
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 21, 14, 7),
                  child: TextField(
                    maxLines: 2,
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
                            calculateCount();

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

                Row(
                  children: [
                    /// Price
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                        child: TextField(
                          focusNode: _nodePrice,
                          onSubmitted: (value) {
                            calculateCount();
                          },
                          onTap: () {
                            setState(() {
                              userInput = '';
                              textFieldResultController.text = '';
                            });
                            // Выделим текст после фокусировки
                            textFieldPriceController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset:
                                  textFieldPriceController.text.length,
                            );
                          },
                          // keyboardType: const TextInputType.numberWithOptions(
                          //     decimal: true, signed: true),
                          // inputFormatters: [
                          //   FilteringTextInputFormatter.allow(
                          //       RegExp(r'^\d*\.?\d{0,2}'))
                          // ],
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

                    /// Discount
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
                        child: TextField(
                          focusNode: _nodeDiscount,
                          // onSubmitted: (value) {
                          //   calculateCount();
                          // },
                          onTap: () {
                            setState(() {
                              userInput = '';
                              textFieldResultController.text = '';
                            });
                            // Выделим текст после фокусировки
                            textFieldDiscountController.selection =
                                TextSelection(
                              baseOffset: 0,
                              extentOffset:
                                  textFieldDiscountController.text.length,
                            );
                          },
                          // keyboardType: const TextInputType.numberWithOptions(
                          //     decimal: true, signed: true),
                          // inputFormatters: [
                          //   FilteringTextInputFormatter.allow(
                          //       RegExp(r'^\d*\.?\d{0,2}'))
                          // ],
                          readOnly: true,
                          controller: textFieldDiscountController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Colors.blueGrey,
                            ),
                            labelText: 'Скидка',
                          ),
                        ),
                      ),
                    ),

                    /// Sum
                    Expanded(
                      flex: 1,
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
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
                        child: TextField(
                          focusNode: _nodeCount,
                          readOnly: true,
                          autofocus: true,
                          onSubmitted: (value) {
                            calculateCount();
                          },
                          onTap: () {
                            setState(() {
                              userInput = '';
                              textFieldResultController.text = '';
                            });
                            // Выделим текст после фокусировки
                            textFieldCountController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset:
                                  textFieldCountController.text.length,
                            );
                          },
                          controller: textFieldCountController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Colors.blueGrey,
                            ),
                            labelText: 'Количество',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                /// Кнопки: Отменить и Добавить
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 7, 7, 0),
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
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(7, 7, 14, 0),
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue)),
                              onPressed: () async {
                                await calculateCount();

                                // Добавим товар в заказ покупателя
                                if (widget.orderCustomer != null) {
                                  bool result =
                                      await addProductToOrderCustomer();
                                  if (result == false) {
                                    return;
                                  }
                                }

                                // Добавим товар в возврат товаров от покупателя
                                if (widget.returnOrderCustomer != null) {
                                  bool result =
                                      await addProductToReturnOrderCustomer();
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

                const Divider(),

                calculatorGrid(),

                /// Result of calculation
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 7),
                      child: SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width - 28,
                        child: MyButton(
                          onTap: () {},
                          buttonText: textFieldResultController.text,
                          color: Colors.blue[50],
                          textColor: Colors.grey,
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
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                                strokeWidth: 2,
                              ))),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.wallpaper,
                        color: Colors.grey,
                        size: 50,
                      ),
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
    String pathPictures = prefs.getString('settings_pathPictures') ?? '';
    if (pathPictures.isNotEmpty) {
      if (pathPictures.endsWith('/') == false) {
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
    listUnits = await dbReadUnitsProduct(uidProduct);

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
    var tPrice = await dbReadProductPrice(
        uidPrice: uidPrice,
        uidProduct: uidProduct,
        uidProductCharacteristic: '');

    textFieldPriceController.text = doubleToString(tPrice);
    textFieldSumController.text = doubleToString(tPrice);

    /// Вывод единицы измерения
    if (listUnits.isNotEmpty) {
      for (var itemUnit in listUnits) {
        if (itemUnit.uid == widget.product.uidUnit) {
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
    // Подставим количество из документа, если оно есть.
    if (widget.listItemDoc != null) {
      // Если нашли товар в списке товаров заказа.
      if (widget.indexItem != null) {
        var itemList = widget.listItemDoc?[widget.indexItem!];

        // Подставим единицу измерения
        var indexUnitItem =
            listUnits.indexWhere((element) => element.uid == itemList?.uidUnit);

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
        double discount = itemList?.discount ?? 0.0;
        double price = itemList?.price ?? 0.0;

        double sumWithoutDiscount = price * count * selectedUnit.multiplicity;
        double sum = sumWithoutDiscount - (sumWithoutDiscount / 100 * discount);

        textFieldCountController.text = doubleThreeToString(count);
        textFieldDiscountController.text = doubleToString(discount);
        textFieldPriceController.text = doubleToString(price);
        textFieldSumController.text = doubleToString(sum);
      } else {
        double count = 0.0;
        double discount = 0.0;
        double price = 0.0;
        double sum = 0.0;

        for (var itemUnit in listUnits) {
          var indexUnitItem = widget.listItemDoc
              ?.indexWhere((element) => element.uidUnit == itemUnit.uid);

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
            discount = itemList?.discount ?? 0.0;
            price = itemList?.price ?? 0.0;

            double sumWithoutDiscount =
                price * count * selectedUnit.multiplicity;
            sum = sumWithoutDiscount - (sumWithoutDiscount / 100 * discount);

            textFieldDiscountController.text = doubleToString(discount);
            textFieldCountController.text = doubleThreeToString(count);
            textFieldPriceController.text = doubleToString(price);
            textFieldSumController.text = doubleToString(sum);
          }
        }

        // Подставим 1 единицу
        if (count == 0) {
          textFieldCountController.text = doubleThreeToString(1.0);
          textFieldDiscountController.text = doubleToString(0.0);
        }
      }
    }

    /// Возврат товаров от покупателя
    // Подставим количество из документа, если оно есть.
    if (widget.listItemReturnDoc != null) {
      // Если нашли товар в списке товаров заказа.
      if (widget.indexItem != null) {
        var itemList = widget.listItemReturnDoc?[widget.indexItem!];

        // Подставим единицу измерения
        var indexUnitItem =
            listUnits.indexWhere((element) => element.uid == itemList?.uidUnit);

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
        double discount = itemList?.discount ?? 0.0;
        double price = itemList?.price ?? 0.0;

        double sumWithoutDiscount = price * count * selectedUnit.multiplicity;
        double sum = sumWithoutDiscount - (sumWithoutDiscount / 100 * discount);

        textFieldCountController.text = doubleThreeToString(count);
        textFieldDiscountController.text = doubleToString(discount);
        textFieldPriceController.text = doubleToString(price);
        textFieldSumController.text = doubleToString(sum);
      } else {
        double count = 0.0;
        double discount = 0.0;
        double price = 0.0;
        //double sum = 0.0;

        for (var itemUnit in listUnits) {
          var indexUnitItem = widget.listItemReturnDoc
              ?.indexWhere((element) => element.uidUnit == itemUnit.uid);

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
            discount = itemList?.discount ?? 0.0;
            price = itemList?.price ?? 0.0;

            double sumWithoutDiscount =
                price * count * selectedUnit.multiplicity;
            double sum =
                sumWithoutDiscount - (sumWithoutDiscount / 100 * discount);

            textFieldCountController.text = doubleThreeToString(count);
            textFieldDiscountController.text = doubleToString(discount);
            textFieldPriceController.text = doubleToString(price);
            textFieldSumController.text = doubleToString(sum);
          }
        }

        // Подставим 1 единицу
        if (count == 0) {
          textFieldCountController.text = doubleThreeToString(1.0);
          textFieldDiscountController.text = doubleToString(0.0);
        }
      }
    }

    /// Выделим текст после заполнения и фокусировки
    textFieldCountController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textFieldCountController.text.length,
    );

    setState(() {});
  }

  calculateCount() {
    var count = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));

    var discount = double.parse(
        doubleToString(double.parse(textFieldDiscountController.text)));

    var price = double.parse(
        doubleThreeToString(double.parse(textFieldPriceController.text)));

    textFieldPriceController.text = doubleToString(price);
    textFieldDiscountController.text = doubleToString(discount);
    textFieldCountController.text = doubleThreeToString(count);

    var sum = (count * price * selectedUnit.multiplicity) -
        ((count * price * selectedUnit.multiplicity) / 100 * discount);

    textFieldSumController.text = doubleToString(sum);

    if (_nodeCount.hasFocus) {
      textFieldCountController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textFieldCountController.text.length,
      );
    }
    if (_nodeDiscount.hasFocus) {
      textFieldDiscountController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textFieldDiscountController.text.length,
      );
    }
    if (_nodePrice.hasFocus) {
      textFieldPriceController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textFieldPriceController.text.length,
      );
    }
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
    var count = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));

    var discount = double.parse(
        doubleToString(double.parse(textFieldDiscountController.text)));

    var price = double.parse(
        doubleToString(double.parse(textFieldPriceController.text)));

    var sum =
        double.parse(doubleToString(double.parse(textFieldSumController.text)));

    /// Добавление товаров в заказе покупателя
    if (widget.listItemDoc != null) {
      // Контроль добавления товара, если на остатке его нет
      bool deniedAddProductWithoutRest =
          prefs.getBool('settings_deniedAddProductWithoutRest')!;
      if (deniedAddProductWithoutRest) {
        if (count * selectedUnit.multiplicity > countOnWarehouse) {
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
        itemList?.count = count;
        itemList?.discount = discount;
        itemList?.sum = sum;
      } else {
        ItemOrderCustomer itemOrderCustomer = ItemOrderCustomer(
            id: 0,
            idOrderCustomer: widget.orderCustomer?.id ?? 0,
            uid: widget.product.uid,
            name: widget.product.name,
            uidUnit: selectedUnit.uid,
            nameUnit: selectedUnit.name,
            count: count,
            price: price,
            discount: discount,
            sum: sum);

        widget.listItemDoc?.add(itemOrderCustomer);
      }
    }
    return true;
  }

  Future<bool> addProductToReturnOrderCustomer() async {
    // Получим количество товара, которое добавляем
    var count = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));

    var discount = double.parse(
        doubleToString(double.parse(textFieldDiscountController.text)));

    var price = double.parse(
        doubleToString(double.parse(textFieldPriceController.text)));

    var sum =
        double.parse(doubleToString(double.parse(textFieldSumController.text)));

    // Найдем индекс строки товара в заказе по товару который добавляем
    var indexItem = widget.listItemReturnDoc?.indexWhere((element) =>
            element.uid == widget.product.uid &&
            element.uidUnit == selectedUnit.uid) ??
        -1;

    // Если нашли товар в списке товаров заказа
    if (indexItem >= 0) {
      var itemList = widget.listItemReturnDoc?[indexItem];
      itemList?.count = count;
      itemList?.discount = discount;
      itemList?.sum =
          itemList.price * itemList.count * selectedUnit.multiplicity;
    } else {
      ItemReturnOrderCustomer itemReturnOrderCustomer = ItemReturnOrderCustomer(
          id: 0,
          idReturnOrderCustomer: widget.returnOrderCustomer?.id ?? 0,
          uid: widget.product.uid,
          name: widget.product.name,
          uidUnit: selectedUnit.uid,
          nameUnit: selectedUnit.name,
          count: count,
          price: price,
          discount: discount,
          sum: sum);
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

  bool isOperator(String x) {
    if (x == '/' || x == 'x' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

  void equalPressed() {
    double answerDouble = 0.0;

    String finalUserInput = userInput;
    finalUserInput = userInput.replaceAll('x', '*');

    // Пропустим эти начальные символы
    if (finalUserInput == 'C' ||
        finalUserInput == '+/-' ||
        finalUserInput == '%' ||
        finalUserInput == '/' ||
        finalUserInput == 'x' ||
        finalUserInput == '=' ||
        finalUserInput == '-' ||
        finalUserInput == '.' ||
        finalUserInput == '*' ||
        finalUserInput == '+') {
      userInput = '';
      finalUserInput = '';
      return;
    }

    // Ввод пользователя перепишем результатом
    textFieldResultController.text = userInput;

    if (finalUserInput.isNotEmpty) {
      Parser p = Parser();
      try {
        Expression exp = p.parse(finalUserInput);
        ContextModel cm = ContextModel();
        answerDouble = exp.evaluate(EvaluationType.REAL, cm);
        answer = answerDouble.toString();
      } catch (e) {
        return;
        showErrorMessage('Error: $e', context);
        userInput = '';
        finalUserInput = '';
        answerDouble = 0.0;
      }
    } else {
      answerDouble = 0.0;
      answer = answerDouble.toString();
    }

    if (answerDouble < 0) {
      answerDouble = 0.0;
      userInput = '';
      finalUserInput = '';
    }

    // Test
    debugPrint(answer);

    if (_nodeCount.hasFocus) {
      textFieldCountController.text = doubleThreeToString(answerDouble);
      textFieldCountController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textFieldCountController.text.length,
      );
    }
    if (_nodeDiscount.hasFocus) {
      textFieldDiscountController.text = doubleToString(answerDouble);
      textFieldDiscountController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textFieldDiscountController.text.length,
      );
    }
    if (_nodePrice.hasFocus) {
      textFieldPriceController.text = doubleToString(answerDouble);
      textFieldPriceController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textFieldPriceController.text.length,
      );
    }

    // Рассчитаем сумму
    calculateCount();
  }

  calculatorGrid() {
    return SizedBox(
      //height: 250,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: buttons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              /// Clear Button
              if (buttons[index] == 'C') {
                return MyButton(
                  onTap: () {
                    setState(() {
                      userInput = '';
                      answer = '0';
                      equalPressed();
                    });
                  },
                  buttonText: buttons[index],
                  color: Colors.blue[100],
                  textColor: Colors.black,
                );
              }

              /// +/- button
              else if (buttons[index] == ' ') {
                return MyButton(
                  onTap: () {
                    setState(() {
                      userInput += buttons[index];
                      equalPressed();
                    });
                  },
                  buttonText: buttons[index],
                  color: Colors.blue[100],
                  textColor: Colors.black,
                );
              }

              /// % Button
              else if (buttons[index] == '%') {
                return MyButton(
                  onTap: () {
                    setState(() {
                      //userInput += buttons[index];
                    });
                  },
                  buttonText: buttons[index],
                  color: Colors.blue[100],
                  textColor: Colors.black,
                );
              }

              /// Delete Button
              else if (buttons[index] == 'Del') {
                return MyButton(
                  onTap: () {
                    setState(() {
                      if (userInput.isEmpty) {
                        return;
                      }
                      userInput = userInput.substring(0, userInput.length - 1);
                      equalPressed();
                    });
                  },
                  buttonText: buttons[index],
                  color: Colors.blue[100],
                  textColor: Colors.black,
                );
              }

              /// Equal_to Button
              else if (buttons[index] == '=') {
                return MyButton(
                  onTap: () {
                    setState(() {
                      equalPressed();
                    });
                  },
                  buttonText: buttons[index],
                  color: Colors.blue[50],
                  textColor: Colors.black,
                );
              }

              /// - Button
              else if (buttons[index] == '-') {
                return MyButton(
                  onTap: () {
                    var isFirstOperatorSymbol = false;
                    if (userInput.isEmpty) {
                      if (_nodeCount.hasFocus) {
                        userInput = textFieldCountController.text;
                        userInput += '-1';
                        isFirstOperatorSymbol = true;
                      }
                      if (_nodeDiscount.hasFocus) {
                        userInput = textFieldDiscountController.text;
                        userInput += '-1';
                        isFirstOperatorSymbol = true;
                      }
                      if (_nodePrice.hasFocus) {
                        userInput = textFieldPriceController.text;
                        userInput += '-1';
                        isFirstOperatorSymbol = true;
                      }
                      setState(() {
                        equalPressed();
                        if (isFirstOperatorSymbol){
                          userInput = '';
                        }
                      });
                    } else {
                      setState(() {
                        userInput += buttons[index];
                        equalPressed();
                      });
                    }

                  },
                  buttonText: buttons[index],
                  color: Colors.blue,
                  textColor: Colors.white,
                );
              }

              /// + Button
              else if (buttons[index] == '+') {
                return MyButton(
                  onTap: () {
                    var isFirstOperatorSymbol = false;
                    if (userInput.isEmpty) {
                      if (_nodeCount.hasFocus) {
                        userInput = textFieldCountController.text;
                        userInput += '+1';
                        isFirstOperatorSymbol = true;
                      }
                      if (_nodeDiscount.hasFocus) {
                        userInput = textFieldDiscountController.text;
                        userInput += '+1';
                        isFirstOperatorSymbol = true;
                      }
                      if (_nodePrice.hasFocus) {
                        userInput = textFieldPriceController.text;
                        userInput += '+1';
                        isFirstOperatorSymbol = true;
                      }
                      setState(() {
                        equalPressed();
                        if (isFirstOperatorSymbol){
                          userInput = '';
                        }
                      });
                    } else {
                      setState(() {
                        userInput += buttons[index];
                        equalPressed();
                      });
                    }

                  },
                  buttonText: buttons[index],
                  color: Colors.blue,
                  textColor: Colors.white,
                );
              }

              ///  other buttons
              else {
                return MyButton(
                  onTap: () {
                    if (isOperator(buttons[index])){
                      if(userInput.isEmpty){
                        if (_nodeCount.hasFocus) {
                          userInput = textFieldCountController.text;
                        }
                        if (_nodeDiscount.hasFocus) {
                          userInput = textFieldDiscountController.text;
                        }
                        if (_nodePrice.hasFocus) {
                          userInput = textFieldPriceController.text;
                        }
                      }
                    }
                    setState(() {
                      userInput += buttons[index];
                      equalPressed();
                    });
                  },
                  buttonText: buttons[index],
                  color:
                      isOperator(buttons[index]) ? Colors.blue[100] : Colors.blue[50],
                  textColor:
                      isOperator(buttons[index]) ? Colors.black : Colors.black,
                );
              }
            }),
      ),
    );
  }
}

// creating Stateless Widget for buttons
class MyButton extends StatelessWidget {
  // declaring variables
  final color;
  final Color textColor;
  final String buttonText;
  final onTap;

  //Constructor
  const MyButton(
      {Key? key,
        required this.color,
        required this.textColor,
        required this.buttonText,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            color: color,
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
