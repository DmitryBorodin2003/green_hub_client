import 'package:flutter/material.dart';

import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';

class Subscriptions extends StatefulWidget {
  final List<User> subscriptionList;
  final List<User> followerList;

  Subscriptions({
    required this.subscriptionList,
    required this.followerList,
  });

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<Subscriptions> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCFED7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Color(0xFFDCFED7),
              child: SafeArea(
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.grey,
                  labelColor: Colors.black,
                  labelStyle: TextStyle(fontSize: 20, fontFamily: 'Roboto'),
                  tabs: [
                    Tab(text: 'Подписки'),
                    Tab(text: 'Подписчики'),
                  ],
                ),
              ),
            ),
            Container(
              height: 2,
              color: Colors.grey,
            ),
            Expanded(
              child: Container(
                color: Color(0xFFDCFED7),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SubscriptionsList(users: widget.subscriptionList, isSubscriptionList: true),
                    SubscriptionsList(users: widget.followerList, isSubscriptionList: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          BottomNavigationLogic.handleNavigation(context, index);
        },
      ),
    );
  }
}

class SubscriptionsList extends StatelessWidget {
  final List<User> users;
  final bool isSubscriptionList;

  const SubscriptionsList({required this.users, required this.isSubscriptionList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10), // Задаем скругление углов
            border: Border.all(color: Colors.grey, width: 1),
          ),
          margin: EdgeInsets.all(8), // Добавляем отступы между элементами списка
          child: ListTile(
            leading: CircleAvatar(
              // Здесь должна быть логика для загрузки аватара
              // Например: backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
            title: Text(
              users[index].name,
              style: TextStyle(fontSize: 16), // Размер текста
            ),
            trailing: isSubscriptionList
                ? ElevatedButton(
              onPressed: () {
                // Здесь должна быть логика отписки
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Устанавливаем красный цвет кнопки
              ),
              child: Text('Отписаться'),
            )
                : null,
          ),
        );
      },
    );
  }
}

class User {
  final String name;

  User({required this.name});
}
