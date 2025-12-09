import 'package:flutter/material.dart';
import 'package:sakkeny_app/firebase_options.dart';
import 'package:sakkeny_app/pages/Startup%20pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://pxmihpfbwvvtfrkowxeb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4bWlocGZid3Z2dGZya293eGViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyODY1NzIsImV4cCI6MjA4MDg2MjU3Mn0.hKkXO0O5Wdd1M0hxAIbbMbxLv7S7e994-0FdfVVA8sM',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saknni App', home:  SplashScreen()
      );
  }
}
