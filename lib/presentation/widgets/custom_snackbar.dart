import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showCustomSnackBar(
    BuildContext context,
    String? message, {
      bool isError = true,
      Duration duration = const Duration(seconds: 3), // Durée par défaut
    }) {
  Flushbar(
    margin: EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    message: message,
    backgroundColor: Colors.blueAccent, // Fond rouge pour le message
    icon: Icon(
      isError ? Icons.cancel_outlined : Icons.check_circle_outline,
      size: 28.0,
      color: Colors.white, // Icône blanche pour contraste
    ),
    duration: duration,
    messageColor: Colors.white, // Texte en blanc pour la lisibilité
  )..show(context);
}
