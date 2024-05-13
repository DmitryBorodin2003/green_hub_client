import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/lenta.dart';
import 'package:green_hub_client/pages/subscriptions.dart';
import 'package:green_hub_client/token_storage.dart';
import '../author.dart';
import '../post.dart';
import '../publication_utils.dart';
import '../user_credentials.dart';
import 'createpost.dart';
import 'custom_page_route.dart';
import 'login.dart';
import 'my_profile.dart';
import 'package:http/http.dart' as http;

class BottomNavigationLogic {
  static void handleNavigation(BuildContext context, int index) async {
    switch (index) {
      case 0:
        //Действия при выборе ленты
        AppMetrica.reportEvent('Click on "Lenta" button');
        var posts = await PublicationUtils.fetchPublications(
            'http://46.19.66.10:8080/publications', context);
        var personalposts = await PublicationUtils.fetchPublications(
            'http://46.19.66.10:8080/publications/subscriptions', context);
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
              page: Lenta(posts: posts, personal_posts: personalposts,)),
        );
        break;
      case 1:
      // Действия при выборе создания поста
        AppMetrica.reportEvent('Click on "New post" button');
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
            page: Createpost(),
          ),
        );
        break;
      case 2:
        //Действия при выборе страницы подписки/подписчики
        AppMetrica.reportEvent('Click on "Subscriptions" button');
        String? currentUsername = UserCredentials().username;
        if (currentUsername != null) {
          var subscriptionsAndSubscribers = await PublicationUtils.fetchSubscriptionsAndSubscribers(currentUsername!);
          List<Author> subscriptionList = subscriptionsAndSubscribers[0];
          List<Author> subscribersList = subscriptionsAndSubscribers[1];
          Navigator.pushReplacement(
            context,
            CustomPageRoute(page: Subscriptions(subscriptionList: subscriptionList, followerList: subscribersList)),
          );
        }
        break;
      case 3:
        //Действия при выборе своего профиля
        AppMetrica.reportEvent('Click on "My profile" button');
        String? currentUsername = UserCredentials().username;
        try {
          Author? author = await PublicationUtils.fetchAuthorByUsername(currentUsername!);
          if (author != null) {
            Navigator.pushReplacement(
              context,
              CustomPageRoute(page: Profile(author: author)),
            );
            print(author.userId);
          } else {
            // Обработка случая, когда пользователь не найден или произошла ошибка
            print('Пользователь с таким именем не найден');
          }
        } catch (e) {
          // Обработка ошибок
          print('Произошла ошибка: $e');
        }
        break;
      default:
    }
  }
}
