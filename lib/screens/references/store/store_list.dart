import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_ref_store.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/screens/references/store/store_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenStoreList extends StatefulWidget {
  const ScreenStoreList({Key? key}) : super(key: key);

  @override
  _ScreenStoreListState createState() => _ScreenStoreListState();
}

class _ScreenStoreListState extends State<ScreenStoreList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool loadingItems = false;

  bool deniedAddStore = false;

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Store> tempItems = [];
  List<Store> listStores = [];

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
        title: const Text('Магазины партнеров'),
      ),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: deniedAddStore
          ? FloatingActionButton(
              onPressed: () async {
                var newItem = Store();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScreenStoreItem(storeItem: newItem),
                  ),
                );
                setState(() {
                  renewItem();
                });
              },
              tooltip: 'Добавить договор',
              child: const Text(
                "+",
                style: TextStyle(fontSize: 25),
              ),
            )
          : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {

    setState(() {
      loadingItems = true;
    });

    final SharedPreferences prefs = await _prefs;

    bool useTestData = prefs.getBool('settings_useTestData') ?? false;

    // Настройки редактирования
    deniedAddStore =
        prefs.getBool('settings_deniedAddStore') ?? false;

    // Очистка списка заказов покупателя
    listStores.clear();
    tempItems.clear();

    // Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataPrice) {
        Store newItem = Store.fromJson(message);
        listStores.add(newItem);
      }
    } else {
      listStores = await dbReadAllStore();
    }

    listStores.sort((a, b) => a.name.compareTo(b.name));

    tempItems.addAll(listStores);

    if (mounted) {
      setState(() {
        loadingItems = false;
      });
    } else {
      loadingItems = false;
    }
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listStores.clear();
        listStores.addAll(tempItems);
      });
      return;
    }

    List<Store> dummySearchList = <Store>[];
    dummySearchList.addAll(listStores);

    if (query.isNotEmpty) {
      List<Store> dummyListData = <Store>[];

      for (var item in dummySearchList) {
        /// Поиск по имени контракта
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }

        /// Поиск по адресу
        if (item.address.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listStores.clear();
        listStores.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listStores.clear();
        listStores.addAll(tempItems);
      });
    }
  }

  searchTextField() {
    var validateSearch = false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
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
        ),
      ],
    );
  }

  listViewItems() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 0, 9, 14),
        child: !loadingItems ? ListView.builder(
          shrinkWrap: true,
          itemCount: listStores.length,
          itemBuilder: (context, index) {
            var storeItem = listStores[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: StoreItem(
                  storeItem: storeItem,
                ));
          },
        ) : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class StoreItem extends StatefulWidget {
  final Store storeItem;

  const StoreItem(
      {Key? key, required this.storeItem})
      : super(key: key);

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return cardStore();
  }

  cardStore() {
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
                      ScreenStoreItem(storeItem: widget.storeItem),
                ),
              );
            },
            title: Text(widget.storeItem.name),
            subtitle: Column(
              children: [
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.source,
                        color: Colors.blue, size: 20),
                    const SizedBox(width: 5),
                    Flexible(flex: 1 ,child: Text(widget.storeItem.name)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.home,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 5),
                              Flexible(
                                  child: Text(widget.storeItem.address)),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
