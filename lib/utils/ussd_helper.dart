import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class UssdHelper {
  /// Lance directement le code USSD sur Android, ou affiche un message/copie sur iOS
  static Future<void> launchUssd({
    required BuildContext context,
    required String ussdCode,
    bool showSnackbarOnCopy = true,
  }) async {
    try {
      if (Platform.isAndroid) {
        await FlutterPhoneDirectCaller.callNumber(ussdCode);
      } else if (Platform.isIOS) {
        final encoded = Uri.encodeComponent(ussdCode);
        final uri = Uri.parse("tel:$encoded");

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          await Clipboard.setData(ClipboardData(text: ussdCode));
          if (showSnackbarOnCopy) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Code USSD copié. Veuillez ouvrir le composeur.")),
            );
          }
        }
      }
    } catch (e) {
      if (showSnackbarOnCopy) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l’appel USSD : $e")),
        );
      }
    }
  }

  /// Affiche une boîte de dialogue sur iOS pour confirmer l'appel
  static Future<void> showUssdDialog(BuildContext context, String ussdCode) async {
    if (Platform.isAndroid) {
      await FlutterPhoneDirectCaller.callNumber(ussdCode);
    } else if (Platform.isIOS) {
      await Clipboard.setData(ClipboardData(text: ussdCode));
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Exécuter le code"),
          content: Text("Appuyez sur 'Appeler' pour lancer ce code :\n\n$ussdCode"),
          actions: [
            TextButton(
              onPressed: () async {
                final encoded = Uri.encodeComponent(ussdCode);
                final url = Uri.parse("tel:$encoded");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
                Navigator.pop(context);
              },
              child: const Text("Appeler", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }
  }

  /// Widget cliquable qui lance le code USSD (affichage stylé)
  static Widget buildClickableUssdWidget({
    required BuildContext context,
    required String ussdCode,
    Color backgroundColor = const Color(0xFFFFF3E0),
    Color borderColor = Colors.orange,
    Color textColor = Colors.orange,
  }) {
    return GestureDetector(
      onTap: () => launchUssd(context: context, ussdCode: ussdCode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call, color: textColor),
            const SizedBox(width: 8),
            Text(
              ussdCode,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
