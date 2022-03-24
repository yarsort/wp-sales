import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_doc_incoming_cash_order.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/db/db_ref_organization.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/ref_cashbox.dart';
import 'package:wp_sales/models/ref_contract.dart';
import 'package:wp_sales/models/ref_organization.dart';
import 'package:wp_sales/models/ref_partner.dart';
import 'package:wp_sales/screens/documents/order_customer/order_customer_selection.dart';
import 'package:wp_sales/screens/references/cashbox/cashbox_selection.dart';
import 'package:wp_sales/screens/references/contracts/contract_selection.dart';
import 'package:wp_sales/screens/references/organizations/organization_selection.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenItemIncomingCashOrder extends StatefulWidget {
  final IncomingCashOrder incomingCashOrder;

  const ScreenItemIncomingCashOrder({
    Key? key,
    required this.incomingCashOrder,
  }) : super(key: key);

  @override
  State<ScreenItemIncomingCashOrder> createState() =>
      _ScreenItemIncomingCashOrderState();
}

class _ScreenItemIncomingCashOrderState
    extends State<ScreenItemIncomingCashOrder> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int countChangeDoc = 0;

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

  /// Поле ввода: Касса
  TextEditingController textFieldCashboxController = TextEditingController();

  /// Поле ввода: Баланс контракта или заказа покупателя
  TextEditingController textFieldBalanceController = TextEditingController();

  /// Поле ввода: Баланс контракта или заказа покупателя
  TextEditingController textFieldBalanceForPaymentController =
      TextEditingController();

  /// Поле ввода: Сумма документа
  TextEditingController textFieldSumController = TextEditingController();

  /// Поле ввода: Валюта документа
  TextEditingController textFieldCurrencyController = TextEditingController();

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
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('ПКО'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Главная'),
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
                  listServiceOrder(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  readBalance() async {
    // Получить баланс заказа
    Map debts = await dbReadSumAccumPartnerDeptByContractDoc(
        uidContract: widget.incomingCashOrder.uidContract,
        uidDoc: widget.incomingCashOrder.uidParent);

    // Запись в реквизиты
    textFieldBalanceController.text = doubleToString(debts['balance']);
    textFieldBalanceForPaymentController.text =
        doubleToString(debts['balanceForPayment']);
  }

  saveDocument() async {
    try {
      if (widget.incomingCashOrder.id != 0) {
        // Обновим объект документа
        await dbUpdateIncomingCashOrder(widget.incomingCashOrder);

        // При записи в регистр накопления "Взаиморасчеты" сумма долга снижается
        // После записи новых данных обмена из учетной системы сумма удаляется
        await dbCreateAccumPartnerDeptsByRegistrar(widget.incomingCashOrder);

        return true;
      } else {
        // Создадим объект документа
        await dbCreateIncomingCashOrder(widget.incomingCashOrder);

        // При записи в регистр накопления "Взаиморасчеты" сумма долга снижается
        // После записи новых данных обмена из учетной системы сумма удаляется
        await dbCreateAccumPartnerDeptsByRegistrar(widget.incomingCashOrder);

        return true;
      }
    } on Exception catch (error) {
      showMessage('Ошибка записи документа!');
      debugPrint(error.toString());
      return false;
    }
  }

  deleteDocument() async {
    try {
      if (widget.incomingCashOrder.id != 0) {
        /// Установим статус записи: 3 - пометка удаления
        widget.incomingCashOrder.status = 3;

        // Обновим объект в базе данных
        await dbUpdateIncomingCashOrder(widget.incomingCashOrder);

        // При записи в регистр накопления "Взаиморасчеты" сумма долга снижается
        // После записи новых данных обмена из учетной системы сумма удаляется
        await dbCreateAccumPartnerDeptsByRegistrar(widget.incomingCashOrder);

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

  updateHeader() async {
    // Заполнение реквизита заказа покупателя
    if (widget.incomingCashOrder.uidParent != '') {
      OrderCustomer orderCustomer =
          await dbReadOrderCustomerUID(widget.incomingCashOrder.uidParent);
      if (orderCustomer.id != 0) {
        if (orderCustomer.numberFrom1C != '') {
          textFieldOrderCustomerController.text =
              'Заказ № ' + orderCustomer.numberFrom1C;
        } else {
          textFieldOrderCustomerController.text = widget.incomingCashOrder.nameParent;
        }

        widget.incomingCashOrder.uidOrganization =
            orderCustomer.uidOrganization;
        widget.incomingCashOrder.uidPartner = orderCustomer.uidPartner;
        widget.incomingCashOrder.uidContract = orderCustomer.uidContract;
        widget.incomingCashOrder.uidCashbox = orderCustomer.uidCashbox;
      } else {
        // Наименование заказа покупателя
        textFieldOrderCustomerController.text =
            widget.incomingCashOrder.nameParent;
      }
    }

    // Заполняем значениями из настроек (по-умолчанию)
    final SharedPreferences prefs = await _prefs;

    /// Заполнение значений по-умолчанию: из документа или из настроек

    widget.incomingCashOrder.uidOrganization =
        widget.incomingCashOrder.uidOrganization == ''
            ? prefs.getString('settings_uidOrganization') ?? ''
            : widget.incomingCashOrder.uidOrganization;

    widget.incomingCashOrder.uidPartner =
        widget.incomingCashOrder.uidPartner == ''
            ? prefs.getString('settings_uidPartner') ?? ''
            : widget.incomingCashOrder.uidPartner;

    widget.incomingCashOrder.uidContract =
        widget.incomingCashOrder.uidContract == ''
            ? ''
            : widget.incomingCashOrder.uidContract;

    widget.incomingCashOrder.uidCashbox =
        widget.incomingCashOrder.uidCashbox == ''
            ? prefs.getString('settings_uidCashbox') ?? ''
            : widget.incomingCashOrder.uidCashbox;

    /// Для всех реквизитов теперь установим текстовые значения на форме по их UID

    Organization organization =
        await dbReadOrganizationUID(widget.incomingCashOrder.uidOrganization);
    widget.incomingCashOrder.nameOrganization = organization.name;

    Partner partner =
        await dbReadPartnerUID(widget.incomingCashOrder.uidPartner);
    widget.incomingCashOrder.namePartner = partner.name;

    Contract contract =
        await dbReadContractUID(widget.incomingCashOrder.uidContract);
    widget.incomingCashOrder.nameContract = contract.name;

    Cashbox cashbox =
        await dbReadCashboxUID(widget.incomingCashOrder.uidCashbox);
    widget.incomingCashOrder.nameCashbox = cashbox.name;

    // Теперь запишем идентификатор объекта
    if (widget.incomingCashOrder.uid == '') {
      widget.incomingCashOrder.uid = const Uuid().v4();
    }

    // Расчет реквизитов наименований на форме
    textFieldOrganizationController.text =
        widget.incomingCashOrder.nameOrganization;
    textFieldPartnerController.text = widget.incomingCashOrder.namePartner;
    textFieldContractController.text = widget.incomingCashOrder.nameContract;
    textFieldCurrencyController.text = widget.incomingCashOrder.nameCurrency;
    textFieldCashboxController.text = widget.incomingCashOrder.nameCashbox;
    textFieldSumController.text = doubleToString(widget.incomingCashOrder.sum);
    textFieldCommentController.text = widget.incomingCashOrder.comment;

    // Технические данные
    textFieldUUIDController.text = widget.incomingCashOrder.uid;
    sendNoTo1C = widget.incomingCashOrder.sendNoTo1C == 1 ? true : false;
    sendYesTo1C = widget.incomingCashOrder.sendYesTo1C == 1 ? true : false;
    textFieldDateSendingTo1CController.text =
        shortDateToString(widget.incomingCashOrder.dateSendingTo1C);
    textFieldNumberFrom1CController.text =
        widget.incomingCashOrder.numberFrom1C;

    // Заполнение реквизита заказа покупателя
    OrderCustomer orderCustomer =
        await dbReadOrderCustomerUID(widget.incomingCashOrder.uidParent);
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
      widget.incomingCashOrder.nameContract = '';
      widget.incomingCashOrder.uidContract = '';

      textFieldCurrencyController.text = '';
      widget.incomingCashOrder.nameCurrency = '';
      widget.incomingCashOrder.uidCurrency = '';

      textFieldCashboxController.text = '';
      widget.incomingCashOrder.nameCashbox = '';
      widget.incomingCashOrder.uidCashbox = '';
    }

    // Проверка договора
    if (textFieldContractController.text.trim() == '') {
      textFieldCurrencyController.text = '';
      widget.incomingCashOrder.nameCurrency = '';
      widget.incomingCashOrder.uidCurrency = '';
    }

    readBalance();

    setState(() {
      countChangeDoc++;
    });
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
              onPressedDelete: () {
                widget.incomingCashOrder.uidOrganization = '';
                widget.incomingCashOrder.nameOrganization = '';
                updateHeader();
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenOrganizationSelection(
                            orderCustomer: orderCustomer)));
                // Изменение организации
                widget.incomingCashOrder.uidOrganization =
                    orderCustomer.uidOrganization;
                widget.incomingCashOrder.nameOrganization =
                    orderCustomer.nameOrganization;
                updateHeader();
              }),

          /// Partner
          TextFieldWithText(
              textLabel: 'Партнер',
              textEditingController: textFieldPartnerController,
              onPressedEditIcon: Icons.people,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.incomingCashOrder.uidPartner = '';
                widget.incomingCashOrder.namePartner = '';
                updateHeader();
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPartnerSelection(
                            orderCustomer: orderCustomer)));
                // Изменение партнера
                widget.incomingCashOrder.uidPartner = orderCustomer.uidPartner;
                widget.incomingCashOrder.namePartner =
                    orderCustomer.namePartner;
                updateHeader();
              }),

          /// Contract
          TextFieldWithText(
              textLabel: 'Договор (торговая точка)',
              textEditingController: textFieldContractController,
              onPressedEditIcon: Icons.recent_actors,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.incomingCashOrder.uidContract = '';
                widget.incomingCashOrder.nameContract = '';
                updateHeader();
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                orderCustomer.uidPartner = widget.incomingCashOrder.uidPartner;
                orderCustomer.namePartner =
                    widget.incomingCashOrder.namePartner;
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenContractSelection(
                            orderCustomer: orderCustomer)));
                // Изменение договора
                widget.incomingCashOrder.uidContract =
                    orderCustomer.uidContract;
                widget.incomingCashOrder.nameContract =
                    orderCustomer.nameContract;
                updateHeader();
              }),

          /// OrderCustomer
          TextFieldWithText(
              textLabel: 'Заказ покупателя',
              textEditingController: textFieldOrderCustomerController,
              onPressedEditIcon: Icons.recent_actors,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.incomingCashOrder.uidParent = '';
                updateHeader();
              },
              onPressedEdit: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenOrderCustomerSelection(
                            incomingCashOrder: widget.incomingCashOrder)));
                updateHeader();
              }),

          /// Cashbox
          TextFieldWithText(
              textLabel: 'Касса',
              textEditingController: textFieldCashboxController,
              onPressedEditIcon: Icons.request_quote,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                widget.incomingCashOrder.uidCashbox = '';
                widget.incomingCashOrder.nameCashbox = '';
                updateHeader();
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenCashboxSelection(
                            orderCustomer: orderCustomer)));
                widget.incomingCashOrder.uidCashbox = orderCustomer.uidCashbox;
                widget.incomingCashOrder.nameCashbox =
                    orderCustomer.nameCashbox;
                updateHeader();
              }),

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

          /// Sum of document
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                onSubmitted: (value) {
                  countChangeDoc++;

                  textFieldSumController.text =
                      doubleToString(double.parse(value));
                  widget.incomingCashOrder.sum = double.parse(value);
                },
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                controller: textFieldSumController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                ],
                decoration: InputDecoration(
                  isDense: true,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 2,
                    minHeight: 2,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  border: const OutlineInputBorder(),
                  labelStyle: const TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'Сумма документа',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            countChangeDoc++;
                            widget.incomingCashOrder.sum = 0.0;
                            updateHeader();
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        //icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
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
              onSubmitted: (value) async {
                widget.incomingCashOrder.comment = value;
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
                        var result = await deleteDocument();
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
              onChanged: (value) {
                setState(() {
                  countChangeDoc++;
                });
              },
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
              onChanged: (value) {
                setState(() {
                  countChangeDoc++;
                });
              },
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
                        widget.incomingCashOrder.status = 1;

                        /// Очистка даты отправки заказа вручную
                        textFieldDateSendingTo1CController.text = '';
                      } else {
                        /// Отметим статус заказа как отправленный
                        widget.incomingCashOrder.status = 2;

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
                        var result = await deleteDocument();
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
