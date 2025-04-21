import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final VoidCallback onPress;

  const CircleButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.size,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(4, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: size * 0.35,
              color: iconColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size * 0.1,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
