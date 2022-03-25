import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/db/db_ref_organization.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/db/db_ref_price.dart';
import 'package:wp_sales/db/db_ref_warehouse.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/ref_cashbox.dart';
import 'package:wp_sales/models/ref_organization.dart';
import 'package:wp_sales/models/ref_partner.dart';
import 'package:wp_sales/models/ref_price.dart';
import 'package:wp_sales/models/ref_warehouse.dart';
import 'package:wp_sales/screens/references/cashbox/cashbox_selection.dart';
import 'package:wp_sales/screens/references/organizations/organization_selection.dart';
import 'package:wp_sales/screens/references/partners/partner_selection.dart';
import 'package:wp_sales/screens/references/price/price_selection.dart';
import 'package:wp_sales/screens/references/warehouses/warehouse_selection.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenSettings extends StatefulWidget {
  const ScreenSettings({Key? key}) : super(key: key);

  @override
  _ScreenSettingsState createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool useTestData = false; // Показывать тестовые данные
  bool deniedEditSettings = false; // Запретить изменять настройки
  bool deniedEditTypePrice = false; // Запретить изменять тип цены в документах
  bool deniedEditPrice = false; // Запретить изменять цены в документах
  bool deniedEditDiscount = false; // Запретить изменять скидку в документах
  bool useWebExchange = false; // Обмен по вебсервису
  bool enabledTextFieldWebExchange = false;
  bool useFTPExchange = false; // Обмен по FTP
  bool enabledTextFieldFTPExchange = false;

  //
  bool useRoutesToPartners = false;

  /// имя пользователя для обмена данными
  TextEditingController textFieldNameUserController = TextEditingController();

  /// Почта пользователя для обмена данными
  TextEditingController textFieldEmailUserController = TextEditingController();

  /// UID пользователя для обмена данными
  TextEditingController textFieldUIDUserController = TextEditingController();

  /// Параметры FTP
  TextEditingController textFieldFTPServerController = TextEditingController();
  TextEditingController textFieldFTPPortController = TextEditingController();
  TextEditingController textFieldFTPUserController = TextEditingController();
  TextEditingController textFieldFTPPasswordController = TextEditingController();
  TextEditingController textFieldFTPWorkCatalogController = TextEditingController();

  /// Параметры WEB-сервиса
  TextEditingController textFieldWEBServerController = TextEditingController();

  /// Параметры заполнения по-умолчанию
  // Поле ввода: Организация
  TextEditingController textFieldOrganizationController = TextEditingController();
  String uidOrganization = '';

  // Поле ввода: Партнер
  TextEditingController textFieldPartnerController = TextEditingController();
  String uidPartner = '';

  // Поле ввода: Договор или торговая точка
  TextEditingController textFieldContractController = TextEditingController();
  String uidContract = '';

  // Поле ввода: Тип цены
  TextEditingController textFieldPriceController = TextEditingController();
  String uidPrice = '';

  // Поле ввода: Склад
  TextEditingController textFieldWarehouseController = TextEditingController();
  String uidWarehouse = '';

  // Поле ввода: Валюта
  TextEditingController textFieldCurrencyController = TextEditingController();
  String uidCurrency = '';

  // Поле ввода: Кассы
  TextEditingController textFieldCashboxController = TextEditingController();
  String uidCashbox = '';

  @override
  void initState() {
    super.initState();
    fillSettings();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Сохранить настройки?'),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            await saveSettings();
                            Navigator.of(context).pop(true);
                          },
                          child: const SizedBox(
                              width: 60, child: Center(child: Text('Да')))),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                          onPressed: () async {
                            Navigator.of(context).pop(true);
                          },
                          child: const SizedBox(
                            width: 60,
                            child: Center(child: Text('Нет')),
                          )),
                    ],
                  ),
                ],
              );
            });
        return value == true;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Настройки'),
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      saveSettings();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.save, size: 26.0),
                  )),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Основные'),
                Tab(text: 'Заполнение'),
                Tab(text: 'Обмен'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  nameGroup(nameGroup: 'Тип данных приложения'),
                  listSettingsTypeData(),
                  nameGroup(nameGroup: 'Запреты и разрешения'),
                  listSettingsMain(),
                ],
              ),
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  nameGroup(nameGroup: 'Значения по-умолчанию', hideDivider: true),
                  listFillingByDefault(),
                ],
              ),
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  nameGroup(nameGroup: 'Параметры пользователя',hideDivider: false),
                  listSettingsOther(),
                  nameGroup(nameGroup: 'Виды обмена данными',hideDivider: false),
                  listSettingsExchange(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(textMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  fillSettings() async {
    final SharedPreferences prefs = await _prefs;

    useTestData = prefs.getBool('settings_useTestData') ?? false;

    // Идентификатор пользователя в приложении для обмена данными
    textFieldNameUserController.text = prefs.getString('settings_NameUser') ?? 'Тестовый пользователь';
    textFieldEmailUserController.text = prefs.getString('settings_EmailUser') ?? 'test@yarsoft.com.ua';
    textFieldUIDUserController.text = prefs.getString('settings_UIDUser') ?? '';

    //Обмен по ftp-серверу
    useFTPExchange = prefs.getBool('settings_useFTPExchange') ?? true;
    enabledTextFieldWebExchange = useFTPExchange;
    textFieldFTPServerController.text = prefs.getString('settings_FTPServer')??'';
    textFieldFTPPortController.text = prefs.getString('settings_FTPPort')??'';
    textFieldFTPUserController.text = prefs.getString('settings_FTPUser')??'';
    textFieldFTPPasswordController.text = prefs.getString('settings_FTPPassword')??'';
    textFieldFTPWorkCatalogController.text = prefs.getString('settings_FTPWorkCatalog')??'';

    // Обмен по web-серверу
    useWebExchange = prefs.getBool('settings_useWebExchange') ?? false;
    enabledTextFieldFTPExchange = useFTPExchange;
    textFieldWEBServerController.text = prefs.getString('settings_WEBServer')!;

    // Разрешения и запреты
    deniedEditSettings = prefs.getBool('settings_deniedEditSettings')!;
    deniedEditTypePrice = prefs.getBool('settings_deniedEditTypePrice')!;
    deniedEditPrice = prefs.getBool('settings_deniedEditPrice')!;
    deniedEditDiscount = prefs.getBool('settings_deniedEditDiscount')!;
    useRoutesToPartners = prefs.getBool('settings_useRoutesToPartners')!;

    // Заполнение значений по-умолчанию
    uidOrganization = prefs.getString('settings_uidOrganization')??'';
    Organization organization = await dbReadOrganizationUID(uidOrganization);
    textFieldOrganizationController.text = organization.name;

    uidPartner = prefs.getString('settings_uidPartner')??'';
    Partner partner = await dbReadPartnerUID(uidPartner);
    textFieldPartnerController.text = partner.name;

    uidPrice = prefs.getString('settings_uidPrice')??'';
    Price price = await dbReadPriceUID(uidPrice);
    textFieldPriceController.text = price.name;

    uidCashbox = prefs.getString('settings_uidCashbox')??'';
    Cashbox cashbox = await dbReadCashboxUID(uidCashbox);
    textFieldCashboxController.text = cashbox.name;

    uidWarehouse = prefs.getString('settings_uidWarehouse')??'';
    Warehouse warehouse = await dbReadWarehouseUID(uidWarehouse);
    textFieldWarehouseController.text = warehouse.name;

    setState(() {});
  }

  saveSettings() async {
    final SharedPreferences prefs = await _prefs;

    /// Тестовые данные в программе
    prefs.setBool('settings_useTestData', useTestData);

    /// Common settings
    prefs.setString('settings_NameUser', textFieldNameUserController.text);
    prefs.setString('settings_EmailUser', textFieldEmailUserController.text);
    prefs.setString('settings_UIDUser', textFieldUIDUserController.text);

    /// Запреты и разрешения
    prefs.setBool('settings_deniedEditSettings', deniedEditSettings);
    prefs.setBool('settings_deniedEditTypePrice', deniedEditTypePrice);
    prefs.setBool('settings_deniedEditPrice', deniedEditPrice);
    prefs.setBool('settings_deniedEditDiscount', deniedEditDiscount);
    prefs.setBool('settings_useRoutesToPartners', useRoutesToPartners);

    /// FTP
    prefs.setBool('settings_useFTPExchange', useFTPExchange);
    prefs.setString('settings_FTPServer', textFieldFTPServerController.text);
    prefs.setString('settings_FTPPort', textFieldFTPPortController.text);
    prefs.setString('settings_FTPUser', textFieldFTPUserController.text);
    prefs.setString('settings_FTPPassword', textFieldFTPPasswordController.text);
    prefs.setString('settings_FTPWorkCatalog', textFieldFTPWorkCatalogController.text);

    /// Значения заполнения документов по-умолчанию
    prefs.setString('settings_uidOrganization', uidOrganization);
    prefs.setString('settings_uidPartner', uidPartner);
    prefs.setString('settings_uidPrice', uidPrice);
    prefs.setString('settings_uidCashbox', uidCashbox);
    prefs.setString('settings_uidWarehouse', uidWarehouse);

    /// Web-service
    prefs.setBool('settings_useWebExchange', useWebExchange);
    prefs.setString('settings_WEBServer', textFieldWEBServerController.text);

    showMessage('Настройки сохранены!');
  }

  nameGroup({String nameGroup = '', bool hideDivider = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nameGroup,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,),
          textAlign: TextAlign.start,),
          if (!hideDivider) const Divider(),
        ],
      ),
    );
  }

  listSettingsTypeData() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Column(
        children: [
          /// Использование тестовых данных в формах
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: useTestData,
                  onChanged: (value) {
                    setState(() {
                      useTestData = !useTestData;
                    });
                  },
                ),
                const Flexible(child: Text('Показывать тестовые данные')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  listSettingsMain() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Column(
        children: [
          /// Запрет на изменение настроек
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedEditSettings,
                  onChanged: (value) {
                    setState(() {
                      deniedEditSettings = !deniedEditSettings;

                    });
                  },
                ),
                const Flexible(child: Text('Запретить изменять настройки')),
              ],
            ),
          ),
          /// Запрет на изменение типа цены в документах
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedEditTypePrice,
                  onChanged: (value) {
                    setState(() {
                      deniedEditTypePrice = !deniedEditTypePrice;

                    });
                  },
                ),
                const Flexible(child: Text('Запретить изменять тип цены в документах')),
              ],
            ),
          ),
          /// Запрет на изменение цен в строках документов
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedEditPrice,
                  onChanged: (value) {
                    setState(() {
                      deniedEditPrice = !deniedEditPrice;

                    });
                  },
                ),
                const Flexible(child: Text('Запретить изменять цены в документах')),
              ],
            ),
          ),
          /// Запрет на изменение скидок в строках документов
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedEditDiscount,
                  onChanged: (value) {
                    setState(() {
                      deniedEditDiscount = !deniedEditDiscount;

                    });
                  },
                ),
                const Flexible(child: Text('Запретить изменять скидки в документах')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  listSettingsExchange() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: [
          /// Использование обмена через FTP
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: useFTPExchange,
                  onChanged: (value) {
                    setState(() {
                      useFTPExchange = !useFTPExchange;
                      enabledTextFieldFTPExchange = useFTPExchange;

                      useWebExchange = !useFTPExchange;
                      enabledTextFieldWebExchange = !useFTPExchange;
                    });
                  },
                ),
                const Flexible(child: Text('Обмен через FTP-сервер')),
              ],
            ),
          ),

          /// FTP сервер
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                enabled: enabledTextFieldFTPExchange,
                keyboardType: TextInputType.text,
                controller: textFieldFTPServerController,
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
                  labelText: 'FTP сервер',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     IconButton(
                        onPressed: () {
                          textFieldFTPUserController.text = '';
                          
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        //icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          /// Порт сервер
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                onChanged: (value) {},
                enabled: enabledTextFieldFTPExchange,
                keyboardType: TextInputType.number,
                controller: textFieldFTPPortController,
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
                  labelText: 'FTP порт',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          textFieldFTPPortController.text = '';
                          
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        //icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          /// Имя FTP пользователя
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                onChanged: (value) {
                  
                },
                enabled: enabledTextFieldFTPExchange,
                keyboardType: TextInputType.text,
                controller: textFieldFTPUserController,
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
                  labelText: 'FTP пользователь',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          textFieldFTPUserController.text = '';
                          
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        //icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          /// Пароль FTP пользователя
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                onChanged: (value) {
                  
                },
                enabled: enabledTextFieldFTPExchange,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.text,
                controller: textFieldFTPPasswordController,
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
                  labelText: 'FTP пароль',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          textFieldFTPPasswordController.text = '';
                          
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        //icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          /// Рабочий каталог FTP
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                onChanged: (value) {},
                enabled: enabledTextFieldFTPExchange,
                keyboardType: TextInputType.text,
                controller: textFieldFTPWorkCatalogController,
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
                  labelText: 'Рабочий каталог',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          textFieldFTPWorkCatalogController.text = '';
                          },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        //icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),

          /// Использование обмена через Web-сервис
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: useWebExchange,
                  onChanged: (value) {
                    setState(() {
                      useWebExchange = !useWebExchange;
                      enabledTextFieldWebExchange = useWebExchange;

                      useFTPExchange = !useWebExchange;
                      enabledTextFieldFTPExchange = !useWebExchange;

                      
                    });
                  },
                ),
                const Flexible(child: Text('Обмен через Web-сервер')),
              ],
            ),
          ),
          /// WEB сервер
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                onChanged: (value) {
                  
                },
                enabled: enabledTextFieldWebExchange,
                keyboardType: TextInputType.text,
                controller: textFieldWEBServerController,
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
                  labelText: 'WEB сервер',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          textFieldWEBServerController.text = '';
                          
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        //icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  listSettingsOther() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: [
          /// Имя пользователя
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                keyboardType: TextInputType.text,
                controller: textFieldNameUserController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'Имя пользователя',
                ),
              ),
            ),
          ),
          /// Почта пользователя
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: textFieldEmailUserController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'Почта пользователя',
                ),
              ),
            ),
          ),
          /// UID пользователя
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                keyboardType: TextInputType.text,
                controller: textFieldUIDUserController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'UID пользователя',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  listFillingByDefault() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
      child: Column(
        children: [
          /// Organization
          TextFieldWithText(
              textLabel: 'Организация',
              textEditingController: textFieldOrganizationController,
              onPressedEditIcon: Icons.person,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () {
                textFieldOrganizationController.text = '';
                uidOrganization = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenOrganizationSelection(
                            orderCustomer: orderCustomer)));
                textFieldOrganizationController.text = orderCustomer.nameOrganization;
                uidOrganization = orderCustomer.uidOrganization;

              }),

          /// Partner
          TextFieldWithText(
              textLabel: 'Партнер',
              textEditingController: textFieldPartnerController,
              onPressedEditIcon: Icons.people,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                textFieldPartnerController.text = '';
                uidPartner = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPartnerSelection(
                            orderCustomer: orderCustomer)));
                textFieldPartnerController.text = orderCustomer.namePartner;
                uidPartner = orderCustomer.uidPartner;
              }),

          /// Price
          TextFieldWithText(
              textLabel: 'Тип цены продажи',
              textEditingController: textFieldPriceController,
              onPressedEditIcon: Icons.request_quote,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                textFieldPriceController.text = '';
                uidPrice = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenPriceSelection(
                            orderCustomer: orderCustomer)));
                textFieldPriceController.text = orderCustomer.namePrice;
                uidPrice = orderCustomer.uidPrice;
              }),

          /// Cashbox
          TextFieldWithText(
              textLabel: 'Касса',
              textEditingController: textFieldCashboxController,
              onPressedEditIcon: Icons.request_quote,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                textFieldCashboxController.text = '';
                uidCashbox = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenCashboxSelection(
                            orderCustomer: orderCustomer)));
                textFieldCashboxController.text = orderCustomer.nameCashbox;
                uidCashbox = orderCustomer.uidCashbox;
              }),

          /// Warehouse
          TextFieldWithText(
              textLabel: 'Склад отгрузки',
              textEditingController: textFieldWarehouseController,
              onPressedEditIcon: Icons.gite,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                textFieldWarehouseController.text = '';
                uidWarehouse = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenWarehouseSelection(
                            orderCustomer: orderCustomer)));
                textFieldWarehouseController.text = orderCustomer.nameWarehouse;
                uidWarehouse = orderCustomer.uidWarehouse;
              }),
        ],
      ),
    );
  }
}
