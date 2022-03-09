import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/price.dart';
import 'package:wp_sales/models/warehouse.dart';
import 'package:wp_sales/screens/references/contracts/contract_selection.dart';
import 'package:wp_sales/screens/references/organizations/organization_selection.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/screens/references/price/price_selection.dart';
import 'package:wp_sales/screens/references/product/product_selection.dart';
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
  /// Количество строк товаров в заказе
  int countItems = 0;

  /// Позиции товаров в заказе
  List<ItemOrderCustomer> itemsOrder = [];

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

  /// Поле ввода: Дата отгрузки (отправки)
  TextEditingController textFieldDateSendingController =
      TextEditingController();

  /// Поле ввода: Дата оплаты
  TextEditingController textFieldDatePayingController = TextEditingController();

  /// Поле ввода: Комментарий
  TextEditingController textFieldCommentController = TextEditingController();

  /// Поле ввода: Номер документа в 1С
  TextEditingController textFieldNumberFrom1CController =
      TextEditingController();

  /// Поле ввода: Отправлено в 1С
  bool sendYesTo1C = false;

  /// Поле ввода: Не отправлять в 1С
  bool sendNoTo1C = false;

  /// Поле ввода: Дата отпрваки в 1С
  TextEditingController textFieldDateSendingTo1CController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    updateHeader();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Заказ'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    Warehouse warehouse = await DatabaseHelper.instance
                        .readWarehouseByUID(widget.orderCustomer.uidWarehouse);
                    Price price = await DatabaseHelper.instance
                        .readPriceByUID(widget.orderCustomer.uidPrice);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenProductSelection(
                            listItemDoc: itemsOrder,
                            warehouse: warehouse,
                            price: price),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, size: 26.0),
                )),
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
              children: [listServiceOrder()],
            ),
          ],
        ),
      ),
    );
  }

  updateHeader() {
    setState(() {
      if (widget.orderCustomer.uid == '') {
        widget.orderCustomer.uid = const Uuid().v4();
      }

      countItems = widget.orderCustomer.countItems;
      textFieldOrganizationController.text =
          widget.orderCustomer.nameOrganization;
      textFieldPartnerController.text = widget.orderCustomer.namePartner;
      textFieldContractController.text = widget.orderCustomer.nameContract;
      textFieldPriceController.text = widget.orderCustomer.namePrice;
      textFieldCurrencyController.text = widget.orderCustomer.nameCurrency;
      textFieldWarehouseController.text = widget.orderCustomer.nameWarehouse;
      textFieldSumController.text = doubleToString(widget.orderCustomer.sum);

      textFieldDateSendingController.text =
          shortDateToString(widget.orderCustomer.dateSending);
      textFieldDatePayingController.text =
          shortDateToString(widget.orderCustomer.datePaying);
      textFieldCommentController.text = widget.orderCustomer.comment;

      // Технические данные
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
    });
  }

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(textMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showExitDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Записать документ?'),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text('Закрыть'),
                onPressed: () {
                  Navigator.of(context).pop('Закрыть');
                },
              ),
              SimpleDialogOption(
                child: const Text('Записать'),
                onPressed: () {
                  Navigator.of(context).pop('Записать');
                },
              ),
            ],
          );
        });
  }

  saveDoc() async {
    try {
      if (widget.orderCustomer.id != 0) {
        await DatabaseHelper.instance.updateOrderCustomer(widget.orderCustomer);
        return true;
      } else {
        await DatabaseHelper.instance.createOrderCustomer(widget.orderCustomer);
        return true;
      }
    } on Exception catch (error) {
      debugPrint('Ошибка записи!');
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
        await DatabaseHelper.instance.updateOrderCustomer(widget.orderCustomer);
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

  listItemsOrder() {
    // Очистка списка заказов покупателя
    itemsOrder.clear();

    // Получение и запись списка заказов покупателей
    for (var message in listDataOrderCustomerItems) {
      ItemOrderCustomer newItemOrderCustomer =
          ItemOrderCustomer.fromJson(message);
      itemsOrder.add(newItemOrderCustomer);
    }

    // Количество документов в списке
    countItems = itemsOrder.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: ColumnBuilder(
          itemCount: countItems,
          itemBuilder: (context, index) {
            final item = itemsOrder[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Card(
                elevation: 2,
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
                              child: Text(doubleThreeToString(item.count))),
                          Expanded(flex: 1, child: Text(item.nameUnit)),
                          Expanded(
                              flex: 1, child: Text(doubleToString(item.price))),
                          Expanded(
                              flex: 1,
                              child: Text(doubleToString(item.discount))),
                          Expanded(
                              flex: 1, child: Text(doubleToString(item.sum))),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Редактировать'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Удалить'),
                        )
                      ];
                    },
                    onSelected: (String value) {
                      debugPrint('You Click on po up menu item');
                    },
                  ),
                ),
              ),
            );
          }),
    );
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
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPartnerSelection(
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
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenContractSelection(
                            orderCustomer: widget.orderCustomer)));
                // Если изменили партнера, изменим его договор и валюту
                if (result != null) {
                  if (result) {
                    widget.orderCustomer.namePrice = '';
                    widget.orderCustomer.uidPrice = '';
                    widget.orderCustomer.nameCurrency = '';
                    widget.orderCustomer.uidCurrency = '';
                  }
                }
                updateHeader();
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
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPriceSelection(
                            orderCustomer: widget.orderCustomer)));
                // Если изменили партнера, изменим его договор и валюту
                if (result != null) {
                  if (result) {
                    widget.orderCustomer.namePrice = '';
                    widget.orderCustomer.uidPrice = '';
                  }
                }
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
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenWarehouseSelection(
                            orderCustomer: widget.orderCustomer)));
                // Если изменили партнера, изменим его договор и валюту
                if (result != null) {
                  if (result) {
                    widget.orderCustomer.nameWarehouse = '';
                    widget.orderCustomer.uidWarehouse = '';
                  }
                }
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
                setState(() {
                  textFieldDateSendingController.text = '';
                  widget.orderCustomer.dateSending = DateTime(1900, 1, 1);
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
                setState(() {
                  textFieldDatePayingController.text = '';
                  widget.orderCustomer.datePaying = DateTime(1900, 1, 1);
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
                }
              }),

          /// Comment
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              maxLines: 3,
              keyboardType: TextInputType.text,
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

          /// Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// Записать документ
                SizedBox(
                  height: 40,
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
                          Icon(Icons.update, color: Colors.white),
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
                  height: 40,
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

  listServiceOrder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: Column(
        children: [
          /// Date sending to 1C
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
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
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
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
                      /// Если нельзя отправлять в 1С, то скажем об этом
                      if (sendNoTo1C) {
                        const snackBar = SnackBar(
                          content: Text(
                              'Ошибка! Установлен флаг: Не отправлять в 1С!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        sendYesTo1C = false;
                      } else {
                        sendYesTo1C = !sendYesTo1C;
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
        ],
      ),
    );
  }
}
