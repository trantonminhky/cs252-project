import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/introduction_screen/introduction_screen.dart';
import '../../constants/colors.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer? _timer;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), (){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IntroductionScreen())
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kThemeColor,
      body: Center(
        child: Text(
          "VIRTOUR",
          style: TextStyle(
            fontSize: 64,
            color: Colors.white,
            fontFamily: "Bayon",
            fontStyle: FontStyle.italic,
            shadows: [
              Shadow(
                color: Color.fromRGBO(0, 0, 0, 0.4),
                offset: Offset(-2, 3),
                blurRadius: 8
              )
            ]
          )
        )
      )
    );
  }
}