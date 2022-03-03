import 'package:flutter/material.dart';
import 'package:wp_sales/models/organization.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';
import 'package:wp_sales/screens/references/organizations/organization_item.dart';

class ScreenOrganizationList extends StatefulWidget {
  const ScreenOrganizationList({Key? key}) : super(key: key);

  @override
  _ScreenOrganizationListState createState() => _ScreenOrganizationListState();
}

class _ScreenOrganizationListState extends State<ScreenOrganizationList> {
  /// Поле ввода: Поиск организации
  TextEditingController textFieldSearchController = TextEditingController();

  List<Organization> tempItems = [];
  List<Organization> listOrganizations = [];

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
        title: const Text('Организации'),
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
          var newItem = Organization();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenOrganizationItem(organizationItem: newItem),
            ),
          );
        },
        tooltip: 'Добавить организацию',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() {
    // Очистка списка заказов покупателя
    listOrganizations.clear();
    tempItems.clear();

    // Получение и запись списка заказов покупателей
    for (var message in listDataOrganizations) {
      Organization newItem = Organization.fromJson(message);
      listOrganizations.add(newItem);
      tempItems.add(newItem); // Как шаблон
    }
  }

  void filterSearchResults(String query) {

    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listOrganizations.clear();
        listOrganizations.addAll(tempItems);
      });
      return;
    }

    List<Organization> dummySearchList = <Organization>[];
    dummySearchList.addAll(listOrganizations);

    if (query.isNotEmpty) {

      List<Organization> dummyListData = <Organization>[];

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
        listOrganizations.clear();
        listOrganizations.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listOrganizations.clear();
        listOrganizations.addAll(tempItems);
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
          itemCount: listOrganizations.length,
          itemBuilder: (context, index) {
            var organizationItem = listOrganizations[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Card(
                elevation: 2,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenOrganizationItem(organizationItem: organizationItem),
                        ),
                      );
                    },
                    title: Text(organizationItem.name),
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
                                      Text(organizationItem.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.home, color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Flexible(child: Text(organizationItem.address)),
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
