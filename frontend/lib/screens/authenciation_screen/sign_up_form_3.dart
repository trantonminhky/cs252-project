import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';

class SignUpForm3 extends StatelessWidget {
  final Function onNext;
  final Function onPrevious;
  final TextEditingController interestsController;
  final TextEditingController locationController;

  const SignUpForm3({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.interestsController,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Column(
        children: [
          const Text(
            "Tell us about your interests...",
            style: TextStyle(
              color: Colors.black,
              fontSize: 23,
              fontFamily: "BeVietnamPro",
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          MyTextField(
            textEditingController: interestsController,
            label: "Interests",
            hintText: "Culture, History, Food...",
          ),
          const SizedBox(height: 48),
          MyTextField(
            textEditingController: locationController,
            label: "Location",
            hintText: "City or Region",
          ),
          const SizedBox(height: 96),
          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onPrevious(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Be Vietnam',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onNext(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: ShapeDecoration(
                        color: Color(0xffd72323),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Done',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Be Vietnam',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
