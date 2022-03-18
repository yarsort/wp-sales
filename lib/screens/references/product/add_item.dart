import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wp_sales/db/db_accum_product_prices.dart';
import 'package:wp_sales/db/db_accum_product_rests.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/models/ref_product.dart';
import 'package:wp_sales/system/system.dart';

class ScreenAddItem extends StatefulWidget {
  final List<ItemReturnOrderCustomer>? listItemReturnDoc;
  final ReturnOrderCustomer? returnOrderCustomer;

  final List<ItemOrderCustomer>? listItemDoc;
  final OrderCustomer? orderCustomer;

  final Product product;

  const ScreenAddItem({
    Key? key,
    this.listItemReturnDoc,
    this.returnOrderCustomer,
    this.listItemDoc,
    this.orderCustomer,
    required this.product,
  }) : super(key: key);

  @override
  State<ScreenAddItem> createState() => _ScreenAddItemState();
}

class _ScreenAddItemState extends State<ScreenAddItem> {
  /// Поле ввода: Product name
  TextEditingController textFieldProductNameController =
      TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подбор товара'),
      ),
      body: ListView(
        children: [
          /// Product name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
            child: TextField(
              maxLines: 3,
              readOnly: true,
              controller: textFieldProductNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Товар',
              ),
            ),
          ),

          /// Price name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              readOnly: true,
              controller: textFieldPriceNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Тип цены',
              ),
            ),
          ),

          /// Warehouse name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              readOnly: true,
              controller: textFieldWarehouseNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Склад',
              ),
            ),
          ),

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
              /// Warehouse
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                  child: TextField(
                    readOnly: true,
                    controller: textFieldWarehouseController,
                    decoration: InputDecoration(
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
                    onChanged: (value) {
                      //calculateCount();
                    },
                    onSubmitted: (value) {
                      calculateCount();
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    controller: textFieldCountController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,3}'))
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                      labelText: 'Количество',
                      suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: const EdgeInsets.fromLTRB(10, 1, 1, 1),
                            onPressed: () {
                              plusCountOnForm();
                              calculateCount();
                            },
                            icon: const Icon(Icons.add, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () {
                              minusCountOnForm();
                              calculateCount();
                            },
                            icon: const Icon(Icons.remove, color: Colors.blue),
                            //icon: const Icon(Icons.delete, color: Colors.red),
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
                            addProductToOrderCustomer();
                          }

                          // Добавим товар в возврат товаров от покупателя
                          if (widget.returnOrderCustomer != null) {
                            addProductToReturnOrderCustomer();
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
    );
  }

  renewItem() async {
    textFieldProductNameController.text = widget.product.name;

    String uidWarehouse = '';
    String nameWarehouse = '';
    String uidPrice = '';
    String namePrice = '';

    if (widget.orderCustomer != null) {
      namePrice = widget.orderCustomer?.namePrice??'';
      uidPrice = widget.orderCustomer?.uidPrice??'';
      nameWarehouse = widget.orderCustomer?.nameWarehouse??'';
      uidWarehouse = widget.orderCustomer?.uidWarehouse??'';
    }

    textFieldPriceNameController.text = namePrice;
    textFieldWarehouseNameController.text = nameWarehouse;

    // Остаток на складе.
    var countOnWarehouse = await dbReadProductRest(
        uidWarehouse: uidWarehouse,
        uidProduct: widget.product.uid,
        uidProductCharacteristic: '');

    textFieldWarehouseController.text = doubleThreeToString(countOnWarehouse);

    // Цена товара.
    var price = await dbReadProductPrice(
        uidPrice: uidPrice,
        uidProduct: widget.product.uid,
        uidProductCharacteristic: '');

    textFieldPriceController.text = doubleToString(price);

    /// Заказ покупателя
    // Подставим количесто из заказа, если оно есть.
    if(widget.listItemDoc != null) {
      var indexItem = widget.listItemDoc?.indexWhere((element) => element.uid == widget.product.uid)??-1;
      // Если нашли товар в списке товаров заказа.
      if (indexItem >= 0) {

        // Подставим из заказа
        var itemList = widget.listItemDoc?[indexItem];
        double count = itemList?.count??0.0;
        double sum = price * (itemList?.count??0.0);

        textFieldCountController.text = doubleThreeToString(count);
        textFieldSumController.text = doubleToString(sum);

      } else {
        // Подставим 1 единицу
        textFieldCountController.text = doubleThreeToString(1.0);
        textFieldSumController.text = doubleToString(price);
      }
    }

    /// Возврат товаров от покупателя
    // Подставим количесто из заказа, если оно есть.
    if(widget.listItemReturnDoc != null) {
      var indexItem = widget.listItemReturnDoc?.indexWhere((element) => element.uid == widget.product.uid)??-1;
      // Если нашли товар в списке товаров заказа.
      if (indexItem >= 0) {

        // Подставим из заказа
        var itemList = widget.listItemReturnDoc?[indexItem];
        double count = itemList?.count??0.0;
        double sum = price * (itemList?.count??0.0);

        textFieldCountController.text = doubleThreeToString(count);
        textFieldSumController.text = doubleToString(sum);
      } else {
        // Подставим 1 единицу
        textFieldCountController.text = doubleThreeToString(1.0);
        textFieldSumController.text = doubleToString(price);
      }
    }
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

  addProductToOrderCustomer() {
    // Получим количество товара, которое добавляем
    var value = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));

    // Найдем индекс строки товара в заказе по товару который добавляем
    var indexItem = widget.listItemDoc?.indexWhere((element) => element.uid == widget.product.uid)??-1;

    // Если нашли товар в списке товаров заказа
    if (indexItem >= 0) {
      var itemList = widget.listItemDoc?[indexItem];
      itemList?.count = value;
      itemList?.sum = itemList.price * itemList.count;
    } else {
      // Добавим новый товар в заказ
      var priceProduct = double.parse(
          doubleThreeToString(double.parse(textFieldPriceController.text)));

      ItemOrderCustomer itemOrderCustomer = ItemOrderCustomer(
          id: 0,
          idOrderCustomer: widget.orderCustomer?.id??0,
          uid: widget.product.uid,
          name: widget.product.name,
          uidUnit: widget.product.uidUnit,
          nameUnit: widget.product.nameUnit,
          count: value,
          price: priceProduct,
          discount: 0.0,
          sum: priceProduct * value);

      widget.listItemDoc?.add(itemOrderCustomer);
    }
  }

  addProductToReturnOrderCustomer() {

    // Получим количество товара, которое добавляем
    var value = double.parse(
        doubleThreeToString(double.parse(textFieldCountController.text)));

    // Найдем индекс строки товара в заказе по товару который добавляем
    var indexItem = widget.listItemReturnDoc?.indexWhere((element) => element.uid == widget.product.uid)??-1;

    // Если нашли товар в списке товаров заказа
    if (indexItem >= 0) {
      var itemList = widget.listItemReturnDoc?[indexItem];
      itemList?.count = value;
      itemList?.sum = itemList.price * itemList.count;
    } else {
      // Добавим новый товар в заказ
      var priceProduct = double.parse(
          doubleThreeToString(double.parse(textFieldPriceController.text)));

      ItemReturnOrderCustomer itemReturnOrderCustomer = ItemReturnOrderCustomer(
          id: 0,
          idReturnOrderCustomer: widget.returnOrderCustomer?.id??0,
          uid: widget.product.uid,
          name: widget.product.name,
          uidUnit: widget.product.uidUnit,
          nameUnit: widget.product.nameUnit,
          count: value,
          price: priceProduct,
          discount: 0.0,
          sum: priceProduct * value);

      widget.listItemReturnDoc?.add(itemReturnOrderCustomer);
    }
  }
}
