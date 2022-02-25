import 'package:flutter/material.dart';
import '../system/drawer.dart';

class OrderCustomer extends StatefulWidget {
  const OrderCustomer({Key? key}) : super(key: key);

  @override
  _OrderCustomerState createState() => _OrderCustomerState();
}

class _OrderCustomerState extends State<OrderCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказы покупателей'),
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Заказы покупателей не обнаружено!',
              style: TextStyle(fontSize: 25, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: '+',
        child: const Text(
          "+",
          style: TextStyle(fontSize: 30),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  
}

