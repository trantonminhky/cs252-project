import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';
import 'package:virtour_frontend/constants/colors.dart';
import 'package:virtour_frontend/frontend_service_layer/auth_service.dart';
import 'package:virtour_frontend/components/bottom_bar.dart';
import 'package:virtour_frontend/providers/user_info_provider.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  static final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar("Please enter your username.");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar("Please enter your password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userInfo = await _authService.signIn(
          _emailController.text, _passwordController.text);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (userInfo != null) {
        ref.read(userSessionProvider.notifier).setUser(userInfo);

        _showSnackBar("Sign in successful! Navigating to home...");

        if (mounted) {
          await Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const BottomNavBar()),
          );
        }
      }
      else {
        _showSnackBar("Sign in failed. An unexpected error occurred");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("Connection error: ${e.toString()}");
    }
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
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextField(
                textEditingController: _emailController,
                label: "Email",
                prefixIcon: CupertinoIcons.mail,
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
                  child: const Text(
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
                        side: const BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      fixedSize: const Size(167, 58),
                      padding: const EdgeInsets.symmetric(
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
                        const Text(
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
                        side: const BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      fixedSize: const Size(167, 58),
                      padding: const EdgeInsets.symmetric(
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
                        const Text(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    fixedSize: const Size(135, 62),
                  ),
                  onPressed: _isLoading ? null : _handleSignIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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
