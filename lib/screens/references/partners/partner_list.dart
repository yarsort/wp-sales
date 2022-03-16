import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/models/ref_partner.dart';
import 'package:wp_sales/screens/references/partners/partner_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenPartnerList extends StatefulWidget {
  const ScreenPartnerList({Key? key}) : super(key: key);

  @override
  _ScreenPartnerListState createState() => _ScreenPartnerListState();
}

class _ScreenPartnerListState extends State<ScreenPartnerList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Partner> tempItems = [];
  List<Partner> listPartners = [];

  @override
  void initState() {
    super.initState();
    renewItem();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newItem = Partner();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenPartnerItem(partnerItem: newItem),
            ),
          );
          setState(() {
            renewItem();
          });
        },
        tooltip: 'Добавить партнера',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 25),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    final SharedPreferences prefs = await _prefs;
    bool useTestData = prefs.getBool('settings_useTestData') ?? false;

    // Очистка списка заказов покупателя
    listPartners.clear();
    tempItems.clear();

    // Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataPartners) {
        Partner newItem = Partner.fromJson(message);
        listPartners.add(newItem);
      }
    } else {
      listPartners = await dbReadAllPartners();
    }

    tempItems.addAll(listPartners);

    setState(() {});
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listPartners.clear();
        listPartners.addAll(tempItems);
      });
      return;
    }

    List<Partner> dummySearchList = <Partner>[];
    dummySearchList.addAll(listPartners);

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
        listPartners.clear();
        listPartners.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listPartners.clear();
        listPartners.addAll(tempItems);
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
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
          itemCount: listPartners.length,
          itemBuilder: (context, index) {
            var partnerItem = listPartners[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScreenPartnerItem(partnerItem: partnerItem),
                        ),
                      );
                      setState(() {
                        renewItem();
                      });
                    },
                    title: Text(partnerItem.name),
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
                                      Text(partnerItem.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.home,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Flexible(
                                          child: Text(partnerItem.address)),
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
                                      Text(doubleToString(partnerItem.balance)),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.price_change,
                                          color: Colors.red, size: 20),
                                      const SizedBox(width: 5),
                                      Text(doubleToString(
                                          partnerItem.balanceForPayment)),
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
                ));
          },
        ),
      ),
    );
  }
}
