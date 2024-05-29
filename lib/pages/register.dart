import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

  bool _validateName(String value) {
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z_](?=[\w.]{2,19}$)\w*\.?\w*$');
    if (!nameRegExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  bool _validateEmail(String value) {
    final RegExp emailRegExp = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b');
    if (!emailRegExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  bool _validatePassword(String value) {
    if (value.length > 20) {
      return false;
    }
    return true;
  }

  void _handleRegister() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      if (_isChecked) {
        if (_validateName(name)) {
          if (_validateEmail(email)) {
            if (_validatePassword(password)) {
              UserCredentials().setUsername(name);
              var url = Uri.parse('http://185.251.89.34:80/registration');
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

                Map<String, dynamic>? decodedToken = JwtDecoder.decode(token);

                if (decodedToken.containsKey('roles')) {
                  List<dynamic> roles = decodedToken['roles'];
                  if (roles.isNotEmpty) {
                    String role = roles.first;
                    await TokenStorage.saveRole(role);
                    print(role);
                    Navigator.pushReplacement(
                      context,
                      CustomPageRoute(
                          page: Lenta()),
                    );
                  } else {
                    print('Роль отсутствует в токене');
                  }
                } else {
                  print('Не удалось распарсить токен или поле "roles" отсутствует');
                }
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Ошибка'),
                      content: Text('Ошибка: ' + response.statusCode.toString()),
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
                    content: Text('Пароль не должен быть длиннее 20 символов'),
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
                  content: Text('Некорректный адрес электронной почты'),
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
                content: Text('Имя пользователя не должно содержать кирилицу и быть длиннее 20 символов'),
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
              content: Text('Подтвердите согласие с пользовательским соглашением'),
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
            content: Text('Поля не должны быть пустыми'),
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
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
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
                                    content: Text("Поставьте галочку, пожалуйста."),
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
                    ),
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
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
