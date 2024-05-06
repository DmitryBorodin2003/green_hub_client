import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';

import 'bottom_navigation_logic.dart';
import 'bottom_navigation_bar.dart';

class Comments extends StatefulWidget {
  @override
  State<Comments> createState() => _CommentState();
}

class _CommentState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCFED7), // Новый цвет фона
      appBar: AppBar(
        backgroundColor: Color(0xFFDCFED7), // Новый цвет для верхней панели
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Комментарии',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 5),
          Divider( // Разделительная серая полоса
            height: 1,
            color: Colors.grey,
            thickness: 1,
          ),
          SizedBox(height: 5),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Здесь можно добавить список комментариев
                  CommentWidget(
                    avatarUrl: 'https://via.placeholder.com/150',
                    username: 'User1',
                    comment: 'Пример комментария 1',
                  ),
                  CommentWidget(
                    avatarUrl: 'https://via.placeholder.com/150',
                    username: 'User2',
                    comment: 'Пример комментария 2',
                  ),
                  // Здесь можно добавить другие комментарии
                ],
              ),
            ),
          ),
          Divider( // Разделительная серая полоса
            height: 1,
            color: Colors.grey,
            thickness: 1,
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Введите ваш комментарий...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Color(0xFFf5fff3), // Новый цвет фона
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    AppMetrica.reportEvent('Click on "Send comment" button');
                    // Действие при нажатии кнопки отправки комментария
                  },
                  icon: Icon(Icons.send, color: Colors.green),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          BottomNavigationLogic.handleNavigation(context, index);
        },
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final String comment;

  const CommentWidget({
    required this.avatarUrl,
    required this.username,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFf5fff3), // Новый цвет фона
        borderRadius: BorderRadius.circular(10), // Скруглённые углы
        border: Border.all(color: Colors.grey, width: 1), // Серая обводка
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(comment, style: TextStyle(fontSize: 16),),
        ],
      ),
    );
  }
}
