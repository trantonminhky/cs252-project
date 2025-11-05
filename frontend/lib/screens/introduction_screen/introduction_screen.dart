import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'carousel_slider.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kThemeColor,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/introduction_scene_background.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 70),
                CarouselSlider(),
                const SizedBox(height: 50),
                const Text(
                  "VIRTOUR",
                  style: TextStyle(
                    fontSize: 98,
                    color: Colors.white,
                    fontFamily: "Bayon",
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.4),
                        offset: Offset(-1, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffffffff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          "/auth",
                          arguments: {"mode": "signUp"},
                        );
                      },
                      child: Text(
                        "Get started",
                        style: TextStyle(
                          color: kThemeColor,
                          fontFamily: "BeVietnamPro",
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already had an account?",
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontWeight: FontWeight.w800,
                        fontFamily: "BeVietnamPro",
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      splashColor: Color.fromRGBO(204, 240, 213, 0.3),
                      borderRadius: BorderRadius.circular(3),
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          "/auth",
                          arguments: {"mode": "signIn"},
                        );
                      },
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontWeight: FontWeight.w800,
                          fontFamily: "BeVietnamPro",
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xffffffff),
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 320, left: 30),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.only(top: 15, left: 10, right: 10),
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Unification Palace",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Go to the main gate",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 110,
                        height: 40,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: kThemeColor,
                          child: Row(
                            children: [
                              const SizedBox(width: 3),
                              Icon(
                                Icons.star_border_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 3),
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  "Complete",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
