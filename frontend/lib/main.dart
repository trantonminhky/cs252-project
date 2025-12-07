import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virtour_frontend/screens/introduction_screen/introduction_screen.dart';
import 'package:virtour_frontend/frontend_service_layer/auth_service.dart';
import 'package:virtour_frontend/screens/map_screen/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore user info from SharedPreferences
  final authService = AuthService();
  await authService.restoreUserInfo();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cultour',
      home: const IntroductionScreen(),
      routes: {
        // '/home': (context) => const HomeScreen(),
        // '/trips': (context) => const Scaffold(
        //       body: Center(child: Text('Trips Screen - Coming Soon')),
        //     ),
        '/map': (context) => const MapScreen(),
        // '/profile': (context) => const Scaffold(
        //       body: Center(child: Text('Profile Screen - Coming Soon')),
        //     ),
      },
    );
  }
}
