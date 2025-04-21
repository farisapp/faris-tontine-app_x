import 'package:flutter/material.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class SettingTile extends StatelessWidget {
  final String titre;
  final IconData icon;
  final Color color;
  final bool? isButtonActive;
  final VoidCallback onPressed;

  const SettingTile({
    Key? key,
    required this.titre,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isButtonActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: Colors.white),
        ),
      ),
      title: Text(titre),
      trailing: (isButtonActive != null)
          ? Switch(
        value: isButtonActive!,
        onChanged: (bool active) => onPressed(), // ✅ Correction ici
        activeColor: AppColor.kTontinet_primary,
        activeTrackColor: AppColor.kTontinet_activeColor.withOpacity(0.5),
      )
          : const Icon(Icons.arrow_forward_ios_outlined, size: 16),
    );
  }
}
