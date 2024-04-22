import 'package:flutter/material.dart';
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

    //Здесь будет переход на ленту
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Register()), // Перенаправление на страницу входа
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
