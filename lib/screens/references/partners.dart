import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wp_sales/models/partner.dart';
import 'package:wp_sales/system/system.dart';

class ScreenCustomers extends StatefulWidget {
  const ScreenCustomers({Key? key}) : super(key: key);

  @override
  _ScreenCustomersState createState() => _ScreenCustomersState();
}

class _ScreenCustomersState extends State<ScreenCustomers> {
  /// Поле ввода: Поиск партнеров
  TextEditingController textFieldSearchController = TextEditingController();

  /// Тестовые данные
  final messageList = [
    {
      'id': 1,
      'isGroup': true,
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'name': 'ФОП Сергеев Алексей',
      'uidParent': '13704c3a-025e-4d5b-b3f9-9213a338e807',
      'balance': 6408.10,
      'balanceForPayment': 0.0,
      'phone': '0988547870',
      'address': 'П.Сагайдачного 32, дом 12',
      'schedulePayment': 0,
    },
    {
      'id': 1,
      'isGroup': false,
      'uid': '13704c3a-025e-4d5b-b3f9-9213a338e807',
      'name': 'ТОВ "Амагама"',
      'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'balance': 3580.59,
      'balanceForPayment': 1550.0,
      'phone': '(098)8547870',
      'address': 'Магазин "Красуня", г. Винница, ул. С. Долгорукого 50',
      'schedulePayment': 7,
    },
    {
      'id': 1,
      'isGroup': false,
      'uid': '23704c3a-025e-4d5b-b3f9-9213a338e807',
      'name': 'ТОВ "Промприбор"',
      'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'balance': 564.0,
      'balanceForPayment': 150.0,
      'phone': '0988547870',
      'address': 'П.Сагайдачного 32, дом 12',
      'schedulePayment': 30,
    },
    {
      'id': 1,
      'isGroup': false,
      'uid': '33704c3a-025e-4d5b-b3f9-9213a338e807',
      'name': 'ТОВ "Агротрейдинг"',
      'uidParent': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'balance': 195600.0,
      'balanceForPayment': 3600.0,
      'phone': '0988547870',
      'address': 'П.Сагайдачного 32, дом 12',
      'schedulePayment': 10,
    },
  ];

  var tempItems = <Partner>[];
  var items = <Partner>[];

  @override
  void initState() {
    renewItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Партнеры'),
      ),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
    );
  }

  void renewItem() {
    // Очистка списка заказов покупателя
    items.clear();
    tempItems.clear();

    // Получение и запись списка заказов покупателей
    for (var message in messageList) {
      Partner newPartner = Partner.fromJson(message);
      items.add(newPartner);
      tempItems.add(newPartner); // Как шаблон
    }
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        items.clear();
        items.addAll(tempItems);
      });
      return;
    }

    List<Partner> dummySearchList = <Partner>[];
    dummySearchList.addAll(items);

    if (query.isNotEmpty) {

      List<Partner> dummyListData = <Partner>[];

      for (var item in dummySearchList) {
        /// Поиск по имени партнера
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        /// Поиск по адресу
        if (item.address.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
        /// Поиск по номеру телефона
        if (item.phone.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(tempItems);
      });
    }
  }

  searchTextField() {
    var validateSearch = false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
      child: TextField(
        onChanged: (String value) {
          filterSearchResults(value);
        },
        controller: textFieldSearchController,
        textInputAction: TextInputAction.continueAction,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelStyle: const TextStyle(
            color: Colors.blueGrey,
          ),
          labelText: 'Поиск',
          errorText: validateSearch ? 'Вы не указали строку поиска!' : null,
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  var value = textFieldSearchController.text;
                  filterSearchResults(value);
                },
                icon: const Icon(Icons.search, color: Colors.blue),
              ),
              IconButton(
                onPressed: () async {
                  textFieldSearchController.text = '';
                  var value = textFieldSearchController.text;
                  filterSearchResults(value);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  listViewItems() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 0, 9, 14),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Card(
                elevation: 2,
                  child: ListTile(
                    onTap: () {},
                    title: Text(item.name),
                    subtitle: Column(
                      children: [
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Text(item.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.home, color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Flexible(child: Text(item.address)),
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
                                      const Icon(Icons.price_change, color: Colors.green, size: 20),
                                      const SizedBox(width: 5),
                                      Text(doubleToString(item.balance)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.price_change, color: Colors.red, size: 20),
                                      const SizedBox(width: 5),
                                      Text(doubleToString(item.balanceForPayment)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, color: Colors.blue,size: 20),
                                      const SizedBox(width: 5),
                                      Text(item.schedulePayment.toString()),
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
                ) 
              );            
          },
        ),
      ),
    );
  }
}
