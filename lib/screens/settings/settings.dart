import 'package:enough_mail/enough_mail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/import/import_screens.dart';
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
  bool deniedAddProductWithoutRest =
      false; // Запретить добавлять товар без остатка

  bool useWebExchange = false; // Обмен по вебсервису
  bool useFTPExchange = false; // Обмен по FTP
  bool useMailExchange = false;

  bool deniedAddOrganization = false; // Запретить добавлять организации
  bool deniedAddPartner = false; // Запретить добавлять партнеров
  bool deniedAddContract = false; // Запретить добавлять контракты
  bool deniedAddStore = false; // Запретить добавлять магазины партнера
  bool deniedAddProduct = false; // Запретить добавлять товары
  bool deniedAddUnit = false; // Запретить добавлять единицы измерения товаров
  bool deniedAddPrice = false; // Запретить добавлять типы цен
  bool deniedAddCurrency = false; // Запретить добавлять валюты
  bool deniedAddWarehouse = false; // Запретить добавлять склады
  bool deniedAddCashbox = false; // Запретить добавлять кассы

  // Использовать маршруты
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
  TextEditingController textFieldFTPPasswordController =
      TextEditingController();
  TextEditingController textFieldFTPWorkCatalogController =
      TextEditingController();

  /// Параметры Mail
  TextEditingController textFieldMailSMTPServerController = TextEditingController();
  TextEditingController textFieldMailSMTPPortController = TextEditingController();
  bool isSMTPServerSecure = false;
  TextEditingController textFieldMailPOPServerController = TextEditingController();
  TextEditingController textFieldMailPOPPortController = TextEditingController();
  bool isPOPServerSecure = false;
  TextEditingController textFieldMailUserController = TextEditingController();
  TextEditingController textFieldMailPasswordController =
  TextEditingController();

  /// Параметры WEB-сервиса
  TextEditingController textFieldWEBServerController = TextEditingController();

  /// Параметры заполнения по-умолчанию
  // Поле ввода: Организация
  TextEditingController textFieldOrganizationController =
      TextEditingController();
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

  // Поле ввода: Склад для возвратов
  TextEditingController textFieldWarehouseReturnController =
      TextEditingController();
  String uidWarehouseReturn = '';

  // Поле ввода: Валюта
  TextEditingController textFieldCurrencyController = TextEditingController();
  String uidCurrency = '';

  // Поле ввода: Кассы
  TextEditingController textFieldCashboxController = TextEditingController();
  String uidCashbox = '';

  // Поле ввода: Количество дней отсрочки платежа
  TextEditingController textFieldCountDatePayingController =
      TextEditingController();
  int countDatePaying = 0;

  // Поле ввода: Количество дней на начало доставки
  TextEditingController textFieldCountDateSendingController =
      TextEditingController();
  int countDateSending = 0;

  /// Картинки
  // Поле ввода: Путь к картинкам в Интернете
  TextEditingController textFieldPathPicturesController =
      TextEditingController();

  // Выключить иерархию партнеров
  bool disablePartnerHierarchy = false;

  // Выключить иерархию продуктов
  bool disableProductHierarchy = false;

  // Видимость паролей
  bool _isObscure = true;
  bool _isObscureMail = true;

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
                            if (!mounted) return;
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
                  nameGroup(nameGroup: 'Подбор элементов'),
                  listSettingsPictures(),
                  // nameGroup(nameGroup: 'Тип данных приложения'),
                  // listSettingsTypeData(),
                  nameGroup(nameGroup: 'Редактирование данных'),
                  listSettingsMain(),
                  nameGroup(nameGroup: 'Добавление новых данных'),
                  listSettingsAddData(),
                ],
              ),
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  nameGroup(
                      nameGroup: 'Значения по-умолчанию', hideDivider: true),
                  listFillingByDefault(),
                ],
              ),
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  nameGroup(
                      nameGroup: 'Параметры пользователя', hideDivider: false),
                  listSettingsOther(),
                  nameGroup(
                      nameGroup: 'Виды обмена данными', hideDivider: false),
                  listTypesExchange(),
                  if(useFTPExchange)nameGroup(
                      nameGroup: 'Параметры обмена через FTP', hideDivider: false),
                  if(useFTPExchange)listSettingsExchangeFTP(),

                  if(useMailExchange)nameGroup(
                      nameGroup: 'Параметры обмена через E-mail', hideDivider: false),
                  if(useMailExchange)listSettingsExchangeMail(),

                  if(useWebExchange)nameGroup(
                      nameGroup: 'Параметры обмена через Web', hideDivider: false),
                  if(useWebExchange)listSettingsExchangeWeb(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  fillSettings() async {
    final SharedPreferences prefs = await _prefs;

    useTestData = prefs.getBool('settings_useTestData') ?? false;

    // Идентификатор пользователя в приложении для обмена данными
    textFieldNameUserController.text =
        prefs.getString('settings_nameUser') ?? 'Тестовый пользователь';
    textFieldEmailUserController.text =
        prefs.getString('settings_emailUser') ?? 'test@yarsoft.com.ua';
    textFieldUIDUserController.text = prefs.getString('settings_UIDUser') ?? '';

    //Обмен по ftp-серверу
    useFTPExchange = prefs.getBool('settings_useFTPExchange') ?? true;

    textFieldFTPServerController.text =
        prefs.getString('settings_FTPServer') ?? '';
    textFieldFTPPortController.text =
        prefs.getString('settings_FTPPort') ?? '21';
    textFieldFTPUserController.text = prefs.getString('settings_FTPUser') ?? '';
    textFieldFTPPasswordController.text =
        prefs.getString('settings_FTPPassword') ?? '';
    textFieldFTPWorkCatalogController.text =
        prefs.getString('settings_FTPWorkCatalog') ?? '';

    //Обмен по mail-серверу
    useMailExchange = prefs.getBool('settings_useMailExchange') ?? false;

    // SMTP
    textFieldMailSMTPServerController.text =
        prefs.getString('settings_MailSMTPServer') ?? '';
    textFieldMailSMTPPortController.text =
        prefs.getString('settings_MailSMTPPort') ?? '25';
    isSMTPServerSecure = prefs.getBool('settings_MailSMTPServerSecure') ?? false;

    // POP3
    textFieldMailPOPServerController.text =
        prefs.getString('settings_MailPOPServer') ?? '';
    textFieldMailPOPPortController.text =
        prefs.getString('settings_MailPOPPort') ?? '110';
    isPOPServerSecure = prefs.getBool('settings_MailPOPServerSecure') ?? false;

    textFieldMailUserController.text = prefs.getString('settings_MailUser') ?? '';
    textFieldMailPasswordController.text =
        prefs.getString('settings_MailPassword') ?? '';


    // Обмен по web-серверу
    useWebExchange = prefs.getBool('settings_useWebExchange') ?? false;

    textFieldWEBServerController.text =
        prefs.getString('settings_WEBServer') ?? '';

    // Разрешения и запреты
    deniedEditSettings = prefs.getBool('settings_deniedEditSettings') ?? false;
    deniedEditTypePrice =
        prefs.getBool('settings_deniedEditTypePrice') ?? true;
    deniedEditPrice = prefs.getBool('settings_deniedEditPrice') ?? true;
    deniedEditDiscount = prefs.getBool('settings_deniedEditDiscount') ?? true;
    deniedAddProductWithoutRest =
        prefs.getBool('settings_deniedAddProductWithoutRest') ?? true;
    useRoutesToPartners =
        prefs.getBool('settings_useRoutesToPartners') ?? false;

    // Разрешение на добавление новых элементов в справочники
    deniedAddOrganization =
        prefs.getBool('settings_deniedAddOrganization') ?? true;
    deniedAddPartner = prefs.getBool('settings_deniedAddPartner') ?? true;
    deniedAddContract = prefs.getBool('settings_deniedAddContract') ?? true;
    deniedAddStore = prefs.getBool('settings_deniedAddStore') ?? true;
    deniedAddProduct = prefs.getBool('settings_deniedAddProduct') ?? true;
    deniedAddUnit = prefs.getBool('settings_deniedAddUnit') ?? true;
    deniedAddPrice = prefs.getBool('settings_deniedAddPrice') ?? true;
    deniedAddCurrency = prefs.getBool('settings_deniedAddCurrency') ?? true;
    deniedAddWarehouse = prefs.getBool('settings_deniedAddWarehouse') ?? true;
    deniedAddCashbox = prefs.getBool('settings_deniedAddCashbox') ?? true;

    // Заполнение значений по-умолчанию
    uidOrganization = prefs.getString('settings_uidOrganization') ?? '';
    Organization organization = await dbReadOrganizationUID(uidOrganization);
    textFieldOrganizationController.text = organization.name;

    uidPartner = prefs.getString('settings_uidPartner') ?? '';
    Partner partner = await dbReadPartnerUID(uidPartner);
    textFieldPartnerController.text = partner.name;

    uidPrice = prefs.getString('settings_uidPrice') ?? '';
    Price price = await dbReadPriceUID(uidPrice);
    textFieldPriceController.text = price.name;

    uidCashbox = prefs.getString('settings_uidCashbox') ?? '';
    Cashbox cashbox = await dbReadCashboxUID(uidCashbox);
    textFieldCashboxController.text = cashbox.name;

    uidWarehouse = prefs.getString('settings_uidWarehouse') ?? '';
    Warehouse warehouse = await dbReadWarehouseUID(uidWarehouse);
    textFieldWarehouseController.text = warehouse.name;

    uidWarehouseReturn = prefs.getString('settings_uidWarehouseReturn') ?? '';
    Warehouse warehouseReturn = await dbReadWarehouseUID(uidWarehouseReturn);
    textFieldWarehouseReturnController.text = warehouseReturn.name;

    countDatePaying = prefs.getInt('settings_countDatePaying') ?? 7;
    textFieldCountDatePayingController.text = countDatePaying.toString();

    countDateSending = prefs.getInt('settings_countDateSending') ?? 1;
    textFieldCountDateSendingController.text =
        countDateSending.toString();

    /// Работа с подбором элементов
    // Картинки в Интернете. Путь + UID товара + '.jpg'
    textFieldPathPicturesController.text =
        prefs.getString('settings_pathPictures') ?? '';
    disablePartnerHierarchy = prefs.getBool('settings_disablePartnerHierarchy') ?? false;
    disableProductHierarchy = prefs.getBool('settings_disableProductHierarchy') ?? false;

    setState(() {});
  }

  saveSettings() async {
    final SharedPreferences prefs = await _prefs;

    /// Тестовые данные в программе
    prefs.setBool('settings_useTestData', useTestData);

    /// Common settings
    prefs.setString('settings_nameUser', textFieldNameUserController.text);
    prefs.setString('settings_emailUser', textFieldEmailUserController.text);
    prefs.setString('settings_UIDUser', textFieldUIDUserController.text);

    /// Эти данные можно записывать только при условии, что они разрешены!
    if (deniedEditSettings == false) {

      /// Запреты и разрешения
      prefs.setBool('settings_deniedEditSettings', deniedEditSettings);
      prefs.setBool('settings_deniedEditTypePrice', deniedEditTypePrice);
      prefs.setBool('settings_deniedEditPrice', deniedEditPrice);
      prefs.setBool('settings_deniedEditDiscount', deniedEditDiscount);
      prefs.setBool('settings_useRoutesToPartners', useRoutesToPartners);
      prefs.setBool(
          'settings_deniedAddProductWithoutRest', deniedAddProductWithoutRest);

      /// Запрет добавления новых елементов
      prefs.setBool('settings_deniedAddOrganization', deniedAddOrganization);
      prefs.setBool('settings_deniedAddPartner', deniedAddPartner);
      prefs.setBool('settings_deniedAddContract', deniedAddContract);
      prefs.setBool('settings_deniedAddStore', deniedAddStore);
      prefs.setBool('settings_deniedAddProduct', deniedAddProduct);
      prefs.setBool('settings_deniedAddUnit', deniedAddUnit);
      prefs.setBool('settings_deniedAddPrice', deniedAddPrice);
      prefs.setBool('settings_deniedAddCurrency', deniedAddCurrency);
      prefs.setBool('settings_deniedAddWarehouse', deniedAddWarehouse);
      prefs.setBool('settings_deniedAddCashbox', deniedAddCashbox);

    }

    /// FTP
    prefs.setBool('settings_useFTPExchange', useFTPExchange);
    prefs.setString('settings_FTPServer', textFieldFTPServerController.text);
    prefs.setString('settings_FTPPort', textFieldFTPPortController.text);
    prefs.setString('settings_FTPUser', textFieldFTPUserController.text);
    prefs.setString('settings_FTPPassword', textFieldFTPPasswordController.text);
    prefs.setString('settings_FTPWorkCatalog', textFieldFTPWorkCatalogController.text);

    /// Mail
    prefs.setBool('settings_useMailExchange', useMailExchange);
    prefs.setString('settings_MailSMTPServer', textFieldMailSMTPServerController.text);
    prefs.setString('settings_MailSMTPPort', textFieldMailSMTPPortController.text);
    prefs.setBool('settings_MailSMTPServerSecure', isSMTPServerSecure);
    prefs.setString('settings_MailPOPServer', textFieldMailPOPServerController.text);
    prefs.setString('settings_MailPOPPort', textFieldMailPOPPortController.text);
    prefs.setBool('settings_MailPOPServerSecure', isPOPServerSecure);
    prefs.setString('settings_MailUser', textFieldMailUserController.text);
    prefs.setString('settings_MailPassword', textFieldMailPasswordController.text);

    /// Значения заполнения документов по-умолчанию
    prefs.setString('settings_uidOrganization', uidOrganization);
    prefs.setString('settings_uidPartner', uidPartner);
    prefs.setString('settings_uidPrice', uidPrice);
    prefs.setString('settings_uidCashbox', uidCashbox);
    prefs.setString('settings_uidWarehouse', uidWarehouse);
    prefs.setString('settings_uidWarehouseReturn', uidWarehouseReturn);
    prefs.setInt('settings_countDatePaying', countDatePaying.toInt());
    prefs.setInt('settings_countDateSending', countDateSending.toInt());

    /// Работа с подбором элементов
    prefs.setString(
        'settings_pathPictures', textFieldPathPicturesController.text);
    prefs.setBool('settings_disablePartnerHierarchy', disablePartnerHierarchy);
    prefs.setBool('settings_disableProductHierarchy', disableProductHierarchy);

    /// Web-service
    prefs.setBool('settings_useWebExchange', useWebExchange);
    prefs.setString('settings_WEBServer', textFieldWEBServerController.text);

    if (!mounted) return;
    showMessage('Настройки сохранены!', context);
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
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                const Flexible(
                    child: Text('Запретить изменять тип цены в документах')),
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
                const Flexible(
                    child: Text('Запретить изменять цены в документах')),
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
                const Flexible(
                    child: Text('Запретить изменять скидки в документах')),
              ],
            ),
          ),

          /// Запрет на добавление товара, если остатка не хватает
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddProductWithoutRest,
                  onChanged: (value) {
                    setState(() {
                      deniedAddProductWithoutRest =
                          !deniedAddProductWithoutRest;
                    });
                  },
                ),
                const Flexible(
                    child: Text('Запретить добавление товара без остатка')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  listSettingsAddData() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: [
          /// Запрет на добавление: Организация
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddOrganization,
                  onChanged: (value) {
                    setState(() {
                      deniedAddOrganization = !deniedAddOrganization;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление организаций')),
              ],
            ),
          ),

          /// Запрет на добавление: Партнер
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddPartner,
                  onChanged: (value) {
                    setState(() {
                      deniedAddPartner = !deniedAddPartner;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление партнеров')),
              ],
            ),
          ),

          /// Запрет на добавление: Контракт
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddContract,
                  onChanged: (value) {
                    setState(() {
                      deniedAddContract = !deniedAddContract;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление контрактов')),
              ],
            ),
          ),

          /// Запрет на добавление: Магазин
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddStore,
                  onChanged: (value) {
                    setState(() {
                      deniedAddStore = !deniedAddStore;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление магазинов')),
              ],
            ),
          ),

          /// Запрет на добавление: Товар
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddProduct,
                  onChanged: (value) {
                    setState(() {
                      deniedAddProduct = !deniedAddProduct;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление товаров')),
              ],
            ),
          ),

          /// Запрет на добавление: Единица измерения
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddUnit,
                  onChanged: (value) {
                    setState(() {
                      deniedAddUnit = !deniedAddUnit;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление единиц')),
              ],
            ),
          ),

          /// Запрет на добавление: Тип цен
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddPrice,
                  onChanged: (value) {
                    setState(() {
                      deniedAddPrice = !deniedAddPrice;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление типов цен')),
              ],
            ),
          ),

          /// Запрет на добавление: Валюты
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddCurrency,
                  onChanged: (value) {
                    setState(() {
                      deniedAddCurrency = !deniedAddCurrency;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление валюты')),
              ],
            ),
          ),

          /// Запрет на добавление: Кассы
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddCashbox,
                  onChanged: (value) {
                    setState(() {
                      deniedAddCashbox = !deniedAddCashbox;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление касс')),
              ],
            ),
          ),

          /// Запрет на добавление: Склады
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: deniedAddWarehouse,
                  onChanged: (value) {
                    setState(() {
                      deniedAddWarehouse = !deniedAddWarehouse;
                    });
                  },
                ),
                const Flexible(child: Text('Запретить добавление складов')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  listTypesExchange() {
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

                      // Отключим остальные флаги
                      if(useFTPExchange){
                        useWebExchange = false;
                        useMailExchange = false;
                      }
                    });
                  },
                ),
                const Flexible(child: Text('Обмен через FTP-сервер')),
              ],
            ),
          ),

          /// Использование обмена через Mail
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: useMailExchange,
                  onChanged: (value) {
                    setState(() {
                      useMailExchange = !useMailExchange;

                      // Отключим остальные флаги
                      if(useMailExchange){
                        useFTPExchange = false;
                        useWebExchange = false;
                      }
                    });
                  },
                ),
                const Flexible(child: Text('Обмен через E-mail сервер')),
              ],
            ),
          ),

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

                      // Отключим остальные флаги
                      if(useWebExchange){
                        useFTPExchange = false;
                        useMailExchange = false;
                      }
                    });
                  },
                ),
                const Flexible(child: Text('Обмен через Web-сервер')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  listSettingsExchangeFTP() {
    return Visibility(
      visible: useFTPExchange,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            /// FTP сервер
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: IntrinsicHeight(
                child: TextField(
                  enabled: useFTPExchange,
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
                            textFieldFTPServerController.text = '';
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
                  enabled: useFTPExchange,
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
                  onChanged: (value) {},
                  enabled: useFTPExchange,
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
                  onChanged: (value) {},
                  enabled: useFTPExchange,
                  obscureText: _isObscure,
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
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                            icon: Icon(_isObscure
                                ? Icons.visibility
                                : Icons.visibility_off)),
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
                  enabled: useFTPExchange,
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

            /// Buttons Тестирование обмена
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 50,
                    width: (MediaQuery.of(context).size.width - 28),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                        onPressed: () async {
                          /// Получение данных обмена
                          final FTPConnect ftpClient = FTPConnect(
                              textFieldFTPServerController.text,
                              port: int.parse(textFieldFTPPortController.text),
                              user: textFieldFTPUserController.text,
                              pass: textFieldFTPPasswordController.text,
                              timeout: 600,
                              debug: true);

                          var res = await ftpClient.connect();
                          if (!res) {
                            if (!mounted) return;
                            showErrorMessage(
                                'Ошибка подключения к серверу FTP!', context);
                            return;
                          } else {
                            if (!mounted) return;
                            showMessage(
                                'Подключение выполнено успешно!', context);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.update, color: Colors.white),
                            SizedBox(width: 14),
                            Text('Тест подключения к FTP'),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  listSettingsExchangeWeb() {
    return Visibility(
      visible: useWebExchange,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            /// WEB сервер
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: IntrinsicHeight(
                child: TextField(
                  onChanged: (value) {},
                  enabled: useWebExchange,
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
            const Divider(),
          ],
        ),
      ),
    );
  }

  listSettingsExchangeMail() {
    return Visibility(
      visible: useMailExchange,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            /// SMTP сервер
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: IntrinsicHeight(
                child: TextField(
                  enabled: useMailExchange,
                  keyboardType: TextInputType.text,
                  controller: textFieldMailSMTPServerController,
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
                    labelText: 'SMTP сервер',
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            textFieldMailSMTPServerController.text = '';
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

            /// Порт SMTP сервер
            Row(children: [
              /// Порт SMTP сервер
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 7, 0, 7),
                  child: IntrinsicHeight(
                    child: TextField(
                      onChanged: (value) {},
                      enabled: useMailExchange,
                      keyboardType: TextInputType.number,
                      controller: textFieldMailSMTPPortController,
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
                        labelText: 'SMTP порт',
                        suffixIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                textFieldMailSMTPPortController.text = '';
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
              ),
              /// Защищенное соединение SMTP
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSMTPServerSecure,
                        onChanged: (value) {
                          setState(() {
                            isSMTPServerSecure = !isSMTPServerSecure;
                          });
                        },
                      ),
                      const Flexible(child: Text('Защищенное соединение')),
                    ],
                  ),
                ),
              ),
            ]),

            /// POP сервер
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: IntrinsicHeight(
                child: TextField(
                  enabled: useMailExchange,
                  keyboardType: TextInputType.text,
                  controller: textFieldMailPOPServerController,
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
                    labelText: 'POP3 сервер',
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            textFieldMailPOPServerController.text = '';
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

            /// Порт POP сервер
            Row(
              children: [
                /// Порт POP сервер
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 7, 0, 7),
                    child: IntrinsicHeight(
                      child: TextField(
                        onChanged: (value) {},
                        enabled: useMailExchange,
                        keyboardType: TextInputType.number,
                        controller: textFieldMailPOPPortController,
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
                          labelText: 'POP3 порт',
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  textFieldMailPOPPortController.text = '';
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
                ),
                /// Защищенное соединение POP
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isPOPServerSecure,
                          onChanged: (value) {
                            setState(() {
                              isPOPServerSecure = !isPOPServerSecure;
                            });
                          },
                        ),
                        const Flexible(child: Text('Защищенное соединение')),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// Имя пользователя
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: IntrinsicHeight(
                child: TextField(
                  onChanged: (value) {},
                  enabled: useMailExchange,
                  keyboardType: TextInputType.text,
                  controller: textFieldMailUserController,
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
                    labelText: 'E-mail пользователя',
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            textFieldMailUserController.text = '';
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

            /// Пароль пользователя
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: IntrinsicHeight(
                child: TextField(
                  onChanged: (value) {},
                  enabled: useMailExchange,
                  obscureText: _isObscureMail,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.text,
                  controller: textFieldMailPasswordController,
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
                    labelText: 'E-mail пароль',
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscureMail = !_isObscureMail;
                              });
                            },
                            icon: Icon(_isObscureMail
                                ? Icons.visibility
                                : Icons.visibility_off)),
                        IconButton(
                          onPressed: () {
                            textFieldMailPasswordController.text = '';
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

            /// Buttons Тестирование обмена
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 50,
                    width: (MediaQuery.of(context).size.width - 28),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                        onPressed: () async {

                          //Проверка подключения к серверу почты
                          /// Прочитаем настройки подключения
                          final SharedPreferences prefs = await _prefs;

                          /// Параметры подключения POP3
                          String settingsMailPOPServer = prefs.getString('settings_MailPOPServer') ?? '';
                          int settingsMailPOPPort = int.parse(prefs.getString('settings_MailPOPPort') ?? '110');
                          bool isPopServerSecure = prefs.getBool('settings_MailPOPServerSecure') ?? false;

                          String settingsMailUser = prefs.getString('settings_MailUser') ?? '';
                          String settingsMailPassword = prefs.getString('settings_MailPassword') ?? '';

                          /// Проверка заполнения параметров подключения
                          if (settingsMailPOPServer.trim() == '') {
                            showMessage('В настройках не указано имя POP3 сервера!', context);
                            return;
                          }
                          if (settingsMailPOPPort.toString().trim() == '') {
                            showMessage('В настройках не указано порт POP3 сервера!', context);
                            return;
                          }
                          if (settingsMailUser.trim() == '') {
                            showMessage('В настройках не указано имя пользователя почты!', context);
                            return;
                          }
                          if (settingsMailPassword.trim() == '') {
                            showMessage('В настройках не указан пароль пользователя почты!', context);
                            return;
                          }

                          try {
                            final client = PopClient();

                            // Подключение к серверу
                            await client.connectToServer(settingsMailPOPServer, settingsMailPOPPort,
                                isSecure: isPopServerSecure);

                            // Авторизация
                            await client.login(settingsMailUser, settingsMailPassword);

                            // Отключение от почтового сервера
                            await client.quit();

                            showMessage('Подключение выполнено успешно!', context);
                          } on PopException catch (e) {
                            showErrorMessage('Ошибка подключения к серверу FTP!', context);
                            showErrorMessage('$e', context);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.update, color: Colors.white),
                            SizedBox(width: 14),
                            Text('Тест подключения к почте'),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
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
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                onSubmitted: (value) {
                  value.replaceAll('o', '0');
                  if (value.length != 36) {
                    showErrorMessage(
                        'UID должен состоять из 36 символов', context);
                  }
                  textFieldUIDUserController.text = value;
                },
                keyboardType: TextInputType.text,
                controller: textFieldUIDUserController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'UID пользователя в учетной системе',
                ),
              ),
            ),
          ),

          /// Delete account
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
          //   child:  ElevatedButton(
          //       style: ButtonStyle(
          //           backgroundColor:
          //           MaterialStateProperty.all(Colors.grey)),
          //       onPressed: () async {
          //         var res = await deleteAccount();
          //         if (res){
          //           // Отправим на страницу авторизации
          //           Navigator.of(context).pushAndRemoveUntil(
          //               MaterialPageRoute(
          //                   builder: (context) =>
          //                   const ScreenLogin()),
          //                   (Route<dynamic> route) => false);
          //         }
          //       },
          //       child: SizedBox(
          //           height: 40,
          //           width: MediaQuery.of(context).size.width - 28,
          //           child: const Center(child: Text('Удалить аккаунт пользователя')))),),
        ],
      ),
    );
  }

  listSettingsPictures() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: [
          /// Ссылка Интернет на каталог с картинками товаров
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: IntrinsicHeight(
              child: TextField(
                keyboardType: TextInputType.text,
                controller: textFieldPathPicturesController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  border: const OutlineInputBorder(),
                  labelStyle: const TextStyle(
                    color: Colors.blueGrey,
                  ),
                  labelText: 'Ссылка на каталог картинок',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          textFieldPathPicturesController.text = '';
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Выключить иерархию партнеров
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: disablePartnerHierarchy,
                  onChanged: (value) {
                    setState(() {
                      disablePartnerHierarchy = !disablePartnerHierarchy;
                    });
                  },
                ),
                const Flexible(child: Text('Выключить иерархию партнеров')),
              ],
            ),
          ),

          /// Выключить иерархию товаров
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Checkbox(
                  value: disableProductHierarchy,
                  onChanged: (value) {
                    setState(() {
                      disableProductHierarchy = !disableProductHierarchy;
                    });
                  },
                ),
                const Flexible(child: Text('Выключить иерархию товаров')),
              ],
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
                textFieldOrganizationController.text =
                    orderCustomer.nameOrganization;
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
              textLabel: 'Склад отгрузки товаров',
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

          /// Warehouse for return
          TextFieldWithText(
              textLabel: 'Склад для возвратов товаров',
              textEditingController: textFieldWarehouseReturnController,
              onPressedEditIcon: Icons.gite,
              onPressedDeleteIcon: Icons.delete,
              onPressedDelete: () async {
                textFieldWarehouseReturnController.text = '';
                uidWarehouseReturn = '';
              },
              onPressedEdit: () async {
                OrderCustomer orderCustomer = OrderCustomer();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenWarehouseSelection(
                            orderCustomer: orderCustomer)));
                textFieldWarehouseReturnController.text =
                    orderCustomer.nameWarehouse;
                uidWarehouseReturn = orderCustomer.uidWarehouse;
              }),

          /// Дата плановой отгрузки
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              onTap: () {
                // Выделим текст после фокусировки
                textFieldCountDateSendingController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: textFieldCountDateSendingController.text.length,
                );
              },
              onSubmitted: (value) {
                countDateSending = int.parse(value);
              },
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              controller: textFieldCountDateSendingController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Количество дней отгрузки',
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        textFieldCountDateSendingController.text = '0';
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Дата плановой оплаты
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
            child: TextField(
              onTap: () {
                // Выделим текст после фокусировки
                textFieldCountDatePayingController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: textFieldCountDatePayingController.text.length,
                );
              },
              onSubmitted: (value) {
                countDatePaying = int.parse(value);
              },
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              controller: textFieldCountDatePayingController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),
                labelText: 'Количество дней оплаты',
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        textFieldCountDatePayingController.text = '0';
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  deleteAccount() async {
    // Попробуем удалить документы из корзины
    final value = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text('Удалить аккаунта пользователя и выйти из приложения?'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        // firebase
                        final _auth = FirebaseAuth.instance;

                        try {
                          var user = _auth.currentUser;
                          await user?.delete();

                          final db = await instance.database;
                          if (db.isOpen) {
                            await db.close();
                          }

                          // Удалим БД
                          var databasesPath = await getDatabasesPath();
                          var path = databasesPath + instance.nameDB;
                          await deleteDatabase(path);

                          showMessage('Аккаунт удален!', context);

                          Navigator.of(context).pop(true);

                        } catch (e) {
                          showErrorMessage(e.toString(), context);
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: const SizedBox(
                          width: 60, child: Center(child: Text('Да')))),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.red)),
                      onPressed: () async {
                        Navigator.of(context).pop(false);
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
  }

}
