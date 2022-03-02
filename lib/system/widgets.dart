import 'package:flutter/material.dart';
import 'package:wp_sales/screens/documents/order_customer_doc_list.dart';
import 'package:wp_sales/screens/references/partners.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: UserAccountsDrawerHeader(
              decoration:  BoxDecoration(color: Colors.blue),
              accountName: Text('Стрижаков Ярослав', style: TextStyle(fontSize: 20),),
              accountEmail: Text("home@dartflutter.ru"),
            ),
          ),
          ListTile(
              title: const Text("Заказы"),
              leading: const Icon(Icons.shopping_basket),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScreenListOrderCustomer()));
              }
          ),
          ListTile(
              title: const Text("Оплаты"),
              leading: const Icon(Icons.payment),
              onTap: () {}
          ),
          const Divider(indent: 10, endIndent: 10),
          ListTile(
              title: const Text("Партнеры"),
              leading: const Icon(Icons.people),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScreenCustomers()));
              }
          ),
          const Divider(indent: 10, endIndent: 10),
          ListTile(
              title: const Text("Настройки"),
              leading: const Icon(Icons.settings),
              onTap: () {}
          ),
          ListTile(
              title: const Text("Справка"),
              leading: const Icon(Icons.settings),
              onTap: () {}
          ),
          ListTile(
              title: const Text("Про автора"),
              leading: const Icon(Icons.settings),
              onTap: () {
                _showMyAlertDialog(context);
              }
          )
        ],
      ),
    );
  }

  _showMyAlertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Про автора"),
      content: Column(
        children: const [
          Text('Стрижаков Ярослав'),
          Text('Разработка ПО'),
          Text('TM \"Yarsoft\" 2022'),
        ],
      ),
      actions: [
        ElevatedButton(
            child: const Text("Закрыть"),
            onPressed: () {
              Navigator.of(context).pop();
            }
        ),
      ],
    );
  }
}

class ColumnBuilder extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection textDirection;
  final VerticalDirection verticalDirection;
  final int itemCount;

  const ColumnBuilder({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    this.mainAxisAlignment: MainAxisAlignment.start,
    this.mainAxisSize: MainAxisSize.max,
    this.crossAxisAlignment: CrossAxisAlignment.center,
    this.textDirection = TextDirection.ltr,
    this.verticalDirection: VerticalDirection.down,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount,
              (index) => itemBuilder(context, index)).toList(),
    );
  }
}