import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_screens.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int countOrderCustomer = 0;
  int countReturnOrderCustomer = 0;
  int countIncomingCashOrder = 0;
  int countProduct = 0;
  int countUnit = 0;
  int countOrganization = 0;
  int countPartner = 0;
  int countContract = 0;
  int countCurrency = 0;
  int countPrice = 0;
  int countWarehouse = 0;
  String nameUser = '';
  String emailUser = '';

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _renewItem();
    _initPackageInfo();
  }

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
                              children: [
                                Text(nameUser,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white)),
                                const SizedBox(height: 5),
                                Text(emailUser,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ])),
                ListTile(
                    title: const Text("Обмен данными"),
                    leading: const Icon(
                      Icons.update,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenExchangeData(),
                        ),
                      );
                    }),
                listTileTitle('Документы'),
                ListTile(
                    title: const Text("Заказы покупателей"),
                    leading: const Icon(
                      Icons.shopping_basket,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countOrderCustomer),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenOrderCustomerList()),
                      );
                    }),
                ListTile(
                    title: const Text("Возвраты покупателей"),
                    leading: const Icon(
                      Icons.undo,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countReturnOrderCustomer),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                            const ScreenReturnOrderCustomerList()),
                      );
                    }),
                ListTile(
                    title: const Text("ПКО (оплаты)"),
                    leading: const Icon(
                      Icons.payment,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countIncomingCashOrder),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenIncomingCashOrderList()),
                      );
                    }),
                listTileTitle('Справочники'),
                ListTile(
                    title: const Text("Организации"),
                    leading: const Icon(
                      Icons.source,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countOrganization),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenOrganizationList()),
                      );
                    }),
                ListTile(
                    title: const Text("Партнеры"),
                    leading: const Icon(
                      Icons.source,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countPartner),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenPartnerList()),
                      );
                    }),
                ListTile(
                    title: const Text("Контракты партнеров"),
                    leading: const Icon(
                      Icons.source,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countContract),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenContractList()),
                      );
                    }),
                ListTile(
                    title: const Text("Товары"),
                    leading: const Icon(
                      Icons.source,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countProduct),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenProductList()),
                      );
                    }),
                ListTile(
                    title: const Text("Единицы измерения"),
                    leading: const Icon(
                      Icons.source,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countUnit),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenUnitList()),
                      );
                    }),
                ListTile(
                    title: const Text("Типы цен"),
                    leading: const Icon(
                      Icons.source,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countPrice),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenPriceList()),
                      );
                    }),
                ListTile(
                    title: const Text("Валюты"),
                    leading: const Icon(
                      Icons.source,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countCurrency),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenCurrencyList()),
                      );
                    }),
                ListTile(
                    title: const Text("Склады"),
                    leading: const Icon(
                      Icons.source,
                      color: Colors.blue,
                    ),
                    trailing: countNotification(countWarehouse),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ScreenWarehouseList()),
                      );
                    }),
                listTileTitle('Параметры'),
                ListTile(
                    title: const Text("Настройки"),
                    leading: const Icon(
                      Icons.settings,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenSettings(),
                        ),
                      );
                    }),
                ListTile(
                    title: const Text("Справка"),
                    leading: const Icon(
                      Icons.help,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenHelp(),
                        ),
                      );
                    }),
                ListTile(
                    title: const Text("О программе"),
                    leading: const Icon(
                      Icons.info,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Закроем Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenAbout(),
                        ),
                      );
                    }),
                const Divider(indent: 8, endIndent: 8),
                ListTile(
                    title: const Text("Выход"),
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.blue,
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const ScreenLogin()));
                    }),
                ListTile(
                    title: Text(
                      'TM Yarsoft. Version: ${_packageInfo.version}. Build:  ${_packageInfo.buildNumber}',
                      style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center,
                    ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _renewItem() async {
    final SharedPreferences prefs = await _prefs;

    // Идентификатор пользователя в приложении для обмена данными
    nameUser = prefs.getString('settings_nameUser') ?? 'Тестовый пользователь';
    emailUser = prefs.getString('settings_emailUser') ?? 'test@yarsoft.com.ua';

    countOrderCustomer = await dbGetCountSendOrderCustomer();
    countReturnOrderCustomer = await dbGetCountSendReturnOrderCustomer();
    countIncomingCashOrder = await dbGetCountIncomingCashOrder();
    countProduct = await dbGetCountProduct();
    countUnit = await dbGetCountUnit();
    countOrganization = await dbGetCountOrganization();
    countPartner = await dbGetCountPartner();
    countContract = await dbGetCountContract();
    countCurrency = await dbGetCountCurrency();
    countPrice = await dbGetCountPrice();
    countWarehouse = await dbGetCountWarehouse();

    setState(() {});
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  countNotification(int countNotification) {
    return Container(
      height: 25,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.red,
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
            contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
