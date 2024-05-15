import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/publication_utils.dart';
import '../comment.dart';
import 'bottom_navigation_logic.dart';
import 'bottom_navigation_bar.dart';
import 'custom_page_route.dart';

class Comments extends StatefulWidget {
  final int postId;

  Comments({required this.postId});

  @override
  State<Comments> createState() => _CommentState();
}

class _CommentState extends State<Comments> {
  final TextEditingController _commentController = TextEditingController();
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
            child: FutureBuilder<List<Comment>>(
              future: PublicationUtils.fetchComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else {
                  List<Comment> comments = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      children: comments.map((comment) {
                        return CommentWidget(
                          avatarUrl: comment.authorImage,
                          username: comment.authorName,
                          comment: comment.text,
                        );
                      }).toList(),
                    ),
                  );
                }
              },
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
                      fillColor: Color(0xFFf5fff3),
                    ),
                    controller: _commentController,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: () async {
                    AppMetrica.reportEvent('Click on "Send comment" button');
                    FocusScope.of(context).unfocus();
                    String newCommentText = TextEditingController().text;
                    print(newCommentText);
                    try {
                      await PublicationUtils.sendComment(widget.postId, _commentController.text);
                      _commentController.clear();
                      setState(() {
                      });
                    } catch (error) {
                      print('Ошибка при отправке комментария: $error');
                    }
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
                backgroundImage: MemoryImage(base64.decode(avatarUrl)),
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
          Text(comment, style: TextStyle(fontSize: 22),),
        ],
      ),
    );
  }
}
