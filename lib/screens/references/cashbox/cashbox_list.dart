import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/models/ref_cashbox.dart';
import 'package:wp_sales/screens/references/cashbox/cashbox_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenCashboxList extends StatefulWidget {
  const ScreenCashboxList({Key? key}) : super(key: key);

  @override
  _ScreenCashboxListState createState() => _ScreenCashboxListState();
}

class _ScreenCashboxListState extends State<ScreenCashboxList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Cashbox> tempItems = [];
  List<Cashbox> listCashboxes = [];

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
        title: const Text('Кассы'),
      ),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newItem = Cashbox();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenCashboxItem(cashboxItem: newItem),
            ),
          );
          setState(() {
            renewItem();
          });
        },
        tooltip: 'Добавить кассу',
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
    listCashboxes.clear();
    tempItems.clear();

    // Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataCashboxes) {
        Cashbox newItem = Cashbox.fromJson(message);
        listCashboxes.add(newItem);
      }
    } else {
      listCashboxes = await dbReadAllCashbox();
    }

    tempItems.addAll(listCashboxes);

    setState(() {});
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listCashboxes.clear();
        listCashboxes.addAll(tempItems);
      });
      return;
    }

    List<Cashbox> dummySearchList = <Cashbox>[];
    dummySearchList.addAll(listCashboxes);

    if (query.isNotEmpty) {
      List<Cashbox> dummyListData = <Cashbox>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listCashboxes.clear();
        listCashboxes.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listCashboxes.clear();
        listCashboxes.addAll(tempItems);
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
          itemCount: listCashboxes.length,
          itemBuilder: (context, index) {
            var cashboxItem = listCashboxes[index];
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
                              ScreenCashboxItem(cashboxItem: cashboxItem),
                        ),
                      );
                      setState(() {
                        renewItem();
                      });
                    },
                    title: Text(cashboxItem.name),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
