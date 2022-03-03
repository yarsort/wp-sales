import 'package:flutter/material.dart';

class ScreenAbout extends StatefulWidget {
  const ScreenAbout({Key? key}) : super(key: key);

  @override
  _ScreenAboutState createState() => _ScreenAboutState();
}

class _ScreenAboutState extends State<ScreenAbout> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О программе'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

          ],
        ),
      ),
    );
  }

}
