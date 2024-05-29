import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/profile.dart';
import 'package:green_hub_client/utilities/publication_utils.dart';
import 'package:green_hub_client/models/author.dart';
import '../storages/user_credentials.dart';
import 'package:green_hub_client/bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:green_hub_client/bottom_navigation_bar/bottom_navigation_logic.dart';
import 'package:green_hub_client/utilities/custom_page_route.dart';
import 'package:green_hub_client/utilities/user_utils.dart';

import '../utilities/action_utils.dart';

class Subscriptions extends StatefulWidget {
  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<Subscriptions> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Author> subscriptionList = [];
  List<Author> followerList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    String? currentUsername = UserCredentials().username;
    if (currentUsername != null) {
      var subscriptionsAndSubscribers = await UserUtils.fetchSubscriptionsAndSubscribers(currentUsername);
      subscriptionList = subscriptionsAndSubscribers[0];
      followerList = subscriptionsAndSubscribers[1];
    }

    setState(() {
      isLoading = false;
    });
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
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    SubscriptionsList(users: subscriptionList, isSubscriptionList: true),
                    SubscriptionsList(users: followerList, isSubscriptionList: false),
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

class SubscriptionsList extends StatefulWidget {
  final List<Author> users;
  final bool isSubscriptionList;

  const SubscriptionsList({
    required this.users,
    required this.isSubscriptionList,
    Key? key,
  }) : super(key: key);

  @override
  State<SubscriptionsList> createState() => _SubscriptionsListState();
}

class _SubscriptionsListState extends State<SubscriptionsList> {

  void _unsubscribeUser(int index) async {
    AppMetrica.reportEvent('Click on "Unsubscribe" button');
    ActionUtils.subscribeOrUnsubscribe('https://greenhubapp.ru:80/users/' + widget.users[index].userId.toString() + '/unsubscribe');
    // Удалить пользователя из списка
    setState(() {
      widget.users.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10), // Задаем скругление углов
            border: Border.all(color: Colors.grey, width: 1),
          ),
          margin: EdgeInsets.all(8), // Добавляем отступы между элементами списка
          child: ListTile(
            leading: GestureDetector(
              onTap: () async {
                Author? author = await UserUtils.fetchAuthorByUsername(widget.users[index].username);
                if (author != null) {
                  Navigator.pushReplacement(
                    context,
                    CustomPageRoute(page: NotMyProfile(author: author)),
                  );
                }
              },
              child: CircleAvatar(
                backgroundImage: MemoryImage(base64Decode(widget.users[index].userImage)),
              ),
            ),
            title: GestureDetector(
              onTap: () async {
                Author? author = await UserUtils.fetchAuthorByUsername(widget.users[index].username);
                if (author != null) {
                  Navigator.pushReplacement(
                    context,
                    CustomPageRoute(page: NotMyProfile(author: author)),
                  );
                }
              },
              child: Text(
                widget.users[index].username,
                style: TextStyle(fontSize: 16), // Размер текста
              ),
            ),
            trailing: widget.isSubscriptionList
                ? ElevatedButton(
              onPressed: () => _unsubscribeUser(index),
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
