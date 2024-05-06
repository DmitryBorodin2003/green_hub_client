import 'package:flutter/material.dart';
import '../post.dart';
import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';
import 'comments.dart';
import 'custom_page_route.dart';
import 'lenta.dart';
import 'login.dart';


class Profile extends StatefulWidget {
  final List<Post> posts;

  Profile({required this.posts});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCFED7),
      body: ListView(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FFF3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          ClipOval(
                            child: Image.network(
                              'https://i.pinimg.com/originals/2b/64/2f/2b642f9183fa80b8c47a9d8f8971eb4d.jpg',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error);
                              },
                            ),
                          ),

                          SizedBox(height: 8),
                          Text(
                            'Райан',
                            style: TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Подписок: 12',
                            style: TextStyle(color: const Color(0xFF4c4c4c), fontFamily: 'Roboto', fontSize: 20),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Подписчиков: 100',
                            style: TextStyle(color: const Color(0xFF4c4c4c), fontFamily: 'Roboto', fontSize: 20),
                          ),
                          SizedBox(height: 6),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Редактировать профиль'),
                                    content: Text('Здесь будет меню редактирования профиля'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Закрыть'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5fc16f),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: const Color(0xFF333333)),
                                  SizedBox(width: 2),
                                  Text('Редактировать', style: TextStyle(color: const Color(0xFF333333), fontFamily: 'Roboto', fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                CustomPageRoute(page: Login()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5fc16f),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.exit_to_app, color: const Color(0xFF333333)),
                                  SizedBox(width: 2),
                                  Text('Выйти', style: TextStyle(color: const Color(0xFF333333), fontFamily: 'Roboto', fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Блок "Список значков" с заслугами владельца профиля
                Container(
                  margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FFF3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            'Список значков',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            '🎉',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Лучший инфлюенсер',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            '🥸',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Топ-10 по адекватности',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            '🐘',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Защитник животных',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],

                  ),

                ),
                SizedBox(height: 8),
                // Блок ленты с постами пользователя
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.posts.length,
                  itemBuilder: (context, index) {
                    final post = widget.posts[index];
                    return Card(
                      color: Color(0xFFF5FFF3),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    post.avatarUrl != null
                                        ? ClipOval(
                                      child: Image.network(
                                        post.avatarUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.error);
                                        },
                                      ),
                                    )
                                        : CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey,
                                      child: Text(post.username[0]),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      post.username,
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(index);
                                  },

                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFFe08684),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Удалить',
                                      style: TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              post.title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                            SizedBox(height: 15),
                            Text(
                              post.content,
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 15),
                            if (post.imageUrl != null)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.network(
                                    post.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${post.rating}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 16),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(Icons.thumb_up),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(Icons.thumb_down),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      CustomPageRoute(
                                        page: Comments(),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.message),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              children: post.tags.map((tag) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(color: Colors.green),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          BottomNavigationLogic.handleNavigation(context, index);
        },
      ),
    );
  }

  void _deletePost(int index) {
    setState(() {
      widget.posts.removeAt(index);
    });
  }

  // Метод для показа диалогового окна удаления поста
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Вы точно хотите удалить публикацию?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Нет"),
            ),
            TextButton(
              onPressed: () {
                _deletePost(index); // Удаляем пост
                Navigator.of(context).pop(); // Закрываем диалоговое окно
              },
              child: Text("Да"),
            ),
          ],
        );
      },
    );
  }
}