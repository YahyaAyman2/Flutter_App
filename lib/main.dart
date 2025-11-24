import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/splash_screen.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Saknni App', home: const SplashScreen());
  }
}
