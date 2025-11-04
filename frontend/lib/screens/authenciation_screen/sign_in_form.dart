import 'package:flutter/material.dart';
import 'package:virtour_frontend/constants/colors.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  String _errorMessage = "";
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.only(left: 52, right: 48, top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Username",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffd9d9d9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  focusNode: _usernameFocusNode,
                  controller: _usernameController,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                  decoration: InputDecoration(
                    hintText: "Username",
                    contentPadding: EdgeInsets.only(left: 10, top: 13),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Password",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
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
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      fontFamily: "BeVietnamPro",
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 49),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kThemeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fixedSize: Size(135, 52),
                  ),
                  onPressed: () {
                    if (_usernameController.text != "deptrAI" ||
                        _passwordController.text != "deptrAI") {
                      setState(
                        () => _errorMessage = "Invalid username or password.",
                      );
                    } else {
                      setState(() => _errorMessage = "");
                    }
                  },
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "BeVietnamPro",
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontFamily: "BeVietnamPro",
                    fontWeight: FontWeight.w300,
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
