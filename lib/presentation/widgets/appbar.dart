import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final Widget titre;
  final Color backgroundColor;

  const AppBarWidget({Key? key, required this.titre, required this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titre,
      backgroundColor: backgroundColor,
      elevation: 0,
    );
  }
}
