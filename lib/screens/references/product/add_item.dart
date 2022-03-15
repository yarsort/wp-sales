import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/ref_price.dart';
import 'package:wp_sales/models/ref_product.dart';
import 'package:wp_sales/models/ref_warehouse.dart';
import 'package:wp_sales/system/system.dart';

class ScreenAddItem extends StatefulWidget {
  final List<ItemOrderCustomer> listItemDoc;
  final OrderCustomer orderCustomer;
  final Product product;

  const ScreenAddItem(
      {Key? key,
      required this.listItemDoc,
      required this.orderCustomer,
      required this.product})
      : super(key: key);

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
  TextEditingController textFieldWarehouseController =
      TextEditingController();

  /// Поле ввода: Price name
  TextEditingController textFieldPriceNameController =
      TextEditingController();
  TextEditingController textFieldPriceController =
      TextEditingController();

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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                  child: TextField(
                    readOnly: true,
                    controller: textFieldPriceController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                      labelText: 'Цена (${widget.orderCustomer.nameCurrency})',
                    ),
                  ),
                ),
              ),
              /// Warehouse
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
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
            ],
          ),

          /// Count
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              onSubmitted: (value) {
                if (value.trim() == '') {
                  textFieldCountController.text = doubleThreeToString(0.000);
                  return;
                }
                var newValue =
                    double.parse(doubleThreeToString(double.parse(value)));
                textFieldCountController.text = doubleThreeToString(newValue);
              },
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
              controller: textFieldCountController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))
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
                      },
                      icon: const Icon(Icons.add, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () {
                        minusCountOnForm();
                      },
                      icon: const Icon(Icons.remove, color: Colors.blue),
                      //icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Buttons: Cancel & Add
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// Отменить добавление товара
                SizedBox(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 49) / 2,
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
                        children: const [
                          Icon(Icons.undo, color: Colors.white),
                          SizedBox(width: 14),
                          Text('Отменить')
                        ],
                      )),
                ),

                const SizedBox(
                  width: 14,
                ),

                /// Добавить товар
                SizedBox(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 35) / 2,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      onPressed: () async {
                        // Добавим товар в заказ
                        addProductToOrderCustomer();

                        // Закроем окно
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 14),
                          Text('Добавить'),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  renewItem() async {
    textFieldProductNameController.text = widget.product.name;
    textFieldPriceNameController.text = widget.orderCustomer.namePrice;
    textFieldWarehouseNameController.text = widget.orderCustomer.nameWarehouse;

    // Остаток на складе.
    var countOnWarehouse = await DatabaseHelper.instance.readProductRest(uidWarehouse: widget.orderCustomer.uidWarehouse, uidProduct: widget.product.uid);
    textFieldWarehouseController.text = doubleThreeToString(countOnWarehouse);

    // Цена товара.
    var price = await DatabaseHelper.instance.readProductPrice(uidPrice: widget.orderCustomer.uidPrice, uidProduct: widget.product.uid);
    textFieldPriceController.text = doubleToString(price);

    // Подставим количесто из заказа, если оно есть.
    // Найдем индекс строки товара в заказе по товару который добавляем.
    var indexItem = widget.listItemDoc.indexWhere(
            (element) => element.uid == widget.product.uid);

    // Если нашли товар в списке товаров заказа.
    if (indexItem >= 0) {

      // Подставим из заказа
      var itemList = widget.listItemDoc[indexItem];
      textFieldCountController.text = doubleThreeToString(itemList.count);

    } else {

      // Подставим 1 единицу
      textFieldCountController.text = doubleThreeToString(1.0);
    }
  }

  plusCountOnForm() {
    if (textFieldCountController.text.trim() == '') {
      textFieldCountController.text = doubleThreeToString(1.0);
      return;
    }

    var value = double.parse(doubleThreeToString(
        double.parse(textFieldCountController.text)));
    value = value + 1.0;

    if (value < 0.000) {
      value = 0.000;
    }
    textFieldCountController.text =
        doubleThreeToString(value);
  }

  minusCountOnForm() {
    var value = double.parse(doubleThreeToString(
        double.parse(textFieldCountController.text)));
    value = value - 1.0;
    if (value <= 0.000) {
      value = 0.000;
    }
    textFieldCountController.text =
        doubleThreeToString(value);
  }

  addProductToOrderCustomer() {
    // Получим количество товара, которое добавляем
    var value = double.parse(doubleThreeToString(
        double.parse(textFieldCountController.text)));

    // Найдем индекс строки товара в заказе по товару который добавляем
    var indexItem = widget.listItemDoc.indexWhere(
            (element) => element.uid == widget.product.uid);

    // Если нашли товар в списке товаров заказа
    if (indexItem >= 0) {

      var itemList = widget.listItemDoc[indexItem];
      itemList.count = value;
      itemList.sum = itemList.price * itemList.count;

    } else {

      // Добавим новый товар в заказ
      var priceProduct = double.parse(doubleThreeToString(
          double.parse(textFieldPriceController.text)));

      ItemOrderCustomer itemOrderCustomer =
      ItemOrderCustomer(
          id: 0,
          idOrderCustomer: widget.orderCustomer.id,
          uid: widget.product.uid,
          name: widget.product.name,
          uidUnit: widget.product.uidUnit,
          nameUnit: widget.product.nameUnit,
          count: value,
          price: priceProduct,
          discount: 0.0,
          sum: priceProduct * value);

      widget.listItemDoc.add(itemOrderCustomer);
    }

    OrderCustomer().allSum(widget.orderCustomer, widget.listItemDoc);
    OrderCustomer().allCount(widget.orderCustomer, widget.listItemDoc);
  }
}
