import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/import/import_screens.dart';
import 'package:wp_sales/screens/documents/incoming_cash_order/incoming_cash_order_item.dart';
import 'package:wp_sales/screens/documents/return_order_customer/return_order_customer_item.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenContractItem extends StatefulWidget {
  final Contract contractItem;

  const ScreenContractItem({Key? key, required this.contractItem})
      : super(key: key);

  @override
  _ScreenContractItemState createState() => _ScreenContractItemState();
}

class _ScreenContractItemState extends State<ScreenContractItem> {
  List<AccumPartnerDept> listAccumPartnerDept = [];

  bool deniedSale = false;
  bool deniedReturn = false;

  bool monday = false;
  bool tuesday = false;
  bool wednesday = false;
  bool thursday = false;
  bool friday = false;
  bool saturday = false;
  bool sunday = false;

  /// Поле ввода: Organization
  TextEditingController textFieldOrganizationController =
      TextEditingController();

  /// Поле ввода: Partner
  TextEditingController textFieldPartnerController = TextEditingController();

  /// Поле ввода: Name
  TextEditingController textFieldNameController = TextEditingController();

  /// Поле ввода: Phone
  TextEditingController textFieldPhoneController = TextEditingController();

  /// Поле ввода: Address
  TextEditingController textFieldAddressController = TextEditingController();

  /// Поле ввода: Date of payment
  TextEditingController textFieldSchedulePaymentController =
      TextEditingController();

  /// Поле ввода: Баланс контракта или заказа покупателя
  TextEditingController textFieldBalanceController = TextEditingController();

  /// Поле ввода: Баланс контракта или заказа покупателя
  TextEditingController textFieldBalanceForPaymentController =
      TextEditingController();

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
    readBalance();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Контракт партнера'),
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
              Tab(text: 'К оплате'),
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
                /// Balance of contract
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 21, 14, 7),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: TextField(
                            readOnly: true,
                            controller: textFieldBalanceController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(
                                color: Colors.blueGrey,
                              ),
                              labelText: 'Баланс',
                            ),
                          )),
                      const SizedBox(width: 14),
                      Expanded(
                          flex: 1,
                          child: TextField(
                            readOnly: true,
                            controller: textFieldBalanceForPaymentController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(
                                color: Colors.blueGrey,
                              ),
                              labelText: 'Баланс (к оплате)',
                            ),
                          )),
                    ],
                  ),
                ),
                listOrderCustomer(),
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
    if (widget.contractItem.uid == '') {
      widget.contractItem.uid = const Uuid().v4();
    }

    Organization organization =
        await dbReadOrganizationUID(widget.contractItem.uidOrganization);
    textFieldOrganizationController.text = organization.name;

    textFieldPartnerController.text = widget.contractItem.namePartner;
    textFieldNameController.text = widget.contractItem.name;
    textFieldPhoneController.text = widget.contractItem.phone;
    textFieldAddressController.text = widget.contractItem.address;
    textFieldSchedulePaymentController.text =
        widget.contractItem.schedulePayment.toString();
    textFieldCommentController.text = widget.contractItem.comment;

    // Технические данные
    textFieldUIDController.text = widget.contractItem.uid;
    textFieldCodeController.text = widget.contractItem.code;

    deniedSale = widget.contractItem.deniedSale;
    deniedReturn = widget.contractItem.deniedReturn;

    monday = widget.contractItem.visitDayOfWeek.contains('1');
    tuesday = widget.contractItem.visitDayOfWeek.contains('2');
    wednesday = widget.contractItem.visitDayOfWeek.contains('3');
    thursday = widget.contractItem.visitDayOfWeek.contains('4');
    friday = widget.contractItem.visitDayOfWeek.contains('5');
    saturday = widget.contractItem.visitDayOfWeek.contains('6');
    sunday = widget.contractItem.visitDayOfWeek.contains('7');

    setState(() {});
  }

  readBalance() async {
    listAccumPartnerDept.clear();
    List<AccumPartnerDept> listDebts = await dbReadAccumPartnerDeptByContract(
        uidContract: widget.contractItem.uid);

    /// Сортировка списка: сначала старые документы
    listDebts.sort((a, b) => a.dateDoc.compareTo(b.dateDoc));

    // Свернем долги по договору
    for (var itemDebts in listDebts) {
      // Ищем контракт в списке и увеличиваем баланс по каждому из них
      var indexItem = listAccumPartnerDept.indexWhere((element) =>
          element.numberDoc == itemDebts.numberDoc);

      // Если нашли долг в списке отобранных, иначе добавим новую апись в список
      if (indexItem >= 0) {
        var itemList = listAccumPartnerDept[indexItem];
        itemList.balance = itemList.balance + itemDebts.balance;
        itemList.balanceForPayment =
            itemList.balanceForPayment + itemDebts.balanceForPayment;
      } else {
        listAccumPartnerDept.add(itemDebts);
      }
    }

    // Получить баланс заказа
    Map debts = await dbReadSumAccumPartnerDeptByContract(
        uidContract: widget.contractItem.uid);

    // Запись в реквизиты
    double balance = debts['balance'];
    double balanceForPayment = debts['balanceForPayment'];

    // Запись в реквизиты
    widget.contractItem.balance = balance;
    widget.contractItem.balanceForPayment = balanceForPayment;

    // Запись в реквизиты
    textFieldBalanceController.text = doubleToString(balance);
    textFieldBalanceForPaymentController.text =
        doubleToString(balanceForPayment);

    setState(() {});
  }

  saveItem() async {
    try {
      widget.contractItem.name = textFieldNameController.text;
      widget.contractItem.phone = textFieldPhoneController.text;
      widget.contractItem.address = textFieldAddressController.text;
      widget.contractItem.schedulePayment =
          int.parse(textFieldSchedulePaymentController.text);
      widget.contractItem.comment = textFieldCommentController.text;
      widget.contractItem.dateEdit = DateTime.now();

      widget.contractItem.deniedSale = deniedSale;
      widget.contractItem.deniedReturn = deniedReturn;

      // Дни недели для посещения партнера по договору
      String dayOfTheWeek = '';
      dayOfTheWeek = dayOfTheWeek + (monday ? '1' : '');
      dayOfTheWeek = dayOfTheWeek + (tuesday ? '2' : '');
      dayOfTheWeek = dayOfTheWeek + (wednesday ? '3' : '');
      dayOfTheWeek = dayOfTheWeek + (thursday ? '4' : '');
      dayOfTheWeek = dayOfTheWeek + (friday ? '5' : '');
      dayOfTheWeek = dayOfTheWeek + (saturday ? '6' : '');
      dayOfTheWeek = dayOfTheWeek + (sunday ? '7' : '');
      widget.contractItem.visitDayOfWeek = dayOfTheWeek; // :)

      // Идентификатор записи
      if (widget.contractItem.id != 0) {
        await dbUpdateContract(widget.contractItem);
        return true;
      } else {
        await dbCreateContract(widget.contractItem);
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
      if (widget.contractItem.id != 0) {
        /// Обновим объект в базе данных
        await dbDeleteContract(widget.contractItem.id);
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
                widget.contractItem.uidOrganization = '';
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
                widget.contractItem.uidOrganization =
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
                widget.contractItem.namePartner = '';
                widget.contractItem.uidPartner = '';
                textFieldPartnerController.text = '';
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPartnerSelection(
                              contract: widget.contractItem,
                              orderCustomer: null,
                            )));

                textFieldPartnerController.text =
                    widget.contractItem.namePartner;

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

          /// Phone
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              controller: textFieldPhoneController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Телефон',
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        textFieldPhoneController.text = '';
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

          /// SchedulePayment
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              controller: textFieldSchedulePaymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Отсрочка платежа (дней)',
              ),
            ),
          ),

          /// Balance of contract
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: TextField(
                      readOnly: true,
                      controller: textFieldBalanceController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Colors.blueGrey,
                        ),
                        labelText: 'Баланс',
                      ),
                    )),
                const SizedBox(width: 14),
                Expanded(
                    flex: 1,
                    child: TextField(
                      readOnly: true,
                      controller: textFieldBalanceForPaymentController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Colors.blueGrey,
                        ),
                        labelText: 'Баланс (к оплате)',
                      ),
                    )),
              ],
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

          /// Запреты и разрешения
          nameGroup(nameGroup: 'Запреты по контракту'),

          /// Продажа товаров запрещена
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedSale,
                  onChanged: (value) {
                    setState(() {
                      deniedSale = !deniedSale;
                    });
                  },
                ),
                const Flexible(child: Text('Продажа товаров запрещена!')),
              ],
            ),
          ),

          /// Возврат товаров запрещен
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedReturn,
                  onChanged: (value) {
                    setState(() {
                      deniedReturn = !deniedReturn;
                    });
                  },
                ),
                const Flexible(child: Text('Возврат товаров запрещен!')),
              ],
            ),
          ),

          nameGroup(nameGroup: 'Дни посещения партнера'),

          /// ПН, ВТ, СР, ЧТ
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Checkbox(
                        value: monday,
                        onChanged: (value) {
                          setState(() {
                            monday = !monday;
                          });
                        },
                      ),
                      const Flexible(child: Text('ПН')),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Checkbox(
                        value: tuesday,
                        onChanged: (value) {
                          setState(() {
                            tuesday = !tuesday;
                          });
                        },
                      ),
                      const Flexible(child: Text('ВТ')),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Checkbox(
                        value: wednesday,
                        onChanged: (value) {
                          setState(() {
                            wednesday = !wednesday;
                          });
                        },
                      ),
                      const Flexible(child: Text('СР')),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Checkbox(
                        value: thursday,
                        onChanged: (value) {
                          setState(() {
                            thursday = !thursday;
                          });
                        },
                      ),
                      const Flexible(child: Text('ЧТ')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// ПТ, СБ, ВС
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Checkbox(
                        value: friday,
                        onChanged: (value) {
                          setState(() {
                            friday = !friday;
                          });
                        },
                      ),
                      const Flexible(child: Text('ПТ')),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Checkbox(
                        value: saturday,
                        onChanged: (value) {
                          setState(() {
                            saturday = !saturday;
                          });
                        },
                      ),
                      const Flexible(
                          child: Text(
                        'СБ',
                        style: TextStyle(color: Colors.red),
                      )),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Checkbox(
                        value: sunday,
                        onChanged: (value) {
                          setState(() {
                            sunday = !sunday;
                          });
                        },
                      ),
                      const Flexible(
                          child: Text(
                        'ВС',
                        style: TextStyle(color: Colors.red),
                      )),
                    ],
                  ),
                ),
              ],
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

  /// Вкладка Заказы

  listOrderCustomer() {
    return ColumnListViewBuilder(
        itemCount: listAccumPartnerDept.length,
        itemBuilder: (context, index) {
          final itemDept = listAccumPartnerDept[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Card(
              elevation: 2,
              child: PopupMenuButton<String>(
                onSelected: (String value) async {
                  // Создадим подчиненный документ возврата заказа
                  if (value == 'return_order_customer') {
                    // Создадим объект
                    var newReturnOrderCustomer = ReturnOrderCustomer();
                    newReturnOrderCustomer.uidOrganization =
                        itemDept.uidOrganization;
                    newReturnOrderCustomer.uidPartner = itemDept.uidPartner;
                    newReturnOrderCustomer.uidContract = itemDept.uidContract;

                    newReturnOrderCustomer.uidParent = itemDept.uidDoc;
                    newReturnOrderCustomer.nameParent =
                        itemDept.nameDoc + ' № ' + itemDept.numberDoc;
                    newReturnOrderCustomer.uidSettlementDocument =
                        itemDept.uidSettlementDocument;
                    newReturnOrderCustomer.nameSettlementDocument =
                        itemDept.nameSettlementDocument;

                    // if (itemDept.uidDoc.isEmpty) {
                    //   newReturnOrderCustomer.uidParent =
                    //       itemDept.uidSettlementDocument;
                    //   newReturnOrderCustomer.nameParent =
                    //       itemDept.nameSettlementDocument +
                    //           ' № ' +
                    //           itemDept.numberDoc;
                    // }

                    // Откроем форму документа
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenItemReturnOrderCustomer(
                            returnOrderCustomer: newReturnOrderCustomer),
                      ),
                    );
                  }

                  // Создадим подчиненный документ оплаты заказа
                  if (value == 'incoming_cash_order') {
                    // Создадим объект
                    var newIncomingCashOrder = IncomingCashOrder();
                    newIncomingCashOrder.uidOrganization =
                        itemDept.uidOrganization;
                    newIncomingCashOrder.uidPartner = itemDept.uidPartner;
                    newIncomingCashOrder.uidContract = itemDept.uidContract;
                    newIncomingCashOrder.uidParent = itemDept.uidDoc;

                    newIncomingCashOrder.uidParent = itemDept.uidDoc;
                    newIncomingCashOrder.nameParent =
                        itemDept.nameDoc + ' № ' + itemDept.numberDoc;
                    newIncomingCashOrder.uidSettlementDocument =
                        itemDept.uidSettlementDocument;
                    newIncomingCashOrder.nameSettlementDocument =
                        itemDept.nameSettlementDocument;

                    // if (itemDept.uidDoc.isEmpty) {
                    //   newIncomingCashOrder.uidParent =
                    //       itemDept.uidSettlementDocument;
                    //   newIncomingCashOrder.nameParent =
                    //       itemDept.nameSettlementDocument +
                    //           ' № ' +
                    //           itemDept.numberDoc;
                    // }

                    if (itemDept.balance > 0) {
                      if (itemDept.balanceForPayment > 0) {
                        newIncomingCashOrder.sum = itemDept.balanceForPayment;
                      } else {
                        newIncomingCashOrder.sum = itemDept.balance;
                      }
                    } else {
                      showMessage(
                          'Сумма баланса равна или меньше ноля!', context);
                      return;
                    }

                    // Откроем форму документа
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenItemIncomingCashOrder(
                            incomingCashOrder: newIncomingCashOrder),
                      ),
                    );
                  }

                  // Обновим список баланса после создания документа, если создание завершено
                  readBalance();
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'return_order_customer',
                    child: Row(children: const [
                      Icon(
                        Icons.undo,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Возврат заказа')
                    ]),
                  ),
                  PopupMenuItem<String>(
                    value: 'incoming_cash_order',
                    child: Row(
                      children: const [
                        Icon(
                          Icons.payment,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Оплата заказа'),
                      ],
                    ),
                  ),
                ],
                child: ListTile(
                  title: itemDept.nameDoc != ''
                      ? Text(itemDept.nameDoc)
                      : const Text('Нет данных заказа'),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Row(children: [
                        Flexible(
                            child: Text(itemDept.nameSettlementDocument +
                                ' от ' +
                                shortDateToString(itemDept.dateDoc))),
                      ]),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Flexible(
                              child: Text(widget.contractItem.namePartner)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.home, color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Flexible(
                              child: widget.contractItem.address != ''
                                  ? Text(widget.contractItem.address)
                                  : const Text('Адрес не указан')),
                        ],
                      ),
                      Row(children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Flexible(
                                      child: widget.contractItem.phone != ''
                                          ? Text(widget.contractItem.phone)
                                          : const Text('Телефон не указан')),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.schedule,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(widget.contractItem.schedulePayment
                                          .toString() +
                                      ' дня(ей) отсрочки'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(itemDept.balance)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(
                                      itemDept.balanceForPayment)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
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
