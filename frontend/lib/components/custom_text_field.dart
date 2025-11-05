import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.textEditingController,
    required this.label,
    required this.prefixIcon,
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
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: "BeVietnamPro",
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Color(0xffd9d9d9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: widget.textEditingController,
            obscureText: _isObscured,
            decoration: InputDecoration(
              hintText: widget.label,
              contentPadding: EdgeInsets.only(left: 10, top: 13),
              border: InputBorder.none,
              prefixIcon: Icon(widget.prefixIcon),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
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
