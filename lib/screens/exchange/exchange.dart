import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_accum_product_prices.dart';
import 'package:wp_sales/db/db_accum_product_rests.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/db/db_ref_organization.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/db/db_ref_price.dart';
import 'package:wp_sales/db/db_ref_product.dart';
import 'package:wp_sales/db/db_ref_warehouse.dart';
import 'package:wp_sales/models/accum_partner_depts.dart';
import 'package:wp_sales/models/accum_product_prices.dart';
import 'package:wp_sales/models/accum_product_rests.dart';
import 'package:wp_sales/models/ref_cashbox.dart';
import 'package:wp_sales/models/ref_contract.dart';
import 'package:wp_sales/models/ref_organization.dart';
import 'package:wp_sales/models/ref_partner.dart';
import 'package:wp_sales/models/ref_price.dart';
import 'package:wp_sales/models/ref_product.dart';
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

  Future<void> loadData() async {
    if (_loading) {
      return;
    }

    listLogs.clear();

    setState(() {
      _loading = true;
      _visibleIndicator = true;
    });

    final SharedPreferences prefs = await _prefs;

    bool useFTPExchange = prefs.getBool('settings_useFTPExchange') ?? false;
    if (useFTPExchange) {
      showMessage('Начало обмена по  FTP.');
      await loadDataByFTP();
      showMessage('Завершение обмена по FTP.');
    }

    bool useWebExchange = prefs.getBool('settings_useFTPExchange') ?? false;
    if (useWebExchange) {
      //loadDataByWebServer();
    }

    setState(() {
      _loading = false;
      _visibleIndicator = false;
    });
  }

  Future<void> loadDataByFTP() async {
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
      showMessage('Подключение выполнено успешно!');
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
        listDownload.add(fileFTPPath);
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
        listLogs.add('Получен файл обмена: $localFile');

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

    /// Распакуем все файлы обменов из формата ZIP
    // Список файлов в формет JSON из архивов обмена
    List<String> listJSONFiles = [];
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

    setState(() {
      _valueProgress = 0.2;
    });

    /// Обрбаотка данных обмена: чтение и запись данных
    //  Прочитаем каждый файл и запишем данных
    for (String pathFile in listJSONFiles) {
      File fileJson = File(pathFile);
      String textJSON = await fileJson.readAsString();

      var jsonData = json.decode(textJSON);

      /// Организации
      await dbDeleteAllOrganization();
      int countItem = 0;
      for (var item in jsonData['Organizations']) {
        await dbCreateOrganization(Organization.fromJson(item));
        countItem++;
      }
      listLogs.add('Организации: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.3;
      });

      /// Партнеры
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

      /// Контракты
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

      /// Долги по контрактам
      await dbDeleteAllPartnerDept();
      countItem = 0;
      for (var item in jsonData['DeptsPartners']) {
        await dbCreatePartnerDept(AccumPartnerDept.fromJson(item));
        countItem++;
      }

      listLogs.add('Взаиморасчеты: ' + countItem.toString() + ' шт');
      setState(() {
        _valueProgress = 0.55;
      });

      /// Типы цен
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

      /// Склады
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

      /// Кассы
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


      /// Каталоги товаров (папки)
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

      /// Товары
      countItem = 0;
      for (var item in jsonData['Products']) {
        await dbCreateProduct(Product.fromJson(item));
        countItem++;
      }
      listLogs.add('Товары: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.85;
      });

      /// Остатки товаров
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

      /// Цены товаров
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

      /// Полученные номеров документов из учетной системы
      countItem = 0;
      for (var item in jsonData['ReceivedDocuments']) {
        if (item.typoDoc == 'ЗаказПокупателя') {
          // Получим заказ
          var orderCustomer =
              await dbReadOrderCustomerByUID(item.uidDoc);

          // Получим товары заказа
          var itemsOrder = await dbReadItemsOrderCustomer(orderCustomer.id);

          // Запишем номер документа из учетной системы
          orderCustomer.numberFrom1C = item.numberDoc;

          // Запишем обновления заказа
          await dbUpdateOrderCustomer(orderCustomer, itemsOrder);
        }

        countItem++;
      }

      listLogs.add('Номера документов: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 1.0;
      });
    }
  }

  Future<void> loadDataByWebServer() async {}

  Future<void> saveDataFromFile(String fileName) async {}

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
              await loadData();
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
}
