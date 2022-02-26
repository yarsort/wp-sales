import 'package:flutter/material.dart';
import 'package:wp_sales/models/orderCustomer.dart';
import 'package:intl/intl.dart';
import '../../system/widgets.dart';

class OrdersCustomer extends StatefulWidget {
  const OrdersCustomer({Key? key}) : super(key: key);

  @override
  _OrdersCustomerState createState() => _OrdersCustomerState();
}

class _OrdersCustomerState extends State<OrdersCustomer> {
  int countNewDocuments = 0;
  int countSendDocuments = 0;
  int countTrashDocuments = 0;

  DateTime startPeriodOrders = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
  DateTime finishPeriodOrders = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,23,59,59);
  
  List<OrderCustomer> listNewOrdersCustomer = [];
  List<OrderCustomer> listSendOrdersCustomer = [];
  List<OrderCustomer> listTrashOrdersCustomer = [];

  final messageList = [
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ТОВ Сертон',
      'uidContract': '',
      'uidPrice': '',
      'sum': '2150.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Великов Сергій',
      'uidContract': '',
      'uidPrice': '',
      'sum': '10050.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'uidContract': '',
      'namePartner': 'ФОП Сергієнко Володимир',
      'uidPrice': '',
      'sum': '1050.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
    {
      'id': '931d0704-dad2-4363-9f29-473f50201cbf',
      'isDeleted': 0,
      'date': '2022-07-20 20:00:00',
      'uid': '03704c3a-025e-4d5b-b3f9-9213a338e807',
      'uidOrganization': '',
      'uidPartner': '',
      'namePartner': 'ФОП Терманов Дмитро',
      'uidContract': '',
      'uidPrice': '',
      'sum': '250.00',
      'dateSending': '2022-07-21 19:00:00',
      'datePaying': '2022-07-22 14:00:00',
      'sendYesTo1C': 0,
      'sendNoTo1C': 0,
      'dateSendingTo1C': '2022-07-21 19:00:00',
      'numberFrom1C': 'DDY-215'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Заказы покупателей'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    
                  },
                  child: const Icon(
                    Icons.filter_list,
                    size: 26.0,
                  ),
                )
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.filter_1), text: 'Новые'),
              Tab(icon: Icon(Icons.filter_2), text: 'Отправленые'),
              Tab(icon: Icon(Icons.filter_none), text: 'Корзина'),
            ],
          ),
        ),
        drawer: const MainDrawer(),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                countNewDocuments == 1 ? noDocuments() : yesNewDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                countSendDocuments == 0 ? noDocuments() : yesSendDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listParameters(),
                countTrashDocuments == 0 ? noDocuments() : yesTrashDocuments(),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: '+',
          child: const Text(
            "+",
            style: TextStyle(fontSize: 30),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  listParameters() {
    return const ExpansionTile(
      title: Text('Параметры отбора'),
      children: [
        ListTile(title: Text('Отбор по датам')),
        ListTile(title: Text('Отбор по контрагенту')),
      ],
    );
  }

  yesNewDocuments() {

    // Очистка списка заказов покупателя
    listNewOrdersCustomer.clear();

    // Получение и запись списка заказов покупателей
    for (var message in messageList) {
      OrderCustomer newOrderCustomer = OrderCustomer.fromJson(message);
      listNewOrdersCustomer.add(newOrderCustomer);}

    // Количество документов в списке
    countNewDocuments = listNewOrdersCustomer.length;

    return ColumnBuilder(
      itemCount: countNewDocuments,
      itemBuilder: (context, index) {
        final item = listNewOrdersCustomer[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            5 * 2.0,
            5,
            5 * 2.0,
            5,
          ),
          child: Card(
            elevation: 5,
            child: ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text(listNewOrdersCustomer[index].namePartner),
              subtitle: Text(
                  'Сумма: ' + doubleToString(listNewOrdersCustomer[index].sum) +
                      '\n'
                          'Номер в 1С: ' +
                      listNewOrdersCustomer[index].numberFrom1C),
              trailing: PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Редактировать'),
                    ),
                    const PopupMenuItem(
                      value: 'send',
                      child: Text('Отправить'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Удалить'),
                    )
                  ];
                },
                onSelected: (String value) {
                  print('You Click on po up menu item');
                },
              ),
            ),
          ),
        );
      });


  }

  yesSendDocuments() {

    // Очистка списка заказов покупателя
    listSendOrdersCustomer.clear();

    // Получение и запись списка заказов покупателей
    for (var message in messageList) {
      OrderCustomer newOrderCustomer = OrderCustomer.fromJson(message);
      listSendOrdersCustomer.add(newOrderCustomer);}

    // Количество документов в списке
    countSendDocuments = listSendOrdersCustomer.length;

    // Отображение списка заказов покупателя
    return ListView.builder(
      itemCount: listSendOrdersCustomer.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.abc),
          title: Text(listSendOrdersCustomer[index].uidPartner),
          subtitle: Text(listSendOrdersCustomer[index].sum.toString()),
          trailing: PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('Просмотр'),
                ),
              ];
            },
            onSelected: (String value){
              print('You Click on po up menu item');
            },
          ),
        );
      },
    );
  }

  yesTrashDocuments() {

    // Очистка списка заказов покупателя
    listTrashOrdersCustomer.clear();

    // Получение и запись списка заказов покупателей
    for (var message in messageList) {
      OrderCustomer newOrderCustomer = OrderCustomer.fromJson(message);
      listTrashOrdersCustomer.add(newOrderCustomer);}

    // Количество документов в списке
    countTrashDocuments = listTrashOrdersCustomer.length;

    // Отображение списка заказов покупателя
    return ListView.builder(
      itemCount: listTrashOrdersCustomer.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.abc),
          title: Text(listTrashOrdersCustomer[index].uidPartner),
          subtitle: Text(listTrashOrdersCustomer[index].sum.toString()),
          trailing: PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Редактировать'),
                ),
                const PopupMenuItem(
                  value: 'erase',
                  child: Text('Уничтожить'),
                )
              ];
            },
            onSelected: (String value){
              print('You Click on po up menu item');
            },
          ),
        );
      },
    );
  }

  noDocuments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            'Заказов не обнаружено!',
            style: TextStyle(fontSize: 25, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  doubleToString(double sum) {
    var f = NumberFormat("##0.00", "en_US");
    return (f.format(sum).toString());
  }
}
