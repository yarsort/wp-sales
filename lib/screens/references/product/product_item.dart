import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/db_ref_product.dart';
import 'package:wp_sales/models/ref_product.dart';
import 'package:wp_sales/screens/references/unit/unit_selection.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenProductItem extends StatefulWidget {
  final Product productItem;

  const ScreenProductItem({Key? key, required this.productItem})
      : super(key: key);

  @override
  _ScreenProductItemState createState() => _ScreenProductItemState();
}

class _ScreenProductItemState extends State<ScreenProductItem> {

  /// Поле ввода: Name
  TextEditingController textFieldNameController = TextEditingController();

  /// Поле ввода: VendorCode
  TextEditingController textFieldVendorCodeController = TextEditingController();

  /// Поле ввода: NameUnit
  TextEditingController textFieldNameUnitController = TextEditingController();

  /// Поле ввода: Barcode
  TextEditingController textFieldBarcodeController = TextEditingController();

  /// Поле ввода: Comment
  TextEditingController textFieldCommentController = TextEditingController();

  /// Поле ввода: UID
  TextEditingController textFieldUIDController = TextEditingController();

  /// Поле ввода: Code
  TextEditingController textFieldCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Товар'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Главная'),
              Tab(text: 'Служебные'),
            ],
          ),
        ),
        //drawer: const MainDrawer(),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listHeaderOrder(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listService(),
              ],
            ),
          ],
        ),

      ),
    );
  }

  renewItem() {
    if (widget.productItem.uid == '') {
      widget.productItem.uid = const Uuid().v4();
    }

    textFieldNameController.text = widget.productItem.name;
    textFieldVendorCodeController.text = widget.productItem.vendorCode;
    textFieldNameUnitController.text = widget.productItem.nameUnit;
    textFieldBarcodeController.text = widget.productItem.barcode;
    textFieldCommentController.text = widget.productItem.comment;

    // Технические данные
    textFieldUIDController.text = widget.productItem.uid;
    textFieldCodeController.text = widget.productItem.code;

    setState(() {});
  }

  saveItem() async {
    try {
      widget.productItem.name = textFieldNameController.text;
      widget.productItem.vendorCode = textFieldVendorCodeController.text;
      widget.productItem.barcode = textFieldBarcodeController.text;
      widget.productItem.comment = textFieldCommentController.text;

      if (widget.productItem.id != 0) {
        await dbUpdateProduct(widget.productItem);
        return true;
      } else {
        await dbCreateProduct(widget.productItem);
        return true;
      }
    } on Exception catch (error) {
      debugPrint('Ошибка записи!');
      debugPrint(error.toString());
      return false;
    }
  }

  deleteItem() async {
    try {
      if (widget.productItem.id != 0) {

        /// Обновим объект в базе данных
        await dbDeleteProduct(widget.productItem.id);
        return true;
      } else {
        return true; // Значит, что запись вообще не была записана!
      }
    } on Exception catch (error) {
      debugPrint('Ошибка удаления!');
      debugPrint(error.toString());
      return false;
    }
  }

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:Text(textMessage),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  listHeaderOrder() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
      child: Column(
        children: [
          /// Name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
            child: TextField(
              controller: textFieldNameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Наименование',
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        textFieldNameController.text = '';
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// VendorCode
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: TextField(
              controller: textFieldVendorCodeController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Артикул',
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        textFieldVendorCodeController.text = '';
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Unit
          TextFieldWithText(
              textLabel: 'Единица измерения',
              textEditingController: textFieldNameUnitController,
              onPressedEditIcon: Icons.dashboard_customize,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.productItem.nameUnit = '';
                widget.productItem.uidUnit = '';
                textFieldNameUnitController.text = '';
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenUnitSelection(
                          productItem: widget.productItem)));

                textFieldNameUnitController.text = widget.productItem.nameUnit;

                setState(() {});
              }),

          /// Barcode
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: textFieldBarcodeController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Штрихкод',
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        textFieldBarcodeController.text = '';
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Comment
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              controller: textFieldCommentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Комментарий',
              ),
            ),
          ),

          /// Buttons Записать / Отменить
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// Записать запись
                SizedBox(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 49) / 2,
                  child: ElevatedButton(
                      onPressed: () async {
                        var result = await saveItem();
                        if (result) {
                          showMessage('Запись сохранена!');
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.update, color: Colors.white),
                          SizedBox(width: 14),
                          Text('Записать')
                        ],
                      )),
                ),

                const SizedBox(
                  width: 14,
                ),

                /// Отменить запись
                SizedBox(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 35) / 2,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red)),
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 14),
                          Text('Отменить'),
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

  listService() {
    return Column(
      children: [
        /// Поле ввода: UID
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 21, 14, 7),
          child: TextField(
            controller: textFieldUIDController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'UID товара',
            ),
          ),
        ),

        /// Поле ввода: Code
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldCodeController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Код',
            ),
          ),
        ),

        /// Buttons Удалить
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// Удалить запись
              SizedBox(
                height: 40,
                width: (MediaQuery.of(context).size.width - 28),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey)),
                    onPressed: () async {
                      var result = await deleteItem();
                      if (result) {
                        showMessage('Запись удалена!');
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 14),
                        Text('Удалить'),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
