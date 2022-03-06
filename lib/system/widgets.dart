import 'package:flutter/material.dart';
import 'package:wp_sales/screens/documents/incoming_cash_order/incoming_cash_order_list.dart';
import 'package:wp_sales/screens/documents/order_customer/order_customer_list.dart';
import 'package:wp_sales/screens/references/contracts/contract_list.dart';
import 'package:wp_sales/screens/references/currency/currency_list.dart';
import 'package:wp_sales/screens/references/organizations/organization_list.dart';
import 'package:wp_sales/screens/references/partners/partner_list.dart';
import 'package:wp_sales/screens/references/price/price_list.dart';
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
                ExpansionTile(
                  title: const Text('Справочники'),
                  children: [
                    ListTile(
                        title: const Text("Организации"),
                        leading: const Icon(Icons.people),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ScreenOrganizationList()));
                        }),
                    ListTile(
                        title: const Text("Партнеры"),
                        leading: const Icon(Icons.people),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ScreenPartnerList()));
                        }),
                    ListTile(
                        title: const Text("Договоры партнеров"),
                        leading: const Icon(Icons.people),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ScreenContractList()));
                        }),
                    ListTile(
                        title: const Text("Типы цен"),
                        leading: const Icon(Icons.people),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ScreenPriceList()));
                        }),
                    ListTile(
                        title: const Text("Валюты"),
                        leading: const Icon(Icons.people),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const ScreenCurrencyList()));
                        }),
                  ],
                ),
                ExpansionTile(
                    title: const Text('Служебные'),
                    children: [
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
                ]),
                ListTile(
                    title: const Text("О программе"),
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
                Text(
                  'TM Yarsoft. Версия: 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
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

class TextFieldWithText extends StatelessWidget {
  final TextEditingController textEditingController;
  final String textLabel;
  final IconData? onPressedEditIcon;
  final IconData? onPressedDeleteIcon;
  final VoidCallback onPressedEdit;
  final VoidCallback onPressedDelete;
  final bool readOnly = true;

  const TextFieldWithText({
    Key? key,
    bool? readOnly,
    required this.textLabel,
    required this.textEditingController,
    required this.onPressedEditIcon,
    required this.onPressedDeleteIcon,
    required this.onPressedEdit,
    required this.onPressedDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
      child: IntrinsicHeight(
        child: TextField(
          keyboardType: TextInputType.text,
          readOnly: readOnly,
          controller: textEditingController,
          decoration: InputDecoration(
            isDense: true,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 2,
              minHeight: 2,
            ),
            contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            border: const OutlineInputBorder(),
            labelStyle: const TextStyle(
              color: Colors.blueGrey,
            ),
            labelText: textLabel,
            suffixIcon: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: const EdgeInsets.fromLTRB(10, 1, 1, 1),
                  onPressed: onPressedEdit,
                  icon: onPressedEditIcon != null
                      ? Icon(onPressedEditIcon, color: Colors.blue)
                      : Icon(onPressedEditIcon, color: Colors.white),
                ),
                IconButton(
                  onPressed: onPressedDelete,
                  icon: onPressedDeleteIcon != null
                      ? Icon(onPressedDeleteIcon, color: Colors.red)
                      : Icon(onPressedDeleteIcon, color: Colors.white),
                  //icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextFieldWithNumber extends StatelessWidget {
  final TextEditingController textEditingController;
  final String textLabel;
  final IconData? onPressedEditIcon;
  final IconData? onPressedDeleteIcon;
  final VoidCallback onPressedEdit;
  final VoidCallback onPressedDelete;
  final bool readOnly = true;

  const TextFieldWithNumber(
      {Key? key,
      bool? readOnly,
      required this.textLabel,
      required this.textEditingController,
      required this.onPressedEditIcon,
      required this.onPressedDeleteIcon,
      required this.onPressedEdit,
      required this.onPressedDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
      child: IntrinsicHeight(
        child: TextField(
          keyboardType: TextInputType.number,
          readOnly: readOnly,
          controller: textEditingController,
          decoration: InputDecoration(
            isDense: true,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 2,
              minHeight: 2,
            ),
            contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            border: const OutlineInputBorder(),
            labelStyle: const TextStyle(
              color: Colors.blueGrey,
            ),
            labelText: textLabel,
            suffixIcon: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: const EdgeInsets.fromLTRB(10, 1, 1, 1),
                  onPressed: onPressedEdit,
                  icon: onPressedEditIcon != null
                      ? Icon(onPressedEditIcon, color: Colors.blue)
                      : Icon(onPressedEditIcon, color: Colors.white),
                ),
                IconButton(
                  onPressed: onPressedDelete,
                  icon: onPressedDeleteIcon != null
                      ? Icon(onPressedDeleteIcon, color: Colors.red)
                      : Icon(onPressedDeleteIcon, color: Colors.white),
                  //icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
