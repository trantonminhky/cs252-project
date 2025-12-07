import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:virtour_frontend/global/userinfo.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';

class SignUpForm1 extends StatefulWidget {
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
  State<SignUpForm1> createState() => _SignUpForm1State();
}

class _SignUpForm1State extends State<SignUpForm1> {
  bool _tagGenerated = false;

  @override
  void initState() {
    super.initState();
    widget.usernameController.addListener(_onUsernameFieldChanged);
  }

  @override
  void dispose() {
    widget.usernameController.removeListener(_onUsernameFieldChanged);
    super.dispose();
  }

  void _onUsernameFieldChanged() {
    if (!_tagGenerated &&
        widget.usernameController.text.isNotEmpty &&
        !widget.usernameController.text.contains('#')) {
      _generateAndAppendTag();
    }
  }

  void _generateAndAppendTag() {
    final random = Random();
    final tag = String.fromCharCodes(
      List.generate(4, (index) {
        // Generate random alphanumeric characters (0-9, a-z, A-Z)
        const chars =
            '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        return chars.codeUnitAt(random.nextInt(chars.length));
      }),
    );

    final currentUsername = widget.usernameController.text;
    if (!currentUsername.contains('#')) {
      setState(() {
        widget.usernameController.text = '$currentUsername#$tag';
        _tagGenerated = true;
      });
    }
  }

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
          const SizedBox(height: 48),
          MyTextField(
            textEditingController: widget.usernameController,
            label: "Email address/Username",
            hintText: "Email address",
            prefixIcon: CupertinoIcons.person,
          ),
          const SizedBox(height: 48),
          MyTextField(
            textEditingController: widget.passwordController,
            label: "Password",
            prefixIcon: CupertinoIcons.lock,
            obscureText: true,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Text(
                        "Stay signed in",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: UserInfo().staySignedIn,
                        onChanged: (newVal) {
                          setState(() {
                            UserInfo().staySignedIn = newVal;
                          });
                        },
                        activeTrackColor: const Color(0xffd72323),
                        inactiveTrackColor: Colors.grey,
                      ),
                    ],
                  ))),
          const SizedBox(height: 96),
          Center(
            child: TextButton(
              onPressed: () => widget.onNext(),
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
