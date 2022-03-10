import 'package:flutter/material.dart';
import 'package:wp_sales/system/widgets.dart';

class ScreenHomePage extends StatefulWidget {
  const ScreenHomePage({Key? key}) : super(key: key);

  @override
  State<ScreenHomePage> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends State<ScreenHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WP Sales'),
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: width - 16,
                      child: Card(
                        color: Colors.blue,
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: const [
                                  Icon(
                                    Icons.comment,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Заказы',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                              Column(
                                children: const [
                                  Icon(
                                    Icons.comment,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Оплаты',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                              Column(
                                children: const [
                                  Icon(
                                    Icons.category,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Товары',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                              Column(
                                children: const [
                                  Icon(
                                    Icons.comment,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Заказы',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
