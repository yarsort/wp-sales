import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wp_sales/home.dart';
import 'package:wp_sales/system/system.dart';

class ScreenSplashScreen extends StatefulWidget {
  const ScreenSplashScreen({Key? key}) : super(key: key);

  @override
  _ScreenSplashScreenState createState() => _ScreenSplashScreenState();
}

class _ScreenSplashScreenState extends State<ScreenSplashScreen> {
  bool visible = false;

  DateTime currentBackPressTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    //Splash screen или отображает кнопки регистрации или переводит на главный экран
    Timer(const Duration(seconds: 4), () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ScreenHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Container(
        decoration: const BoxDecoration(
            ),
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
                children: const [
                  SizedBox(
                    height: 120,
                  ),
                  FlutterLogo(size: 140),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    'WP Sales',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Помощник менеджера продаж',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white70),
                  ),
                  Expanded(child: SizedBox(),),
                  Text(
                    'ТМ Yarsoft 2022',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
