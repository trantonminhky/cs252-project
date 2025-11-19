import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/authenciation_screen.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              "assets/images/intro_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 606,
            left: 25,
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                  width: 362,
                  child: Image.asset(
                    "assets/images/cultour_logo.png",
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 44),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) {
                          return const AuthenciationScreen(initialIndex: 0);
                        },
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFD72323),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const SizedBox(
                    width: 288,
                    height: 52,
                    child: Center(
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w600,
                          height: 0.9,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    const Text(
                      "Already had an account?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) {
                              return const AuthenciationScreen(initialIndex: 1);
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
