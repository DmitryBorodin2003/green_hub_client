import 'package:flutter/material.dart';
import '../post.dart';
import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';
import 'lenta.dart';
import 'login.dart';


class NotMyProfile extends StatefulWidget {
  final List<Post> posts; // Список постов

  NotMyProfile({required this.posts});

  @override
  State<NotMyProfile> createState() => _NotMyProfileState();
}

class _NotMyProfileState extends State<NotMyProfile> with TickerProviderStateMixin {
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
                              'https://s0.rbk.ru/v6_top_pics/media/img/0/61/755695733019610.png',
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
                            'Грета',
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
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5fc16f),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Text('Подписаться', style: TextStyle(color: const Color(0xFF333333), fontFamily: 'Roboto', fontSize: 18)),
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
                    color: Color(0xFFF5FFF3), // Цвет фона блока
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
                            '🥸',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Новый пользователь',
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
                            'Защитник природы',
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
                      color: Color(0xFFF5FFF3), // Цвет фона карточки поста
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
                                  borderRadius: BorderRadius.circular(7), // Применяем скругление углов
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7), // Применяем скругление углов
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
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Страница комментариев'),
                                          content: Text('Здесь будет страница комментариев'),
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
                                  icon: Icon(Icons.message),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Выводим список тегов
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
}
