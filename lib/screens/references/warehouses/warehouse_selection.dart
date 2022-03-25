import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_ref_warehouse.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/models/ref_warehouse.dart';
import 'package:wp_sales/screens/references/warehouses/warehouse_item.dart';

class ScreenWarehouseSelection extends StatefulWidget {

  final OrderCustomer? orderCustomer;
  final ReturnOrderCustomer? returnOrderCustomer;

  const ScreenWarehouseSelection({Key? key,
    this.orderCustomer,
    this.returnOrderCustomer}) : super(key: key);

  @override
  _ScreenWarehouseSelectionState createState() => _ScreenWarehouseSelectionState();
}

class _ScreenWarehouseSelectionState extends State<ScreenWarehouseSelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

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
      //drawer: const MainDrawer(),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var newItem = Warehouse();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenWarehouseItem(warehouseItem: newItem),
            ),
          );
        },
        tooltip: 'Добавить склад',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    // Очистка списка заказов покупателя
    listWarehouses.clear();
    tempItems.clear();

    listWarehouses =
        await dbReadAllWarehouse();
    tempItems.addAll(listWarehouses);

    setState(() {});

    // // Получение и запись списка заказов покупателей
    // for (var message in listDataWarehouses) {
    //   Warehouse newItem = Warehouse.fromJson(message);
    //   listWarehouses.add(newItem);
    //   tempItems.add(newItem); // Как шаблон
    // }
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
                    onTap: () {
                      setState(() {
                        if (widget.orderCustomer != null) {
                          widget.orderCustomer?.uidWarehouse =
                              warehouseItem.uid;
                          widget.orderCustomer?.nameWarehouse =
                              warehouseItem.name;
                        }
                        if (widget.returnOrderCustomer != null) {
                          widget.returnOrderCustomer?.uidWarehouse =
                              warehouseItem.uid;
                          widget.returnOrderCustomer?.nameWarehouse =
                              warehouseItem.name;
                        }
                      });
                      Navigator.pop(context);
                    },
                    title: Text(warehouseItem.name),
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
                                      Text(warehouseItem.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.home, color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Flexible(child: Text(warehouseItem.address)),
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
                )
            );
          },
        ),
      ),
    );
  }
}
