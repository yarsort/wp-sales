import 'package:flutter/material.dart';
import 'package:wp_sales/models/order_customer.dart';

class AddItemOrderCustomer extends StatefulWidget {
  final List<ItemOrderCustomer> itemOrderCustomer;

  const AddItemOrderCustomer({Key? key, required this.itemOrderCustomer})
      : super(key: key);

  @override
  _AddItemOrderCustomerState createState() => _AddItemOrderCustomerState();
}

class _AddItemOrderCustomerState extends State<AddItemOrderCustomer> {
  /// Поле ввода: Поиск товаров
  TextEditingController textFieldSearchController = TextEditingController();

  final duplicateItems = List<String>.generate(10000, (i) => "Item $i");
  var items = <String>[];

  @override
  void initState() {
    items.addAll(duplicateItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Подбор товаров'),
      ),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
    );
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = <String>[];
    dummySearchList.addAll(duplicateItems);
    if(query.isNotEmpty) {
      List<String> dummyListData = <String>[];
      for (var item in dummySearchList) {
        if(item.contains(query)) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  searchTextField() {
    var validateSearch = false;

    return Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
        child: TextField(
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
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
          );
        },
      ),
    );
  }
}
