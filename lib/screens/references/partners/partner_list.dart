import 'package:flutter/material.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/models/accum_partner_depts.dart';
import 'package:wp_sales/models/ref_partner.dart';
import 'package:wp_sales/screens/references/partners/partner_item.dart';
import 'package:wp_sales/system/system.dart';

// Обороты по долгам контрактов
List<AccumPartnerDept> listPartnerDebts = [];

class ScreenPartnerList extends StatefulWidget {
  const ScreenPartnerList({Key? key}) : super(key: key);

  @override
  _ScreenPartnerListState createState() => _ScreenPartnerListState();
}

class _ScreenPartnerListState extends State<ScreenPartnerList> {
  /// Поле ввода: Поиск
  TextEditingController textFieldSearchController = TextEditingController();

  bool showPartnerHierarchy = true;

  bool deniedAddPartner = false;

  // Текущий выбранный каталог иерархии товаров
  Partner parentPartner = Partner();

  List<Partner> listDataPartners = [];

  List<Partner> listPartners = [];

  // Список каталогов для построения иерархии
  List<Partner> treeParentItems = [];

  List<Partner> listPartnersForListView = [];

  // Список идентификаторов партнеров для поиска балансов
  List<String> listPartnersUID = [];

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
        title: const Text('Партнеры'),
      ),
      body: Column(
        children: [
          searchTextField(),
          listViewItems(),
        ],
      ),
      floatingActionButton: deniedAddPartner
          ? FloatingActionButton(
              onPressed: () async {
                var newItem = Partner();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScreenPartnerItem(partnerItem: newItem),
                  ),
                );
                setState(() {
                  renewItem();
                });
              },
              tooltip: 'Добавить партнера',
              child: const Text(
                "+",
                style: TextStyle(fontSize: 25),
              ),
            )
          : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void renewItem() async {
    // Главный каталог всегда будет с таким идентификатором
    if (parentPartner.uid == '') {
      parentPartner.uid = '00000000-0000-0000-0000-000000000000';
    }

    /// Очистка данных
    setState(() {
      listDataPartners.clear();
      listPartners.clear();
      listPartnersForListView.clear(); // Список для отображения на форме
      listPartnersUID.clear();
    });

    ///Первым в список добавим каталог товаров, если он есть
    if (showPartnerHierarchy) {
      if (parentPartner.uid != '00000000-0000-0000-0000-000000000000') {
        listPartners.add(parentPartner);
      }
    }

    /// Загрузка данных из БД
    if (showPartnerHierarchy) {
      // Покажем записи текущего родителя
      listDataPartners = await dbReadPartnersByParent(parentPartner.uid);
    } else {
      String searchString = textFieldSearchController.text.trim().toLowerCase();
      if (searchString.toLowerCase().length >= 3) {
        // Покажем все записи для поиска
        listDataPartners = await dbReadPartnersForSearch(searchString);
      } else {
        // Покажем все записи
        listDataPartners = await dbReadAllPartners();
      }
    }

    /// Сортировка списка: сначала каталоги, потом элементы
    listDataPartners.sort((a, b) => a.name.compareTo(b.name));

    /// Заполним список товаров для отображения на форме
    for (var newItem in listDataPartners) {
      // Пропустим сам каталог, потому что он добавлен первым до заполнения
      if (newItem.uid == parentPartner.uid) {
        continue;
      }

      // Если надо показывать иерархию элементов
      if (showPartnerHierarchy) {
        // Если у товара родитель не является текущим выбранным каталогом
        if (newItem.uidParent != parentPartner.uid) {
          continue;
        }
      } else {
        // Без иерархии показывать каталоги нельзя!
        if (newItem.isGroup == 1) {
          continue;
        }
      }

      // Выводщ только каталогов
      if (newItem.isGroup == 0) {
        continue;
      }

      // Добавим партнера
      listPartners.add(newItem);
    }

    /// Вывод товаров

    /// Заполним список товаров для отображения на форме
    for (var newItem in listDataPartners) {

      // Выводщ только товаров
      if (newItem.isGroup == 1) {
        continue;
      }

      // Добавим партнера
      listPartners.add(newItem);
      listPartnersUID.add(newItem.uid);
    }

    await readDebts();

    setState(() {});
  }

  readDebts() async {
    if (listPartnersUID.isEmpty) {
      debugPrint('Нет UIDs дл вывода долгов...');
      return;
    }

    /// Долги партнеров
    listPartnerDebts =
        await dbReadAllAccumPartnerDeptByUIDPartners(listPartnersUID);

    debugPrint('Долги партнеров: ' + listPartnerDebts.length.toString());

    setState(() {
      debugPrint('Обновлено...');
    });
  }

  searchTextField() {
    var validateSearch = false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
      child: TextField(
        onSubmitted: (String value) {
          renewItem();
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
                  renewItem();
                },
                icon: const Icon(Icons.search, color: Colors.blue),
              ),
              IconButton(
                onPressed: () async {
                  textFieldSearchController.text = '';
                  renewItem();
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
              PopupMenuButton<String>(
                onSelected: (String value) async {
                  if (value == 'showProductHierarchy') {
                    setState(() {
                      showPartnerHierarchy = !showPartnerHierarchy;
                      parentPartner = Partner();
                      treeParentItems.clear();
                      textFieldSearchController.text = '';
                    });
                    renewItem();
                  }
                },
                icon: const Icon(Icons.more_vert, color: Colors.blue),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'showProductHierarchy',
                    child: Row(
                      children: const [
                        Icon(
                          Icons.source,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Выключить иерархию'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  listViewItems() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 0, 9, 14),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: listPartners.length,
          itemBuilder: (context, index) {
            var partnerItem = listPartners[index];
            var balance = 0.0;
            var balanceForPayment = 0.0;

            var indexItemDebt = listPartnerDebts
                .indexWhere((element) => element.uidPartner == partnerItem.uid);
            if (indexItemDebt >= 0) {
              var itemList = listPartnerDebts[indexItemDebt];
              balance = itemList.balance;
              balanceForPayment = itemList.balanceForPayment;
            } else {
              balance = 0.0;
              balanceForPayment = 0.0;
            }

            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Card(
                    elevation: 2,
                    child: partnerItem.isGroup == 1
                        ? DirectoryPartnerItem(
                            parentPartner: parentPartner,
                            partner: partnerItem,
                            tap: () {
                              if (partnerItem.uid == parentPartner.uid) {
                                if (treeParentItems.isNotEmpty) {
                                  // Назначим нового родителя выхода из узла дерева
                                  parentPartner = treeParentItems[
                                      treeParentItems.length - 1];

                                  // Удалим старого родителя для будущего узла
                                  treeParentItems.remove(treeParentItems[
                                      treeParentItems.length - 1]);
                                } else {
                                  // Отправим дерево на его самый главный узел
                                  parentPartner = Partner();
                                }
                                renewItem();
                              } else {
                                treeParentItems.add(parentPartner);
                                parentPartner = partnerItem;
                                renewItem();
                              }
                            })
                        : PartnerItem(
                            partner: partnerItem,
                            tap: () {},
                            balance: balance,
                            balanceForPayment: balanceForPayment,
                          )));
          },
        ),
      ),
    );
  }
}

class PartnerItem extends StatelessWidget {
  final Partner partner;
  final Function tap;
  final double balance;
  final double balanceForPayment;

  const PartnerItem(
      {Key? key,
      required this.partner,
      required this.tap,
      required this.balance,
      required this.balanceForPayment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenPartnerItem(partnerItem: partner),
          ),
        );
      },
      title: Text(partner.name),
      subtitle: Column(
        children: [
          const Divider(),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(
                            child: partner.phone != ''
                                ? Text(partner.phone)
                                : const Text('Нет данных')),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.home, color: Colors.blue, size: 20),
                        const SizedBox(width: 5),
                        Flexible(
                            child: partner.address != ''
                                ? Text(partner.address)
                                : const Text('Нет данных')),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 3,
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DirectoryPartnerItem extends StatelessWidget {
  final Partner parentPartner;
  final Partner partner;
  final Function tap;
  final Function? popTap;

  const DirectoryPartnerItem({
    Key? key,
    required this.parentPartner,
    required this.partner,
    required this.tap,
    this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: partner.uid != parentPartner.uid
          ? null
          : const Color.fromRGBO(227, 242, 253, 1.0),
      onTap: () => tap(),
      //onLongPress: popTap == null ? null : popTap,
      contentPadding: const EdgeInsets.all(0),
      minLeadingWidth: 20,
      leading: const Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: Icon(
          Icons.folder,
          color: Colors.blue,
        ),
      ),
      title: Text(
        partner.name,
        style: const TextStyle(
          fontSize: 16,
        ),
        maxLines: 2,
      ),
      trailing: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: partner.uid != parentPartner.uid
            ? const Icon(Icons.navigate_next)
            : const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}
