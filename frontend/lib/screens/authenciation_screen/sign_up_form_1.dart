import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';

class SignUpForm1 extends StatelessWidget {
  final Function onNext;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  const SignUpForm1({
    super.key,
    required this.onNext,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 149, left: 20, right: 30),
      child: Column(
        children: [
          const Text(
            "Sign up to save all your progress!",
            style: TextStyle(
              color: Colors.black,
              fontSize: 23,
              fontFamily: "BeVietnamPro",
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 85),
          MyTextField(
            textEditingController: usernameController,
            label: "Email address/Username",
            hintText: "Email address",
            prefixIcon: CupertinoIcons.person,
          ),
          const SizedBox(height: 71),
          MyTextField(
            textEditingController: passwordController,
            label: "Password",
            prefixIcon: CupertinoIcons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 114),
          TextButton(
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
        ],
      ),
    );
  }
}
