import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/price.dart';
import 'package:wp_sales/models/product.dart';
import 'package:wp_sales/models/warehouse.dart';
import 'package:wp_sales/system/system.dart';

class ScreenProductSelection extends StatefulWidget {
  List<ItemOrderCustomer> listItemDoc = [];
  Price price = Price();
  Warehouse warehouse = Warehouse();

  ScreenProductSelection(
      {Key? key,
      required this.listItemDoc,
      required this.price,
      required this.warehouse})
      : super(key: key);

  @override
  _ScreenProductSelectionState createState() => _ScreenProductSelectionState();
}

class _ScreenProductSelectionState extends State<ScreenProductSelection> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchCatalogController =
      TextEditingController();
  TextEditingController textFieldSearchBoughtController =
      TextEditingController();
  TextEditingController textFieldSearchRecommendController =
      TextEditingController();

  List<Product> tempItems = [];
  List<Product> listProducts = [];

  @override
  void initState() {
    super.initState();
    renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Подбор товаров'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Каталог'),
              Tab(text: 'Купленные'),
              Tab(text: 'Рекомендации'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                searchTextFieldCatalog(),
                listViewCatalog(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: const [],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: const [],
            ),
          ],
        ),
      ),
    );
  }

  void renewItem() async {
    // Очистка списка заказов покупателя
    listProducts.clear();
    tempItems.clear();

    listProducts = await DatabaseHelper.instance.readAllProducts();

    tempItems.addAll(listProducts);

    setState(() {});
  }

  void filterSearchCatalogResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listProducts.clear();
        listProducts.addAll(tempItems);
      });
      return;
    }

    List<Product> dummySearchList = <Product>[];
    dummySearchList.addAll(listProducts);

    if (query.isNotEmpty) {
      List<Product> dummyListData = <Product>[];

      for (var item in dummySearchList) {
        /// Поиск по имени
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listProducts.clear();
        listProducts.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listProducts.clear();
        listProducts.addAll(tempItems);
      });
    }
  }

  searchTextFieldCatalog() {
    var validateSearch = false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
      child: TextField(
        onChanged: (String value) {
          filterSearchCatalogResults(value);
        },
        controller: textFieldSearchCatalogController,
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
                  var value = textFieldSearchCatalogController.text;
                  filterSearchCatalogResults(value);
                },
                icon: const Icon(Icons.search, color: Colors.blue),
              ),
              IconButton(
                onPressed: () async {
                  textFieldSearchCatalogController.text = '';
                  var value = textFieldSearchCatalogController.text;
                  filterSearchCatalogResults(value);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  listViewCatalog() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 0, 9, 14),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listProducts.length,
        itemBuilder: (context, index) {
          double price = 123.56;
          double countOnWarehouses = 561.0;

          var productItem = listProducts[index];
          return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Card(
                elevation: 2,
                child: ListTile(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController textFieldNameBottomController =
                            TextEditingController();

                        TextEditingController textFieldCountBottomController =
                            TextEditingController();

                        TextEditingController textFieldPriceBottomController =
                            TextEditingController();

                        TextEditingController
                            textFieldWarehouseBottomController =
                            TextEditingController();

                        textFieldNameBottomController.text = productItem.name;

                        textFieldPriceBottomController.text =
                            doubleToString(price);

                        textFieldWarehouseBottomController.text =
                            doubleThreeToString(countOnWarehouses);

                        double countToForm = 1.0;
                        for (var itemList in widget.listItemDoc) {
                          if(itemList.uid == productItem.uid) {
                            countToForm = itemList.count;
                            break;
                          }
                        }

                        textFieldCountBottomController.text =
                              doubleThreeToString(countToForm);

                        return SizedBox(
                          //height: 600,
                          child: Center(
                            child: Column(
                              children: [
                                /// Name
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 14, 14, 0),
                                  child: TextField(
                                    readOnly: true,
                                    controller: textFieldNameBottomController,
                                    decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(14, 5, 14, 5),
                                      border: OutlineInputBorder(),
                                      labelStyle: TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                      labelText: 'Товар',
                                    ),
                                  ),
                                ),

                                /// Price & CountOnWarehouse
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 14, 14, 0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    49) /
                                                2,
                                        child: TextField(
                                          readOnly: true,
                                          controller:
                                              textFieldPriceBottomController,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                14, 5, 14, 5),
                                            border: OutlineInputBorder(),
                                            labelStyle: TextStyle(
                                              color: Colors.blueGrey,
                                            ),
                                            labelText: 'Цена',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    49) /
                                                2,
                                        child: TextField(
                                          readOnly: true,
                                          controller:
                                              textFieldWarehouseBottomController,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                14, 5, 14, 5),
                                            border: OutlineInputBorder(),
                                            labelStyle: TextStyle(
                                              color: Colors.blueGrey,
                                            ),
                                            labelText: 'Остаток',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Count
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 14, 14, 0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: textFieldCountBottomController,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          14, 5, 14, 5),
                                      border: const OutlineInputBorder(),
                                      labelStyle: const TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                      labelText: 'Количество',
                                      suffixIcon: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              double tempCount = 0.0;
                                              try {
                                                tempCount = tempCount +
                                                    double.parse(
                                                        textFieldCountBottomController
                                                            .text);
                                                tempCount++;
                                              } on Exception catch (_) {
                                                tempCount = 1.0;
                                              }

                                              /// Если обнулили, то ставим единицу
                                              if (tempCount == 0) {
                                                tempCount = 1.0;
                                              }
                                              textFieldCountBottomController
                                                      .text =
                                                  doubleThreeToString(
                                                      tempCount);
                                            },
                                            icon: const Icon(Icons.add,
                                                color: Colors.blue),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              double tempCount = 0.0;
                                              try {
                                                tempCount = tempCount +
                                                    double.parse(
                                                        textFieldCountBottomController
                                                            .text);
                                                tempCount--;
                                              } on Exception catch (_) {
                                                tempCount = 1.0;
                                              }

                                              /// Если обнулили, то ставим единицу
                                              if (tempCount == 0) {
                                                tempCount = 1.0;
                                              }

                                              textFieldCountBottomController
                                                      .text =
                                                  doubleThreeToString(
                                                      tempCount);
                                            },
                                            icon: const Icon(Icons.remove,
                                                color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                /// Divider
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(14, 7, 14, 0),
                                  child: Divider(),
                                ),

                                /// Buttons
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 7, 14, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      /// Добавить товар
                                      SizedBox(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                28,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                /// Количество товара на форме
                                                var tempCountItem = double.parse(
                                                    textFieldCountBottomController
                                                        .text);
                                                if (tempCountItem == 0) {
                                                  Navigator.pop(context);
                                                  return;
                                                }

                                                bool addNewItem = true;

                                                for (var itemList in widget.listItemDoc) {
                                                  if(itemList.uid == productItem.uid) {
                                                    itemList.count =
                                                        tempCountItem;
                                                    itemList.sum =
                                                        itemList.count *
                                                            itemList.price;

                                                    /// Не надо добавлять новую строку
                                                    addNewItem = false;
                                                    break;
                                                  }
                                                }

                                                if (addNewItem) {
                                                  /// Добавим новую строку заказа
                                                  ItemOrderCustomer itemList =
                                                      ItemOrderCustomer(
                                                          id: 0,
                                                          idOrderCustomer: 0,
                                                          name:
                                                              productItem.name,
                                                          uid: productItem.uid,
                                                          price: price,
                                                          count: tempCountItem,
                                                          discount: 0,
                                                          nameUnit: productItem
                                                              .nameUnit,
                                                          uidUnit: productItem
                                                              .uidUnit,
                                                          sum: tempCountItem *
                                                              price);

                                                  widget.listItemDoc
                                                      .add(itemList);
                                                }
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.add,
                                                    color: Colors.white),
                                                SizedBox(width: 14),
                                                Text('Добавить')
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  title: Text(productItem.name),
                  subtitle: Column(
                    children: [
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const Icon(Icons.price_change,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  doubleToString(price),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 5),
                                Text(doubleThreeToString(countOnWarehouses) +
                                    ' ' +
                                    productItem.nameUnit),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}
