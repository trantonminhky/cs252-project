import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';
import 'package:virtour_frontend/constants/colors.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 796,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextField(
                textEditingController: _usernameController,
                label: "Username",
                prefixIcon: CupertinoIcons.person,
              ),
              const SizedBox(height: 30),
              MyTextField(
                textEditingController: _passwordController,
                label: "Password",
                prefixIcon: CupertinoIcons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      fontFamily: "BeVietnamPro",
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black,
                      decorationThickness: 1.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      fixedSize: Size(167, 58),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset(
                            "assets/images/google_logo.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Google",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      fixedSize: Size(167, 58),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset(
                            "assets/images/apple_logo.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Apple",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 149),

              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kThemeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    fixedSize: Size(135, 52),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "BeVietnamPro",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
