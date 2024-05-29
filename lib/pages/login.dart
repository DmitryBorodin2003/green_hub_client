import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/banned.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../token_storage.dart';
import '../user_credentials.dart';
import 'custom_page_route.dart';
import 'lenta.dart';
import 'register.dart';
import 'package:http/http.dart' as http;
import '../publication_utils.dart';

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isNotEmpty && password.isNotEmpty) {
      UserCredentials().setUsername(name);
      var url = Uri.parse('http://185.251.89.34:80/auth');
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': name,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var token = responseData['token'];
        await TokenStorage.saveToken(token);

        Map<String, dynamic>? decodedToken = JwtDecoder.decode(token);

        if (decodedToken.containsKey('roles')) {
          List<dynamic> roles = decodedToken['roles'];
          if (roles.isNotEmpty) {
            String role = roles.first;
            await TokenStorage.saveRole(role);
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
      } else if (response.statusCode == 406) {
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
              page: BannedPage()),
        );
      }
      else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ошибка'),
              content: Text('Ошибка при входе на стороне сервера: ' + response.statusCode.toString()),
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
            content: Text('Ошибка при авторизации на стороне клиента: некорректный ввод'),
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
          height: 280,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Имя',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AppMetrica.reportEvent('Click on "Login" button');
                    _handleLogin();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16)), // Увеличение высоты кнопки
                  ),
                  child: Text(
                    'Войти',
                    style: TextStyle(fontSize: 22, fontFamily: 'Roboto'),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Wrap(
                alignment: WrapAlignment.center, // Выравнивание элементов по центру
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Новый пользователь? ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AppMetrica.reportEvent('Click on "login to register" button');
                      Navigator.pushReplacement(
                        context,
                        CustomPageRoute(page: Register()), // Перенаправление на страницу входа
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Зарегистрироваться',
                        style: TextStyle(
                          color: Colors.green,
                        ),
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
