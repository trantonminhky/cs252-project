import 'package:flutter/material.dart';
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
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _repeatPasswordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _rObscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repeatPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: const Text(
                "Username",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xffd9d9d9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  focusNode: _usernameFocusNode,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: "Username",
                    contentPadding: EdgeInsets.only(left: 10, top: 13),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: const Text(
                "Password",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xffd9d9d9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  focusNode: _passwordFocusNode,
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Password",
                    contentPadding: EdgeInsets.only(left: 10, top: 13),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: const Text(
                "Repeat Password",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 48),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xffd9d9d9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  focusNode: _repeatPasswordFocusNode,
                  controller: _repeatPasswordController,
                  obscureText: _rObscureText,
                  decoration: InputDecoration(
                    hintText: "Repeat Password",
                    contentPadding: EdgeInsets.only(left: 10, top: 13),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _rObscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _rObscureText = !_rObscureText),
                    ),
                  ),
                ),
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
                  onPressed: () {

                  },
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
