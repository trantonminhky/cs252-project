import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/authenciation_screen.dart';
import 'package:virtour_frontend/screens/introduction_screen/introduction_screen.dart';
import 'screens/splash_screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Virtour',
      initialRoute: "/intro",
      routes: {
        // "/c": (context) => const SplashScreen(),
        "/intro": (context) => const IntroductionScreen(),
        "/auth": (context) => const AuthenciationScreen(),
      },
    );
  }
}
