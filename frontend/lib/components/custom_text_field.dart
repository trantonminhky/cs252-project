import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;
  final String? hintText;
  final bool digitsOnly;
  final IconData? prefixIcon;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.textEditingController,
    required this.label,
    this.hintText,
    this.digitsOnly = false,
    this.prefixIcon,
    this.obscureText = false,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: "BeVietnamPro",
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffd9d9d9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: widget.textEditingController,
            obscureText: _isObscured,
            keyboardType: widget.digitsOnly ? TextInputType.number : null,
            decoration: InputDecoration(
              hintText: widget.hintText ?? widget.label,
              //contentPadding: EdgeInsets.only(left: 10, top: 13),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: Icon(widget.prefixIcon),
              prefixIconConstraints: widget.prefixIcon == null
                  ? const BoxConstraints(maxHeight: 48, maxWidth: 10)
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _isObscured
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                      ),
                      onPressed: () {
                        setState(() => _isObscured = !_isObscured);
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
