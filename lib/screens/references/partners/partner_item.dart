import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/screens/documents/incoming_cash_order/incoming_cash_order_item.dart';
import 'package:wp_sales/screens/documents/return_order_customer/return_order_customer_item.dart';
import 'package:wp_sales/screens/references/contracts/contract_item.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenPartnerItem extends StatefulWidget {
  final Partner partnerItem;

  const ScreenPartnerItem({Key? key, required this.partnerItem})
      : super(key: key);

  @override
  _ScreenPartnerItemState createState() => _ScreenPartnerItemState();
}

class _ScreenPartnerItemState extends State<ScreenPartnerItem> {

  List<Contract> tempItems = [];
  List<Contract> listContracts = [];
  List<AccumPartnerDept> listAccumPartnerDept = [];

  /// Поле ввода: Name
  TextEditingController textFieldNameController = TextEditingController();

  /// Поле ввода: Phone
  TextEditingController textFieldPhoneController = TextEditingController();

  /// Поле ввода: Address
  TextEditingController textFieldAddressController = TextEditingController();

  /// Поле ввода: Balance
  TextEditingController textFieldBalanceController = TextEditingController();

  /// Поле ввода: BalanceForPayment
  TextEditingController textFieldBalanceForPaymentController = TextEditingController();

  /// Поле ввода: SchedulePayment
  TextEditingController textFieldSchedulePaymentController = TextEditingController();

  /// Поле ввода: Comment
  TextEditingController textFieldCommentController = TextEditingController();

  /// Поле ввода: UID
  TextEditingController textFieldUIDController = TextEditingController();

  /// Поле ввода: Code
  TextEditingController textFieldCodeController = TextEditingController();

  double balance = 0.0;
  double balanceForPayment = 0.0;

  @override
  void initState() {
    super.initState();
    renewItem();
    readBalance();
  }

  renewItem() async {
      if (widget.partnerItem.uid == '') {
        widget.partnerItem.uid = const Uuid().v4();
      }

      textFieldNameController.text = widget.partnerItem.name;
      textFieldPhoneController.text = widget.partnerItem.phone;
      textFieldAddressController.text = widget.partnerItem.address;
      textFieldSchedulePaymentController.text = widget.partnerItem.schedulePayment.toString();
      textFieldCommentController.text = widget.partnerItem.comment;

      /// Технические данные
      textFieldUIDController.text = widget.partnerItem.uid;
      textFieldCodeController.text = widget.partnerItem.code;

      /// Получение списка контрактов партнера
      await readContracts();

      /// Вывод долгов на форме
      List<String> listPartnersUID = [];
      listPartnersUID.add(widget.partnerItem.uid);

      // Получим долги партнера
      List<AccumPartnerDept> listPartnerDebts =
      await dbReadAllAccumPartnerDeptByUIDPartners(listPartnersUID);

      // Найдем в списке долгов наши долги
      var indexItemDebt = listPartnerDebts
          .indexWhere((element) => element.uidPartner == widget.partnerItem.uid);
      if (indexItemDebt >= 0) {
        var itemList = listPartnerDebts[indexItemDebt];
        balance = itemList.balance;
        balanceForPayment = itemList.balanceForPayment;
      } else {
        balance = 0.0;
        balanceForPayment = 0.0;
      }

      // Выведем на форму
      textFieldBalanceController.text = doubleToString(balance);
      textFieldBalanceForPaymentController.text = doubleToString(balanceForPayment);

      setState(() {});
  }

  readContracts() async {
    listContracts.clear();
    tempItems.clear();

    if (widget.partnerItem.uid.isNotEmpty) {
      listContracts = await dbReadContractsOfPartner(
          widget.partnerItem.uid);
      tempItems.addAll(listContracts);
    }
  }

  readBalance() async {
    listAccumPartnerDept.clear();
    List<AccumPartnerDept> listDebts = await dbReadAccumPartnerDeptByPartner(
        uidPartner: widget.partnerItem.uid);

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

    // Удалим балансы с нулевым остатком, после оплат через ПКО
    listAccumPartnerDept.removeWhere((item) => item.balance == 0);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Партнер'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Главная'),
              Tab(text: 'Контракты'),
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
              shrinkWrap: false,
              children: [
                listViewContracts(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listDebtsCustomer(),
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

  saveItem() async {
    try {
      widget.partnerItem.name = textFieldNameController.text;
      widget.partnerItem.phone = textFieldPhoneController.text;
      widget.partnerItem.address = textFieldAddressController.text;
      widget.partnerItem.schedulePayment = int.parse(textFieldSchedulePaymentController.text);
      widget.partnerItem.comment = textFieldCommentController.text;
      widget.partnerItem.dateEdit = DateTime.now();

      if (widget.partnerItem.id != 0) {
        await dbUpdatePartner(widget.partnerItem);
        return true;
      } else {
        await dbCreatePartner(widget.partnerItem);
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
      if (widget.partnerItem.id != 0) {
        /// Обновим объект в базе данных
        await dbDeletePartner(widget.partnerItem.id);
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
                widget.partnerItem.name = textFieldNameController.text;
              },
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
              onChanged: (value) {
                widget.partnerItem.phone = textFieldPhoneController.text;
              },
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
              onChanged: (value) {
                widget.partnerItem.address = textFieldAddressController.text;
              },
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

          /// Balance
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              controller: textFieldBalanceController,
              readOnly: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Баланс партнера',
              ),
            ),
          ),

          /// Balance for payment
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          //   child: TextField(
          //     controller: textFieldBalanceForPaymentController,
          //     readOnly: true,
          //     decoration: const InputDecoration(
          //       contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          //       border: OutlineInputBorder(),
          //       labelStyle: TextStyle(
          //         color: Colors.blueGrey,
          //       ),
          //       labelText: 'Баланс партнера (просроченный по оплате)',
          //     ),
          //   ),
          // ),

          /// Divider
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Divider(),
          ),

          /// Comment
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              onChanged: (value) {
                widget.partnerItem.comment = textFieldCommentController.text;
              },
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

  listViewContracts() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ColumnListViewBuilder(
          itemCount: listContracts.length,
          itemBuilder: (context, index) {
            final contractItem = listContracts[index];
            return ContractItem(contractItem: contractItem);
          }),
    );
  }

  listDebtsCustomer() {
    return ColumnListViewBuilder(
        itemCount: listAccumPartnerDept.length,
        itemBuilder: (context, index) {
          final itemDept = listAccumPartnerDept[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 5),
            child: Card(
              elevation: 3,
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
                      ? Text(itemDept.nameDoc + ' №' +itemDept.numberDoc)
                      : Text(itemDept.nameSettlementDocument + ' №' +itemDept.numberDoc),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.date_range,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Flexible(
                              child: Text(fullDateToString(itemDept.dateDoc))),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.home, color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Flexible(
                              child: widget.partnerItem.address != ''
                                  ? Text(widget.partnerItem.address)
                                  : const Text('Нет данных')),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Flexible(
                                      child: widget.partnerItem.phone != ''
                                          ? Text(widget.partnerItem.phone)
                                          : const Text('Нет данных')),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.schedule,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(widget.partnerItem.schedulePayment
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
                contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'UID партнера',
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


class ContractItem extends StatefulWidget {
  final Contract contractItem;

  const ContractItem({Key? key, required this.contractItem}) : super(key: key);

  @override
  State<ContractItem> createState() => _ContractItemState();
}

class _ContractItemState extends State<ContractItem> {
  double balance = 0.0;
  double balanceForPayment = 0.0;

  @override
  void initState() {
    super.initState();
    renewDataContract();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ScreenContractItem(contractItem: widget.contractItem),
            ),
          );
        },
        title: Text(widget.contractItem.name),
        subtitle: Column(
          children: [
            const Divider(),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Flexible(
                              child: widget.contractItem.phone != ''
                                  ? Text(widget.contractItem.phone)
                                  : const Text('Нет данных')),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.home,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Flexible(
                              child: widget.contractItem.address != ''
                                  ? Text(widget.contractItem.address)
                                  : const Text('Нет данных')),
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
                              doubleToString(balance)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.price_change,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 5),
                          Text(doubleToString(balanceForPayment)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  renewDataContract() async {
    // Получить баланс заказа
    Map debts = await dbReadSumAccumPartnerDeptByContract(uidContract: widget.contractItem.uid);

    // Запись в реквизиты
    balance = debts['balance'];
    balanceForPayment = debts['balanceForPayment'];

    setState(() {});
  }
}
