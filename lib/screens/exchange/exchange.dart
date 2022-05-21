import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wp_sales/import/import_db.dart';
import 'package:wp_sales/import/import_model.dart';

class ScreenExchangeData extends StatefulWidget {
  const ScreenExchangeData({Key? key}) : super(key: key);

  @override
  _ScreenExchangeDataState createState() => _ScreenExchangeDataState();
}

class _ScreenExchangeDataState extends State<ScreenExchangeData> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool _loading = false; // факт загрузки
  double _valueProgress = 0.0;
  bool _visibleIndicator = false; // Отображение видимости панели прогресс-бара

  List<String> listLogs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) {
          return true;
        }
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Прекратить обмен данными?'),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop(true);
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
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Обмен данными'),
          actions: [
            IconButton(
                onPressed: () {
                  if (_loading) {
                    showMessage('Обмен в процессе...', context);
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
              actionButtons(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 45,
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: ElevatedButton(
                onPressed: () async {
                  if (_loading) {
                    showMessage('Обмен в процессе...', context);
                    return;
                  }

                  // Начало обмена
                  setState(() {
                    _loading = true;
                    _visibleIndicator = true;
                  });

                  // Процесс обмена
                  await uploadData();
                  //await downloadData();

                  // Окончание обмена
                  setState(() {
                    _loading = false;
                    _visibleIndicator = false;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.sync, color: Colors.white),
                    SizedBox(width: 14),
                    Text('Отправить')
                  ],
                )),
          ),
          SizedBox(
            height: 45,
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: ElevatedButton(
                onPressed: () async {
                  if (_loading) {
                    showMessage('Обмен в процессе...', context);
                    return;
                  }

                  // Начало обмена
                  setState(() {
                    _loading = true;
                    _visibleIndicator = true;
                    _valueProgress = 0;
                  });

                  // Процесс обмена
                  await uploadData();
                  await downloadData();

                  // Окончание обмена
                  setState(() {
                    _loading = false;
                    _visibleIndicator = false;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.sync, color: Colors.white),
                    SizedBox(width: 14),
                    Text('Получить')
                  ],
                )),
          ),
        ],
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
    if (!_loading) {
      return;
    }

    setState(() {
      _loading = true;
      _visibleIndicator = true;
    });

    //showMessage('Начало обмена...', context);

    final SharedPreferences prefs = await _prefs;

    bool useFTPExchange = prefs.getBool('settings_useFTPExchange') ?? false;
    if (useFTPExchange) {
      showMessage('Загрузка данных из FTP.', context);
      await downloadDataFromFTP();
      showMessage('Завершение загрузки из FTP.', context);
    }

    bool useMailExchange = prefs.getBool('settings_useMailExchange') ?? false;
    if (useMailExchange) {
      showMessage('Загрузка данных из почты.', context);
      await downloadDataFromEmail();
      showMessage('Завершение загрузки из почты.', context);
    }

    bool useWebExchange = prefs.getBool('settings_useWebExchange') ?? false;
    if (useWebExchange) {
      await downloadDataFromWebServer();
    }

    showMessage('Обмен успешно завершен.', context);

    setState(() {
      _loading = false;
      _visibleIndicator = false;
    });
  }

  // Получение данных из FTP Server
  Future<void> downloadDataFromFTP() async {
    if (!_loading) {
      return;
    }

    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    List<String> listDownload = [];

    /// Определение пользвателя обмена
    String settingsUIDUser = prefs.getString('settings_UIDUser') ?? '';
    if (settingsUIDUser.trim() == '') {
      showMessage('В настройках не указан UID  пользователя!', context);
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
        debug: false);

    var res = await ftpClient.connect();
    if (!res) {
      showErrorMessage('Ошибка подключения к серверу FTP!', context);
      return;
    } else {
      // showMessage('Подключение выполнено успешно!');
    }

    // Установка рабочего каталога для чтения данных на сервере FTP
    if (settingsFTPWorkCatalog.trim() != '') {
      bool res = await ftpClient.changeDirectory(settingsFTPWorkCatalog);
      if (!res) {
        showMessage('Ошибка установки рабочего каталога!', context);
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
        if (fileFTPPath.contains('full_')) {
          listDownload.add(fileFTPPath);
        }
        if (fileFTPPath.contains('numbers_')) {
          listDownload.add(fileFTPPath);
        }
        if (fileFTPPath.contains('report_')) {
          listDownload.add(fileFTPPath);
        }
      }
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

        bool resDel = await ftpClient.deleteFile(pathFile);
        if (!resDel) {
          listLogs.add('Ошибка удаления файл обмена из FTP: $pathFile');
        }

        // Добавим для дальнейшей обработки
        listLocalDownloaded.add(localFile.path.toString());
      } else {
        // Логируем про ошибку загрузки файла
        listLogs.add('Ошибка скачивания файл обмена из FTP: $pathFile');
      }
    }

    // Отключимся от сервера
    await ftpClient.disconnect();

    /// Список файлов с данными в формате JSON
    List<String> listJSONFiles = [];

    /// Распакуем файлы данных их архивов по разным итерационным каталогам
    if (listLocalDownloaded.isNotEmpty) {
      listJSONFiles = await unZipArchives(listLocalDownloaded);
    }

    /// Получений список файлов в формате JSON, отправим на обработку
    /// Файлами могут быть данные:
    /// 1. Обмен товарами, партнерами, контрактами и т.д.
    /// 2. Отчеты для менеджера по запросу.
    /// 3. Запросы на какие-либо данные из учетной системы.
    await saveDownloadedData(listJSONFiles);
  }

  // Получение данных из E-mail
  Future<void> downloadDataFromEmail() async {
    if (!_loading) {
      return;
    }

    /// Список файлов с данными в формате JSON
    List<String> listJSONFiles = [];

    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    /// Определение пользвателя обмена
    String settingsUIDUser = prefs.getString('settings_UIDUser') ?? '';
    if (settingsUIDUser.trim() == '') {
      if (!mounted) return;
      showMessage('В настройках не указан UID  пользователя!', context);
      return;
    }

    /// Параметры подключения POP3
    String settingsMailPOPServer =
        prefs.getString('settings_MailPOPServer') ?? '';
    int settingsMailPOPPort =
        int.parse(prefs.getString('settings_MailPOPPort') ?? '110');
    bool isPopServerSecure =
        prefs.getBool('settings_MailPOPServerSecure') ?? false;

    String settingsMailUser = prefs.getString('settings_MailUser') ?? '';
    String settingsMailPassword =
        prefs.getString('settings_MailPassword') ?? '';

    /// Проверка заполнения параметров подключения
    if (settingsMailPOPServer.trim() == '') {
      if (!mounted) return;
      showMessage('В настройках не указано имя POP3 сервера!', context);
      return;
    }
    if (settingsMailPOPPort.toString().trim() == '') {
      if (!mounted) return;
      showMessage('В настройках не указано порт POP3 сервера!', context);
      return;
    }
    if (settingsMailUser.trim() == '') {
      if (!mounted) return;
      showMessage('В настройках не указано имя пользователя почты!', context);
      return;
    }
    if (settingsMailPassword.trim() == '') {
      if (!mounted) return;
      showMessage('В настройках не указан пароль пользователя почты!', context);
      return;
    }

    try {
      final client = PopClient(isLogEnabled: false);

      // Connect
      await client.connectToServer(settingsMailPOPServer, settingsMailPOPPort,
          isSecure: isPopServerSecure);
      await client.login(settingsMailUser, settingsMailPassword);
      final status = await client.status();

      // Список писем, которые в будущем надо будет обработать
      List<int> listNumbersMessages = [];

      var countMessages = status.numberOfMessages;
      while (countMessages > 0) {
        // Получим тему письма
        var message = await client.retrieveTopLines(countMessages, 8);

        // Проверим это письмо для текущего пользователя?
        var subject = message.decodeSubject() ?? ''; // На всякий случай
        if (subject.contains(settingsUIDUser)) {
          listNumbersMessages.add(countMessages);
        }
        countMessages--;
      }

      // Получим путь к временному каталогу устройства
      Directory tempDir = await getTemporaryDirectory();

      // Обработаем письма и получим данные из них: *.zip
      for (var numberMessage in listNumbersMessages) {
        var message = await client.retrieve(numberMessage);
        if (message.hasAttachments() == false) {
          continue;
        }

        List<ContentInfo> listAttachments = message.findContentInfo();
        for (var contentInfo in listAttachments) {
          MimePart? mimePart = message.getPart(contentInfo.fetchId);

          // Раскодируем данные
          Uint8List? uint8List = mimePart?.decodeContentBinary();

          // Если нет данных - пропустим
          if (uint8List!.isEmpty) {
            continue;
          }

          var nameFile = contentInfo.contentDisposition?.filename ??
              '$settingsUIDUser.json';
          var pathLocalFile = tempDir.path + '/' + nameFile;

          // Запишем даные в файл
          final File localFile = File(pathLocalFile);
          await localFile.writeAsBytes(uint8List);

          listJSONFiles.add(pathLocalFile);
        }
      }

      // Disconnect
      await client.quit();
    } on PopException catch (e) {
      if (!mounted) return;
      showErrorMessage('Ошибка почтового сервера POP3!', context);
      showErrorMessage('$e', context);
      setState(() {
        _loading = false;
      });
    }

    /// Получений список файлов в формате JSON, отправим на обработку
    /// Файлами могут быть данные:
    /// 1. Обмен товарами, партнерами, контрактами и т.д.
    /// 2. Отчеты для менеджера по запросу.
    /// 3. Запросы на какие-либо данные из учетной системы.
    await saveDownloadedData(listJSONFiles);
  }

  // Получение данных из Web Server
  Future<void> downloadDataFromWebServer() async {
    if (!_loading) {
      return;
    }
  }

  // Обработка полученных данных из JSON: разделение потоков
  Future<void> saveDownloadedData(List<String> listJSONFiles) async {
    if (!_loading) {
      return;
    }

    //  Нет данных для скачивания и обработки
    if (listJSONFiles.isEmpty) {
      listLogs.add('Данных для обновления не обнаружено!');
      setState(() {
        _valueProgress = 0.0;
      });
      return;
    }

    setState(() {
      _valueProgress = 0.2;
    });

    showMessage('Начало обработки данных.', context);

    /// Обработка данных обмена: чтение и запись данных
    //  Прочитаем каждый файл и запишем данных
    for (String pathFile in listJSONFiles) {
      File fileJson = File(pathFile);
      String textJSON = await fileJson.readAsString();

      var jsonData = json.decode(textJSON);

      // Прочитаем тип обмена из полученных данных
      var typeExchange = jsonData['typeExchange'];

      // Обмен данными
      if (typeExchange == 'full') {
        await saveFromJsonDataFull(jsonData);
      }

      // Обмен данными в легкой форме: долги, остатки, цены, номера
      if (typeExchange == 'lite') {
        await saveFromJsonDataFull(jsonData);
      }

      // Обмен отчетами
      if (typeExchange == 'report') {
        await saveFromJsonDataReport(jsonData);
      }
    }
  }

  // Обработка полученных данных из JSON: Обычный
  Future<void> saveFromJsonDataFull(jsonData) async {
    if (!_loading) {
      return;
    }

    /// Количество полученных элементов для индикации прогресса
    int countItem = 0;

    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    var settingsMap = jsonData['Settings'];

    /// Параметры пользователя
    String settingsNameUser = prefs.getString('settings_nameUser') ?? '';
    if (settingsNameUser.isEmpty ||
        settingsNameUser == 'Тестовый пользователь') {
      prefs.setString('settings_nameUser', settingsMap['nameUser']);
    }

    /// Настройки пользователя (по-умолчанию)
    String settingsUidOrganization =
        prefs.getString('settings_uidOrganization') ?? '';
    if (settingsUidOrganization.isEmpty) {
      prefs.setString(
          'settings_uidOrganization', settingsMap['settings_uidOrganization']);
    }

    String settingsUidPrice = prefs.getString('settings_uidPrice') ?? '';
    if (settingsUidPrice.isEmpty) {
      prefs.setString('settings_uidPrice', settingsMap['settings_uidPrice']);
    }

    String settingsUidCashbox = prefs.getString('settings_uidCashbox') ?? '';
    if (settingsUidCashbox.isEmpty) {
      prefs.setString(
          'settings_uidCashbox', settingsMap['settings_uidCashbox']);
    }

    String settingsUidWarehouse =
        prefs.getString('settings_uidWarehouse') ?? '';
    if (settingsUidWarehouse.isEmpty) {
      prefs.setString(
          'settings_uidWarehouse', settingsMap['settings_uidWarehouse']);
    }

    /// Запреты и разрешения для пользователя
    prefs.setBool(
        'settings_deniedAddOrganization',
        settingsMap['settings_deniedAddOrganization'] == 'false'
            ? false
            : true);
    prefs.setBool('settings_deniedAddPartner',
        settingsMap['settings_deniedAddPartner'] == 'false' ? false : true);
    prefs.setBool('settings_deniedAddContract',
        settingsMap['settings_deniedAddContract'] == 'false' ? false : true);
    prefs.setBool('settings_deniedAddProduct',
        settingsMap['settings_deniedAddProduct'] == 'false' ? false : true);
    prefs.setBool('settings_deniedAddUnit',
        settingsMap['settings_deniedAddUnit'] == 'false' ? false : true);
    prefs.setBool('settings_deniedAddPrice',
        settingsMap['settings_deniedAddPrice'] == 'false' ? false : true);
    prefs.setBool('settings_deniedAddCurrency',
        settingsMap['settings_deniedAddCurrency'] == 'false' ? false : true);
    prefs.setBool('settings_deniedAddWarehouse',
        settingsMap['settings_deniedAddWarehouse'] == 'false' ? false : true);
    prefs.setBool('settings_deniedAddCashbox',
        settingsMap['settings_deniedAddCashbox'] == 'false' ? false : true);

    /// Организации
    try {
      if (jsonData['Organizations'] != null) {
        await dbDeleteAllOrganization();
        for (var item in jsonData['Organizations']) {
          await dbCreateOrganization(Organization.fromJson(item));
          countItem++;
        }
        listLogs.add('Организации: ' + countItem.toString() + ' шт');
        setState(() {
          _valueProgress = 0.1;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки справочника "Организации". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Каталоги партнеров (папки)
    try {
      if (jsonData['PartnersParent'] != null) {
        await dbDeleteAllPartner();
        countItem = 0;
        for (var item in jsonData['PartnersParent']) {
          await dbCreatePartner(Partner.fromJson(item));
          countItem++;
        }
        listLogs.add('Каталоги партнеров: ' + countItem.toString() + ' шт');

        setState(() {
          _valueProgress = 0.2;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки справочника "Каталоги партнеров". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Партнеры
    try {
      if (jsonData['Partners'] != null) {
        countItem = 0;
        for (var item in jsonData['Partners']) {
          await dbCreatePartner(Partner.fromJson(item));
          countItem++;
        }
        listLogs.add('Партнеры: ' + countItem.toString() + ' шт');
        setState(() {
          _valueProgress = 0.2;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки справочника "Партнеры". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Контракты
    try {
      if (jsonData['Contracts'] != null) {
        await dbDeleteAllContract();
        countItem = 0;
        for (var item in jsonData['Contracts']) {
          await dbCreateContract(Contract.fromJson(item));
          countItem++;
        }
        listLogs.add('Контракты: ' + countItem.toString() + ' шт');
        setState(() {
          _valueProgress = 0.3;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки справочника "Контракты". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Магазины (Торговые точки)
    try {
      if (jsonData['Stores'] != null) {
        await dbDeleteAllStore();
        countItem = 0;
        for (var item in jsonData['Stores']) {
          await dbCreateStore(Store.fromJson(item));
          countItem++;
        }
        listLogs
            .add('Магазины (торговые точки): ' + countItem.toString() + ' шт');
        setState(() {
          _valueProgress = 0.4;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки справочника "Магазины". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Долги по контрактам
    try {
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
          _valueProgress = 0.5;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки регистра накопления "Долги по контрактам". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Долги по контрактам по документам расчета
    try {
      if (jsonData['DeptsPartnersByDocuments'] != null) {
        await dbDeleteAllPartnerDept();
        countItem = 0;
        for (var item in jsonData['DeptsPartnersByDocuments']) {
          await dbCreatePartnerDept(AccumPartnerDept.fromJson(item));
          countItem++;
        }
        // После записи документов, обновим записи по регистраторам без номера документа
        listLogs.add('Взаиморасчеты по документам расчета: ' +
            countItem.toString() +
            ' шт');
        setState(() {
          _valueProgress = 0.55;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки регистра накопления "Долги по контрактам по документам расчета". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Типы цен
    try {
      if (jsonData['Prices'] != null) {
        await dbDeleteAllPrice();
        countItem = 0;
        for (var item in jsonData['Prices']) {
          await dbCreatePrice(Price.fromJson(item));
          countItem++;
        }
        listLogs.add('Типы цен: ' + countItem.toString() + ' шт');
        setState(() {
          _valueProgress = 0.65;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки справочника "Типы цен". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Склады
    try {
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
    } catch (e) {
      listLogs
          .add('Ошибка обработки справочника "Склады". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Кассы
    try {
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
    } catch (e) {
      listLogs
          .add('Ошибка обработки справочника "Кассы". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Каталоги товаров (папки)
    try {
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
    } catch (e) {
      listLogs.add(
          'Ошибка обработки справочника "Каталоги товаров". \n Описание ошибки:$e');
      setState(() {});
    }

    /// Товары
    try {
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
    } catch (e) {
      listLogs
          .add('Ошибка обработки справочника "Товары". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Единицы измерения
    try {
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
    } catch (e) {
      listLogs.add(
          'Ошибка обработки справочника "Единицы измерения". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Валюты
    try {
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
    } catch (e) {
      listLogs
          .add('Ошибка обработки справочника "Валюты". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Остатки товаров
    try {
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
    } catch (e) {
      listLogs.add(
          'Ошибка обработки регистра накопления "Остатки товаров". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Цены товаров
    try {
      if (jsonData['Currency'] != null) {
        await dbDeleteAllProductPrice();
        countItem = 0;
        for (var item in jsonData['ProductsPrices']) {
          await dbCreateProductPrice(AccumProductPrice.fromJson(item));
          countItem++;
        }
        listLogs.add('Цены товаров: ' + countItem.toString() + ' шт');
        setState(() {
          _valueProgress = 1.0;
        });
      }
    } catch (e) {
      listLogs.add(
          'Ошибка обработки регистра сведений "Цены товаров". \n Описание ошибки: $e');
      setState(() {});
    }

    /// Полученные номеров документов из учетной системы
    countItem = 0;
    try {
      if (jsonData['ReceivedDocuments'] != null) {
        for (var item in jsonData['ReceivedDocuments']) {
          if (item['typeDoc'] == 'orderCustomer') {
            // Получим объект
            var orderCustomer = await dbReadOrderCustomerUID(item['uidDoc']);

            // Получим товары заказа
            var itemsOrder = await dbReadItemsOrderCustomer(orderCustomer.id);

            // Запишем номер документа из учетной системы
            orderCustomer.numberFrom1C = item['numberDoc'];

            // Запишем обновления заказа
            await dbUpdateOrderCustomer(orderCustomer, itemsOrder);
          }

          if (item['typeDoc'] == 'incomingCashOrder') {
            // Получим объект
            var incomingCashOrder =
                await dbReadIncomingCashOrderUID(item['uidDoc']);

            // Запишем номер документа из учетной системы
            incomingCashOrder.numberFrom1C = item['numberDoc'];

            // Запишем обновления записи
            await dbUpdateIncomingCashOrder(incomingCashOrder);
          }

          if (item['typeDoc'] == 'returnOrderCustomer') {
            // Получим объект
            var returnOrderCustomer =
                await dbReadReturnOrderCustomer(item['uidDoc']);

            // Получим товары
            var itemsOrder =
                await dbReadItemsReturnOrderCustomer(returnOrderCustomer.id);

            // Запишем номер документа из учетной системы
            returnOrderCustomer.numberFrom1C = item['numberDoc'];

            // Запишем обновления записи
            await dbUpdateReturnOrderCustomer(returnOrderCustomer, itemsOrder);
          }
          countItem++;
        }
        listLogs.add('Номера документов: ' + countItem.toString() + ' шт');
      }
    } catch (e) {
      listLogs
          .add('Ошибка обработки номеров документов. \n Описание ошибки: $e');
      setState(() {});
    }

    setState(() {
      _valueProgress = 1.0;
    });
  }

// Обработка полученных данных из JSON: Отчеты
  Future<void> saveFromJsonDataReport(jsonData) async {
    if (!_loading) {
      return;
    }
  }

// Запись данных в JSON: Обычный
  Future<void> saveToJsonDataReport(jsonData) async {
    if (!_loading) {
      return;
    }
  }

  /// Отправка данных в учетные системы

// Начало отправки данных
  Future<void> uploadData() async {
    if (!_loading) {
      return;
    }

    listLogs.clear();

    final SharedPreferences prefs = await _prefs;
    List<String> listToUpload = [];

    var resultSending = false;

    /// Отправка на FTP
    bool useFTPExchange = prefs.getBool('settings_useFTPExchange') ?? false;
    if (useFTPExchange) {
      showMessage('Отправка данных в учетную систему.', context);

      // Добавим файлы
      String pathZipFile = await generateDataSimple();
      listToUpload.add(pathZipFile);

      // Отправим на FTP-сервер
      resultSending = await uploadDataToFTP(listToUpload);
    }

    /// Отправка на E-mail
    bool useMailExchange = prefs.getBool('settings_useMailExchange') ?? false;
    if (useMailExchange) {
      showMessage('Отправка данных в учетную систему.', context);

      // Добавим файлы
      String pathZipFile = await generateDataSimple();
      listToUpload.add(pathZipFile);

      // Отправим на Email-сервер
      resultSending = await uploadDataToMail(listToUpload);
    }

    /// Установим статус отправлено у записей
    if (resultSending) {
      // Заказ покупателя
      List<OrderCustomer> listDocsOrderCustomer =
          await dbReadAllNewOrderCustomer();
      for (var itemDoc in listDocsOrderCustomer) {
        itemDoc.status = 2;
        itemDoc.dateSendingTo1C = DateTime.now();
        await dbUpdateOrderCustomerWithoutItems(itemDoc);
      }
      // Возврат заказа покупателя
      List<ReturnOrderCustomer> listDocsReturnOrderCustomer =
          await dbReadAllNewReturnOrderCustomer();
      for (var itemDoc in listDocsReturnOrderCustomer) {
        itemDoc.status = 2;
        itemDoc.dateSendingTo1C = DateTime.now();
        await dbUpdateReturnOrderCustomerWithoutItems(itemDoc);
      }
      // Приходный кассовый ордер
      List<IncomingCashOrder> listDocsIncomingCashOrder =
          await dbReadAllNewIncomingCashOrder();
      for (var itemDoc in listDocsIncomingCashOrder) {
        itemDoc.status = 2;
        itemDoc.dateSendingTo1C = DateTime.now();
        await dbUpdateIncomingCashOrder(itemDoc);
      }
    }

    bool useWebExchange = prefs.getBool('settings_useWebExchange') ?? false;
    if (useWebExchange) {
      await uploadDataToWebServer();
    }
  }

  // Отправка данных на FTP Server
  Future<bool> uploadDataToFTP(List<String> listToUpload) async {
    if (!_loading) {
      return false;
    }

    // Если файлов для отправки нет, значит все ОК
    if (listToUpload.isEmpty) {
      return true;
    }

    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    /// Определение пользвателя обмена
    String settingsUIDUser = prefs.getString('settings_UIDUser') ?? '';
    if (settingsUIDUser.trim() == '') {
      showMessage('В настройках не указан UID  пользователя!', context);
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
      showErrorMessage('Ошибка подключения к серверу FTP!', context);
      return false;
    } else {
      //showMessage('Подключение выполнено успешно!');
    }

    // Установка рабочего каталога для чтения данных на сервере FTP
    if (settingsFTPWorkCatalog.trim() != '') {
      bool res = await ftpClient.changeDirectory(settingsFTPWorkCatalog);
      if (!res) {
        showMessage('Ошибка установки рабочего каталога!', context);
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

  // Отправка данных на Email Server
  Future<bool> uploadDataToMail(List<String> listToUpload) async {
    if (!_loading) {
      return false;
    }

    // Если файлов для отправки нет, значит все ОК
    if (listToUpload.isEmpty) {
      return true;
    }

    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    /// Определение пользвателя обмена
    String settingsNameUser = prefs.getString('settings_nameUser') ?? '';
    String settingsEmailUser = prefs.getString('settings_emailUser') ?? '';
    String settingsUIDUser = prefs.getString('settings_UIDUser') ?? '';
    if (settingsUIDUser.trim() == '') {
      if (!mounted) return false;
      showMessage('В настройках не указан UID  пользователя!', context);
      return false;
    }

    /// Параметры подключения POP3
    String settingsMailSMTPServer =
        prefs.getString('settings_MailSMTPServer') ?? '';
    int settingsMailSMTPPort =
        int.parse(prefs.getString('settings_MailSMTPPort') ?? '110');
    bool isSMTPServerSecure =
        prefs.getBool('settings_MailSMTPServerSecure') ?? false;

    String settingsMailUser = prefs.getString('settings_MailUser') ?? '';
    String settingsMailPassword =
        prefs.getString('settings_MailPassword') ?? '';

    /// Проверка заполнения параметров подключения
    if (settingsMailSMTPServer.trim() == '') {
      showMessage('В настройках не указано имя SMTP сервера!', context);
      return false;
    }
    if (settingsMailSMTPPort.toString().trim() == '') {
      showMessage('В настройках не указано порт SMTP сервера!', context);
      return false;
    }
    if (settingsMailUser.trim() == '') {
      showMessage('В настройках не указано имя пользователя почты!', context);
      return false;
    }
    if (settingsMailPassword.trim() == '') {
      showMessage('В настройках не указан пароль пользователя почты!', context);
      return false;
    }

    // Найдем и отправим файлы на сервер
    int countSendFiles = 0;
    for (var pathFile in listToUpload) {
      final client = SmtpClient('mail.adm.tools', isLogEnabled: false);

      try {
        await client.connectToServer(
            settingsMailSMTPServer, settingsMailSMTPPort,
            isSecure: isSMTPServerSecure);
        await client.ehlo();
        await client.authenticate(settingsMailUser, settingsMailPassword);

        File fileToUpload = File(pathFile);

        final builder = MessageBuilder();
        builder.from = [MailAddress('WP Sales', settingsMailUser)];
        builder.to = [MailAddress('WP Sales', settingsMailUser)];
        builder.subject = 'WP Sales. Data to server from user: ' + settingsNameUser;
        builder.addTextHtml('<p>Data from <b>WP Sales</b> to server.</p>'
            '<p><b>Operation: </b> sending data to central system.<br>'
            '<b>User: </b> $settingsNameUser.<br>'
            '<b>E-Mail: </b> $settingsEmailUser.</p>');
        await builder.addFile(fileToUpload, MediaType.guessFromFileName(pathFile));

        final mimeMessage = builder.buildMimeMessage();
        final sendResponse = await client.sendMessage(mimeMessage);

        if (sendResponse.isOkStatus) {
          countSendFiles++;
        }
      } on SmtpException catch (e) {
        showErrorMessage('Ошибка почтового сервера SMTP!', context);
        showErrorMessage('$e', context);
        setState(() {
          _loading = false;
        });
      }
    }

    // Если отправлены все файлы, значит все ОК! :)
    if (countSendFiles == listToUpload.length) {
      return true;
    } else {
      return false;
    }
  }

// Отправка данных на Web Server
  Future<void> uploadDataToWebServer() async {
    if (!_loading) {
      return;
    }
  }

  /// Генерация данных

// Отправка данных на FTP Server
  Future<String> generateDataSimple() async {
    /// Прочитаем настройки подключения
    final SharedPreferences prefs = await _prefs;

    /// Определение пользвателя обмена
    String settingsUidUser = prefs.getString('settings_UIDUser') ?? '';
    String settingsNameUser = prefs.getString('settings_NameUser') ?? '';
    String settingsEmailUser = prefs.getString('settings_EmailUser') ?? '';

    if (settingsUidUser.trim() == '') {
      showMessage('В настройках не указан UID  пользователя!', context);
      return '';
    }

    // Массив на отправку
    var data = {};

    // Массив настроек
    var dataSettings = {};
    dataSettings["dateSending"] = DateTime.now().toIso8601String();
    dataSettings["uidUser"] = settingsUidUser;
    dataSettings["nameUser"] = settingsNameUser;
    dataSettings["emailUser"] = settingsEmailUser;

    // Номер документов для которых надо получить номера из учетной системы
    // Наличие номера говорит о том, что запись была зарегистрирована
    List numberDocs = []; // передается по процедурам
    int countOrderCustomer = 0;
    int countReturnOrderCustomer = 0;
    int countIncomingCashOrder = 0;

    /// Получим массив документов: Заказы покупателя
    List<dynamic> listDocsOrderCustomer =
        await createListDocsOrderCustomer(numberDocs, countOrderCustomer);

    if (countOrderCustomer > 0) {
      listLogs.add('Отправлено: Заказ покупателя - ' +
          countOrderCustomer.toString() +
          ' шт.');
    }

    /// Получим массив документов: Возвраты товаров от покупателей
    List<dynamic> listDocsReturnOrderCustomer =
        await createListDocsReturnOrderCustomer(
            numberDocs, countReturnOrderCustomer);

    if (countReturnOrderCustomer > 0) {
      listLogs.add('Отправлено: Возврат товаров покупателя - ' +
          countReturnOrderCustomer.toString() +
          ' шт.');
    }

    /// Получим массив документов: Приходные кассовые ордера
    List<dynamic> listDocsIncomingCashOrder =
        await createListDocsIncomingCashOrder(
            numberDocs, countIncomingCashOrder);

    if (countIncomingCashOrder > 0) {
      listLogs.add('Отправлено: Приходный кассовый ордер - ' +
          countIncomingCashOrder.toString() +
          ' шт.');
    }

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

    // Временное название для исключения дубликатов заказов от менеджера
    String tempUID = const Uuid().v4();

    // Путь к файлу обмена
    String pathLocalFile =
        tempDir.path + '/orders_$settingsUidUser' + '_' + tempUID + '.json';

    // Путь к файлу архива
    String pathLocalZipFile =
        tempDir.path + '/orders_$settingsUidUser' + '_' + tempUID + '.zip';

    // Запишем даные в файл
    final File localFile = File(pathLocalFile);
    await localFile.writeAsString(dataString);

    List<String> paths = [];
    paths.add(pathLocalFile);

    var res = await FTPConnect.zipFiles(paths, pathLocalZipFile);
    if (!res) {
      showErrorMessage('Ошибка архивирования файла для отправки', context);
    }
    return pathLocalZipFile;
  }

  Future<List> createListDocsOrderCustomer(
      List<dynamic> numberDocs, int countOrderCustomer) async {
    // Получим данные для выгрузки
    List<OrderCustomer> listDocs = await dbReadAllNewOrderCustomer();

    // Каждый документ выгрузим в JSON
    List dataList = [];
    for (var itemDoc in listDocs) {
      // Проверка заполненности реквизитов
      // Реквизиты (обязательные): Организация, партнер, контракт
      if (itemDoc.uidOrganization == '' ||
          itemDoc.uidPartner == '' ||
          itemDoc.uidContract == '') {
        continue;
      }

      // Если явно указано, что не надо отправлять
      if (itemDoc.sendNoTo1C == 1) {
        continue;
      }

      // Заполним структуру для получения номера доумента из учетной системы
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

      countOrderCustomer++;
    }
    return dataList;
  }

  Future<List> createListDocsReturnOrderCustomer(
      List<dynamic> numberDocs, int countReturnOrderCustomer) async {
    // Получим данные для выгрузки
    List<ReturnOrderCustomer> listDocs =
        await dbReadAllNewReturnOrderCustomer();

    // Каждый документ выгрузим в JSON
    List dataList = [];
    for (var itemDoc in listDocs) {
      // Проверка заполненности реквизитов
      // Реквизиты (обязательные): Организация, партнер, контракт
      if (itemDoc.uidOrganization == '' ||
          itemDoc.uidPartner == '' ||
          itemDoc.uidContract == '') {
        continue;
      }

      // Если явно указано, что не надо отправлять
      if (itemDoc.sendNoTo1C == 1) {
        continue;
      }

      // Заполним структуру для получения номера доумента из учетной системы
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

      countReturnOrderCustomer++;
    }
    return dataList;
  }

  Future<List> createListDocsIncomingCashOrder(
      List<dynamic> numberDocs, int countIncomingCashOrder) async {
    // Получим данные для выгрузки
    List<IncomingCashOrder> listDocs = await dbReadAllNewIncomingCashOrder();

    // Каждый документ выгрузим в JSON
    List dataList = [];
    for (var itemDoc in listDocs) {
      // Проверка заполненности реквизитов
      // Реквизиты (обязательные): Организация, партнер, контракт
      if (itemDoc.uidOrganization == '' ||
          itemDoc.uidPartner == '' ||
          itemDoc.uidContract == '') {
        continue;
      }

      // Если явно указано, что не надо отправлять
      if (itemDoc.sendNoTo1C == 1) {
        continue;
      }

      // Заполним структуру для получения номера доумента из учетной системы
      var dataNumber = {};

      // Добавим номер (UID) документа
      dataNumber['uid'] = itemDoc.uid;
      dataNumber['typeDoc'] = 'incomingCashOrder';
      numberDocs.add(dataNumber);

      // Конвертация данных
      var data = itemDoc.toJson();

      // Добавим документ в список
      dataList.add(data);

      countIncomingCashOrder++;
    }
    return dataList;
  }
}
