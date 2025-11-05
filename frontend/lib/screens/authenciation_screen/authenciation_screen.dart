import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_in_form.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_form.dart';
import '../../constants/colors.dart';
class AuthenciationScreen extends StatefulWidget {
  const AuthenciationScreen({super.key});

  @override
  State<AuthenciationScreen> createState() => _AuthenciationScreenState();
}

class _AuthenciationScreenState extends State<AuthenciationScreen>
    with SingleTickerProviderStateMixin {
  bool _didInitialize = false;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          _tabController.index = 1;
        } else if (mode == 'signUp') {
          _tabController.index = 0;
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
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 77),
            TabBar(
              controller: _tabController,
              isScrollable: false,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              tabs: [
                SizedBox(
                  height: 54,
                  child: Tab(
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        fontFamily: "BeVietnamPro",
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                      fontFamily: "BeVietnamPro",
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [SignUpForm(), SignInForm()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
