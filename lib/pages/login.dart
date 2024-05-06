import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import '../post.dart';
import 'custom_page_route.dart';
import 'lenta.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        CustomPageRoute(
            page: Lenta(
                posts: [
                  Post(
                      content: 'Сегодня мы с командой убрали мусор на берегах водохранилища!',
                      title: 'Отчет об уборке мусора',
                      username: 'Грета',
                      avatarUrl: 'https://s0.rbk.ru/v6_top_pics/media/img/0/61/755695733019610.png',
                      rating: 100,
                      tags: ['#Уборка', '#Воронеж', '#Мусор'],
                      imageUrl: 'https://vremenynet.ru/image_3814.png'),
                  Post(
                    content: 'Уличные животные тоже хотят еды и тепла. Пожалуйста, помогайте нам!',
                    title: 'Не забывайте нас!',
                    username: 'Мистер Кот',
                    avatarUrl: 'https://static5.tgstat.ru/channels/_0/af/af18c25836a1cac48b3e857f96911013.jpg',
                    rating: 200,
                    tags: ['#Животные', '#Кот'],
                  )
                ]
            )
        ), // Переход на экран ленты
      );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Новый пользователь? ',
                    style: TextStyle(
                      color: Colors.black,
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
                    child: Text(
                      'Зарегистрироваться',
                      style: TextStyle(
                        color: Colors.green,
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
