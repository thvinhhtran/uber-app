import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:users/Assisstants/assistants_method.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login.dart';
import 'package:users/screens/main_screen.dart';
import 'package:users/infohandle/app_info.dart'; // import provider

class Splashscreen extends ConsumerStatefulWidget {
  const Splashscreen({super.key});

  @override
  ConsumerState<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends ConsumerState<Splashscreen> {

  startTimer() {
    Timer(Duration(seconds: 3), () async  {
      if (firebaseAuth.currentUser != null) {
        // Lấy thông tin user và cập nhật vào provider
        final userInfo = await AssistantsMethod.readCurrentOnlineUserInfo();
        ref.read(userProvider.notifier).state = userInfo;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen()));
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Grab',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}