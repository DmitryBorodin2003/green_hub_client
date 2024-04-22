import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/login.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: Login()
  ));
}