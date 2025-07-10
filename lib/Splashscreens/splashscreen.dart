import 'dart:async';

import 'package:flutter/material.dart';
import 'package:users/Assisstants/assistants_method.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login.dart';
import 'package:users/screens/main_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  startTimer() {
    Timer(Duration(seconds: 3), () async  {
      if (await firebaseAuth.currentUser != null) {
        firebaseAuth.currentUser!= null ? AssistantsMethod.readCurrentOnlineUserInfo() :null;
        Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));

      }
      else {
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Ubers',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,

          ),
          ),
        ),
    );
  }
}