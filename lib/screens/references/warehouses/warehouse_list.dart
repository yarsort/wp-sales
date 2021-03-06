import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_ref_warehouse.dart';
import 'package:wp_sales/models/ref_warehouse.dart';
import 'package:wp_sales/screens/references/warehouses/warehouse_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenWarehouseList extends StatefulWidget {
  const ScreenWarehouseList({Key? key}) : super(key: key);

  @override
  _ScreenWarehouseListState createState() => _ScreenWarehouseListState();
}

class _ScreenWarehouseListState extends State<ScreenWarehouseList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  bool deniedAddWarehouse = false;

  List<Warehouse> tempItems = [];
  List<Warehouse> listWarehouses = [];

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
        title: const Text('Склады'),
      ),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: deniedAddWarehouse ? FloatingActionButton(
        onPressed: () async {
          var newItem = Warehouse();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenWarehouseItem(warehouseItem: newItem),
            ),
          );
          setState(() {
            renewItem();
          });
        },
        tooltip: 'Добавить склад',
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
    deniedAddWarehouse = prefs.getBool('settings_deniedAddWarehouse') ?? false;

    // Очистка списка заказов покупателя
    listWarehouses.clear();
    tempItems.clear();

    // Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataWarehouses) {
        Warehouse newItem = Warehouse.fromJson(message);
        listWarehouses.add(newItem);
      }
    } else {
      listWarehouses = await dbReadAllWarehouse();
    }

    tempItems.addAll(listWarehouses);

    setState(() {});
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listWarehouses.clear();
        listWarehouses.addAll(tempItems);
      });
      return;
    }

    List<Warehouse> dummySearchList = <Warehouse>[];
    dummySearchList.addAll(listWarehouses);

    if (query.isNotEmpty) {
      List<Warehouse> dummyListData = <Warehouse>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
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
        listWarehouses.clear();
        listWarehouses.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listWarehouses.clear();
        listWarehouses.addAll(tempItems);
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
          itemCount: listWarehouses.length,
          itemBuilder: (context, index) {
            var warehouseItem = listWarehouses[index];
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
                              ScreenWarehouseItem(warehouseItem: warehouseItem),
                        ),
                      );
                      setState(() {
                        renewItem();
                      });
                    },
                    title: Text(warehouseItem.name),
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
                                      Text(warehouseItem.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.home,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Flexible(
                                          child: Text(warehouseItem.address)),
                                    ],
                                  )
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
