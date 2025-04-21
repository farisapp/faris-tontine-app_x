import 'package:flutter/material.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class RoundBorderTextField extends StatelessWidget {

  final IconData? icon;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String Function(String?) validator;
  final int minLines;
  final void Function(String?) onChanged;
  final void Function(String?) onSaved;


  RoundBorderTextField(
      {this.icon,
        required this.hintText,
        this.obscureText = false,
        this.keyboardType = TextInputType.text,
        required this.controller,
        required this.validator,
        this.minLines = 1,
        required this.onChanged,
        required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: minLines,
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColor.kTontinet_iconColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColor.kTontinet_textColor1
              ),
              borderRadius: BorderRadius.all(Radius.circular(35.0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColor.kTontinet_textColor1
              ),
              borderRadius: BorderRadius.all(Radius.circular(35.0)),
            ),
            contentPadding: EdgeInsets.all(10),
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14, color: AppColor.kTontinet_textColor1)
        ),
        //initialValue: initialValue,
        validator: validator,
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
  }
}