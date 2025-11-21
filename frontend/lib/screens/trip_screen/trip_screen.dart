import "package:flutter/material.dart";

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
    );
  }
}
