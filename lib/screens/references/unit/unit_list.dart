import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_ref_unit.dart';
import 'package:wp_sales/models/ref_unit.dart';
import 'package:wp_sales/screens/references/unit/unit_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenUnitList extends StatefulWidget {
  const ScreenUnitList({Key? key}) : super(key: key);

  @override
  _ScreenUnitListState createState() => _ScreenUnitListState();
}

class _ScreenUnitListState extends State<ScreenUnitList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  bool deniedEditUnits = false;

  List<Unit> tempItems = [];
  List<Unit> listUnit = [];

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
        title: const Text('Единицы измерений'),
      ),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: deniedEditUnits ? FloatingActionButton(
        onPressed: () async {
          var newItem = Unit();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenUnitItem(unitItem: newItem),
            ),
          );
          renewItem();
        },
        tooltip: 'Добавить единицу измерения',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 25),
        ),
      ) : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    final SharedPreferences prefs = await _prefs;
    bool useTestData = prefs.getBool('settings_useTestData') ?? false;

    // Настройки редактирования
    deniedEditUnits = prefs.getBool('settings_deniedEditUnits') ?? false;

    // Очистка списка заказов покупателя
    listUnit.clear();
    tempItems.clear();

    // Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataUnit) {
        Unit newItem = Unit.fromJson(message);
        listUnit.add(newItem);
      }
    } else {
      listUnit = await dbReadAllUnit();
    }

    tempItems.addAll(listUnit);

    setState(() {});
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listUnit.clear();
        listUnit.addAll(tempItems);
      });
      return;
    }

    List<Unit> dummySearchList = <Unit>[];
    dummySearchList.addAll(listUnit);

    if (query.isNotEmpty) {
      List<Unit> dummyListData = <Unit>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listUnit.clear();
        listUnit.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listUnit.clear();
        listUnit.addAll(tempItems);
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
          itemCount: listUnit.length,
          itemBuilder: (context, index) {
            var unitItem = listUnit[index];
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
                              ScreenUnitItem(unitItem: unitItem),
                        ),
                      );
                      renewItem();
                    },
                    title: Text(unitItem.name),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
