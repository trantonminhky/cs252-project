import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form_1.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form_2.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form_3.dart';
import 'package:virtour_frontend/services/auth_service.dart';
import 'package:virtour_frontend/constants/userinfo.dart';
import 'package:virtour_frontend/screens/main_layout.dart';

class SignUpContainer extends StatefulWidget {
  const SignUpContainer({super.key});

  @override
  State<SignUpContainer> createState() => _SignUpContainerState();
}

class _SignUpContainerState extends State<SignUpContainer> {
  int _index = 0;
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController interestsController;
  late final TextEditingController userTypeController;
  List<String> _selectedPreferences = [];
  bool _isLoading = false;
  static final AuthService _authService = AuthService();
  final UserInfo _userInfo = UserInfo();

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    ageController = TextEditingController();
    interestsController = TextEditingController();
    userTypeController = TextEditingController();
  }

  //helper for error
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
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

    try {
      final result = await _authService.signUp(
        usernameController.text,
        passwordController.text,
        nameController.text,
        int.parse(ageController.text),
        userTypeController.text.toLowerCase() == 'tourist',
        _selectedPreferences,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result.isEmpty) {
        _showSnackBar("Cannot receive response.");
        return;
      }

      switch (result['success']) {
        case true:
          _showSnackBar("Sign up successful, navigating to home.");
          if (mounted) {
            navigateToHome();
          }
          break;
        case false:
          _showSnackBar("Sign up failed. Reason: ${result['message']}");
          break;
        default:
          _showSnackBar("An unexpected error occurred.");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("Connection error: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    ageController.dispose();
    interestsController.dispose();
    userTypeController.dispose();
    super.dispose();
  }

  void changeIndex(int newIndex) {
    setState(() => _index = newIndex);
  }

  void navigateToHome() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) {
          return const MainLayout();
        },
      ),
    );
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          IndexedStack(
            index: _index,
            children: [
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                child: SignUpForm1(
                  onNext: () => {
                    if (usernameController.text.isEmpty)
                      {_showSnackBar("Username cannot be empty")}
                    else if (passwordController.text.isEmpty)
                      {_showSnackBar("Password cannot be empty")}
                    else
                      {changeIndex(1)},
                  },
                  usernameController: usernameController,
                  passwordController: passwordController,
                ),
              ),
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                child: SignUpForm2(
                  onNext: () => {
                    if (nameController.text.isEmpty)
                      {_showSnackBar("Name cannot be empty")}
                    else if (ageController.text.isEmpty)
                      {_showSnackBar("Age cannot be empty")}
                    else
                      {changeIndex(2)},
                  },
                  onPrevious: () => changeIndex(0),
                  nameController: nameController,
                  ageController: ageController,
                  userInfo: _userInfo,
                ),
              ),
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                child: SignUpForm3(
                  onNext: () => _handleSignUp(),
                  onPrevious: () => changeIndex(1),
                  interestsController: interestsController,
                  userTypeController: userTypeController,
                  onPreferencesSelected: (preferences) {
                    setState(() {
                      _selectedPreferences = preferences;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
