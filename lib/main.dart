import 'dart:ffi';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/lenta.dart';
import 'package:green_hub_client/pages/login.dart';
import 'package:green_hub_client/pages/register.dart';
import 'package:green_hub_client/publication_utils.dart';
import 'package:green_hub_client/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppMetrica.activate(_config);

  await TokenStorage.clearToken();
  await TokenStorage.clearRole();

  runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: Lenta(),
  ));
}

AppMetricaConfig get _config =>
    const AppMetricaConfig('b58682f7-3a5e-4bf6-ad64-2d9e0d3a489d', logs: true);