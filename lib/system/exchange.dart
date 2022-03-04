import 'package:flutter/material.dart';

class ScreenExchangeData extends StatefulWidget {
  const ScreenExchangeData({Key? key}) : super(key: key);

  @override
  _ScreenExchangeDataState createState() => _ScreenExchangeDataState();
}

class _ScreenExchangeDataState extends State<ScreenExchangeData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Обмен данными'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => (item){
              // Создание нового заказа
              if (item == 0) {}
              if (item == 1) {}
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text('Отправить')),
              const PopupMenuItem<int>(value: 1, child: Text('Получить')),
            ],
          ),
        ],
      ),
      body: Container(),
    );
  }
}
