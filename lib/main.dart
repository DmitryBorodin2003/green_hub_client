import 'dart:ffi';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/login.dart';
import 'package:green_hub_client/pages/register.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppMetrica.activate(_config);

  runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: Login()
  ));
}

AppMetricaConfig get _config =>
    const AppMetricaConfig('b58682f7-3a5e-4bf6-ad64-2d9e0d3a489d', logs: true);