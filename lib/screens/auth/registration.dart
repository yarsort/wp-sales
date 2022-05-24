import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_sales/home.dart';
import 'package:wp_sales/screens/auth/login.dart';
import 'package:wp_sales/system/system.dart';

class ScreenRegistration extends StatefulWidget {
  const ScreenRegistration({Key? key}) : super(key: key);

  @override
  _ScreenRegistrationState createState() => _ScreenRegistrationState();
}

class _ScreenRegistrationState extends State<ScreenRegistration> {
  final _auth = FirebaseAuth.instance;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // string for displaying the error Message
  String? errorMessage;

  // Our form key
  final _formKey = GlobalKey<FormState>();

  // Editing Controller
  final firstNameEditingController = TextEditingController();
  final secondNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// Name
    final firstNameField = TextFormField(
        autofocus: false,
        controller: firstNameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ('Имя не может быть пустым');
          }
          if (!regex.hasMatch(value)) {
            return ('Укажите имя (минимум 3 символа)');
          }
          return null;
        },
        onSaved: (value) {
          firstNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          labelText: 'Имя',
          hintText: 'Имя',
          border: OutlineInputBorder(),
        ));

    //second name field
    final secondNameField = TextFormField(
        autofocus: false,
        controller: secondNameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ('Фамилия не может быть пустой');
          }
          return null;
        },
        onSaved: (value) {
          secondNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          labelText: 'Фамилия',
          hintText: 'Фамилия',
          border: OutlineInputBorder(),
        ));

    // Email field
    final emailField = TextFormField(
        autofocus: false,
        controller: emailEditingController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ('Укажите Ваш E-mail');
          }
          // reg expression for email validation
          if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
              .hasMatch(value)) {
            return ('Укажите правильный E-mail');
          }
          return null;
        },
        onSaved: (value) {
          firstNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.mail),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          labelText: 'E-mail',
          hintText: 'E-mail',
          border: OutlineInputBorder(),
        ));

    //password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordEditingController,
        obscureText: true,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ('Укажите пароль');
          }
          if (!regex.hasMatch(value)) {
            return ('Укажите правильный пароль (минимум 6 символов)');
          }
          return null;
        },
        onSaved: (value) {
          firstNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          labelText: 'Пароль',
          hintText: 'Пароль',
          border: OutlineInputBorder(),
        ));

    // Confirm password field
    final confirmPasswordField = TextFormField(
        autofocus: false,
        controller: confirmPasswordEditingController,
        obscureText: true,
        validator: (value) {
          if (confirmPasswordEditingController.text !=
              passwordEditingController.text) {
            return 'Пароли не совпадают';
          }
          return null;
        },
        onSaved: (value) {
          confirmPasswordEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          labelText: 'Подтверждение пароля',
          hintText: 'Подтверждение пароля',
          border: OutlineInputBorder(),
        ));

    final signUpButton = ElevatedButton(
        onPressed: () async {
          signUp(emailEditingController.text, passwordEditingController.text);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              height: 50,
            ),
            Text(
              'Регистрация',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ));

    final loginButton = ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue[200]),
        ),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const ScreenLogin()));
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

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () {
      //       // passing this to our root
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ),
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
                    const SizedBox(height: 15),
                    secondNameField,
                    const SizedBox(height: 15),
                    firstNameField,
                    const SizedBox(height: 15),
                    emailField,
                    const SizedBox(height: 15),
                    passwordField,
                    const SizedBox(height: 15),
                    confirmPasswordField,
                    const SizedBox(height: 15),
                    signUpButton,
                    const SizedBox(height: 15),
                    loginButton,
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {postDetailsToFirestore()})
            .catchError((e) {
          showErrorMessage(e!.message, context);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case 'invalid-email':
            errorMessage = 'Неправильный почтовый ящик.';
            break;
          case 'wrong-password':
            errorMessage = 'Неправильный пароль.';
            break;
          case 'user-not-found':
            errorMessage = 'Пользователь с этим почтовым ящиком не обнаружен.';
            break;
          case 'user-disabled':
            errorMessage = 'Пользователь с этим почтовым ящиком отключен.';
            break;
          case 'too-many-requests':
            errorMessage = 'Слишком много запросов';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Авторизация с почтовым именем и паролем отклбчена.';
            break;
          default:
            errorMessage = 'Неизвестная ошибка.';
        }
        showErrorMessage(errorMessage!, context);
        debugPrint(error.code);
      }
    }
  }

  postDetailsToFirestore() async {
    showMessage('Аккаунт успешно создан!', context);

    final SharedPreferences prefs = await _prefs;

    prefs.setString(
        'settings_nameUser',
        firstNameEditingController.text +
            ' ' +
            secondNameEditingController.text);
    prefs.setString('settings_emailUser', emailEditingController.text);

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => const ScreenHomePage()),
        (route) => false);
  }
}
