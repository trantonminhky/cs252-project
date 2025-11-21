import "package:flutter/material.dart";
import "package:virtour_frontend/components/bottom_bar.dart";

//placeholder code to test functionality in place_overview
class TripScreen extends StatelessWidget {
  const TripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Screen"),
      ),
      body: const Center(
        child: Text("This is the Trip Screen"),
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 1, // Trips screen
      ),
    );
  }
}
