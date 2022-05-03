import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wp_sales/home.dart';
import 'package:wp_sales/screens/auth/login.dart';
import 'package:wp_sales/system/system.dart';

class ScreenSplashScreen extends StatefulWidget {
  const ScreenSplashScreen({Key? key}) : super(key: key);

  @override
  _ScreenSplashScreenState createState() => _ScreenSplashScreenState();
}

class _ScreenSplashScreenState extends State<ScreenSplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  bool visible = false;
  DateTime currentBackPressTime = DateTime.now();
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();

    _initPackageInfo();
    initializeUser();
  }

  Future initializeUser() async {
    if (FirebaseAuth.instance.currentUser != null){
      Timer(
        const Duration(seconds: 3),
            () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                const ScreenHomePage()),
                (Route<dynamic> route) => false),
      );
    } else {
      Timer(const Duration(seconds: 4),
              () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                  const ScreenLogin()),
                  (Route<dynamic> route) => false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Container(
        decoration: const BoxDecoration(),
        child: WillPopScope(
          onWillPop: () async {
            bool backStatus = onWillPop();
            if (backStatus) {
              exit(0);
            }
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 120,
                  ),
                  const FlutterLogo(size: 140),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'WP Sales',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Помощник менеджера продаж',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white70),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Text(
                    'TM Yarsoft. Version: ${_packageInfo.version}. Build:  ${_packageInfo.buildNumber}',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      showMessage('Для выхода нажмите кнопку "Назад" еще раз.', context);
      return false;
    }
    return true;
  }

  cornerLogo() {
    return CircleAvatar(
      radius: 58,
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          height: 114,
          width: 114,
        ),
      ),
    );
  }

  logo() {
    return Image.asset(
      'assets/app_logo.png',
      height: 100,
      width: 100,
      fit: BoxFit.cover,
    );
  }
}
