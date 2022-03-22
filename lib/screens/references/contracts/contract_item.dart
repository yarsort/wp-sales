import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/models/accum_partner_depts.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/models/ref_contract.dart';
import 'package:wp_sales/screens/documents/incoming_cash_order/incoming_cash_order_item.dart';
import 'package:wp_sales/screens/documents/return_order_customer/return_order_customer_item.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/system/system.dart';
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

  /// Поле ввода: Partner
  TextEditingController textFieldPartnerController = TextEditingController();

  /// Поле ввода: Name
  TextEditingController textFieldNameController = TextEditingController();

  /// Поле ввода: Phone
  TextEditingController textFieldPhoneController = TextEditingController();

  /// Поле ввода: Address
  TextEditingController textFieldAddressController = TextEditingController();

  /// Поле ввода: Date of payment
  TextEditingController textFieldSchedulePaymentController = TextEditingController();

  /// Поле ввода: Баланс контракта или заказа покупателя
  TextEditingController textFieldBalanceController = TextEditingController();

  /// Поле ввода: Баланс контракта или заказа покупателя
  TextEditingController textFieldBalanceForPaymentController = TextEditingController();

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
          title: const Text('Договор партнера'),
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

    textFieldPartnerController.text = widget.contractItem.namePartner;
    textFieldNameController.text = widget.contractItem.name;
    textFieldPhoneController.text = widget.contractItem.phone;
    textFieldAddressController.text = widget.contractItem.address;
    textFieldSchedulePaymentController.text = widget.contractItem.schedulePayment.toString();
    textFieldCommentController.text = widget.contractItem.comment;

    // Технические данные
    textFieldUIDController.text = widget.contractItem.uid;
    textFieldCodeController.text = widget.contractItem.code;

    setState(() {});
  }

  readBalance() async {

    listAccumPartnerDept = await dbReadAccumPartnerDeptByContract(uidContract: widget.contractItem.uid);

    // Получить баланс заказа
    Map debts = await dbReadSumAccumPartnerDeptByContract(uidContract: widget.contractItem.uid);

    // Запись в реквизиты
    double balance = debts['balance'];
    double balanceForPayment = debts['balanceForPayment'];

    // Запись в реквизиты
    widget.contractItem.balance = balance;
    widget.contractItem.balanceForPayment = balanceForPayment;

    // Запись в реквизиты
    textFieldBalanceController.text = doubleToString(balance);
    textFieldBalanceForPaymentController.text = doubleToString(balanceForPayment);

    setState(() {});

  }

  saveItem() async {
    try {
      widget.contractItem.name = textFieldNameController.text;
      widget.contractItem.phone = textFieldPhoneController.text;
      widget.contractItem.address = textFieldAddressController.text;
      widget.contractItem.schedulePayment = int.parse(textFieldSchedulePaymentController.text);
      widget.contractItem.comment = textFieldCommentController.text;

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

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:Text(textMessage),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Вкладка Шапка

  listHeaderOrder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: Column(
        children: [

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
                            contract: widget.contractItem, orderCustomer: null,)));

                textFieldPartnerController.text = widget.contractItem.namePartner;

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

          /// Divider
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Divider(),
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

                /// Удалить запись
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
      ),
    );
  }

  /// Вкладка Заказы

  listOrderCustomer() {
    return ColumnBuilder(
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
                    newReturnOrderCustomer.uidOrganization = itemDept.uidOrganization;
                    newReturnOrderCustomer.uidPartner = itemDept.uidPartner;
                    newReturnOrderCustomer.uidContract = itemDept.uidContract;
                    newReturnOrderCustomer.uidParent = itemDept.uidDoc;
                    newReturnOrderCustomer.numberFrom1C = itemDept.numberDoc;

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
                    newIncomingCashOrder.uidOrganization = itemDept.uidOrganization;
                    newIncomingCashOrder.uidPartner = itemDept.uidPartner;
                    newIncomingCashOrder.uidContract = itemDept.uidContract;
                    newIncomingCashOrder.uidParent = itemDept.uidDoc;
                    newIncomingCashOrder.numberFrom1C = itemDept.numberDoc;

                    if (itemDept.balanceForPayment > 0) {
                      newIncomingCashOrder.sum = itemDept.balanceForPayment;
                    } else {
                      showMessage('Сумма баланса меньше ноля!');
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
                  title: Text(itemDept.nameDoc + ' № ' + itemDept.numberDoc),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Row(children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Flexible(
                                      child:
                                      Text(widget.contractItem.namePartner)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(widget.contractItem.phone),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.home,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Flexible(
                                      child: Text(widget.contractItem.address)),
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                      doubleToString(itemDept.balance)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(itemDept.balanceForPayment)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.schedule,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(widget.contractItem.schedulePayment
                                      .toString()),
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
                labelText: 'UID партнера в 1С',
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
