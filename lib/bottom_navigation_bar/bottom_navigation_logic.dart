import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/lenta.dart';
import 'package:green_hub_client/pages/subscriptions.dart';
import 'package:green_hub_client/storages/token_storage.dart';
import 'package:green_hub_client/models/author.dart';
import 'package:green_hub_client/pages/createpost.dart';
import 'package:green_hub_client/utilities/custom_page_route.dart';
import 'package:green_hub_client/pages/login.dart';
import 'package:green_hub_client/pages/my_profile.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utilities/user_utils.dart';

class BottomNavigationLogic {
  static void handleNavigation(BuildContext context, int index) async {
    switch (index) {
      case 0:
      //Действия при выборе ленты
        AppMetrica.reportEvent('Click on "Lenta" button');
        Navigator.pushAndRemoveUntil(
          context,
          CustomPageRoute(page: Lenta()),
              (Route<dynamic> route) => false,
        );
        break;
      case 1:
      // Действия при выборе создания поста
        AppMetrica.reportEvent('Click on "New post" button');
        if (await TokenStorage.getToken() != null) {
          Navigator.push(
            context,
            CustomPageRoute(
              page: Createpost(),
            ),
          );
        } else {
          Navigator.push(
            context,
            CustomPageRoute(
              page: Login(),
            ),
          );
        }
        break;
      case 2:
        //Действия при выборе страницы подписки/подписчики
        AppMetrica.reportEvent('Click on "Subscriptions" button');
        if (await TokenStorage.getToken() != null) {
          Navigator.push(
            context,
            CustomPageRoute(page: Subscriptions()),
          );
        } else {
          Navigator.push(
            context,
            CustomPageRoute(
              page: Login(),
            ),
          );
        }

        break;
      case 3:
        //Действия при выборе своего профиля
        AppMetrica.reportEvent('Click on "My profile" button');
        if (await TokenStorage.getToken() != null) {
          print(await TokenStorage.getToken());
          print(await TokenStorage.getUsername());
          String? currentUsername = await TokenStorage.getUsername();
          try {
            Author? author = await UserUtils.fetchAuthorByUsername(currentUsername!);
            if (author != null) {
              Navigator.push(
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
        } else {
          Navigator.push(
            context,
            CustomPageRoute(
              page: Login(),
            ),
          );
        }
        break;
      default:
    }
  }
}
