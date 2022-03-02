import 'package:flutter/material.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/screens/documents/order_customer_add_item.dart';
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

  /// Тестовые данные
  final tempItemsOrders = [
    {
      'id': 1,
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'name': 'Подовжувач 2 гнізда 5м без з/з LILA 720-0205-203 Lezard',
      'uidUnit': '',
      'nameUnit': 'шт.',
      'count': 3.0,
      'price': 63.67,
      'discount': 0.0,
      'sum': 191.01
    },
    {
      'id': 2,
      'uid': '03704c3a-025e-4d5b-93f9-9213a338e807',
      'name': 'Лампа світл G45 9W E27 4200K LED GLOB Lezard',
      'uidUnit': '',
      'nameUnit': 'шт.',
      'count': 3.0,
      'price': 63.67,
      'discount': 0.0,
      'sum': 191.01
    },
    {
      'id': 3,
      'uid': '03704c3a-025e-4d5b-73f9-9213a338e807',
      'name': 'Прожектор 50W 6400K чорний IP65 230V LL-8050 Feron',
      'uidUnit': '',
      'nameUnit': 'шт.',
      'count': 5.0,
      'price': 261.52,
      'discount': 0.0,
      'sum': 1307.60
    },
    {
      'id': 4,
      'uid': '03704c3a-025e-4d5b-83f9-9213a338e807',
      'name': 'СІП 2х16 кабель',
      'uidUnit': '',
      'nameUnit': 'м.п.',
      'count': 11.0,
      'price': 18.4,
      'discount': 0.0,
      'sum': 1202.4
    },
  ];

  @override
  void initState() {
    setState(() {
      countItems = widget.orderCustomer.countItems;
      textFieldOrganizationController.text = widget.orderCustomer.nameOrganization;
      textFieldPartnerController.text = widget.orderCustomer.namePartner;
      textFieldContractController.text = widget.orderCustomer.nameContract;
      textFieldPriceController.text = widget.orderCustomer.namePrice;
      textFieldWarehouseController.text = widget.orderCustomer.nameWarehouse;
      textFieldCurrencyController.text = widget.orderCustomer.nameCurrency;
      textFieldSumController.text = doubleToString(widget.orderCustomer.sum);

      textFieldDateSendingController.text = shortDateToString(widget.orderCustomer.dateSending);
      textFieldDatePayingController.text = shortDateToString(widget.orderCustomer.datePaying);
      textFieldCommentController.text = widget.orderCustomer.comment;

      // Технические данные
      sendNoTo1C = widget.orderCustomer.sendNoTo1C == 1 ? true : false;
      sendYesTo1C = widget.orderCustomer.sendYesTo1C == 1 ? true : false;
      textFieldDateSendingTo1CController.text = shortDateToString(widget.orderCustomer.dateSendingTo1C);
      textFieldNumberFrom1CController.text = widget.orderCustomer.numberFrom1C;

    });

    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Заказ покупателя'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.filter_list, size: 26.0),
                )),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.filter_1), text: 'Главная'),
              Tab(icon: Icon(Icons.list), text: 'Товары'),
              Tab(icon: Icon(Icons.tune), text: 'Служебные'),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddItemOrderCustomer(itemOrderCustomer: itemsOrder),
              ),
            );
          },
          tooltip: '+',
          child: const Text(
            "+",
            style: TextStyle(fontSize: 30),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:Text(textMessage),
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

  saveDocument() {
    return true;
  }

  deleteDocument() {
    return true;
  }

  eraseDocument() {
    return true;
  }

  listItemsOrder() {
    // Очистка списка заказов покупателя
    itemsOrder.clear();

    // Получение и запись списка заказов покупателей
    for (var message in tempItemsOrders) {
      ItemOrderCustomer newItemOrderCustomer =
          ItemOrderCustomer.fromJson(message);
      itemsOrder.add(newItemOrderCustomer);
    }

    // Количество документов в списке
    countItems = itemsOrder.length;

    return ColumnBuilder(
        itemCount: countItems,
        itemBuilder: (context, index) {
          final item = itemsOrder[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(10,5,10,0),
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
        });
  }

  listHeaderOrder() {
    var validateOrganisation = false;
    var validatePartner = false;
    var validateContract = false;
    var validateWarehouse = false;

    return Column(
      children: [
        /// Organization
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            controller: textFieldOrganizationController,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Организация',
              errorText:
                  validateOrganisation ? 'Вы не указали организацию!' : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.people, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Partner
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldPartnerController,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Партнер',
              errorText: validatePartner ? 'Вы не указали партнера!' : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.people, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Contract
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldContractController,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Договор (торговая точка)',
              errorText: validateContract
                  ? 'Вы не указали договор (торговую точку)!'
                  : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.recent_actors, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Price
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldPriceController,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Тип цены продажи',
              errorText: validateContract ? 'Вы не указали тип цены' : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.request_quote, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Warehouse
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldWarehouseController,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Склад отгрузки',
              errorText: validateWarehouse ? 'Вы не указали склад!' : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.gite, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Sum of document
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldSumController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Сумма документа',
              suffixIcon: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textFieldCurrencyController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Divider
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
          child: Divider(),
        ),

        /// Sending date to partner
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldDateSendingController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Дата отгрузки',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min, //
                children: [
                  IconButton(
                    onPressed: () async {
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
                        });
                      }
                    },
                    icon: const Icon(Icons.date_range, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        textFieldDateSendingController.text = '';
                      });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Paying of partner
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldDatePayingController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Дата оплаты',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min, //
                children: [
                  IconButton(
                    onPressed: () async {
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
                        });
                      }
                    },
                    icon: const Icon(Icons.date_range, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        textFieldDatePayingController.text = '';
                      });
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
            textInputAction: TextInputAction.continueAction,
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
                height: 40,
                width: (MediaQuery.of(context).size.width - 49) / 2,
                child: ElevatedButton(
                    onPressed: () async {
                      var result = saveDocument();
                      if (result) {
                        showMessage('Запись сохранена!');
                        Navigator.of(context).pop();
                      } else {
                        return;
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
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: () async {
                      var result = deleteDocument();
                      if (result) {
                        showMessage('Запись помечена на удаление!');
                        Navigator.of(context).pop();
                      } else {
                        return;
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
    );
  }

  listServiceOrder() {
    return Column(
      children: [
        /// Date sending to 1C
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            controller: textFieldDateSendingTo1CController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(
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
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(
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
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
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
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
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
    );
  }
}
