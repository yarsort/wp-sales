import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/import/import_model.dart';
import 'package:wp_sales/screens/references/contracts/contract_item.dart';
import 'package:wp_sales/system/system.dart';

class ScreenContractList extends StatefulWidget {
  const ScreenContractList({Key? key}) : super(key: key);

  @override
  _ScreenContractListState createState() => _ScreenContractListState();
}

class _ScreenContractListState extends State<ScreenContractList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool loadingItems = false;

  // Флаг отображения списка контрактов с балансом
  bool onlyWithBalance = false;

  bool deniedEditContracts = false;

  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  List<Contract> tempItems = [];
  List<Contract> listContracts = [];

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
        title: const Text('Договоры партнеров'),
      ),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: deniedEditContracts
          ? FloatingActionButton(
              onPressed: () async {
                var newItem = Contract();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScreenContractItem(contractItem: newItem),
                  ),
                );
                setState(() {
                  renewItem();
                });
              },
              tooltip: 'Добавить договор',
              child: const Text(
                "+",
                style: TextStyle(fontSize: 25),
              ),
            )
          : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {

    setState(() {
      loadingItems = true;
    });

    final SharedPreferences prefs = await _prefs;

    bool useTestData = prefs.getBool('settings_useTestData') ?? false;

    // Настройки редактирования
    deniedEditContracts =
        prefs.getBool('settings_deniedEditContracts') ?? false;

    // Очистка списка заказов покупателя
    listContracts.clear();
    tempItems.clear();

    // Если включены тестовые данные
    if (useTestData) {
      for (var message in listDataPrice) {
        Contract newItem = Contract.fromJson(message);
        listContracts.add(newItem);
      }
    } else {
      // Показать только с балансами
      if (onlyWithBalance) {
        List<AccumPartnerDept> listAccumPartnerDept = await dbReadAllAccumPartnerDept();
        List listContractUID = [];
        for (var partnerDebts in listAccumPartnerDept) {
          // Если контракта нет в списке
          if (!listContractUID.contains(partnerDebts.uidContract)) {
            listContractUID.add(partnerDebts.uidContract);
          }
        }
        listContracts = await dbReadContractsByUID(listContractUID);

      } else {
        listContracts = await dbReadAllContracts();
      }

    }

    listContracts.sort((a, b) => a.name.compareTo(b.name));

    tempItems.addAll(listContracts);

    if (mounted) {
      setState(() {
        loadingItems = false;
      });
    } else {
      loadingItems = false;
    }
  }

  void filterSearchResults(String query) {
    /// Уберем пробелы
    query = query.trim();

    /// Искать можно только при наличии 3 и более символов
    if (query.length < 3) {
      setState(() {
        listContracts.clear();
        listContracts.addAll(tempItems);
      });
      return;
    }

    List<Contract> dummySearchList = <Contract>[];
    dummySearchList.addAll(listContracts);

    if (query.isNotEmpty) {
      List<Contract> dummyListData = <Contract>[];

      for (var item in dummySearchList) {
        /// Поиск по имени контракта
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }

        /// Поиск по имени партнера
        if (item.namePartner.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }

        /// Поиск по адресу
        if (item.address.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }

        /// Поиск по номеру телефона
        if (item.phone.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        listContracts.clear();
        listContracts.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listContracts.clear();
        listContracts.addAll(tempItems);
      });
    }
  }

  searchTextField() {
    var validateSearch = false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: TextField(
            onChanged: (String value) {
              filterSearchResults(value);
            },
            controller: textFieldSearchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              labelText: 'Поиск',
              errorText: validateSearch ? 'Вы не указали строку поиска!' : null,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      var value = textFieldSearchController.text;
                      filterSearchResults(value);
                    },
                    icon: const Icon(Icons.search, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () async {
                      textFieldSearchController.text = '';
                      var value = textFieldSearchController.text;
                      filterSearchResults(value);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
            child: Row(
              children: [
                Checkbox(
                  value: onlyWithBalance,
                  onChanged: (value) {
                    setState(() {
                      onlyWithBalance = !onlyWithBalance;
                      renewItem();
                    });
                  },
                ),
                const Flexible(child: Text('Только с балансом')),
              ],
            )),
      ],
    );
  }

  listViewItems() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 0, 9, 14),
        child: !loadingItems ? ListView.builder(
          shrinkWrap: true,
          itemCount: listContracts.length,
          itemBuilder: (context, index) {
            var contractItem = listContracts[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ContractItem(
                  contractItem: contractItem,
                ));
          },
        ) : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class ContractItem extends StatefulWidget {
  final Contract contractItem;

  const ContractItem(
      {Key? key, required this.contractItem})
      : super(key: key);

  @override
  State<ContractItem> createState() => _ContractItemState();
}

class _ContractItemState extends State<ContractItem> {
  double balance = 0.0;
  double balanceForPayment = 0.0;

  @override
  void initState() {
    super.initState();
    renewDataContract();
  }

  @override
  Widget build(BuildContext context) {
    return cardContract();
  }

  cardContract() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Card(
          elevation: 2,
          child: ListTile(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ScreenContractItem(contractItem: widget.contractItem),
                ),
              );
            },
            title: Text(widget.contractItem.name),
            subtitle: Column(
              children: [
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 5),
                              Flexible(
                                  child: Text(widget.contractItem.namePartner)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 5),
                              Text(widget.contractItem.phone),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.home,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 5),
                              Flexible(
                                  child: Text(widget.contractItem.address)),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.price_change,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 5),
                              Text(doubleToString(balance)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.price_change,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 5),
                              Text(doubleToString(balanceForPayment)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 5),
                              Text(widget.contractItem.schedulePayment
                                  .toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  renewDataContract() async {
    // Получить баланс заказа
    Map debts = await dbReadSumAccumPartnerDeptByContract(
        uidContract: widget.contractItem.uid);

    // Запись в реквизиты
    balance = debts['balance'];
    balanceForPayment = debts['balanceForPayment'];

    if (mounted) {
      setState(() {});
    }
  }
}
