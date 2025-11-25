import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/home_screen/home_screen.dart';
import 'package:virtour_frontend/screens/profile_screen/profile_screen.dart';
import 'package:virtour_frontend/screens/trip_screen/trip_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final Widget _questIcon;
  late final Widget _homeIcon;
  late final Widget _profileIcon;
  late final Widget _mapIcon;

  void _changeIndex(int newIndex) {
    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);
    }
  }

  @override
  void initState() {
    super.initState();
    _questIcon = Image.asset(
      "assets/icons/quest.png",
      width: 30,
      height: 30,
    );
    _homeIcon = Image.asset(
      "assets/icons/home.png",
      width: 30,
      height: 30,
    );
    _profileIcon = Image.asset(
      "assets/icons/profile.png",
      width: 30,
      height: 30,
    );
    _mapIcon = Image.asset(
      "assets/icons/pin.png",
      width: 30,
      height: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: [
        // Home screen has its own navigator
        Navigator(
          onGenerateRoute: (settings) {
            return CupertinoPageRoute(builder: (context) {
              return const HomeScreen();
            });
          },
        ),
        const TripScreen(),
        // temporarily dismiss MapScreen()
        // const MapScreen(),
        const Text("MapScreen"),
        Navigator(
          onGenerateRoute: (settings) {
            return CupertinoPageRoute(builder: (context) {
              return const ProfileScreen();
            });
          },
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _changeIndex,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xffd72323),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: "BeVietnamPro",
          fontWeight: FontWeight.w700,
        ),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: "BeVietnamPro",
          fontWeight: FontWeight.w700,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _homeIcon, // Use cached image
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _questIcon, // Use cached image
            ),
            label: "Trips",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _mapIcon, // Use cached image
            ),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _profileIcon, // Use cached image
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
