import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_accum_product_prices.dart';
import 'package:wp_sales/db/db_accum_product_rests.dart';
import 'package:wp_sales/db/db_doc_incoming_cash_order.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/db/db_doc_return_order_customer.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/db/db_ref_currency.dart';
import 'package:wp_sales/db/db_ref_organization.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/db/db_ref_price.dart';
import 'package:wp_sales/db/db_ref_product.dart';
import 'package:wp_sales/db/db_ref_unit.dart';
import 'package:wp_sales/db/db_ref_warehouse.dart';
import 'package:wp_sales/models/accum_partner_depts.dart';
import 'package:wp_sales/models/accum_product_prices.dart';
import 'package:wp_sales/models/accum_product_rests.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/models/ref_cashbox.dart';
import 'package:wp_sales/models/ref_contract.dart';
import 'package:wp_sales/models/ref_currency.dart';
import 'package:wp_sales/models/ref_organization.dart';
import 'package:wp_sales/models/ref_partner.dart';
import 'package:wp_sales/models/ref_price.dart';
import 'package:wp_sales/models/ref_product.dart';
import 'package:wp_sales/models/ref_unit.dart';
import 'package:wp_sales/models/ref_warehouse.dart';
import 'package:wp_sales/screens/settings/settings.dart';

class ScreenExchangeData extends StatefulWidget {
  const ScreenExchangeData({Key? key}) : super(key: key);

  @override
  _ScreenExchangeDataState createState() => _ScreenExchangeDataState();
}

class _ScreenExchangeDataState extends State<ScreenExchangeData> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  double _valueProgress = 0.0;
  List<String> listLogs = [];
  bool _loading = false; // факт загрузки
  bool _visibleIndicator = false; // Отображение видимости панели прогресс-бара

  @override
  void initState() {
    super.initState();
    renewItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Обмен данными'),
        actions: [
          IconButton(
              onPressed: () {
                if (_loading) {
                  showMessage('Обмен в процессе...');
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreenSettings(),
                  ),
                );
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
        child: Column(
          children: [
            progressIndicator(),
            Expanded(
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: listLogs.length,
                  itemBuilder: (context, index) {
                    var logItem = listLogs[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          onTap: () {},
                          leading: const SizedBox(
                            height: 40,
                            width: 40,
                            child: Center(
                              child: Icon(
                                Icons.info,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          title: Text(
                            logItem,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: actionButtons(),
    );
  }

  renewItem() {}

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        content: Text(textMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  showErrorMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(textMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  progressIndicator() {
    return Visibility(
      visible: _visibleIndicator,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: LinearProgressIndicator(
            value: _valueProgress,
          )),
    );
  }

  actionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
      child: SizedBox(
        height: 50,
        width: (MediaQuery.of(context).size.width - 49) / 2,
        child: ElevatedButton(
            onPressed: () async {
              if (_loading) {
                return;
              }
              await uploadData();
              await downloadData();
              setState(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.sync, color: Colors.white),
                SizedBox(width: 14),
                Text('Выполнить обмен')
              ],
            )),
      ),
    );
  }

  /// Получение данных из учетных систем

  Future<List<String>> unZipArchives(listLocalDownloaded) async {
    /// Определение пользвателя обмена
    final SharedPreferences prefs = await _prefs;
    String settingsUIDUser = prefs.getString('settings_UIDUser') ?? '';

    // Получим путь к временному каталогу устройства
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    // Список файлов в формет JSON из архивов обмена
    List<String> listJSONFiles = [];

    // Итератор нужен для того что бы каждый архив был в своем каталоге.
    // Далее каждый файл распаковывается и обрабатывается подряд
    int iterator = 1;

    //  Прочитаем каждый файл и запишем данных
    for (String pathDownloadedFile in listLocalDownloaded) {
      // Каждый файл в отдельном каталоге, что бы создать уникальность
      String localJsonFile =
          tempPath + '/' + iterator.toString() + '_' + settingsUIDUser;

      final File localZipFile = File(pathDownloadedFile);
      List listUnzippedFlies =
          await FTPConnect.unZipFile(localZipFile, localJsonFile);

      for (var itemUnzippedFile in listUnzippedFlies) {
        listJSONFiles.add(itemUnzippedFile);
      }
      iterator++;
    }

    return listJSONFiles;
  }

  /// Получение данных из учетных систем

  // Начало получения данных
  Future<void> downloadData() async {

    listLogs.clear();

    setState(() {
      _loading = true;
      _visibleIndicator = true;
    });

    final SharedPreferences prefs = await _prefs;

    bool useFTPExchange = prefs.getBool('settings_useFTPExchange') ?? false;
    if (useFTPExchange) {
      showMessage('Загрузка данных из FTP.');
      await downloadDataFromFTP();
      showMessage('Завершение загрузки из FTP.');
    }

    bool useWebExchange = prefs.getBool('settings_useFTPExchange') ?? false;
    if (useWebExchange) {
      await downloadDataFromWebServer();
    }



    setState(() {
      _loading = false;
      _visibleIndicator = false;
    });
  }

  // Получение данных из FTP Server
  Future<void> downloadDataFromFTP() async {
    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    List<String> listDownload = [];
    setState(() {
      _valueProgress = 0;
    });

    /// Определение пользвателя обмена
    String settingsUIDUser = prefs.getString('settings_UIDUser') ?? '';
    if (settingsUIDUser.trim() == '') {
      showMessage('В настройках не указан UID  пользователя!');
      return;
    }

    /// Параметры подключения
    String settingsFTPServer = prefs.getString('settings_FTPServer') ?? '';
    String settingsFTPPort = prefs.getString('settings_FTPPort') ?? '21';
    String settingsFTPUser = prefs.getString('settings_FTPUser') ?? '';
    String settingsFTPPassword = prefs.getString('settings_FTPPassword') ?? '';
    String settingsFTPWorkCatalog =
        prefs.getString('settings_FTPWorkCatalog') ?? '';

    /// Получение данных обмена
    // Экземпляр коннектора
    final FTPConnect ftpClient = FTPConnect(settingsFTPServer,
        port: int.parse(settingsFTPPort),
        user: settingsFTPUser,
        pass: settingsFTPPassword,
        timeout: 600,
        debug: true);

    var res = await ftpClient.connect();
    if (!res) {
      showErrorMessage('Ошибка подключения к серверу FTP!');
      return;
    } else {
      // showMessage('Подключение выполнено успешно!');
    }

    // Установка рабочего каталога для чтения данных на сервере FTP
    if (settingsFTPWorkCatalog.trim() != '') {
      bool res = await ftpClient.changeDirectory(settingsFTPWorkCatalog);
      if (!res) {
        showMessage('Ошибка установки рабочего каталога!');
        await ftpClient.disconnect();
        return;
      }
    }

    // Получим и обработаем каждое имя файла
    List<String> listDirectoryContentOnlyNames =
        await ftpClient.listDirectoryContentOnlyNames();
    for (var fileFTPPath in listDirectoryContentOnlyNames) {
      // Каждый файл обмена содержит в своем имени идентификатор получателя
      if (fileFTPPath.contains(settingsUIDUser)) {
        if (fileFTPPath.contains('update_')) {
          listDownload.add(fileFTPPath);
        }
      }
    }

    //  Нет данных для скачивания и обработки
    if (listDownload.isEmpty) {
      listLogs.add('Данные для обработки не обнаружено!');
      setState(() {
        _valueProgress = 0.0;
      });
      await ftpClient.disconnect();
      return;
    }

    // Получим путь к временному каталогу устройства
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    // Список скачанных архивов обмена
    List<String> listLocalDownloaded = [];

    for (String pathFile in listDownload) {
      final File localFile = File('$tempPath/$pathFile');

      // Попытаемся получить файл из сервера
      bool res = await ftpClient.downloadFileWithRetry(pathFile, localFile);
      if (res) {
        // Логируем про загруженный файл
        //listLogs.add('Получен файл обмена: $localFile');

        // Добавим для дальнейшей обработки
        listLocalDownloaded.add(localFile.path.toString());
      } else {
        // Логируем про ошибку загрузки файла
        listLogs.add('Ошибка скачивания файл обмена из FTP: $pathFile');
      }
    }

    // Отключимся от сервера
    await ftpClient.disconnect();

    setState(() {
      _valueProgress = 0.1;
    });

    /// Распакуем файлы данных их архивов по разным итерационным каталогам
    List<String> listJSONFiles = [];
    listJSONFiles = await unZipArchives(listLocalDownloaded);

    setState(() {
      _valueProgress = 0.2;
    });

    /// Получений список файлов в формате JSON, отправим на обработку
    /// Файлами могут быть данные:
    /// 1. Обмен товарами, партнерами, контрактами и т.д.
    /// 2. Отчеты для менеджера по запросу.
    /// 3. Запросы на какие-либо данные из учетной системы.

    await saveDownloadedData(listJSONFiles);
  }

  // Получение данных из Web Server
  Future<void> downloadDataFromWebServer() async {}

  // Обработка полученных данных из JSON: разделение потоков
  Future<void> saveDownloadedData(List<String> listJSONFiles) async {
    /// Обработка данных обмена: чтение и запись данных
    //  Прочитаем каждый файл и запишем данных
    for (String pathFile in listJSONFiles) {
      File fileJson = File(pathFile);
      String textJSON = await fileJson.readAsString();

      var jsonData = json.decode(textJSON);

      // Прочитаем тип обмена из полученных данных
      var typeExchange = jsonData['typeExchange'];

      // Простой обмен
      //if (typeExchange == 'simple') {
      await saveFromJsonDataSimple(jsonData);
      //}

      // Обмен отчетами
      if (typeExchange == 'report') {
        await saveFromJsonDataReport(jsonData);
      }
    }
  }

  // Обработка полученных данных из JSON: Обычный
  Future<void> saveFromJsonDataSimple(jsonData) async {
    int countItem = 0;

    /// Организации
    if (jsonData['Organizations'] != null) {
      await dbDeleteAllOrganization();
      for (var item in jsonData['Organizations']) {
        await dbCreateOrganization(Organization.fromJson(item));
        countItem++;
      }
      listLogs.add('Организации: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.3;
      });
    }

    /// Партнеры
    if (jsonData['Partners'] != null) {
      await dbDeleteAllPartner();
      countItem = 0;
      for (var item in jsonData['Partners']) {
        await dbCreatePartner(Partner.fromJson(item));
        countItem++;
      }
      listLogs.add('Партнеры: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.4;
      });
    }

    /// Контракты
    if (jsonData['Contracts'] != null) {
      await dbDeleteAllContract();
      countItem = 0;
      for (var item in jsonData['Contracts']) {
        await dbCreateContract(Contract.fromJson(item));
        countItem++;
      }
      listLogs.add('Контракты: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.5;
      });
    }

    /// Долги по контрактам
    if (jsonData['DeptsPartners'] != null) {
      await dbDeleteAllPartnerDept();
      countItem = 0;
      for (var item in jsonData['DeptsPartners']) {
        await dbCreatePartnerDept(AccumPartnerDept.fromJson(item));
        countItem++;
      }
      // После записи документов, обновим записи по регистраторам без номера документа
      listLogs.add('Взаиморасчеты: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.55;
      });
    }

    /// Типы цен
    if (jsonData['Prices'] != null) {
      await dbDeleteAllPrice();
      countItem = 0;
      for (var item in jsonData['Prices']) {
        await dbCreatePrice(Price.fromJson(item));
        countItem++;
      }
      listLogs.add('Типы цен: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.6;
      });
    }

    /// Склады
    if (jsonData['Warehouses'] != null) {
      await dbDeleteAllWarehouse();
      countItem = 0;
      for (var item in jsonData['Warehouses']) {
        await dbCreateWarehouse(Warehouse.fromJson(item));
        countItem++;
      }
      listLogs.add('Склады: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.7;
      });
    }

    /// Кассы
    if (jsonData['Cashboxes'] != null) {
      await dbDeleteAllCashbox();
      countItem = 0;
      for (var item in jsonData['Cashboxes']) {
        await dbCreateCashbox(Cashbox.fromJson(item));
        countItem++;
      }
      listLogs.add('Кассы: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.7;
      });
    }

    /// Каталоги товаров (папки)
    if (jsonData['ProductsParent'] != null) {
      await dbDeleteAllProduct();
      countItem = 0;
      for (var item in jsonData['ProductsParent']) {
        await dbCreateProduct(Product.fromJson(item));
        countItem++;
      }
      listLogs.add('Каталоги товаров: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.8;
      });
    }

    /// Товары
    if (jsonData['Products'] != null) {
      countItem = 0;
      for (var item in jsonData['Products']) {
        await dbCreateProduct(Product.fromJson(item));
        countItem++;
      }
      listLogs.add('Товары: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.85;
      });
    }

    /// Единицы измерения
    if (jsonData['Units'] != null) {
      await dbDeleteAllUnit();
      countItem = 0;

      for (var item in jsonData['Units']) {
        await dbCreateUnit(Unit.fromJson(item));
        countItem++;
      }
      listLogs.add('Единицы измерения: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.88;
      });
    }

    /// Валюты
    if (jsonData['Currency'] != null) {
      await dbDeleteAllCurrency();
      countItem = 0;
      for (var item in jsonData['Currency']) {
        await dbCreateCurrency(Currency.fromJson(item));
        countItem++;
      }
      listLogs.add('Валюты: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.89;
      });
    }

    /// Остатки товаров
    if (jsonData['Currency'] != null) {
      await dbDeleteAllProductRest();
      countItem = 0;
      for (var item in jsonData['Rests']) {
        await dbCreateProductRest(AccumProductRest.fromJson(item));
        countItem++;
      }

      listLogs.add('Остатки товаров: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.9;
      });
    }

    /// Цены товаровок
    ///
    if (jsonData['Currency'] != null) {
      await dbDeleteAllProductPrice();
      countItem = 0;
      for (var item in jsonData['ProductsPrices']) {
        await dbCreateProductPrice(AccumProductPrice.fromJson(item));
        countItem++;
      }
      listLogs.add('Цены товаров: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.9;
      });
    }

    /// Полученные номеров документов из учетной системы
    countItem = 0;
    if (jsonData['ReceivedDocuments'] != null) {
      for (var item in jsonData['ReceivedDocuments']) {
        if (item['typeDoc'] == 'ЗаказПокупателя') {
          // Получим заказ
          var orderCustomer = await dbReadOrderCustomerUID(item['uidDoc']);

          // Получим товары заказа
          var itemsOrder = await dbReadItemsOrderCustomer(orderCustomer.id);

          // Запишем номер документа из учетной системы
          orderCustomer.numberFrom1C = item['numberDoc'];

          // Запишем обновления заказа
          await dbUpdateOrderCustomer(orderCustomer, itemsOrder);
        }
        countItem++;
      }
      listLogs.add('Номера документов: ' + countItem.toString() + ' шт');
    }
    setState(() {
      _valueProgress = 1.0;
    });
  }

  // Обработка полученных данных из JSON: Отчеты
  Future<void> saveFromJsonDataReport(jsonData) async {}

  // Запись данных в JSON: Обычный
  Future<void> saveToJsonDataReport(jsonData) async {}

  /// Отправка данных в учетные системы

  // Начало отправки данных
  Future<void> uploadData() async {
    if (_loading) {
      return;
    }

    listLogs.clear();

    setState(() {
      _loading = true;
      _visibleIndicator = true;
    });

    final SharedPreferences prefs = await _prefs;
    List<String> listToUpload = [];

    bool useFTPExchange = prefs.getBool('settings_useFTPExchange') ?? false;
    if (useFTPExchange) {
      showMessage('Начало отправки на FTP.');

      // Добавим файлы
      String pathZipFile = await generateDataSimple();
      listToUpload.add(pathZipFile);

      // Отправим на FTP-сервер
      await uploadDataToFTP(listToUpload);

      showMessage('Завершение отправки на FTP.');
    }

    bool useWebExchange = prefs.getBool('settings_useFTPExchange') ?? false;
    if (useWebExchange) {
      await uploadDataToWebServer();
    }

    setState(() {
      _loading = false;
      _visibleIndicator = false;
    });
  }

  // Получение данных из FTP Server
  Future<bool> uploadDataToFTP(List<String> listToUpload) async {
    // Если файлов для отправки нет, значит все ОК
    if (listToUpload.isEmpty) {
      return true;
    }

    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    /// Определение пользвателя обмена
    String settingsUIDUser = prefs.getString('settings_UIDUser') ?? '';
    if (settingsUIDUser.trim() == '') {
      showMessage('В настройках не указан UID  пользователя!');
      return false;
    }

    /// Параметры подключения
    String settingsFTPServer = prefs.getString('settings_FTPServer') ?? '';
    String settingsFTPPort = prefs.getString('settings_FTPPort') ?? '21';
    String settingsFTPUser = prefs.getString('settings_FTPUser') ?? '';
    String settingsFTPPassword = prefs.getString('settings_FTPPassword') ?? '';
    String settingsFTPWorkCatalog =
        prefs.getString('settings_FTPWorkCatalog') ?? '';

    /// Получение данных обмена
    // Экземпляр коннектора
    final FTPConnect ftpClient = FTPConnect(settingsFTPServer,
        port: int.parse(settingsFTPPort),
        user: settingsFTPUser,
        pass: settingsFTPPassword,
        timeout: 600,
        debug: true);

    var res = await ftpClient.connect();
    if (!res) {
      showErrorMessage('Ошибка подключения к серверу FTP!');
      return false;
    } else {
      //showMessage('Подключение выполнено успешно!');
    }

    // Установка рабочего каталога для чтения данных на сервере FTP
    if (settingsFTPWorkCatalog.trim() != '') {
      bool res = await ftpClient.changeDirectory(settingsFTPWorkCatalog);
      if (!res) {
        showMessage('Ошибка установки рабочего каталога!');
        await ftpClient.disconnect();
        return false;
      }
    }

    // Найдем и отправим файлы на сервер
    int countSendFiles = 0;
    for (var pathFile in listToUpload) {
      File fileToUpload = File(pathFile);
      bool res =
          await ftpClient.uploadFileWithRetry(fileToUpload, pRetryCount: 2);
      if (res) {
        countSendFiles++;
      }
    }
    await ftpClient.disconnect();

    // Если отправлены все файлы, значит все ОК! :)
    if (countSendFiles == listToUpload.length) {
      return true;
    } else {
      return false;
    }
  }

  // Отправка данных на Web Server
  Future<void> uploadDataToWebServer() async {}

  /// Генерация данных

  // Отправка данных на FTP Server
  Future<String> generateDataSimple() async {
    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    /// Определение пользвателя обмена
    String settingsUidUser = prefs.getString('settings_UIDUser') ?? '';
    String settingsNameUser = prefs.getString('settings_nameUser') ?? '';
    if (settingsUidUser.trim() == '') {
      showMessage('В настройках не указан UID  пользователя!');
      return '';
    }

    // Массив на отправку
    var data = {};

    // Массив настроек
    var dataSettings = {};
    dataSettings["dateSending"] = DateTime.now().toIso8601String();
    dataSettings["uidUser"] = settingsUidUser;
    dataSettings["nameUser"] = settingsNameUser;

    // Номер документов для которых надо получить номера из учетной системы
    // Наличие номера говорит о том, что запись была зарегистрирована
    List numberDocs = []; // передается по процедурам

    // Получим массив документов: Заказы покупателя
    List<dynamic> listDocsOrderCustomer =
        await createListDocsOrderCustomer(numberDocs);
    // Получим массив документов: Возвраты товаров от покупателей
    List<dynamic> listDocsReturnOrderCustomer =
        await createListDocsReturnOrderCustomer(numberDocs);
    // Получим массив документов: Приходные кассовые ордера
    List<dynamic> listDocsIncomingCashOrder =
        await createListDocsIncomingCashOrder(numberDocs);

    // Добавим данные на кодирование в JSON
    data['settings'] = dataSettings;
    data['numberDocs'] = numberDocs;
    data['docsOrderCustomer'] = listDocsOrderCustomer;
    data['docsReturnOrderCustomer'] = listDocsReturnOrderCustomer;
    data['docsIncomingCashOrder'] = listDocsIncomingCashOrder;

    // Закодируем список в JSON и отправим на сервер обмена
    String dataString = json.encode(data);

    // Получим путь к временному каталогу устройства
    Directory tempDir = await getTemporaryDirectory();

    // Путь к файлу обмена
    String pathLocalFile = tempDir.path + '/orders_$settingsUidUser.json';

    // Путь к файлу архива
    String pathLocalZipFile = tempDir.path + '/orders_$settingsUidUser.zip';

    // Запишем даные в файл
    final File localFile = File(pathLocalFile);
    localFile.writeAsString(dataString);

    List<String> paths = [];
    paths.add(pathLocalFile);

    var res = await FTPConnect.zipFiles(paths, pathLocalZipFile);
    if (!res) {
      showErrorMessage('Ошибка архивирования файла для отправки');
    }
    return pathLocalZipFile;
  }

  Future<List> createListDocsOrderCustomer(List<dynamic> numberDocs) async {
    // Получим данные для выгрузки
    List<OrderCustomer> listDocs = await dbReadAllNewOrderCustomer();

    // Каждый документ выгрузим в JSON
    List dataList = [];
    for (var itemDoc in listDocs) {
      var dataNumber = {};

      // Добавим номер (UID) документа
      dataNumber['uid'] = itemDoc.uid;
      dataNumber['typeDoc'] = 'orderCustomer';
      numberDocs.add(dataNumber);

      // Конвертация данных шапки
      var data = itemDoc.toJson();

      // Конвертация товаров
      var listDataProduct = [];
      List<ItemOrderCustomer> listItemOrderCustomer =
          await dbReadItemsOrderCustomer(itemDoc.id);
      for (var itemOrderCustomer in listItemOrderCustomer) {
        var dataProduct = itemOrderCustomer.toJson();
        listDataProduct.add(dataProduct);
      }

      // Добавим товары документа
      data['products'] = listDataProduct;

      // Добавим документ в список
      dataList.add(data);
    }
    return dataList;
  }

  Future<List> createListDocsReturnOrderCustomer(
      List<dynamic> numberDocs) async {
    // Получим данные для выгрузки
    List<ReturnOrderCustomer> listDocs = await dbReadAllNewReturnOrderCustomer();

    // Каждый документ выгрузим в JSON
    List dataList = [];
    for (var itemDoc in listDocs) {
      var dataNumber = {};

      // Добавим номер (UID) документа
      dataNumber['uid'] = itemDoc.uid;
      dataNumber['typeDoc'] = 'returnOrderCustomer';
      numberDocs.add(dataNumber);

      // Конвертация данных шапки
      var data = itemDoc.toJson();

      // Конвертация товаров
      var listDataProduct = [];
      List<ItemReturnOrderCustomer> listItemOrderCustomer =
      await dbReadItemsReturnOrderCustomer(itemDoc.id);
      for (var itemOrderCustomer in listItemOrderCustomer) {
        var dataProduct = itemOrderCustomer.toJson();
        listDataProduct.add(dataProduct);
      }

      // Добавим товары документа
      data['products'] = listDataProduct;

      // Добавим документ в список
      dataList.add(data);
    }
    return dataList;
  }

  Future<List> createListDocsIncomingCashOrder(List<dynamic> numberDocs) async {
    // Получим данные для выгрузки
    List<IncomingCashOrder> listDocs = await dbReadAllNewIncomingCashOrder();

    // Каждый документ выгрузим в JSON
    List dataList = [];
    for (var itemDoc in listDocs) {
      var dataNumber = {};

      // Добавим номер (UID) документа
      dataNumber['uid'] = itemDoc.uid;
      dataNumber['typeDoc'] = 'incomingCashOrder';
      numberDocs.add(dataNumber);

      // Конвертация данных
      var data = itemDoc.toJson();

      // Добавим документ в список
      dataList.add(data);
    }
    return dataList;
  }
}
