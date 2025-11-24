import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/providers/trip_provider.dart";
import "package:virtour_frontend/screens/trip_screen/trip_screen_content.dart";

class TripScreen extends ConsumerWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(tripProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My trips",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              places.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 245),
                      child: DottedBorder(
                        options: const RoundedRectDottedBorderOptions(
                          radius: Radius.circular(16),
                          dashPattern: <double>[3, 3],
                          strokeWidth: 2,
                        ),
                        child: SizedBox(
                          height: 279,
                          width: 372,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 21,
                              horizontal: 43,
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/icons/carbon_warning.png",
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Nothing here...",
                                  style: TextStyle(
                                    color: Color(0xffff6165),
                                    fontSize: 20,
                                    fontFamily: "BeVietnamPro",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xffd72323),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const SizedBox(
                                    width: 277,
                                    height: 33,
                                    child: Center(
                                      child: Text(
                                        "Create a trip",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: "BeVietnamPro",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const SizedBox(
                                    width: 277,
                                    height: 33,
                                    child: Center(
                                      child: Text(
                                        "Create with AI",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: "BeVietnamPro",
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
                      ),
                    )
                  : const Expanded(child: TripScreenContent()),
            ],
          ),
        ),
      ),
    );
  }
}
