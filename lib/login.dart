import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epictour/home.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  bool isLoading = false;

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email está em um formato inválido';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'A senha deve ter ao menos 8 caracteres';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tela de Login"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Email*',
                              hintText: "exemplo@email.com"),
                          controller: emailInputController,
                          keyboardType: TextInputType.emailAddress,
                          validator: emailValidator,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Senha', hintText: "********"),
                          controller: pwdInputController,
                          obscureText: true,
                          validator: pwdValidator,
                        ),
                        RaisedButton(
                          child: Text("Login"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            if (_loginFormKey.currentState.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: emailInputController.text,
                                      password: pwdInputController.text)
                                  .then((authResult) => Firestore.instance
                                          .collection("users")
                                          .document(authResult.user.uid)
                                          .get()
                                          .then((DocumentSnapshot result) {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                      title: "Bem vindo " +
                                                          capitalize(
                                                              result["fname"]),
                                                      uid: authResult.user.uid,
                                                    )));
                                      }).catchError((err) => print(err)))
                                  .catchError((err) => print(err));
                            }
                          },
                        ),
                        Text("Ainda não possuí conta?"),
                        FlatButton(
                          child: Text("Crie sua conta aqui!"),
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },
                        )
                      ],
                    ),
                  ))));
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
