import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  TextEditingController? textEditingController;
  IconData? iconData;
  String? hintString;
  bool? isObscure = true;
  bool? enabled = true;

  CustomTextField({
    super.key,
    this.textEditingController,
    this.iconData,
    this.hintString,
    this.isObscure,
    this.enabled,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(14),
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        enabled: widget.enabled,
        controller: widget.textEditingController,
        obscureText: widget.isObscure!,
        decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              widget.iconData,
              color: Colors.blueAccent,
            ),
            hintText: widget.hintString,
            hintStyle: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
