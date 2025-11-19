import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';
import 'package:virtour_frontend/screens/map_screen/map_screen.dart';

class SignUpForm2 extends StatelessWidget {
  final Function onNext;
  final Function onPrevious;
  final TextEditingController nameController;
  final TextEditingController ageController;

  const SignUpForm2({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.nameController,
    required this.ageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 30),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(CupertinoIcons.back, size: 40),
              onPressed: () => onPrevious(),
            ),
          ),
          const SizedBox(height: 49),
          const Text(
            "We would like to know more about you...",
            style: TextStyle(
              color: Colors.black,
              fontSize: 23,
              fontFamily: "BeVietnamPro",
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 83),
          MyTextField(
            textEditingController: nameController,
            label: "Name",
            hintText: "First name - Last name",
          ),
          const SizedBox(height: 71),
          MyTextField(
            textEditingController: ageController,
            label: "Age",
            digitsOnly: true,
          ),
          const SizedBox(height: 94),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xffd72323),
              fixedSize: const Size(109, 52),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text(
              "Done",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: "BeVietnamPro",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
