import 'package:flutter/material.dart';

class ScreenHelp extends StatefulWidget {
  const ScreenHelp({Key? key}) : super(key: key);

  @override
  _ScreenHelpState createState() => _ScreenHelpState();
}

class _ScreenHelpState extends State<ScreenHelp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справка'),
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
