import 'package:flutter/material.dart';
import 'package:users/screens/register.dart';
import 'package:users/themeprovider/theme_provider.dart';
import 'screens/main_page.dart';
import 'package:firebase_core/firebase_core.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User App',
      themeMode: ThemeMode.system,
      theme: Mythemes.lightTheme,
      darkTheme: Mythemes.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const RegisterScreen(),
    );
  }
}


