import 'package:flutter/material.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';
import 'package:virtour_frontend/constants/userinfo.dart';

class SignUpForm2 extends StatelessWidget {
  final Function onNext;
  final Function onPrevious;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController userTypeController;

  const SignUpForm2({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.nameController,
    required this.ageController,
    required this.userTypeController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "We would like to know more about you...",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
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
          const SizedBox(height: 48),
          const Text(
            "I am signing up as a...",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: "BeVietnamPro",
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            items: const [
              DropdownMenuItem(
                value: 'Tourist',
                child: Text('Tourist'),
              ),
              DropdownMenuItem(
                value: 'Business',
                child: Text('Business'),
              ),
            ],
            initialValue: 'Tourist',
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: "BeVietnamPro",
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
            onChanged: (String? value) {
              userTypeController.text = value ?? "Tourist";
            },
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
                          'Next',
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
