import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/models/ref_cashbox.dart';

class ScreenCashboxItem extends StatefulWidget {
  final Cashbox cashboxItem;

  const ScreenCashboxItem({Key? key, required this.cashboxItem})
      : super(key: key);

  @override
  _ScreenCashboxItemState createState() => _ScreenCashboxItemState();
}

class _ScreenCashboxItemState extends State<ScreenCashboxItem> {

  /// Поле ввода: Name
  TextEditingController textFieldNameController = TextEditingController();

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
          title: const Text('Касса'),
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

  renewItem() async {

    if (widget.cashboxItem.uid == '') {
      widget.cashboxItem.uid = const Uuid().v4();
    }

    textFieldNameController.text = widget.cashboxItem.name;
    textFieldCommentController.text = widget.cashboxItem.comment;

    // Технические данные
    textFieldUIDController.text = widget.cashboxItem.uid;
    textFieldCodeController.text = widget.cashboxItem.code;

    setState(() {});
  }

  saveItem() async {
    try {
      widget.cashboxItem.name = textFieldNameController.text;
      widget.cashboxItem.comment = textFieldCommentController.text;

      if (widget.cashboxItem.id != 0) {
        await dbUpdateCashbox(widget.cashboxItem);
        return true;
      } else {
        await dbCreateCashbox(widget.cashboxItem);
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
      if (widget.cashboxItem.id != 0) {

        /// Обновим объект в базе данных
        await dbDeleteCashbox(widget.cashboxItem.id);
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

    return Column(
      children: [
        /// Name
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(

            controller: textFieldNameController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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

        /// Comment
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldCommentController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
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

  listDocuments() {
    return Container();
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
              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'UID',
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
              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
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
