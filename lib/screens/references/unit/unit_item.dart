import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/unit.dart';
import 'package:wp_sales/system/system.dart';

class ScreenUnitItem extends StatefulWidget {
  final Unit unitItem;

  const ScreenUnitItem({Key? key, required this.unitItem})
      : super(key: key);

  @override
  _ScreenUnitItemState createState() => _ScreenUnitItemState();
}

class _ScreenUnitItemState extends State<ScreenUnitItem> {

  /// Поле ввода: Name
  TextEditingController textFieldNameController = TextEditingController();

  /// Поле ввода: Multiplicity
  TextEditingController textFieldMultiplicityController = TextEditingController();

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
          title: const Text('Единица измерения'),
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
    if (widget.unitItem.uid == '') {
      widget.unitItem.uid = const Uuid().v4();
    }

    if (widget.unitItem.multiplicity == 0.0) {
      widget.unitItem.multiplicity = 1.0;
    }

    textFieldNameController.text = widget.unitItem.name;
    textFieldCommentController.text = widget.unitItem.comment;
    textFieldMultiplicityController.text = doubleThreeToString(widget.unitItem.multiplicity);

    // Технические данные
    textFieldUIDController.text = widget.unitItem.uid;
    textFieldCodeController.text = widget.unitItem.code;

    setState(() {});
  }

  saveItem() async {
    try {
      widget.unitItem.name = textFieldNameController.text;
      widget.unitItem.comment = textFieldCommentController.text;
      widget.unitItem.multiplicity = double.parse(textFieldMultiplicityController.text);

      if (widget.unitItem.multiplicity == 0.0) {
        widget.unitItem.multiplicity = 1.0;
      }

      if (widget.unitItem.id != 0) {
        await DatabaseHelper.instance.updateUnit(widget.unitItem);
        return true;
      } else {
        await DatabaseHelper.instance.createUnit(widget.unitItem);
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
      if (widget.unitItem.id != 0) {

        /// Обновим объект в базе данных
        await DatabaseHelper.instance.deleteUnit(widget.unitItem.id);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
      child: Column(
        children: [
          /// Name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
            child: TextField(
              onChanged: (value) {
                widget.unitItem.name = textFieldNameController.text;
              },
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

          /// Multiplicity
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              controller: textFieldMultiplicityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Кратность',
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
                          Icon(Icons.undo, color: Colors.white),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
      child: Column(
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
      ),
    );
  }
}
