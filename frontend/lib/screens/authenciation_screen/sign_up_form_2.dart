import 'package:flutter/material.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';

class SignUpForm2 extends StatelessWidget {
  final Function onNext;
  final Function onPrevious;
  final TextEditingController nameController;
  final TextEditingController ageController;

  const SignUpForm2({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.nameController,
    required this.ageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Column(
        children: [
          const Text(
            "We would like to know more about you...",
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
            textEditingController: nameController,
            label: "Name",
            hintText: "First name - Last name",
          ),
          const SizedBox(height: 48),
          MyTextField(
            textEditingController: ageController,
            label: "Age",
            digitsOnly: true,
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
                        color: const Color(0xffd72323),
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
