import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virtour_frontend/providers/user_info_provider.dart';
import 'package:virtour_frontend/screens/profile_screen/region_progress_page.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userSessionProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: "BeVietnamPro",
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                      children: [
                        const TextSpan(
                          text: "Welcome back,\n",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),
                        ),
                        TextSpan(
                          text: user!.username,
                          style: const TextStyle(
                            color: Color(0xffd72323),
                            fontSize: 46,
                          ),
                        ),
                        TextSpan(
                          text: "#${user.discriminant}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 119),
                  Image.asset(
                    "assets/icons/user_avatar.png",
                  ),
                ],
              ),
              const SizedBox(height: 63),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 2,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  style: ListTileStyle.list,
                  tileColor: const Color(0xfff6f6f6),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return const RegionProgressPage();
                        },
                      ),
                    );
                  },
                  leading: Image.asset(
                    "assets/icons/Progress.png",
                    width: 19,
                    height: 19,
                  ),
                  title: const Text(
                    "Progress",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: Transform.flip(
                    flipX: true,
                    child: const Icon(CupertinoIcons.back, size: 25),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 2,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  style: ListTileStyle.list,
                  tileColor: const Color(0xfff6f6f6),
                  onTap: () {},
                  leading: Image.asset(
                    "assets/icons/Setting.png",
                    width: 19,
                    height: 19,
                  ),
                  title: const Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: Transform.flip(
                    flipX: true,
                    child: const Icon(CupertinoIcons.back, size: 25),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {},
                    child: const Text(
                      'Sign out',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
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
