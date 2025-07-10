import 'package:flutter/material.dart';
import 'package:users/Splashscreens/splashscreen.dart';
import 'package:users/screens/forgot_password.dart';
import 'package:users/screens/login.dart';
import 'package:users/screens/register.dart';
import 'package:users/themeprovider/theme_provider.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home:  MainScreen(),
    );
  }
}


