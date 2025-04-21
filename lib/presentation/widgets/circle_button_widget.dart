import 'package:flutter/material.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class CircleButtonWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const CircleButtonWidget(
      {Key? key,
      required this.name,
      required this.icon,
      this.iconColor,
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 23,
        child: Icon(
          icon,
          size: 26,
          color: iconColor ?? Colors.white,
        ),
        backgroundColor: backgroundColor ?? AppColor.kTontinet_primary_light,
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}
