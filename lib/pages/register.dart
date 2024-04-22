import 'package:flutter/material.dart';
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
                    // Переход на ленту
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
                        MaterialPageRoute(builder: (context) => Login()),
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
