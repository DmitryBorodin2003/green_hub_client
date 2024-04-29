import 'package:flutter/material.dart';
import '../post.dart';
import 'custom_page_route.dart';
import 'lenta.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isChecked = false;

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
                    Navigator.pushReplacement(
                      context,
                      CustomPageRoute(page: Lenta(
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
