import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VisitedPlacesPage extends StatelessWidget {
  const VisitedPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Transform.translate(
                offset: const Offset(-15, 0),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(CupertinoIcons.back, size: 40),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Comming soon"),
            ],
          ),
        ),
      ),
    );
  }
}
