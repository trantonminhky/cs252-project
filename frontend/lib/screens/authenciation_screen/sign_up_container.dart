import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form_1.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form_2.dart';
import 'package:virtour_frontend/screens/authenciation_screen/auth_service.dart';

class SignUpContainer extends StatefulWidget {
  const SignUpContainer({super.key});

  @override
  State<SignUpContainer> createState() => _SignUpContainerState();
}

class _SignUpContainerState extends State<SignUpContainer> {
  int _index = 0;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  bool _isLoading = false;
  AuthService authService = AuthService();

//helper for error
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (usernameController.text.isEmpty) {
      _showSnackBar("Username cannot be empty");
      return;
    } else if (passwordController.text.isEmpty) {
      _showSnackBar("Password cannot be empty");
      return;
    } else if (nameController.text.isEmpty) {
      _showSnackBar("Name cannot be empty");
      return;
    } else if (ageController.text.isEmpty) {
      _showSnackBar("Age cannot be empty");
      return;
    }

    setState(() => _isLoading = true);
    final result = await authService.signUp(
      usernameController.text,
      passwordController.text,
      nameController.text,
      int.parse(ageController.text),
    );
    setState(() => _isLoading = false);
    if (result.isEmpty) {
      _showSnackBar("Cannot receive response.");
    }
    switch (result['success']) {
      case true:
        _showSnackBar("Sign up successful, navigating to home.");
        navigateToHome();
        break;
      case false:
        _showSnackBar("Sign up failed. Reason: ${result['message']}");
        break;
      default:
        _showSnackBar("An unexpected error occurred.");
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void changeIndex(int newIndex) {
    setState(() => _index = newIndex);
  }

  void navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 796,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Stack(alignment: Alignment.center, children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            child: IndexedStack(
              index: _index,
              children: [
                SignUpForm1(
                  onNext: () => {
                    if (usernameController.text.isEmpty)
                      {_showSnackBar("Username cannot be empty")}
                    else if (passwordController.text.isEmpty)
                      {_showSnackBar("Password cannot be empty")}
                    else
                      {changeIndex(1)}
                  },
                  usernameController: usernameController,
                  passwordController: passwordController,
                ),
                SignUpForm2(
                  onNext: () => {
                    if (nameController.text.isEmpty)
                      {_showSnackBar("Name cannot be empty")}
                    else if (ageController.text.isEmpty)
                      {_showSnackBar("Age cannot be empty")}
                    else
                      {_handleSignUp()}
                  },
                  onPrevious: () => changeIndex(0),
                  nameController: nameController,
                  ageController: ageController,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ]));
  }
}
