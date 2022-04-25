import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/import/import_screens.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenStoreItem extends StatefulWidget {
  final Store storeItem;

  const ScreenStoreItem({Key? key, required this.storeItem})
      : super(key: key);

  @override
  _ScreenStoreItemState createState() => _ScreenStoreItemState();
}

class _ScreenStoreItemState extends State<ScreenStoreItem> {
  List<AccumPartnerDept> listAccumPartnerDept = [];

  /// Поле ввода: Organization
  TextEditingController textFieldOrganizationController =
      TextEditingController();

  /// Поле ввода: Partner
  TextEditingController textFieldPartnerController = TextEditingController();

  /// Поле ввода: Contract
  TextEditingController textFieldContractController = TextEditingController();

  /// Поле ввода: Store
  TextEditingController textFieldStoreController = TextEditingController();

  /// Поле ввода: Name
  TextEditingController textFieldNameController = TextEditingController();
  
  /// Поле ввода: Address
  TextEditingController textFieldAddressController = TextEditingController();

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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Магазин партнера'),
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
    if (widget.storeItem.uid == '') {
      widget.storeItem.uid = const Uuid().v4();
    }

    textFieldNameController.text = widget.storeItem.name;

    Organization organization =
        await dbReadOrganizationUID(widget.storeItem.uidOrganization);
    textFieldOrganizationController.text = organization.name;

    Partner partner =
        await dbReadPartnerUID(widget.storeItem.uidPartner);
    textFieldPartnerController.text = partner.name;

    Contract contract =
      await dbReadContractUID(widget.storeItem.uidContract);
    textFieldContractController.text = contract.name;

    textFieldAddressController.text = widget.storeItem.address;
    textFieldCommentController.text = widget.storeItem.comment;

    // Технические данные
    textFieldUIDController.text = widget.storeItem.uid;
    textFieldCodeController.text = widget.storeItem.code;

    setState(() {});
  }

  saveItem() async {
    try {
      widget.storeItem.name = textFieldNameController.text;
      widget.storeItem.address = textFieldAddressController.text;
      widget.storeItem.comment = textFieldCommentController.text;
      widget.storeItem.dateEdit = DateTime.now();

      // Идентификатор записи
      if (widget.storeItem.id != 0) {
        await dbUpdateStore(widget.storeItem);
        return true;
      } else {
        await dbCreateStore(widget.storeItem);
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
      if (widget.storeItem.id != 0) {
        /// Обновим объект в базе данных
        await dbDeleteStore(widget.storeItem.id);
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

  /// Вкладка Шапка

  listHeaderOrder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: Column(
        children: [
          /// Organization
          TextFieldWithText(
              textLabel: 'Организация',
              textEditingController: textFieldOrganizationController,
              onPressedEditIcon: Icons.person,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.storeItem.uidOrganization = '';
                textFieldOrganizationController.text = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenOrganizationSelection(
                              orderCustomer: orderCustomer,
                            )));
                widget.storeItem.uidOrganization =
                    orderCustomer.uidOrganization;
                textFieldOrganizationController.text =
                    orderCustomer.nameOrganization;

                setState(() {});
              }),

          /// Partner
          TextFieldWithText(
              textLabel: 'Партнер',
              textEditingController: textFieldPartnerController,
              onPressedEditIcon: Icons.people,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.storeItem.uidPartner = '';
                textFieldPartnerController.text = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPartnerSelection(
                          orderCustomer: orderCustomer,
                            )));
                widget.storeItem.uidPartner = orderCustomer.uidPartner;
                textFieldPartnerController.text = orderCustomer.namePartner;

                setState(() {});
              }),

          /// Contract
          TextFieldWithText(
              textLabel: 'Контракт',
              textEditingController: textFieldContractController,
              onPressedEditIcon: Icons.people,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.storeItem.uidContract = '';
                textFieldContractController.text = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                orderCustomer.uidPartner = widget.storeItem.uidPartner;

                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenContractSelection(
                          orderCustomer: orderCustomer,
                        )));
                widget.storeItem.uidContract = orderCustomer.uidContract;
                textFieldContractController.text = orderCustomer.nameContract;

                setState(() {});
              }),

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

          /// Address
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              controller: textFieldAddressController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Адрес партнера',
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        textFieldAddressController.text = '';
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
                          showMessage('Запись сохранена!', context);
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

                /// Удалить запись
                SizedBox(
                  height: 40,
                  width: (MediaQuery.of(context).size.width - 35) / 2,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
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

  nameGroup({String nameGroup = '', bool hideDivider = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameGroup,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          if (!hideDivider) const Divider(),
        ],
      ),
    );
  }

  /// Вкладка Служебные

  listService() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: Column(
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
                labelText: 'UID договора (контракта)',
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
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey)),
                      onPressed: () async {
                        var result = await deleteItem();
                        if (result) {
                          showMessage('Запись удалена!', context);
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
