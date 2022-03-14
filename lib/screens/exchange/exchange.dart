import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ssh2/ssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/contract.dart';
import 'package:wp_sales/models/organization.dart';
import 'package:wp_sales/models/partner.dart';
import 'package:wp_sales/models/price.dart';
import 'package:wp_sales/models/product.dart';
import 'package:wp_sales/models/warehouse.dart';
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
  bool loading = false;
  bool _visibleIndicator = false;

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
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScreenSettings(),
              ),
            );
          }, icon: const Icon(Icons.settings))
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

  renewItem() {

  }

  Future<void> loadData() async {
    if (loading) {
      return;
    }
    listLogs.clear();

    setState(() {
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
      String fileName = 'ssh2_test_upload.txt';
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
      List<Organization> listOrganization = await DatabaseHelper.instance.readAllOrganization();
      for (var item in listOrganization) {
        await DatabaseHelper.instance.deleteOrganization(item.id);
      }
      int countItem = 0;
      for (var item in jsonData['Organizations']) {
        await DatabaseHelper.instance
            .createOrganization(Organization.fromJson(item));
        countItem++;
      }
      listLogs.add('Организации: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.3;
      });

      /// Партнеры
      List<Partner> listPartners = await DatabaseHelper.instance.readAllPartners();
      for (var item in listPartners) {
        await DatabaseHelper.instance.deletePartner(item.id);
      }
      countItem = 0;
      for (var item in jsonData['Partners']) {
        await DatabaseHelper.instance.createPartner(Partner.fromJson(item));
        countItem++;
      }
      listLogs.add('Партнеры: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.4;
      });

      /// Контракты
      List<Contract> listContracts = await DatabaseHelper.instance.readAllContracts();
      for (var item in listContracts) {
        await DatabaseHelper.instance.deleteContract(item.id);
      }
      countItem = 0;
      for (var item in jsonData['Contracts']) {
        await DatabaseHelper.instance.createContract(Contract.fromJson(item));
        countItem++;
      }
      listLogs.add('Контракты: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.5;
      });

      /// Типы цен
      List<Price> listPrices = await DatabaseHelper.instance.readAllPrices();
      for (var item in listPrices) {
        await DatabaseHelper.instance.deletePrice(item.id);
      }
      countItem = 0;
      for (var item in jsonData['Prices']) {
        await DatabaseHelper.instance.createPrice(Price.fromJson(item));
        countItem++;
      }
      listLogs.add('Типы цен: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.6;
      });

      /// Склады
      List<Warehouse> listWarehouses = await DatabaseHelper.instance.readAllWarehouse();
      for (var item in listWarehouses) {
        await DatabaseHelper.instance.deleteWarehouse(item.id);
      }
      countItem = 0;
      for (var item in jsonData['Warehouses']) {
        await DatabaseHelper.instance.createWarehouse(Warehouse.fromJson(item));
        countItem++;
      }
      listLogs.add('Склады: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.7;
      });

      /// Каталоги товаров (папки)
      List<Product> listProducts = await DatabaseHelper.instance.readAllProducts();
      for (var item in listProducts) {
        await DatabaseHelper.instance.deleteProduct(item.id);
      }
      countItem = 0;
      for (var item in jsonData['ProductsParent']) {
        await DatabaseHelper.instance.createProduct(Product.fromJson(item));
        countItem++;
      }
      listLogs.add('Каталоги товаров: ' + countItem.toString() + ' шт');

      setState(() {
        _valueProgress = 0.8;
      });

      /// Товары
      countItem = 0;
      for (var item in jsonData['Products']) {
        await DatabaseHelper.instance.createProduct(Product.fromJson(item));
        countItem++;
      }
      listLogs.add('Товары: ' + countItem.toString() + ' шт');

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
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 28),
      child: SizedBox(
        height: 40,
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
