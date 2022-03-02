import 'package:flutter/material.dart';
import 'package:wp_sales/models/partner.dart';
import 'package:wp_sales/system/system.dart';

class ScreenPartnerItem extends StatefulWidget {
  final Partner partnerItem;

  const ScreenPartnerItem({Key? key, required this.partnerItem})
      : super(key: key);

  @override
  _ScreenPartnerItemState createState() => _ScreenPartnerItemState();
}

class _ScreenPartnerItemState extends State<ScreenPartnerItem> {

  /// Поле ввода: Name
  TextEditingController textFieldNameController = TextEditingController();

  /// Поле ввода: Phone
  TextEditingController textFieldPhoneController = TextEditingController();

  /// Поле ввода: Address
  TextEditingController textFieldAddressController = TextEditingController();

  /// Поле ввода: Balance
  TextEditingController textFieldBalanceController = TextEditingController();

  /// Поле ввода: BalanceForPayment
  TextEditingController textFieldBalanceForPaymentController = TextEditingController();

  /// Поле ввода: Comment
  TextEditingController textFieldCommentController = TextEditingController();

  /// Поле ввода: UID
  TextEditingController textFieldUIDController = TextEditingController();

  /// Поле ввода: Code
  TextEditingController textFieldCodeController = TextEditingController();

  @override
  void initState() {
    setState(() {
      textFieldNameController.text = widget.partnerItem.name;
      textFieldPhoneController.text = widget.partnerItem.phone;
      textFieldAddressController.text = widget.partnerItem.address;
      textFieldBalanceController.text = doubleToString(widget.partnerItem.balance);
      textFieldBalanceForPaymentController.text = doubleToString(widget.partnerItem.balanceForPayment);
      textFieldCommentController.text = widget.partnerItem.comment;

      // Технические данные
      textFieldUIDController.text = widget.partnerItem.uid;
      textFieldCodeController.text = widget.partnerItem.code;
    });
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Партнер'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.filter_list,
                    size: 26.0,
                  ),
                )),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.filter_1), text: 'Главная'),
              Tab(icon: Icon(Icons.filter_2), text: 'Документы'),
              Tab(icon: Icon(Icons.filter_3), text: 'Служебные'),
            ],
          ),
        ),
        //drawer: const MainDrawer(),
        body: TabBarView(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listHeaderOrder(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listDocuments(),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                listService(),
              ],
            ),
          ],
        ),

      ),
    );
  }

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:Text(textMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  listHeaderOrder() {

    return Column(
      children: [
        /// Name
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            controller: textFieldNameController,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Наименование',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      textFieldNameController.text = '';
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Phone
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldPhoneController,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Телефон',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      textFieldPhoneController.text = '';
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Address
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldAddressController,
            textInputAction: TextInputAction.continueAction,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Адрес партнера',
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      textFieldAddressController.text = '';
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Balance
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldBalanceController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Баланс партнера',
            ),
          ),
        ),

        /// Balance for payment
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldBalanceForPaymentController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Баланс партнера (просроченный по оплате)',
            ),
          ),
        ),

        /// Divider
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
          child: Divider(),
        ),

        /// Comment
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          child: TextField(
            controller: textFieldCommentController,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Комментарий',
            ),
          ),
        ),

        /// Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// Записать документ
              SizedBox(
                height: 40,
                width: (MediaQuery.of(context).size.width - 49) / 2,
                child: ElevatedButton(
                    onPressed: () async {
                      showMessage('Запись сохранена!');
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.update, color: Colors.white),
                        SizedBox(width: 14),
                        Text('Записать')
                      ],
                    )),
              ),

              const SizedBox(
                width: 14,
              ),

              /// Отменить запись
              SizedBox(
                height: 40,
                width: (MediaQuery.of(context).size.width - 35) / 2,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: () async {
                      showMessage('Изменение отменено!');
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 14),
                        Text('Отменить'),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  listDocuments() {
    return Container();
  }

  listService() {
    return Column(
      children: [
        /// Поле ввода: UID
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            controller: textFieldUIDController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'UID партнера в 1С',
            ),
          ),
        ),

        /// Поле ввода: Code
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: TextField(
            controller: textFieldCodeController,
            readOnly: true,
            textInputAction: TextInputAction.continueAction,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Код в 1С',
            ),
          ),
        ),
      ],
    );
  }
}
