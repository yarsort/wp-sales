import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/db_doc_incoming_cash_order.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/db/db_doc_return_order_customer.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/db/db_ref_organization.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/db/db_ref_price.dart';
import 'package:wp_sales/db/db_ref_product.dart';
import 'package:wp_sales/db/db_ref_warehouse.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/models/ref_cashbox.dart';
import 'package:wp_sales/models/ref_organization.dart';
import 'package:wp_sales/models/ref_partner.dart';
import 'package:wp_sales/models/ref_price.dart';
import 'package:wp_sales/models/ref_product.dart';
import 'package:wp_sales/models/ref_warehouse.dart';
import 'package:wp_sales/screens/documents/incoming_cash_order/incoming_cash_order_item.dart';
import 'package:wp_sales/screens/documents/return_order_customer/return_order_customer_item.dart';
import 'package:wp_sales/screens/references/cashbox/cashbox_selection.dart';
import 'package:wp_sales/screens/references/contracts/contract_selection.dart';
import 'package:wp_sales/screens/references/organizations/organization_selection.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/screens/references/price/price_selection.dart';
import 'package:wp_sales/screens/references/product/add_item.dart';
import 'package:wp_sales/screens/references/product/product_selection_treeview.dart';
import 'package:wp_sales/screens/references/warehouses/warehouse_selection.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenItemOrderCustomer extends StatefulWidget {
  final OrderCustomer orderCustomer;

  const ScreenItemOrderCustomer({Key? key, required this.orderCustomer})
      : super(key: key);

  @override
  _ScreenItemOrderCustomerState createState() =>
      _ScreenItemOrderCustomerState();
}

class _ScreenItemOrderCustomerState extends State<ScreenItemOrderCustomer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int countChangeDoc = 0;

  /// Количество строк товаров в заказе
  int countItems = 0;
  bool firstOpen = true;

  /// Позиции товаров в заказе
  List<ItemOrderCustomer> itemsOrder = [];

  /// Позиции товаров в заказе
  List<dynamic> listDocsByParent = [];

  /// Поле ввода: Организация
  TextEditingController textFieldOrganizationController =
      TextEditingController();

  /// Поле ввода: Партнер
  TextEditingController textFieldPartnerController = TextEditingController();

  /// Поле ввода: Договор или торговая точка
  TextEditingController textFieldContractController = TextEditingController();

  /// Поле ввода: Тип цены
  TextEditingController textFieldPriceController = TextEditingController();

  /// Поле ввода: Склад
  TextEditingController textFieldWarehouseController = TextEditingController();

  /// Поле ввода: Сумма документа
  TextEditingController textFieldSumController = TextEditingController();

  /// Поле ввода: Валюта документа
  TextEditingController textFieldCurrencyController = TextEditingController();

  /// Поле ввода: Касса
  TextEditingController textFieldCashboxController = TextEditingController();

  /// Поле ввода: Дата отгрузки (отправки)
  TextEditingController textFieldDateSendingController =
      TextEditingController();

  /// Поле ввода: Дата оплаты
  TextEditingController textFieldDatePayingController = TextEditingController();

  /// Поле ввода: Комментарий
  TextEditingController textFieldCommentController = TextEditingController();

  /// Поле ввода: UUID
  TextEditingController textFieldUUIDController = TextEditingController();

  /// Поле ввода: Номер документа в 1С
  TextEditingController textFieldNumberFrom1CController =
      TextEditingController();

  /// Поле ввода: Отправлено в 1С
  bool sendYesTo1C = false;

  /// Поле ввода: Не отправлять в 1С
  bool sendNoTo1C = false;

  /// Поле ввода: Дата отправки в 1С
  TextEditingController textFieldDateSendingTo1CController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    updateHeader();
    renewItems();
    renewDocsByParent();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Если не изменился счетчик изменений документа
        if (countChangeDoc <= 1) {
          return true;
        }

        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Сохранить документ?'),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            var result = await saveDoc();
                            if (result) {
                              showMessage('Запись сохранена!');
                              Navigator.of(context).pop(true);
                            }
                          },
                          child: const SizedBox(
                              width: 60, child: Center(child: Text('Да')))),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          onPressed: () async {
                            Navigator.of(context).pop(true);
                          },
                          child: const SizedBox(
                            width: 60,
                            child: Center(child: Text('Нет')),
                          )),
                    ],
                  ),
                ],
              );
            });
        return value == true;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Заказ'),
            actions: [
              IconButton(
                onPressed: () async {
                  if (widget.orderCustomer.nameOrganization == '') {
                    showMessageError('Организация не заполнена!');
                    return;
                  }
                  if (widget.orderCustomer.namePartner == '') {
                    showMessageError('Партнер не заполнен!');
                    return;
                  }
                  if (widget.orderCustomer.nameContract == '') {
                    showMessageError('Контракт не заполнен!');
                    return;
                  }
                  if (widget.orderCustomer.namePrice == '') {
                    showMessageError('Тип цены не заполнен!');
                    return;
                  }
                  if (widget.orderCustomer.nameWarehouse == '') {
                    showMessageError('Склад не заполнен!');
                    return;
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenProductSelectionTreeView(
                          listItemDoc: itemsOrder,
                          orderCustomer: widget.orderCustomer),
                    ),
                  );
                  renewItems();
                  updateHeader();
                },
                icon: const Icon(Icons.add),
              )
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Главная'),
                Tab(text: 'Товары'),
                Tab(text: 'Служебные'),
              ],
            ),
          ),
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
                  listViewItemsOrder(),
                ],
              ),
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  listServiceOrder(),
                  listButtonsDocsByParent(),
                  listViewDocsByParent(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateHeader() async {
    // Это новый документ
    if (widget.orderCustomer.uid == '') {
      widget.orderCustomer.uid = const Uuid().v4();

      final SharedPreferences prefs = await _prefs;

      // Заполнение значений по-умолчанию
      var uidOrganization = prefs.getString('settings_uidOrganization') ?? '';
      Organization organization = await dbReadOrganizationUID(uidOrganization);
      widget.orderCustomer.uidOrganization = organization.uid;
      widget.orderCustomer.nameOrganization = organization.name;

      var uidPartner = prefs.getString('settings_uidPartner') ?? '';
      Partner partner = await dbReadPartnerUID(uidPartner);
      widget.orderCustomer.uidPartner = partner.uid;
      widget.orderCustomer.namePartner = partner.name;

      var uidPrice = prefs.getString('settings_uidPrice') ?? '';
      Price price = await dbReadPriceUID(uidPrice);
      widget.orderCustomer.uidPrice = price.uid;
      widget.orderCustomer.namePrice = price.name;

      var uidCashbox = prefs.getString('settings_uidCashbox') ?? '';
      Cashbox cashbox = await dbReadCashboxUID(uidCashbox);
      widget.orderCustomer.uidCashbox = cashbox.uid;
      widget.orderCustomer.nameCashbox = cashbox.name;

      var uidWarehouse = prefs.getString('settings_uidWarehouse') ?? '';
      Warehouse warehouse = await dbReadWarehouseUID(uidWarehouse);
      widget.orderCustomer.uidWarehouse = warehouse.uid;
      widget.orderCustomer.nameWarehouse = warehouse.name;
    }

    countItems = widget.orderCustomer.countItems;
    textFieldOrganizationController.text =
        widget.orderCustomer.nameOrganization;
    textFieldPartnerController.text = widget.orderCustomer.namePartner;
    textFieldContractController.text = widget.orderCustomer.nameContract;
    textFieldPriceController.text = widget.orderCustomer.namePrice;
    textFieldCurrencyController.text = widget.orderCustomer.nameCurrency;
    textFieldCashboxController.text = widget.orderCustomer.nameCashbox;
    textFieldWarehouseController.text = widget.orderCustomer.nameWarehouse;
    textFieldSumController.text = doubleToString(widget.orderCustomer.sum);

    textFieldDateSendingController.text =
        shortDateToString(widget.orderCustomer.dateSending);
    textFieldDatePayingController.text =
        shortDateToString(widget.orderCustomer.datePaying);
    textFieldCommentController.text = widget.orderCustomer.comment;

    // Технические данные
    textFieldUUIDController.text = widget.orderCustomer.uid;
    sendNoTo1C = widget.orderCustomer.sendNoTo1C == 1 ? true : false;
    sendYesTo1C = widget.orderCustomer.sendYesTo1C == 1 ? true : false;
    textFieldDateSendingTo1CController.text =
        shortDateToString(widget.orderCustomer.dateSendingTo1C);
    textFieldNumberFrom1CController.text = widget.orderCustomer.numberFrom1C;

    // Проверка Организации
    if ((textFieldPartnerController.text.trim() == '') ||
        (textFieldOrganizationController.text.trim() == '')) {
      textFieldContractController.text = '';
      widget.orderCustomer.nameContract = '';
      widget.orderCustomer.uidContract = '';

      textFieldPriceController.text = '';
      widget.orderCustomer.namePrice = '';
      widget.orderCustomer.uidPrice = '';

      textFieldCurrencyController.text = '';
      widget.orderCustomer.nameCurrency = '';
      widget.orderCustomer.uidCurrency = '';

      textFieldCashboxController.text = '';
      widget.orderCustomer.nameCashbox = '';
      widget.orderCustomer.uidCashbox = '';
    }

    // Проверка договора
    if (textFieldContractController.text.trim() == '') {
      textFieldPriceController.text = '';
      widget.orderCustomer.namePrice = '';
      widget.orderCustomer.uidPrice = '';

      textFieldCurrencyController.text = '';
      widget.orderCustomer.nameCurrency = '';
      widget.orderCustomer.uidCurrency = '';
    }

    setState(() {
      countChangeDoc++;
    });
  }

  showMessageError(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(textMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(textMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  nameGroup({String nameGroup = '', bool hideDivider = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 0),
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

  renewItems() async {
    countItems = 0;

    if (firstOpen) {
      itemsOrder.clear();

      if (widget.orderCustomer.id != 0) {
        itemsOrder = await dbReadItemsOrderCustomer(widget.orderCustomer.id);
      }
      firstOpen = false;
    }

    // Количество документов в списке
    countItems = itemsOrder.length;
    widget.orderCustomer.countItems = countItems;

    debugPrint('Количество товаров: ' + countItems.toString());

    setState(() {});
  }

  renewDocsByParent() async {
    countItems = 0;

    listDocsByParent.clear();

    if (widget.orderCustomer.id != 0) {
      var tempList1 =
          await dbReadIncomingCashOrderUIDParent(widget.orderCustomer.uid);
      listDocsByParent.addAll(tempList1);
      var tempList2 =
          await dbReadReturnOrderCustomerUIDParent(widget.orderCustomer.uid);
      listDocsByParent.addAll(tempList2);
    }

    // Количество документов в списке
    countItems = listDocsByParent.length;

    debugPrint('Количество подчиненных документов: ' + countItems.toString());

    setState(() {});
  }

  saveDoc() async {
    try {
      /// Сумма товаров в заказе
      OrderCustomer().allSum(widget.orderCustomer, itemsOrder);

      /// Количество товаров в заказе
      OrderCustomer().allCount(widget.orderCustomer, itemsOrder);

      if (widget.orderCustomer.id != 0) {
        await dbUpdateOrderCustomer(widget.orderCustomer, itemsOrder);
        return true;
      } else {
        await dbCreateOrderCustomer(widget.orderCustomer, itemsOrder);
        return true;
      }
    } on Exception catch (error) {
      showMessage('Ошибка записи документа!');
      debugPrint(error.toString());
      return false;
    }
  }

  deleteDoc() async {
    try {
      if (widget.orderCustomer.id != 0) {
        /// Установим статус записи: 3 - пометка удаления
        widget.orderCustomer.status = 3;

        /// Обновим объект в базе данных
        await dbUpdateOrderCustomer(widget.orderCustomer, itemsOrder);
        return true;
      } else {
        return true; // Значит, что запись вообще не была записана!
      }
    } on Exception catch (error) {
      debugPrint('Ошибка отправки в корзину!');
      debugPrint(error.toString());
      return false;
    }
  }

  eraseDoc() {
    return true;
  }

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
              onPressedDelete: () {},
              onPressedEdit: () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenOrganizationSelection(
                            orderCustomer: widget.orderCustomer)));
                // Если изменили партнера, изменим его договор и валюту
                if (result != null) {
                  if (result) {
                    widget.orderCustomer.nameContract = '';
                    widget.orderCustomer.uidContract = '';
                    widget.orderCustomer.namePrice = '';
                    widget.orderCustomer.uidPrice = '';
                    widget.orderCustomer.nameCurrency = '';
                    widget.orderCustomer.uidCurrency = '';
                  }
                }
                updateHeader();
              }),

          /// Partner
          TextFieldWithText(
              textLabel: 'Партнер',
              textEditingController: textFieldPartnerController,
              onPressedEditIcon: Icons.people,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.orderCustomer.namePartner = '';
                widget.orderCustomer.uidPartner = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPartnerSelection(
                            orderCustomer: widget.orderCustomer)));

                // Если изменили партнера, изменим его договор и валюту
                widget.orderCustomer.nameContract = '';
                widget.orderCustomer.uidContract = '';
                widget.orderCustomer.namePrice = '';
                widget.orderCustomer.uidPrice = '';
                widget.orderCustomer.nameCurrency = '';
                widget.orderCustomer.uidCurrency = '';
                updateHeader();
              }),

          /// Contract
          TextFieldWithText(
              textLabel: 'Договор (торговая точка)',
              textEditingController: textFieldContractController,
              onPressedEditIcon: Icons.recent_actors,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.orderCustomer.nameContract = '';
                widget.orderCustomer.uidContract = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenContractSelection(
                            orderCustomer: widget.orderCustomer)));

                // Если изменили контрак, изменим цену и валюту
                widget.orderCustomer.namePrice = '';
                widget.orderCustomer.uidPrice = '';
                widget.orderCustomer.nameCurrency = '';
                widget.orderCustomer.uidCurrency = '';

                await updateHeader();
              }),

          /// Price
          TextFieldWithText(
              textLabel: 'Тип цены продажи',
              textEditingController: textFieldPriceController,
              onPressedEditIcon: Icons.request_quote,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.orderCustomer.namePrice = '';
                widget.orderCustomer.uidPrice = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPriceSelection(
                            orderCustomer: widget.orderCustomer)));

                updateHeader();
              }),

          /// Cashbox
          TextFieldWithText(
              textLabel: 'Касса',
              textEditingController: textFieldCashboxController,
              onPressedEditIcon: Icons.request_quote,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.orderCustomer.nameCashbox = '';
                widget.orderCustomer.uidCashbox = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenCashboxSelection(
                            orderCustomer: widget.orderCustomer)));

                updateHeader();
              }),

          /// Warehouse
          TextFieldWithText(
              textLabel: 'Склад отгрузки',
              textEditingController: textFieldWarehouseController,
              onPressedEditIcon: Icons.gite,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.orderCustomer.nameWarehouse = '';
                widget.orderCustomer.uidWarehouse = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenWarehouseSelection(
                              orderCustomer: widget.orderCustomer,
                              returnOrderCustomer: ReturnOrderCustomer(),
                            )));
                updateHeader();
              }),

          /// Sum of document
          TextFieldWithText(
              textLabel: 'Сумма документа',
              textEditingController: textFieldSumController,
              onPressedEditIcon: null,
              onPressedDeleteIcon: null,
              onPressedDelete: () async {},
              onPressedEdit: () async {}),

          /// Divider
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Divider(),
          ),

          /// Date sending to partner
          TextFieldWithText(
              textLabel: 'Дата отгрузки (планируемая)',
              textEditingController: textFieldDateSendingController,
              onPressedEditIcon: Icons.date_range,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                setState(() async {
                  widget.orderCustomer.dateSending = DateTime(1900, 1, 1);
                  await updateHeader();
                });
              },
              onPressedEdit: () async {
                DateTime selectedDate = DateTime.now();
                var _datePick = await showDatePicker(
                  context: context,
                  helpText: 'Выберите дату отгрузки',
                  firstDate: DateTime(2021, 1, 1),
                  lastDate: DateTime(2101),
                  initialDate: selectedDate,
                );
                if (_datePick != null) {
                  setState(() {
                    textFieldDateSendingController.text =
                        shortDateToString(_datePick);
                    widget.orderCustomer.dateSending = _datePick;
                  });
                }
              }),

          /// Date paying to partner
          TextFieldWithText(
              textLabel: 'Дата оплаты (планируемая)',
              textEditingController: textFieldDatePayingController,
              onPressedEditIcon: Icons.date_range,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                setState(() async {
                  widget.orderCustomer.datePaying = DateTime(1900, 1, 1);
                  await updateHeader();
                });
              },
              onPressedEdit: () async {
                DateTime selectedDate = DateTime.now();
                var _datePick = await showDatePicker(
                  context: context,
                  helpText: 'Выберите дату оплаты',
                  firstDate: DateTime(2021, 1, 1),
                  lastDate: DateTime(2101),
                  initialDate: selectedDate,
                );
                if (_datePick != null) {
                  setState(() {
                    textFieldDatePayingController.text =
                        shortDateToString(_datePick);
                    widget.orderCustomer.datePaying = _datePick;
                  });
                  await updateHeader();
                }
              }),

          /// Comment
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              onSubmitted: (value) async {
                widget.orderCustomer.comment = value;
                await updateHeader();
              },
              maxLines: 3,
              keyboardType: TextInputType.text,
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

          /// Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// Записать документ
                SizedBox(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 49) / 2,
                  child: ElevatedButton(
                      onPressed: () async {
                        var result = await saveDoc();
                        if (result) {
                          showMessage('Запись сохранена!');
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.save, color: Colors.white),
                          SizedBox(width: 14),
                          Text('Записать')
                        ],
                      )),
                ),

                const SizedBox(
                  width: 14,
                ),

                /// Удалить документ
                SizedBox(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 35) / 2,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () async {
                        var result = await deleteDoc();
                        if (result) {
                          showMessage('Запись отправлена в корзину!');
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 14),
                          Text('В корзину'),
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

  listViewItemsOrder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: ColumnBuilder(
          itemCount: itemsOrder.length,
          itemBuilder: (context, index) {
            final item = itemsOrder[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Card(
                  elevation: 2,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: PopupMenuButton<String>(
                      onSelected: (String value) async {
                        if (value == 'delete') {
                          itemsOrder = List.from(itemsOrder)..removeAt(index);
                          setState(() {
                            OrderCustomer()
                                .allSum(widget.orderCustomer, itemsOrder);
                            OrderCustomer()
                                .allCount(widget.orderCustomer, itemsOrder);
                            updateHeader();
                          });
                        }
                        if (value == 'edit') {
                          Product productItem =
                              await dbReadProductUID(item.uid);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScreenAddItem(
                                  listItemDoc: itemsOrder,
                                  orderCustomer: widget.orderCustomer,
                                  product: productItem),
                            ),
                          );
                          setState(() {
                            OrderCustomer()
                                .allSum(widget.orderCustomer, itemsOrder);
                            OrderCustomer()
                                .allCount(widget.orderCustomer, itemsOrder);
                            updateHeader();
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'view',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.search,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Просмотр'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(children: const [
                            Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Изменить')
                          ]),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Удалить'),
                            ],
                          ),
                        ),
                      ],
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          children: [
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child:
                                        Text(doubleThreeToString(item.count))),
                                Expanded(flex: 1, child: Text(item.nameUnit)),
                                Expanded(
                                    flex: 1,
                                    child: Text(doubleToString(item.price))),
                                Expanded(
                                    flex: 1,
                                    child: Text(doubleToString(item.sum))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            );
          }),
    );
  }

  listViewDocsByParent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: ColumnBuilder(
          itemCount: listDocsByParent.length,
          itemBuilder: (context, index) {
            final item = listDocsByParent[index];

            var nameDoc = '';
            if (item.runtimeType == IncomingCashOrder) {
              if (item.numberFrom1C != '') {
                nameDoc = 'Оплата заказа № ' + item.numberFrom1C;
              } else {
                nameDoc = 'Оплата заказа № <номер не получен>';
              }
            }
            if (item.runtimeType == ReturnOrderCustomer) {
              if (item.numberFrom1C != '') {
                nameDoc = 'Возврат заказа № ' + item.numberFrom1C;
              } else {
                nameDoc = 'Возврат заказа № <номер не получен>';
              }
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Card(
                elevation: 3,
                child: ListTile(
                  //tileColor: Colors.cyan[50],
                  onTap: () async {},
                  title: Text(nameDoc),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Icon(Icons.domain,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Flexible(flex: 1, child: Text(item.nameContract)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(children: [
                        Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        color: Colors.blue, size: 20),
                                    const SizedBox(width: 5),
                                    Text(shortDateToString(item.date)),
                                  ],
                                ),
                              ],
                            )),
                        Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.price_change,
                                        color: Colors.blue, size: 20),
                                    const SizedBox(width: 5),
                                    Text(doubleToString(item.sum) + ' грн'),
                                  ],
                                ),
                              ],
                            ))
                      ]),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  listButtonsDocsByParent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Подчиненные документы',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              PopupMenuButton<String>(
                onSelected: (String value) async {
                  if (value == 'return_order_customer') {
                    // Проверим что бы заказ был записан!
                    if (widget.orderCustomer.id == 0) {
                      showMessageError('Заказ не записан!');
                      return;
                    }

                    // Создадим подчиненный документ
                    var newReturnOrderCustomer = ReturnOrderCustomer();
                    newReturnOrderCustomer.uidParent = widget.orderCustomer.uid;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenItemReturnOrderCustomer(
                            returnOrderCustomer: newReturnOrderCustomer),
                      ),
                    );
                    renewDocsByParent();
                  }
                  if (value == 'incoming_cash_order') {
                    // Проверим что бы заказ был записан!
                    if (widget.orderCustomer.id == 0) {
                      showMessageError('Заказ не записан!');
                      return;
                    }

                    // Создадим подчиненный документ
                    var newIncomingCashOrder = IncomingCashOrder();
                    newIncomingCashOrder.uidParent = widget.orderCustomer.uid;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenItemIncomingCashOrder(
                            incomingCashOrder: newIncomingCashOrder),
                      ),
                    );
                    renewDocsByParent();
                  }
                },
                child: const Icon(Icons.add, color: Colors.blue),
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
              ),
            ],
          ),
          const SizedBox(
            height: 7,
          ),
          const Divider(),
        ],
      ),
    );
  }

  listServiceOrder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
          title: const Text(
            'Параметры отправки документа',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: TextField(
                controller: textFieldUUIDController,
                readOnly: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'UUID',
                ),
              ),
            ),

            /// Date sending to 1C
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: TextField(
                controller: textFieldDateSendingTo1CController,
                readOnly: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'Дата отправки в 1С',
                ),
              ),
            ),

            /// Number sending to 1C
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: TextField(
                controller: textFieldNumberFrom1CController,
                readOnly: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'Номер документа в 1С',
                ),
              ),
            ),

            /// Sending to 1C
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: sendYesTo1C,
                    onChanged: (value) {
                      setState(() {
                        countChangeDoc++;

                        /// Если нельзя отправлять в 1С, то скажем об этом
                        if (sendNoTo1C) {
                          const snackBar = SnackBar(
                            content: Text(
                                'Ошибка! Установлен флаг: Не отправлять в 1С!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          /// Снятие флага на повторную отправку в учетную систему
                          sendYesTo1C = false;
                        } else {
                          /// Флаг отметки на отправку
                          sendYesTo1C = !sendYesTo1C;
                        }

                        if (!sendYesTo1C) {
                          /// Отметим статус заказа как неотправленный
                          widget.orderCustomer.status = 1;

                          /// Очистка даты отправки заказа вручную
                          textFieldDateSendingTo1CController.text = '';
                        } else {
                          /// Отметим статус заказа как отправленный
                          widget.orderCustomer.status = 2;

                          /// Фиксация даты отправки заказа вручную
                          textFieldDateSendingTo1CController.text =
                              shortDateToString(DateTime.now());
                        }
                      });
                    },
                  ),
                  const Text('Отправлено в учетную систему'),
                ],
              ),
            ),

            /// No Sending to 1C
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: sendNoTo1C,
                    onChanged: (value) {
                      setState(() {
                        countChangeDoc++;

                        /// Если нельзя отправлять в 1С, то скажем об этом
                        if (sendYesTo1C) {
                          const snackBar = SnackBar(
                            content: Text('Ошибка! Заказ уже отправлен в 1С!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          sendNoTo1C = false;
                        } else {
                          sendNoTo1C = !sendNoTo1C;
                        }
                      });
                    },
                  ),
                  const Text('Не отправлять в учетную систему'),
                ],
              ),
            ),
          ]),
    );
  }
}
