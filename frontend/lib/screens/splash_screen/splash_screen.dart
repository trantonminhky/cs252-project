import 'package:flutter/material.dart';
import '../../global/colors.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, "/intro");
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
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
