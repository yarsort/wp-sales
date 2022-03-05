import 'package:flutter/material.dart';

class ScreenSettings extends StatefulWidget {
  const ScreenSettings({Key? key}) : super(key: key);

  @override
  _ScreenSettingsState createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {

  bool deniedEditSettings = false; // Запретить изменять настройки
  bool deniedEditTypePrice = false; // Запретить изменять тип цены в документах
  bool deniedEditPrice = false; // Запретить изменять цены в документах
  bool deniedEditDiscount = false; // Запретить изменять скидку в документах

  bool useWebExchange = false; // Обмен по вебсервису
  bool enabledTextFieldWebExchange = false;

  bool useFTPExchange = false; // Обмен по FTP
  bool enabledTextFieldFTPExchange = false;

  /// Параметры FTP
  TextEditingController textFieldFTPServerController = TextEditingController();
  TextEditingController textFieldFTPPortController = TextEditingController();
  TextEditingController textFieldFTPUserController = TextEditingController();
  TextEditingController textFieldFTPPasswordController = TextEditingController();
  TextEditingController textFieldFTPWorkCatalogController = TextEditingController();

  /// Параметры WEB-сервиса
  TextEditingController textFieldWEBServerController = TextEditingController();

  @override
  void initState() {
    useFTPExchange = true;
    enabledTextFieldFTPExchange = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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

                  },
                  child: const Icon(Icons.save, size: 26.0),
                )),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Основные'),
              Tab(text: 'Обмен'),
              Tab(text: 'Прочее'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listSettingsMain(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listSettingsExchange(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listSettingsOther()
              ],
            ),
          ],
        ),
      ),
    );
  }

  listSettingsMain() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
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
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
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
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: Column(
        children: const [

        ],
      ),
    );
  }

}
