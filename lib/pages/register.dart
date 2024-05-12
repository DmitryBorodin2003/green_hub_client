import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import '../author.dart';
import '../post.dart';
import '../publication_utils.dart';
import '../token_storage.dart';
import '../user_credentials.dart';
import 'custom_page_route.dart';
import 'lenta.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({Key? key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isChecked = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _handleRegister() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (_isChecked && name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      UserCredentials().setUsername(name);
      var url = Uri.parse('http://46.19.66.10:8080/registration');
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        var responseData = json.decode(response.body);
        var token = responseData['token'];
        await TokenStorage.saveToken(token);

        var posts = await PublicationUtils.fetchPublications(
            'http://46.19.66.10:8080/publications', context);
        var personalposts = await PublicationUtils.fetchPublications(
            'http://46.19.66.10:8080/publications/subscriptions', context);
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
              page: Lenta(posts: posts, personal_posts: personalposts,)),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ошибка'),
              content: Text('Ошибка при входе'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Закрыть всплывающее окно
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ошибка'),
            content: Text('Некорректный ввод'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрыть всплывающее окно
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.85;

    return Scaffold(
      backgroundColor: const Color(0xFFDCFED7),
      body: Center(
        child: Container(
          width: containerWidth,
          height: 380,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Имя',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Пароль',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Поставив галочку, вы соглашаетесь с ',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          AppMetrica.reportEvent('Click on "Terms of use" button');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Пользовательское соглашение"),
                                content: Text("Поставьте галочку пж"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      // Действие при нажатии на кнопку "Закрыть"
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Закрыть"),
                                  ),
                                ],
                              );
                            },
                          );
                        },

                        child: Text(
                          'Пользовательским соглашением',
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AppMetrica.reportEvent('Click on "Register" button');
                    _handleRegister();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16)), // Увеличение высоты кнопки
                  ),
                  child: Text(
                    'Зарегистрироваться',
                    style: TextStyle(fontSize: 22, fontFamily: 'Roboto'),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Уже зарегистрированы? ',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AppMetrica.reportEvent('Click on "register to login" button');
                      Navigator.pushReplacement(
                        context,
                        CustomPageRoute(page: Login()),
                      );
                    },
                    child: Text(
                      'Войти',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
