import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wp_sales/home.dart';
import 'package:wp_sales/screens/auth/registration.dart';

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({Key? key}) : super(key: key);

  @override
  _ScreenLoginState createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // firebase
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    // Email field
    final emailField = TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ('Введите E-Mail');
          }
          // reg expression for email validation
          if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
              .hasMatch(value)) {
            return ('Пожалуйста, введите правильный почтовый адрес');
          }
          return null;
        },
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.mail, color: Colors.blue,),
          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          labelText: 'E-mail',
          hintText: 'E-mail',
          border: OutlineInputBorder(),
        ));

    // Password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: true,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ('Укажите пароль');
          }
          if (!regex.hasMatch(value)) {
            return ('Введите пароль (минимум 6 символов)');
          }
          //return ('');
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.vpn_key, color: Colors.blue,),
          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          labelText: 'Пароль',
          hintText: 'Пароль',
          border: OutlineInputBorder(),
        ));

    final login2Button = ElevatedButton(
        onPressed: () async {
          signIn(emailController.text, passwordController.text);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 50,),
            Text('Войти',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),),
            SizedBox(height: 50,),
          ],
        ));

    final registration2Button = ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue[200]),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const ScreenRegistration()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 50,),
            Text('Зарегистрироватся',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),),
            SizedBox(height: 50,),
          ],
        ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_splash.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            //color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                         height: MediaQuery.of(context).size.height * 0.15,
                         child: Image.asset(
                           'assets/images/wpsales_logo.png',
                           fit: BoxFit.contain,
                         )),
                    // const SizedBox(
                    //     height: 150,
                    //     child: FlutterLogo(size: 150,)),
                    const SizedBox(height: 45),
                    emailField,
                    const SizedBox(height: 15),
                    passwordField,
                    const SizedBox(height: 15),
                    login2Button,
                    const SizedBox(height: 15),
                    registration2Button,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  showMessage(String textMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(textMessage),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Login function
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) => {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ScreenHomePage())),
        });
        showMessage('Авторизация успешно выполнена!');

      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case 'invalid-email':
            errorMessage = 'Указан неправильный E-mail.';
            break;
          case 'wrong-password':
            errorMessage = 'Указан неправильный пароль.';
            break;
          case 'user-not-found':
            errorMessage = 'Пользователь не найден.';
            break;
          case 'user-disabled':
            errorMessage = 'Пользователь отключен.';
            break;
          case 'too-many-requests':
            errorMessage = 'Слишком много запросов подключения.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Операция авторизации пользователя не подключена.';
            break;
          default:
            errorMessage = 'Неизвестная ошибка.';
        }
        showMessage(errorMessage!);
        debugPrint(error.code);
      }
    }
  }
}