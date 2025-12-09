import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/authenciation_screen.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive sizes
    final logoHeight = screenHeight * 0.085; // ~70px on standard screen
    final logoWidth = screenWidth * 0.88; // ~362px on standard screen
    final buttonWidth = screenWidth * 0.70; // ~288px on standard screen
    final buttonHeight = screenHeight * 0.065; // ~52px on standard screen

    // Position from bottom instead of top for better responsiveness
    final bottomPadding = screenHeight * 0.12; // ~12% from bottom

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
            left: 0,
            right: 0,
            bottom: bottomPadding,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.061), // ~25px
              child: Column(
                children: [
                  SizedBox(
                    height: logoHeight,
                    width: logoWidth,
                    child: Image.asset(
                      "assets/images/cultour_logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.055), // ~44px
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
                      padding: EdgeInsets.zero,
                    ),
                    child: SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: Center(
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight * 0.025, // ~20px
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w600,
                            height: 0.9,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.016), // ~13px
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already had an account?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.020, // ~16px
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
                                return const AuthenciationScreen(
                                    initialIndex: 1);
                              },
                            ),
                          );
                        },
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            color: Colors.white,
                            fontSize: screenHeight * 0.020, // ~16px
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
          ),
        ],
      ),
    );
  }
}
