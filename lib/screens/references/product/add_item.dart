import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/ref_price.dart';
import 'package:wp_sales/models/ref_product.dart';
import 'package:wp_sales/models/ref_warehouse.dart';
import 'package:wp_sales/system/system.dart';

class ScreenAddItem extends StatefulWidget {
  final List<ItemOrderCustomer> listItemDoc;
  final Price price;
  final Warehouse warehouse;
  final Product product;

  const ScreenAddItem(
      {Key? key,
      required this.listItemDoc,
      required this.price,
      required this.warehouse,
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

  /// Поле ввода: Price name
  TextEditingController textFieldPriceNameController = TextEditingController();

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
                labelText: 'Наименование',
              ),
            ),
          ),

          /// Price name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
            child: TextField(
              readOnly: true,
              controller: textFieldPriceNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Наименование',
              ),
            ),
          ),

          /// Warehouse name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
            child: TextField(
              readOnly: true,
              controller: textFieldWarehouseNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Наименование',
              ),
            ),
          ),

          /// Count
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
            child: TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: false),
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
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () {},
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
                  height: 40,
                  width: (MediaQuery.of(context).size.width - 49) / 2,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () async {
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
                  height: 40,
                  width: (MediaQuery.of(context).size.width - 35) / 2,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      onPressed: () async {},
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
    textFieldPriceNameController.text = widget.price.name;
    textFieldWarehouseNameController.text = widget.warehouse.name;
    textFieldCountController.text = '0.0';
  }
}
