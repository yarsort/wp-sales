import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_doc_incoming_cash_order.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';
import 'package:wp_sales/screens/documents/order_customer/order_customer_item.dart';
import 'package:wp_sales/system/system.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenOrderCustomerSelection extends StatefulWidget {
  final IncomingCashOrder? incomingCashOrder;
  final ReturnOrderCustomer? returnOrderCustomer;

  const ScreenOrderCustomerSelection({Key? key,
    this.incomingCashOrder,
    this.returnOrderCustomer}) : super(key: key);

  @override
  _ScreenOrderCustomerSelectionState createState() =>
      _ScreenOrderCustomerSelectionState();
}

class _ScreenOrderCustomerSelectionState extends State<ScreenOrderCustomerSelection> {
  /// Поля ввода: Поиск
  TextEditingController textFieldNewSearchController = TextEditingController();

  /// Количество документов в списках на текущий момент
  int countParentDocuments = 0;

  /// Списки документов
  List<OrderCustomer> listParentOrdersCustomer = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    await loadParentDocuments();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Выбор заказа'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          yesSendDocuments(),
        ],
      ),
    );
  }

  loadParentDocuments() async {
    // Очистка списка заказов покупателя
    listParentOrdersCustomer.clear();
    countParentDocuments = 0;

    String uidPartner = '';
    if (widget.incomingCashOrder != null) {
      uidPartner = widget.incomingCashOrder?.uidPartner??'';
    }
    if (widget.returnOrderCustomer != null) {
      uidPartner = widget.returnOrderCustomer?.uidPartner??'';
    }

    //  Получим список заказов партнера
    List tempListParentOrdersCustomer = await dbReadOrderCustomerUIDPartner(uidPartner);

    //  Если в подчиненном документе есть указанны договор, то отфильтруем по нему
    for (var itemOrderCustomer in tempListParentOrdersCustomer) {
      if (widget.returnOrderCustomer?.uidContract != '') {

        // Если контракт не такой как в документе, то пропустим его.
        // Значит идет подбор заказов строго по договору.
        if (widget.returnOrderCustomer?.uidContract != itemOrderCustomer?.uidContract) {
          continue;
        }
      }
      listParentOrdersCustomer.add(itemOrderCustomer);
    }

    // Количество документов в списке
    countParentDocuments = listParentOrdersCustomer.length;

    debugPrint('Количество новых документов: ' + countParentDocuments.toString());
  }

  yesSendDocuments() {
    // Отображение списка заказов покупателя
    return ColumnBuilder(
        itemCount: listParentOrdersCustomer.length,
        itemBuilder: (context, index) {
          final orderCustomer = listParentOrdersCustomer[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Card(
              elevation: 3,
              child: ListTile(
                tileColor: orderCustomer.numberFrom1C != ''
                    ? Colors.lightGreen[50]
                    : Colors.deepOrange[50],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScreenItemOrderCustomer(orderCustomer: orderCustomer),
                    ),
                  );
                  loadData();
                },
                title: Text(orderCustomer.namePartner),
                subtitle: Column(
                  children: [
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.domain, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(
                            flex: 1, child: Text(orderCustomer.nameContract)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(orderCustomer.date)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(
                                      orderCustomer.dateSending)),
                                ],
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.price_change,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(doubleToString(orderCustomer.sum) +
                                      ' грн'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered_rtl,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(orderCustomer.countItems.toString() +
                                      ' поз'),
                                ],
                              ),
                            ],
                          ))
                    ]),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.more_time,
                                      color: Colors.blue, size: 20),
                                  const SizedBox(width: 5),
                                  Text(shortDateToString(
                                      orderCustomer.dateSendingTo1C)),
                                ],
                              )
                            ],
                          )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  orderCustomer.numberFrom1C != ''
                                      ? const Icon(Icons.repeat_one,
                                      color: Colors.green, size: 20)
                                      : const Icon(Icons.repeat_one,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 5),
                                  orderCustomer.numberFrom1C != ''
                                      ? Text(orderCustomer.numberFrom1C)
                                      : const Text('Нет данных!',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              )
                            ],
                          ))
                    ]),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
