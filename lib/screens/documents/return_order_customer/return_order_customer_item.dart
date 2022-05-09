import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/import/import_screens.dart';
import 'package:wp_sales/screens/documents/order_customer/order_customer_selection.dart';
import 'package:wp_sales/screens/references/product/product_selection_treeview.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenItemReturnOrderCustomer extends StatefulWidget {
  final ReturnOrderCustomer returnOrderCustomer;

  const ScreenItemReturnOrderCustomer(
      {Key? key, required this.returnOrderCustomer,})
      : super(key: key);

  @override
  _ScreenItemReturnOrderCustomerState createState() =>
      _ScreenItemReturnOrderCustomerState();
}

class _ScreenItemReturnOrderCustomerState
    extends State<ScreenItemReturnOrderCustomer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int countChangeDoc = 0;

  /// Количество строк товаров в заказе
  int countItems = 0;
  bool firstOpen = true;

  /// Позиции товаров в заказе
  List<ItemReturnOrderCustomer> itemsReturnOrder = [];

  /// Поле ввода: Организация
  TextEditingController textFieldOrganizationController =
      TextEditingController();

  /// Поле ввода: Партнер
  TextEditingController textFieldPartnerController = TextEditingController();

  /// Поле ввода: Договор или торговая точка
  TextEditingController textFieldContractController = TextEditingController();

  /// Поле ввода: Заказ покупателя
  TextEditingController textFieldOrderCustomerController =
      TextEditingController();

  /// Поле ввода: Документ расчета
  TextEditingController textFieldSettlementDocumentController =
  TextEditingController();

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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Если не изменился счетчик изменений документа
        if (countChangeDoc <= 1) {
          return true;
        }

        // Попробуем записать документ
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
                            var result = await saveDocument();
                            if (result) {
                              showMessage('Запись сохранена!', context);
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
            title: const Text('Возврат покупателя'),
            actions: [
              IconButton(
                onPressed: () async {
                  if (widget.returnOrderCustomer.nameOrganization == '') {
                    showErrorMessage('Организация не заполнена!', context);
                    return;
                  }
                  if (widget.returnOrderCustomer.namePartner == '') {
                    showErrorMessage('Партнер не заполнен!', context);
                    return;
                  }
                  if (widget.returnOrderCustomer.nameContract == '') {
                    showErrorMessage('Контракт не заполнен!', context);
                    return;
                  }
                  if (widget.returnOrderCustomer.namePrice == '') {
                    showErrorMessage('Тип цены не заполнен!', context);
                    return;
                  }
                  if (widget.returnOrderCustomer.nameWarehouse == '') {
                    showErrorMessage('Склад не заполнен!', context);
                    return;
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenProductSelectionTreeView(
                        listItemReturnDoc: itemsReturnOrder,
                        returnOrderCustomer: widget.returnOrderCustomer,
                        orderCustomer: OrderCustomer(),
                        listItemDoc: const [],
                      ),
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
                  listItemsOrder(),
                ],
              ),
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  listServiceOrder(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateHeader() async {
    // Заполнение реквизита заказа покупателя
    if (widget.returnOrderCustomer.uidParent != '') {
      OrderCustomer orderCustomer =
          await dbReadOrderCustomerUID(widget.returnOrderCustomer.uidParent);
      if (orderCustomer.id != 0) {
        if (orderCustomer.numberFrom1C != '') {
          textFieldOrderCustomerController.text = 'Заказ № ' + orderCustomer.numberFrom1C;
        } else {
          textFieldOrderCustomerController.text = 'Заказ № <номер не получен>';
        }

        widget.returnOrderCustomer.uidOrganization = orderCustomer.uidOrganization;
        widget.returnOrderCustomer.uidPartner      = orderCustomer.uidPartner;
        widget.returnOrderCustomer.uidContract     = orderCustomer.uidContract;
        widget.returnOrderCustomer.uidPrice        = orderCustomer.uidPrice;
        widget.returnOrderCustomer.uidWarehouse    = orderCustomer.uidWarehouse;
      } else {
        // Наименование заказа покупателя
        textFieldOrderCustomerController.text = widget.returnOrderCustomer.nameParent;
      }
    }

    // Заполняем значениями из настроек (по-умолчанию)
    final SharedPreferences prefs = await _prefs;

    /// Заполнение значений по-умолчанию: из документа или из настроек
    if (widget.returnOrderCustomer.uidOrganization.isEmpty){
      widget.returnOrderCustomer.uidOrganization = prefs.getString('settings_uidOrganization') ?? '';
    }
    if (widget.returnOrderCustomer.uidPartner.isEmpty){
      widget.returnOrderCustomer.uidPartner = prefs.getString('settings_uidPartner') ?? '';
    }
    if (widget.returnOrderCustomer.uidPrice.isEmpty){
      widget.returnOrderCustomer.uidPrice = prefs.getString('settings_uidPrice') ?? '';
    }

    // Сначала проверка на склад возврата
    if (widget.returnOrderCustomer.uidWarehouse.isEmpty){
      widget.returnOrderCustomer.uidWarehouse = prefs.getString('settings_uidWarehouseReturn') ?? '';
    }
    // Проверка на основной склад
    if (widget.returnOrderCustomer.uidWarehouse.isEmpty){
      widget.returnOrderCustomer.uidWarehouse = prefs.getString('settings_uidWarehouse') ?? '';
    }

    /// Для всех реквизитов теперь установим текстовые значения на форме по их UID
    Organization organization =
        await dbReadOrganizationUID(widget.returnOrderCustomer.uidOrganization);
    widget.returnOrderCustomer.nameOrganization = organization.name;

    Partner partner =
        await dbReadPartnerUID(widget.returnOrderCustomer.uidPartner);
    widget.returnOrderCustomer.namePartner = partner.name;

    Contract contract =
        await dbReadContractUID(widget.returnOrderCustomer.uidContract);
    widget.returnOrderCustomer.nameContract = contract.name;

    Price price =
        await dbReadPriceUID(widget.returnOrderCustomer.uidPrice);
    widget.returnOrderCustomer.namePrice = price.name;

    Warehouse warehouse =
        await dbReadWarehouseUID(widget.returnOrderCustomer.uidWarehouse);
    widget.returnOrderCustomer.nameWarehouse = warehouse.name;

    // Теперь запишем идентификатор объекта
    if (widget.returnOrderCustomer.uid == '') {
      widget.returnOrderCustomer.uid = const Uuid().v4();
    }

    // Расчет реквизитов наименований на форме
    countItems = widget.returnOrderCustomer.countItems;
    textFieldOrganizationController.text = widget.returnOrderCustomer.nameOrganization;
    textFieldPartnerController.text = widget.returnOrderCustomer.namePartner;
    textFieldContractController.text = widget.returnOrderCustomer.nameContract;
    textFieldSettlementDocumentController.text = widget.returnOrderCustomer.nameSettlementDocument;
    textFieldPriceController.text = widget.returnOrderCustomer.namePrice;
    textFieldCurrencyController.text = widget.returnOrderCustomer.nameCurrency;
    textFieldWarehouseController.text = widget.returnOrderCustomer.nameWarehouse;
    textFieldSumController.text = doubleToString(widget.returnOrderCustomer.sum);
    textFieldDateSendingController.text = shortDateToString(widget.returnOrderCustomer.dateSending);
    textFieldDatePayingController.text = shortDateToString(widget.returnOrderCustomer.datePaying);
    textFieldCommentController.text = widget.returnOrderCustomer.comment;

    // Технические данные
    textFieldUUIDController.text = widget.returnOrderCustomer.uid;
    sendNoTo1C = widget.returnOrderCustomer.sendNoTo1C == 1 ? true : false;
    sendYesTo1C = widget.returnOrderCustomer.sendYesTo1C == 1 ? true : false;
    textFieldDateSendingTo1CController.text =
        shortDateToString(widget.returnOrderCustomer.dateSendingTo1C);
    textFieldNumberFrom1CController.text =
        widget.returnOrderCustomer.numberFrom1C;

    // Заполнение реквизита заказа покупателя
    OrderCustomer orderCustomer =
    await dbReadOrderCustomerUID(widget.returnOrderCustomer.uidParent);
    if (orderCustomer.id != 0) {
      if (orderCustomer.numberFrom1C != '') {
        textFieldOrderCustomerController.text =
            'Заказ № ' + orderCustomer.numberFrom1C;
      } else {
        textFieldOrderCustomerController.text = 'Заказ № <номер не получен>';
      }
    }

    // Проверка Организации
    if ((textFieldPartnerController.text.trim() == '') ||
        (textFieldOrganizationController.text.trim() == '')) {
      textFieldContractController.text = '';
      widget.returnOrderCustomer.nameContract = '';
      widget.returnOrderCustomer.uidContract = '';

      widget.returnOrderCustomer.nameSettlementDocument = '';
      widget.returnOrderCustomer.uidSettlementDocument = '';

      textFieldPriceController.text = '';
      widget.returnOrderCustomer.namePrice = '';
      widget.returnOrderCustomer.uidPrice = '';

      textFieldCurrencyController.text = '';
      widget.returnOrderCustomer.nameCurrency = '';
      widget.returnOrderCustomer.uidCurrency = '';

      textFieldCashboxController.text = '';
    }

    // Проверка договора
    if (textFieldContractController.text.trim() == '') {
      textFieldPriceController.text = '';

      widget.returnOrderCustomer.nameSettlementDocument = '';
      widget.returnOrderCustomer.uidSettlementDocument = '';

      widget.returnOrderCustomer.namePrice = '';
      widget.returnOrderCustomer.uidPrice = '';

      textFieldCurrencyController.text = '';
      widget.returnOrderCustomer.nameCurrency = '';
      widget.returnOrderCustomer.uidCurrency = '';
    }

    setState(() {
      countChangeDoc++;
    });
  }

  renewItems() async {
    countItems = 0;

    if (firstOpen) {
      itemsReturnOrder.clear();

      if (widget.returnOrderCustomer.id != 0) {
        itemsReturnOrder = await dbReadItemsReturnOrderCustomer(widget.returnOrderCustomer.id);
      }
      firstOpen = false;
    }

    // Количество документов в списке
    countItems = itemsReturnOrder.length;
    widget.returnOrderCustomer.countItems = countItems;

    debugPrint('Количество товаров: ' + countItems.toString());

    setState(() {});
  }

  Future<bool> saveDocument() async {
    try {
      if (widget.returnOrderCustomer.status == 2) {
        showErrorMessage('Документ заблокирован! Статус: отправлен.', context);
        return false;
      }

      /// Сумма товаров в заказе
      ReturnOrderCustomer()
          .allSum(widget.returnOrderCustomer, itemsReturnOrder);

      /// Количество товаров в заказе
      ReturnOrderCustomer()
          .allCount(widget.returnOrderCustomer, itemsReturnOrder);

      if (widget.returnOrderCustomer.id != 0) {
        await dbUpdateReturnOrderCustomer(
            widget.returnOrderCustomer, itemsReturnOrder);
        return true;
      } else {
        await dbCreateReturnOrderCustomer(
            widget.returnOrderCustomer, itemsReturnOrder);
        return true;
      }
    } on Exception catch (error) {
      showMessage('Ошибка записи документа!', context);
      debugPrint(error.toString());
      return false;
    }
  }

  Future<bool> deleteDocument() async {
    try {
      if (widget.returnOrderCustomer.id != 0) {
        /// Установим статус записи: 3 - пометка удаления
        widget.returnOrderCustomer.status = 3;

        /// Обновим объект в базе данных
        await dbUpdateReturnOrderCustomer(
            widget.returnOrderCustomer, itemsReturnOrder);
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
              onPressedDelete: () async {
                widget.returnOrderCustomer.nameOrganization = '';
                widget.returnOrderCustomer.uidOrganization = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenOrganizationSelection(
                              returnOrderCustomer: widget.returnOrderCustomer,
                              orderCustomer: OrderCustomer(),
                            )));
                // Если изменили партнера, изменим его договор и валюту
                if (result != null) {
                  if (result) {
                    widget.returnOrderCustomer.nameContract = '';
                    widget.returnOrderCustomer.uidContract = '';
                    widget.returnOrderCustomer.namePrice = '';
                    widget.returnOrderCustomer.uidPrice = '';
                    widget.returnOrderCustomer.nameCurrency = '';
                    widget.returnOrderCustomer.uidCurrency = '';
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
                widget.returnOrderCustomer.namePartner = '';
                widget.returnOrderCustomer.uidPartner = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPartnerSelection(
                            returnOrderCustomer: widget.returnOrderCustomer)));

                // Если изменили партнера, изменим его договор и валюту
                widget.returnOrderCustomer.nameContract = '';
                widget.returnOrderCustomer.uidContract = '';
                widget.returnOrderCustomer.namePrice = '';
                widget.returnOrderCustomer.uidPrice = '';
                widget.returnOrderCustomer.nameCurrency = '';
                widget.returnOrderCustomer.uidCurrency = '';
                updateHeader();
              }),

          /// Contract
          TextFieldWithText(
              textLabel: 'Договор (торговая точка)',
              textEditingController: textFieldContractController,
              onPressedEditIcon: Icons.recent_actors,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.returnOrderCustomer.nameContract = '';
                widget.returnOrderCustomer.uidContract = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenContractSelection(
                            returnOrderCustomer: widget.returnOrderCustomer)));

                // Если изменили контракт, изменим цену и валюту
                widget.returnOrderCustomer.namePrice = '';
                widget.returnOrderCustomer.uidPrice = '';
                widget.returnOrderCustomer.nameCurrency = '';
                widget.returnOrderCustomer.uidCurrency = '';

                await updateHeader();
              }),

          /// OrderCustomer
          TextFieldWithText(
              textLabel: 'Заказ покупателя',
              textEditingController: textFieldOrderCustomerController,
              onPressedEditIcon: Icons.recent_actors,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.returnOrderCustomer.uidParent = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenOrderCustomerSelection(
                            returnOrderCustomer: widget.returnOrderCustomer)));
                updateHeader();
              }),

          /// Settlement document
          TextFieldWithText(
              textLabel: 'Документ расчета',
              textEditingController: textFieldSettlementDocumentController,
              onPressedEditIcon: null,
              onPressedDeleteIcon: null,
              onPressedDelete: () {},
              onPressedEdit: () {}),

          /// Price
          TextFieldWithText(
              textLabel: 'Тип цены продажи',
              textEditingController: textFieldPriceController,
              onPressedEditIcon: Icons.request_quote,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.returnOrderCustomer.namePrice = '';
                widget.returnOrderCustomer.uidPrice = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPriceSelection(
                            returnOrderCustomer: widget.returnOrderCustomer)));

                updateHeader();
              }),

          /// Warehouse
          TextFieldWithText(
              textLabel: 'Склад отгрузки',
              textEditingController: textFieldWarehouseController,
              onPressedEditIcon: Icons.gite,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.returnOrderCustomer.nameWarehouse = '';
                widget.returnOrderCustomer.uidWarehouse = '';
                await updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenWarehouseSelection(
                            returnOrderCustomer: widget.returnOrderCustomer)));
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
                widget.returnOrderCustomer.dateSending = DateTime(1900, 1, 1);
                await updateHeader();
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
                    widget.returnOrderCustomer.dateSending = _datePick;
                  });
                }
                await updateHeader();
              }),

          /// Date paying to partner
          TextFieldWithText(
              textLabel: 'Дата оплаты (планируемая)',
              textEditingController: textFieldDatePayingController,
              onPressedEditIcon: Icons.date_range,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.returnOrderCustomer.datePaying = DateTime(1900, 1, 1);
                await updateHeader();
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
                    widget.returnOrderCustomer.datePaying = _datePick;
                  });
                }
                await updateHeader();
              }),

          /// Comment
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              onSubmitted: (value) async {
                widget.returnOrderCustomer.comment = value;
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
                        var result = await saveDocument();
                        if (result) {
                          showMessage('Запись сохранена!', context);
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
                        var result = await deleteDocument();
                        if (result) {
                          showMessage('Запись отправлена в корзину!', context);
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

  listItemsOrder() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 14, 0),
          child: Row(children: [
            /// Sum of document
            Expanded(
              flex: 3,
              child: TextFieldWithText(
                  textLabel: 'Сумма товаров',
                  textEditingController: textFieldSumController,
                  onPressedEditIcon: null,
                  onPressedDeleteIcon: null,
                  onPressedDelete: () async {},
                  onPressedEdit: () async {}),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.blue)),
                    onPressed: () async {
                      if (widget.returnOrderCustomer.nameOrganization == '') {
                        showErrorMessage('Организация не заполнена!', context);
                        return;
                      }
                      if (widget.returnOrderCustomer.namePartner == '') {
                        showErrorMessage('Партнер не заполнен!', context);
                        return;
                      }
                      if (widget.returnOrderCustomer.nameContract == '') {
                        showErrorMessage('Контракт не заполнен!', context);
                        return;
                      }
                      if (widget.returnOrderCustomer.namePrice == '') {
                        showErrorMessage('Тип цены не заполнен!', context);
                        return;
                      }
                      if (widget.returnOrderCustomer.nameWarehouse == '') {
                        showErrorMessage('Склад не заполнен!', context);
                        return;
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenProductSelectionTreeView(
                              listItemReturnDoc: itemsReturnOrder,
                              returnOrderCustomer: widget.returnOrderCustomer),
                        ),
                      );

                      /// Сумма товаров в заказе
                      ReturnOrderCustomer().allSum(widget.returnOrderCustomer, itemsReturnOrder);

                      /// Количество товаров в заказе
                      ReturnOrderCustomer()
                          .allCount(widget.returnOrderCustomer, itemsReturnOrder);

                      /// Обновление данных
                      renewItems();
                      updateHeader();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Text('Подбор')],
                    )),
              ),
            )
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ColumnListViewBuilder(
              itemCount: itemsReturnOrder.length,
              itemBuilder: (context, index) {
                final item = itemsReturnOrder[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Card(
                      elevation: 2,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) async {
                            if (value == 'delete') {
                              itemsReturnOrder = List.from(itemsReturnOrder)
                                ..removeAt(index);
                              setState(() {
                                ReturnOrderCustomer().allSum(
                                    widget.returnOrderCustomer, itemsReturnOrder);
                                ReturnOrderCustomer().allCount(
                                    widget.returnOrderCustomer, itemsReturnOrder);
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
                                      returnOrderCustomer:
                                          widget.returnOrderCustomer,
                                      listItemReturnDoc: itemsReturnOrder,
                                      indexItem: index,
                                      product: productItem),
                                ),
                              );
                              setState(() {
                                ReturnOrderCustomer().allSum(
                                    widget.returnOrderCustomer, itemsReturnOrder);
                                ReturnOrderCustomer().allCount(
                                    widget.returnOrderCustomer, itemsReturnOrder);
                                updateHeader();
                              });
                            }
                          },
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
                        ),
                      )),
                );
              }),
        ),
      ],
    );
  }

  listServiceOrder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        title: const Text(
          'Параметры документа',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.start,
        ),
        children: [
          /// UUID
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
                        widget.returnOrderCustomer.status = 1;

                        /// Очистка даты отправки заказа вручную
                        textFieldDateSendingTo1CController.text = '';
                      } else {
                        /// Отметим статус заказа как отправленный
                        widget.returnOrderCustomer.status = 2;

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

          /// Buttons Переотправить
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// Переотправить документ
                SizedBox(
                  height: 40,
                  width: (MediaQuery.of(context).size.width - 28),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.blue)),
                      onPressed: () async {
                        /// Отметим статус заказа как неотправленный
                        widget.returnOrderCustomer.status = 1;
                        widget.returnOrderCustomer.dateSendingTo1C = DateTime(1900, 1, 1);
                        widget.returnOrderCustomer.sendYesTo1C = 0;
                        widget.returnOrderCustomer.sendNoTo1C = 0;

                        var result = await saveDocument();
                        if (result) {
                          showMessage('Запись отправлена на отправку!', context);
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.refresh, color: Colors.white),
                          SizedBox(width: 14),
                          Text('Отправить повторно'),
                        ],
                      )),
                ),
              ],
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
                          MaterialStateProperty.all(Colors.red)),
                      onPressed: () async {
                        var result = await deleteDocument();
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
                          Text('Удалить в корзину'),
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
