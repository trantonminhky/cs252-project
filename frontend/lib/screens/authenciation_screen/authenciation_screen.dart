import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_in_form.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form.dart';
import '../../constants/colors.dart';

enum AuthMode { signUp, signIn }

class AuthenciationScreen extends StatefulWidget {
  const AuthenciationScreen({super.key});

  @override
  State<AuthenciationScreen> createState() => _AuthenciationScreenState();
}

class _AuthenciationScreenState extends State<AuthenciationScreen> {
  AuthMode _authMode = AuthMode.signUp;
  bool _didInitialize = false;
  int _formKey = 0;

  void _switchAuthMode(AuthMode newMode) {
    if (_authMode != newMode) {
      setState(() {
        _authMode = newMode;
        _formKey++;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialize) {
      _didInitialize = true;
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is Map<String, String>) {
        final mode = routeArgs['mode'];
        if (mode == 'signIn') {
          _authMode = AuthMode.signIn;
        } else if (mode == 'signUp') {
          _authMode = AuthMode.signUp;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kThemeColor,
      appBar: AppBar(
        backgroundColor: kThemeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/intro");
          },
        ),
        title: Text(
          "Account",
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
            fontFamily: "Bayon",
            fontSize: 64,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 70),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchAuthMode(AuthMode.signUp),
                  child: Container(
                    alignment: Alignment.center,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _authMode == AuthMode.signUp
                          ? Colors.white
                          : kThemeColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: _authMode == AuthMode.signUp
                            ? Colors.black
                            : Colors.white,
                        fontFamily: "BeVietnamPro",
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchAuthMode(AuthMode.signIn),
                  child: Container(
                    alignment: Alignment.center,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _authMode == AuthMode.signIn
                          ? Colors.white
                          : kThemeColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        color: _authMode == AuthMode.signIn
                            ? Colors.black
                            : Colors.white,
                        fontFamily: "BeVietnamPro",
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _authMode == AuthMode.signIn ? 0 : 1,
              children: [
                SizedBox(
                  height: double.infinity,
                  child: SignInForm(key: ValueKey('signIn-$_formKey'))
                ),
                SignUpForm(key: ValueKey('signUp-$_formKey')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
