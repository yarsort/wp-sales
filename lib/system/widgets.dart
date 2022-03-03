import 'package:flutter/material.dart';
import 'package:wp_sales/screens/documents/incoming_cash_order_list.dart';
import 'package:wp_sales/screens/documents/order_customer_list.dart';
import 'package:wp_sales/screens/references/organizations/organization_list.dart';
import 'package:wp_sales/screens/references/partners/partner_list.dart';
import 'package:wp_sales/screens/settings/about.dart';
import 'package:wp_sales/screens/settings/help.dart';
import 'package:wp_sales/screens/settings/settings.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: Stack(children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FlutterLogo(size: 80),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Стрижаков Ярослав',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white)),
                                SizedBox(height: 5),
                                Text("home@dartflutter.ru",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ])),
                listTileTitle('Документы'),
                ListTile(
                    title: const Text("Заказы покупателей"),
                    leading: const Icon(Icons.shopping_basket),
                    trailing: countNotification(0),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ScreenOrderCustomerList()));
                    }),
                ListTile(
                    title: const Text("ПКО (оплаты)"),
                    leading: const Icon(Icons.payment),
                    trailing: countNotification(156),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ScreenIncomingCashOrderList()));
                    }),
                listTileTitle('Справочники'),
                ListTile(
                    title: const Text("Организации"),
                    leading: const Icon(Icons.people),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScreenOrganizationList()));
                    }),
                ListTile(
                    title: const Text("Партнеры"),
                    leading: const Icon(Icons.people),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScreenPartnerList()));
                    }),
                listTileTitle('Служебные'),
                ListTile(
                    title: const Text("Настройки"),
                    leading: const Icon(Icons.settings),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScreenSettings()));
                    }),
                ListTile(
                    title: const Text("Справка"),
                    leading: const Icon(Icons.help),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScreenHelp()));
                    }),
                ListTile(
                    title: const Text("Про автора"),
                    leading: const Icon(Icons.info),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScreenAbout()));
                    }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text('TM Yarsoft. Версия: 1.0.0', style: TextStyle(color: Colors.blue),),
              ],
            ),
          )
        ],
      ),
    );
  }

  countNotification(int countNotification) {
    return Container(
      height: 25,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.blue,
      ),
      child: Text(
        countNotification.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

Widget listTileTitle(String title) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        SizedBox(
          height: 16,
          child: Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            width: 100,
            height: 1,
            decoration: const BoxDecoration(
                border: Border(
              top: BorderSide(color: Colors.black12, width: 1.0),
            )),
          ),
        )
      ],
    ),
  );
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
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection = TextDirection.ltr,
    this.verticalDirection = VerticalDirection.down,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => itemBuilder(context, index))
          .toList(),
    );
  }
}
