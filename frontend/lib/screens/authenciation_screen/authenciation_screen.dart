import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_in_form.dart';
import 'package:virtour_frontend/screens/authenciation_screen/sign_up_container.dart';

class AuthenciationScreen extends StatefulWidget {
  final int initialIndex;
  const AuthenciationScreen({super.key, required this.initialIndex});

  @override
  State<AuthenciationScreen> createState() => _AuthenciationScreenState();
}

class _AuthenciationScreenState extends State<AuthenciationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = widget.initialIndex;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -26,
            top: -11,
            child: SizedBox(
              width: 596,
              height: 335,
              child: Image.asset(
                "assets/images/auth_background.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),

          Positioned(
            top: 180,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 796,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [SignUpContainer(), SignInForm()],
              ),
            ),
          ),

          Positioned(
            top: 165,
            child: Container(
              width: 310,
              height: 41,
              padding: EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(500),
                  border: BoxBorder.all(
                    color: Colors.black,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: SizedBox(
                      height: 33,
                      width: 151,
                      child: Center(
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            color: const Color(0xFF1E1E1E),
                            fontSize: 14,
                            fontFamily: 'BeVietnamPro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: SizedBox(
                      height: 33,
                      width: 151,
                      child: Center(
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                            color: const Color(0xFF1E1E1E),
                            fontSize: 14,
                            fontFamily: 'BeVietnamPro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 45,
            left: 10,
            child: IconButton(
              color: Colors.white,
              icon: Icon(CupertinoIcons.back, size: 40),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
