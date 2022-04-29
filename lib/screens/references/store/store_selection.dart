import 'package:flutter/material.dart';
import 'package:wp_sales/screens/references/store/store_item.dart';

import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';

class ScreenStoreSelection extends StatefulWidget {
  final OrderCustomer? orderCustomer;
  final ReturnOrderCustomer? returnOrderCustomer;
  final IncomingCashOrder? incomingCashOrder;

  const ScreenStoreSelection(
      {Key? key, this.orderCustomer, this.returnOrderCustomer, this.incomingCashOrder})
      : super(key: key);

  @override
  _ScreenStoreSelectionState createState() =>
      _ScreenStoreSelectionState();
}

class _ScreenStoreSelectionState extends State<ScreenStoreSelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Store> tempItems = [];
  List<Store> listStores = [];

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
        title: const Text('Магазины партнера'),
      ),
      //drawer: const MainDrawer(),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var newStoreItem = Store();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ScreenStoreItem(storeItem: newStoreItem),
            ),
          );
        },
        tooltip: 'Добавить магазин',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    // Очистка списка заказов покупателя
    listStores.clear();
    tempItems.clear();

    // Временные данные
    List<Store> tListStores = [];
    String tUidOrganization = '';

    // Получение данных: Заказ покупателя
    if (widget.orderCustomer != null) {
      tUidOrganization = widget.orderCustomer?.uidOrganization??'';
      tListStores = await dbReadStoresOfPartner(
          widget.orderCustomer?.uidPartner ?? '');
    }

    // Получение данных: Возврат товаров от покупателя
    if (widget.returnOrderCustomer != null) {
      tUidOrganization = widget.returnOrderCustomer?.uidOrganization??'';
      tListStores = await dbReadStoresOfPartner(
          widget.returnOrderCustomer?.uidPartner ?? '');
    }

    // Получение данных: Оплата товаров
    if (widget.incomingCashOrder != null) {
      tUidOrganization = widget.incomingCashOrder?.uidOrganization??'';
      tListStores = await dbReadStoresOfPartner(
          widget.incomingCashOrder?.uidPartner ?? '');
    }

    // Фильтрация по организации из документа
    for (var itemStores in tListStores) {
      // Если указан договор, то надо проверить на организацию
      if (itemStores.uidContract != '00000000-0000-0000-0000-000000000000') {
        if (itemStores.uidOrganization != tUidOrganization) {
          continue;
        }
      }

      // Добавим в список
      listStores.add(itemStores);
      tempItems.add(itemStores);
    }

    // Обновление формы
    setState(() {});
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
        /// Поиск по имени партнера
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
          itemCount: listStores.length,
          itemBuilder: (context, index) {
            var storeItem = listStores[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    onTap: () async {

                      if (widget.orderCustomer != null) {
                        widget.orderCustomer?.uidStore = storeItem.uid;
                        widget.orderCustomer?.nameStore = storeItem.name;

                        widget.orderCustomer?.uidPrice = storeItem.uidPrice;
                        Price price = await dbReadPriceUID(storeItem.uidPrice);

                        widget.orderCustomer?.namePrice = price.name;
                      }

                      setState(() {});
                      Navigator.pop(context);
                    },
                    title: Text(storeItem.name),
                    subtitle: Column(
                      children: [
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.home,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Flexible(
                                          child: Text(storeItem.address)),
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
