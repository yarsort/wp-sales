import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/product.dart';

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
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.filter_list,
                    size: 26.0,
                  ),
                )),
          ],
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

    textFieldNameController.text = widget.productItem.name;
    textFieldVendorCodeController.text = widget.productItem.vendorCode;
    textFieldNameUnitController.text = widget.productItem.nameUnit;
    textFieldBarcodeController.text = widget.productItem.barcode;
    textFieldCommentController.text = widget.productItem.comment;

    // Технические данные
    textFieldUIDController.text = widget.productItem.uid;
    textFieldCodeController.text = widget.productItem.code;

    if (widget.productItem.uid == '') {
      widget.productItem.uid == const Uuid().v4();
    }

    setState(() {});
  }

  saveItem() async {
    try {
      if (widget.productItem.id != 0) {
        await DatabaseHelper.instance.updateProduct(widget.productItem);
        return true;
      } else {
        await DatabaseHelper.instance.createProduct(widget.productItem);
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
        await DatabaseHelper.instance.deleteProduct(widget.productItem.id);
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
      ),
    );
  }

  listHeaderOrder() {

    return Column(
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
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
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

        /// NameUnit
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            controller: textFieldNameUnitController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Единица измерения',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      textFieldNameUnitController.text = '';
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Barcode
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
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
                height: 40,
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
                height: 40,
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
    );
  }

  listService() {
    return Column(
      children: [
        /// Поле ввода: UID
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            controller: textFieldUIDController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'UID записи в 1С',
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
              labelText: 'Код в 1С',
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
