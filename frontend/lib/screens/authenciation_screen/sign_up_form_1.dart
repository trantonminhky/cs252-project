import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';

class SignUpForm1 extends StatelessWidget {
  final Function onNext;
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  const SignUpForm1({
    super.key,
    required this.onNext,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70, left: 32, right: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sign up to save all your progress!",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: "BeVietnamPro",
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 33),
          MyTextField(
            textEditingController: emailController,
            label: "Email",
            prefixIcon: CupertinoIcons.mail,
          ),
          const SizedBox(height: 33),
          MyTextField(
            textEditingController: usernameController,
            label: "Username",
            prefixIcon: CupertinoIcons.person,
          ),
          const SizedBox(height: 33),
          MyTextField(
            textEditingController: passwordController,
            label: "Password",
            prefixIcon: CupertinoIcons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 75),
          Center(
            child: TextButton(
              onPressed: () => onNext(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xffd72323),
                fixedSize: const Size(109, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
