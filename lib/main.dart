import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/price.dart';
import 'package:wp_sales/models/warehouse.dart';
import 'package:wp_sales/screens/auth/home.dart';
import 'package:wp_sales/screens/auth/login.dart';
import 'package:wp_sales/screens/references/product/product_selection_treeview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  //await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  void dispose() {
    DatabaseHelper.instance.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WP Sales',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenProductSelectionTreeView(
          listItemDoc: const <ItemOrderCustomer> [],
          price: Price(),
          warehouse: Warehouse()),
      // home: StreamBuilder<User?>(
      // stream: FirebaseAuth.instance.authStateChanges(),
      // builder: (context, snapshot) {
      //   if (snapshot.hasData) {
      //     return const ScreenHomePage();
      //   }
      //   return const ScreenLogin();
      // }),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
        Locale('uk'),
        // ... other locales the app supports
      ],
      locale: const Locale('ru'),
    );
  }
}
