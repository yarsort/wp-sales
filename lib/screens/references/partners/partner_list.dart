import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wp_sales/models/partner.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';
import 'package:wp_sales/screens/references/partners/partner_item.dart';

class ScreenPartnerList extends StatefulWidget {
  const ScreenPartnerList({Key? key}) : super(key: key);

  @override
  _ScreenPartnerListState createState() => _ScreenPartnerListState();
}

class _ScreenPartnerListState extends State<ScreenPartnerList> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Partner> tempItems = [];
  List<Partner> listPartners = [];

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
      drawer: const MainDrawer(),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var newItem = Partner();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenPartnerItem(partnerItem: newItem),
            ),
          );
        },
        tooltip: 'Добавить партнера',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() {
    // Очистка списка заказов покупателя
    listPartners.clear();
    tempItems.clear();

    // Получение и запись списка заказов покупателей
    for (var message in listDataPartners) {
      Partner newPartner = Partner.fromJson(message);
      listPartners.add(newPartner);
      tempItems.add(newPartner); // Как шаблон
    }
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
        textInputAction: TextInputAction.continueAction,
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
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dismissible: DismissiblePane(onDismissed: () {}),
                      children: [
                        SlidableAction(
                          // An action can be bigger than the others.
                          //flex: 2,
                          onPressed: (context) {},
                          backgroundColor: const Color(0xFF7BC043),
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: null,
                        ),
                        SlidableAction(
                          onPressed:  (context) {},
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: null,
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScreenPartnerItem(partnerItem: partnerItem),
                          ),
                        );
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
                                        const Icon(Icons.phone, color: Colors.blue, size: 20),
                                        const SizedBox(width: 5),
                                        Text(partnerItem.phone),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.home, color: Colors.blue, size: 20),
                                        const SizedBox(width: 5),
                                        Flexible(child: Text(partnerItem.address)),
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
                                        Text(doubleToString(partnerItem.balance)),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.price_change, color: Colors.red, size: 20),
                                        const SizedBox(width: 5),
                                        Text(doubleToString(partnerItem.balanceForPayment)),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule, color: Colors.blue,size: 20),
                                        const SizedBox(width: 5),
                                        Text(partnerItem.schedulePayment.toString()),
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
                  ),
                ) 
              );            
          },
        ),
      ),
    );
  }
}
