import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form_1.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form_2.dart';
import 'package:virtour_frontend/screens/authenciation_screen/auth_service.dart';

class SignUpContainer extends StatefulWidget {
  const SignUpContainer({super.key});

  @override
  State<SignUpContainer> createState() => _SignUpContainerState();
}

class _SignUpContainerState extends State<SignUpContainer> {
  int _index = 0;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void changeIndex(int newIndex) {
    setState(() => _index = newIndex);
  }

  void navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 796,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        child: IndexedStack(
          index: _index,
          children: [
            SignUpForm1(
              onNext: () => changeIndex(1),
              usernameController: usernameController,
              passwordController: passwordController,
            ),
            SignUpForm2(
              onNext: navigateToHome,
              onPrevious: () => changeIndex(0),
              nameController: nameController,
              ageController: ageController,
            ),
          ],
        ),
      ),
    );
  }
}
