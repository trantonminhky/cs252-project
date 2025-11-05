import 'package:flutter/material.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';
import 'package:virtour_frontend/constants/colors.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: MyTextField(
                textEditingController: _usernameController,
                label: "Username",
                prefixIcon: Icons.person,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: MyTextField(
                textEditingController: _passwordController,
                label: "Password",
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: MyTextField(
                textEditingController: _repeatPasswordController,
                label: "Repeat Password",
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "or",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "BeVietnamPro",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 60,
                  child: Card(
                    color: Color(0xffd9d9d9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                ),
                const SizedBox(width: 80),
                SizedBox(
                  width: 100,
                  height: 60,
                  child: Card(
                    color: Color(0xffd9d9d9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kThemeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
