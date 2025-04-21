import 'package:flutter/material.dart';

class RoundTextButton extends StatelessWidget {
  final String titre;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final double fontSize;
  final double elevation;
  final VoidCallback onPressed;


  RoundTextButton({
    required this.titre,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.width = 155,
    this.height = 40,
    this.fontSize = 18,
    this.elevation = 10
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          //side: BorderSide(width: 1, color: Colors.brown),
          foregroundColor: textColor, minimumSize: Size(width, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: backgroundColor,
          elevation: elevation,
          //padding: EdgeInsets.symmetric(horizontal: 40)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null ? Icon(icon, color: textColor,) : Container(),
            SizedBox(width: icon != null ? 5 : 0,),
            Text(titre, style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: FontWeight.bold))
          ],
        )
    );
  }
}